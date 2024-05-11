class_name BadMultiBullet
extends MultiMeshInstance2D

@export var bullet_shape:Shape2D
@export var collide_with_areas:bool = true
@export var collide_with_bodies:bool = true
@export_flags_2d_physics var collision_mask:int

var data:Array[BulletData]
var space_state:PhysicsDirectSpaceState2D

func _ready():
	update_space_state()

func _process(delta):
	if not BulletManager.use_interpolation:
		return
	
	if Engine.get_frames_per_second() < Engine.physics_ticks_per_second:
		return
	
	var weight = Engine.get_physics_interpolation_fraction()
	
	for i in multimesh.visible_instance_count:
		data[i].current_position = lerp(
			data[i].previous_position,
			data[i].next_position,
			weight
		)
	
		data[i].current_rotation = lerp_angle(
			data[i].previous_rotation,
			data[i].next_rotation,
			weight
		)
	
		data[i].current_spin = lerp_angle(
			data[i].previous_spin,
			data[i].next_spin,
			weight
		)
	
		multimesh.set_instance_transform_2d(
			i,
			Transform2D(
				data[i].current_rotation + data[i].current_spin,
				data[i].current_position)
		)


func _physics_process(delta):
	# collision detection
	update_space_state.call_deferred()

	# use global coordinates, not local to node
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = bullet_shape
	query.collision_mask = collision_mask
	query.collide_with_areas = collide_with_areas
	query.collide_with_bodies = collide_with_bodies
	
	for i in multimesh.visible_instance_count:
		query.transform = Transform2D(0, data[i].current_position)
#
		var result = space_state.intersect_shape(query)
		
		if result:
			data[i].life_time = 0

	# remove yang udah habis lifetime
	for i in range(multimesh.visible_instance_count-1,-1,-1):
		if data[i].life_time > 0:
			data[i].life_time -= delta
		else:
			remove_bullet(i)
	
	# update bullet
	for i in multimesh.visible_instance_count:
		# update linear
		if data[i].linear_acceleration != 0 and data[i].linear_current_speed != data[i].linear_final_speed: 
			data[i].linear_current_speed = move_toward(data[i].linear_current_speed, data[i].linear_final_speed, data[i].linear_acceleration * delta)
			
			if data[i].linear_pingpong and is_equal_approx(data[i].linear_current_speed, data[i].linear_final_speed):
				data[i].linear_final_speed = data[i].linear_initial_speed
				data[i].linear_initial_speed = data[i].linear_current_speed
		
		var direction = Vector2.from_angle(data[i].current_rotation)
		data[i].velocity = direction * data[i].linear_current_speed

		if data[i].velocity != Vector2.ZERO:
			data[i].next_position = data[i].current_position + data[i].velocity * delta
	
		# update angular
		if data[i].angular_acceleration != 0 and data[i].angular_current_speed != data[i].angular_final_speed: 
			data[i].angular_current_speed = move_toward(data[i].angular_current_speed, data[i].angular_final_speed, data[i].angular_acceleration * delta)
	
		if data[i].aim_target and data[i].target:
			if data[i].lock_target:
				data[i].target_position = data[i].target.global_position
			
			var desired_direction = data[i].current_position.direction_to(data[i].target_position)
			var delta_angle = data[i].velocity.angle_to(desired_direction)
			
			if abs(delta_angle) > 0:
				var desired_rotation = data[i].current_rotation + delta_angle
				data[i].next_rotation = move_toward(data[i].current_rotation, desired_rotation, abs(data[i].angular_current_speed) * delta)
			
			if not data[i].lock_target and is_zero_approx(delta_angle):
				data[i].aim_target = false
				data[i].angular_current_speed = 0
				data[i].angular_acceleration = 0
				
		elif data[i].angular_current_speed != 0:
			data[i].next_rotation = data[i].current_rotation + data[i].angular_current_speed * delta
			
			if data[i].angular_pingpong and is_equal_approx(data[i].angular_current_speed, data[i].angular_final_speed):
				data[i].angular_final_speed = data[i].angular_initial_speed
				data[i].angular_initial_speed = data[i].angular_current_speed
	
		# update spin
		if data[i].spin_acceleration != 0 and data[i].spin_current_speed != data[i].spin_final_speed: 
			data[i].spin_current_speed = move_toward(data[i].spin_current_speed, data[i].spin_final_speed, data[i].spin_acceleration * delta)
			
			if data[i].spin_pingpong and is_equal_approx(data[i].spin_current_speed, data[i].spin_final_speed):
				data[i].spin_final_speed = data[i].spin_initial_speed
				data[i].spin_initial_speed = data[i].spin_current_speed
		
		if data[i].spin_current_speed != 0:
			data[i].next_spin = data[i].current_spin + data[i].spin_current_speed * delta

	
	for i in multimesh.visible_instance_count:
		if BulletManager.use_interpolation:
			data[i].previous_position = data[i].current_position
			data[i].previous_rotation = data[i].current_rotation
			data[i].previous_spin = data[i].current_spin
		else:
			# update transform
			multimesh.set_instance_transform_2d(
				i,
				Transform2D(
					data[i].next_rotation + data[i].next_spin,
					data[i].next_position)
			)
			data[i].current_position = data[i].next_position
			data[i].current_rotation = data[i].next_rotation
			data[i].current_spin = data[i].next_spin



func update_space_state():
	space_state = get_world_2d().get_direct_space_state()


func add_bullet(p_position:Vector2,p_rotation:float,p_data:BulletData,p_target:Node2D=null):
	if multimesh.visible_instance_count < 0:
		multimesh.visible_instance_count = 0
		
	if multimesh.instance_count < multimesh.visible_instance_count + 1:
		multimesh.instance_count = multimesh.visible_instance_count + 1
	
	var new_data:BulletData = p_data.duplicate()
	new_data.set_up(p_position,p_rotation,p_target)
	
	multimesh.visible_instance_count += 1
	if data.size() < multimesh.visible_instance_count:
		data.append(new_data)
	else:
		var idx = multimesh.visible_instance_count - 1
		data[idx] = new_data


func remove_bullet(idx:int):
	if multimesh.visible_instance_count == 0:
		return
		
	multimesh.visible_instance_count -= 1
	data.remove_at(idx)
