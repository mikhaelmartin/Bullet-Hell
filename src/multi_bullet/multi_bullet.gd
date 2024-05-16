class_name MultiBullet
extends MultiMeshInstance2D

@export var bullet_shape:Shape2D
@export var num_threads:int 
@export var collide_with_areas:bool = true
@export var collide_with_bodies:bool = true
@export_flags_2d_physics var collision_mask:int

var space_state:PhysicsDirectSpaceState2D

var life_time:PackedFloat32Array = []

var aim_target:PackedInt32Array = []
var lock_target:PackedInt32Array = []

var linear_initial_speed:PackedFloat32Array = []
var linear_final_speed:PackedFloat32Array = []
var linear_acceleration:PackedFloat32Array = []
var linear_pingpong:PackedInt32Array = []

var angular_initial_speed:PackedFloat32Array = []
var angular_final_speed:PackedFloat32Array = []
var angular_acceleration:PackedFloat32Array = []
var angular_pingpong:PackedInt32Array = []

var spin_initial_speed:PackedFloat32Array = []
var spin_final_speed:PackedFloat32Array = []
var spin_acceleration:PackedFloat32Array = []
var spin_pingpong:PackedInt32Array = []

var target:Array[Node2D]

var linear_current_speed:PackedFloat32Array = []
var angular_current_speed:PackedFloat32Array = []
var spin_current_speed:PackedFloat32Array = []

var target_position:PackedVector2Array = []
var velocity:PackedVector2Array = []

var current_position:PackedVector2Array = []
var previous_position:PackedVector2Array = []
var next_position:PackedVector2Array = []

var current_rotation:PackedFloat32Array = []
var previous_rotation:PackedFloat32Array = []
var next_rotation:PackedFloat32Array = []

var current_spin:PackedFloat32Array = []
var previous_spin:PackedFloat32Array = []
var next_spin:PackedFloat32Array = []


func _ready():
	multimesh.visible_instance_count = 0
	update_space_state()

func _process(_delta):
	# update transform
	if BulletManager.use_interpolation and Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		var weight = Engine.get_physics_interpolation_fraction()
		
		for i in multimesh.visible_instance_count:
			current_position[i] = lerp(
				previous_position[i],
				next_position[i],
				weight
			)
		
			current_rotation[i] = lerp_angle(
				previous_rotation[i],
				next_rotation[i],
				weight
			)
		
			current_spin[i] = lerp_angle(
				previous_spin[i],
				next_spin[i],
				weight
			)
			
			multimesh.set_instance_transform_2d(
			i,
			Transform2D(
				current_rotation[i] + current_spin[i],
				current_position[i])
			)
	else:
		# if fps is too small use physics process
		for i in multimesh.visible_instance_count:
			multimesh.set_instance_transform_2d(
				i,
				Transform2D(
					current_rotation[i] + current_spin[i],
					current_position[i])
			)


func _physics_process(delta):
	# collisions
	# call will be deferred if this on a thread
	if process_thread_group == PROCESS_THREAD_GROUP_SUB_THREAD:
		update_space_state.call_deferred()
	else:
		update_space_state()
	
	# collision detection
	# use global coordinates, not local to node
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = bullet_shape
	query.collision_mask = collision_mask
	query.collide_with_areas = collide_with_areas
	query.collide_with_bodies = collide_with_bodies
	
	for i in multimesh.visible_instance_count:
		query.transform = Transform2D(0, current_position[i])

		var result = space_state.intersect_shape(query)
		
		if result:
			life_time[i] = 0
			continue
	
		# update bullet
		# update linear
		if linear_acceleration[i] != 0 and linear_current_speed[i] != linear_final_speed[i]: 
			linear_current_speed[i] = move_toward(linear_current_speed[i], linear_final_speed[i], linear_acceleration[i] * delta)
			
			if linear_pingpong[i] and is_equal_approx(linear_current_speed[i], linear_final_speed[i]):
				linear_final_speed[i] = linear_initial_speed[i]
				linear_initial_speed[i] = linear_current_speed[i]
		
		velocity[i] = Vector2.from_angle(current_rotation[i]) * linear_current_speed[i]
		
		if velocity[i] != Vector2.ZERO:
			next_position[i] = current_position[i] + velocity[i] * delta
			
		# update angular
		if angular_acceleration[i] != 0 and angular_current_speed[i] != angular_final_speed[i]: 
			angular_current_speed[i] = move_toward(angular_current_speed[i], angular_final_speed[i], angular_acceleration[i] * delta)
	
			if angular_pingpong[i] and is_equal_approx(angular_current_speed[i], angular_final_speed[i]):
				angular_final_speed[i] = angular_initial_speed[i]
				angular_initial_speed[i] = angular_current_speed[i]
				
		if aim_target[i] and target[i]:
			if lock_target[i]:
				target_position[i] = target[i].global_position
			
			var desired_direction = current_position[i].direction_to(target_position[i])
			var delta_angle = velocity[i].angle_to(desired_direction)
			
			if abs(delta_angle) != 0:
				var desired_rotation = current_rotation[i] + delta_angle
				next_rotation[i] = move_toward(current_rotation[i], desired_rotation, abs(angular_current_speed[i]) * delta)
			
			if not lock_target[i] and is_zero_approx(delta_angle):
				aim_target[i] = false
				angular_current_speed[i] = 0
				angular_acceleration[i] = 0
				
		elif angular_current_speed[i] != 0:
			next_rotation[i] = current_rotation[i] + angular_current_speed[i] * delta
			
		
		# update spin
		if spin_acceleration[i] != 0 and spin_current_speed[i] != spin_final_speed[i]: 
			spin_current_speed[i] = move_toward(spin_current_speed[i], spin_final_speed[i], spin_acceleration[i] * delta)
			
			if spin_pingpong[i] and is_equal_approx(spin_current_speed[i], spin_final_speed[i]):
				spin_final_speed[i] = spin_initial_speed[i]
				spin_initial_speed[i] = spin_current_speed[i]
		
		if spin_current_speed[i] != 0:
			next_spin[i] = current_spin[i] + spin_current_speed[i] * delta
	
		if BulletManager.use_interpolation and Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
			previous_position[i] = current_position[i]
			previous_rotation[i] = current_rotation[i]
			previous_spin[i] = current_spin[i]
		else:
			current_position[i] = next_position[i]
			current_rotation[i] = next_rotation[i]
			current_spin[i] = next_spin[i]
			
	# remove yang udah habis lifetime
	for i in multimesh.visible_instance_count:
		life_time[i] -= delta
		if life_time[i] <= 0:
			remove_bullet(i)


func update_space_state():
	space_state = get_world_2d().get_direct_space_state()


func add_bullet(p_position:Vector2,p_rotation:float,p_data:BulletData,p_target:Node2D=null):
	if multimesh.visible_instance_count < 0:
		multimesh.visible_instance_count = 0
		
	if multimesh.instance_count <= multimesh.visible_instance_count:
		grow_buffer(100)
	
	set_at(multimesh.visible_instance_count, p_position, p_rotation, p_data, p_target)
	multimesh.visible_instance_count += 1


func remove_bullet(idx:int):
	if multimesh.visible_instance_count == 0:
		return
		
	multimesh.visible_instance_count -= 1
	swap_index_a_with_b(idx, multimesh.visible_instance_count)


func grow_buffer(amount:int):
	multimesh.instance_count += amount
	
	life_time.resize(multimesh.instance_count)
	
	aim_target.resize(multimesh.instance_count)
	lock_target.resize(multimesh.instance_count)
	
	linear_initial_speed.resize(multimesh.instance_count)
	linear_final_speed.resize(multimesh.instance_count)
	linear_acceleration.resize(multimesh.instance_count)
	linear_pingpong.resize(multimesh.instance_count)
	
	angular_initial_speed.resize(multimesh.instance_count)
	angular_final_speed.resize(multimesh.instance_count)
	angular_acceleration.resize(multimesh.instance_count)
	angular_pingpong.resize(multimesh.instance_count)
	
	spin_initial_speed.resize(multimesh.instance_count)
	spin_final_speed.resize(multimesh.instance_count)
	spin_acceleration.resize(multimesh.instance_count)
	spin_pingpong.resize(multimesh.instance_count)
	
	target.resize(multimesh.instance_count)
	
	linear_current_speed.resize(multimesh.instance_count)
	angular_current_speed.resize(multimesh.instance_count)
	spin_current_speed.resize(multimesh.instance_count)
	
	target_position.resize(multimesh.instance_count)
	
	velocity.resize(multimesh.instance_count)
	
	current_position.resize(multimesh.instance_count)
	previous_position.resize(multimesh.instance_count)
	next_position.resize(multimesh.instance_count)
	
	current_rotation.resize(multimesh.instance_count)
	previous_rotation.resize(multimesh.instance_count)
	next_rotation.resize(multimesh.instance_count)

	current_spin.resize(multimesh.instance_count)
	previous_spin.resize(multimesh.instance_count)
	next_spin.resize(multimesh.instance_count)


func append(p_position:Vector2, p_rotation:float, p_data, p_target:Node2D):
	life_time.append(p_data.life_time)
	
	aim_target.append(p_data.aim_target)
	lock_target.append(p_data.lock_target)
	
	linear_initial_speed.append(p_data.linear_initial_speed)
	linear_final_speed.append(p_data.linear_final_speed)
	linear_acceleration.append(p_data.linear_acceleration)
	linear_pingpong.append(p_data.linear_pingpong)
	
	angular_initial_speed.append(p_data.angular_initial_speed)
	angular_final_speed.append(p_data.angular_final_speed)
	angular_acceleration.append(p_data.angular_acceleration)
	angular_pingpong.append(p_data.angular_pingpong)
	
	spin_initial_speed.append(p_data.spin_initial_speed)
	spin_final_speed.append(p_data.spin_final_speed)
	spin_acceleration.append(p_data.spin_acceleration)
	spin_pingpong.append(p_data.spin_pingpong)
	
	target.append(p_target)
	
	linear_current_speed.append(p_data.linear_initial_speed)
	angular_current_speed.append(p_data.angular_initial_speed)
	spin_current_speed.append(p_data.spin_initial_speed)
	
	target_position.append(p_target.global_position if p_target else Vector2.ZERO)
	
	velocity.append(Vector2.from_angle(p_rotation) * linear_initial_speed[-1])
	
	current_position.append(p_position)
	previous_position.append(p_position)
	next_position.append(p_position)
	
	current_rotation.append(p_rotation)
	previous_rotation.append(p_rotation)
	next_rotation.append(p_rotation)

	current_spin.append(0)
	previous_spin.append(0)
	next_spin.append(0)


func set_at(idx, p_position:Vector2, p_rotation:float, p_data, p_target:Node2D):
	life_time[idx] = p_data.life_time
	
	aim_target[idx] = int(p_data.aim_target)
	lock_target[idx] = int(p_data.lock_target)
	
	linear_initial_speed[idx] = p_data.linear_initial_speed
	linear_final_speed[idx] = p_data.linear_final_speed
	linear_acceleration[idx] = p_data.linear_acceleration
	linear_pingpong[idx] = int(p_data.linear_pingpong)
	
	angular_initial_speed[idx] = p_data.angular_initial_speed
	angular_final_speed[idx] = p_data.angular_final_speed
	angular_acceleration[idx] = p_data.angular_acceleration
	angular_pingpong[idx] = int(p_data.angular_pingpong)
	
	spin_initial_speed[idx] = p_data.spin_initial_speed
	spin_final_speed[idx] = p_data.spin_final_speed
	spin_acceleration[idx] = p_data.spin_acceleration
	spin_pingpong[idx] = int(p_data.spin_pingpong)
	
	target[idx] = p_target
	
	linear_current_speed[idx] = p_data.linear_initial_speed
	angular_current_speed[idx] = p_data.angular_initial_speed
	spin_current_speed[idx] = p_data.spin_initial_speed
	
	target_position[idx] = p_target.global_position if p_target else Vector2.ZERO
	
	velocity[idx] = Vector2.from_angle(p_rotation) * linear_initial_speed[-1]
	
	current_position[idx] = p_position
	previous_position[idx] = p_position
	next_position[idx] = p_position
	
	current_rotation[idx] = p_rotation
	previous_rotation[idx] = p_rotation
	next_rotation[idx] = p_rotation

	current_spin[idx] = 0
	previous_spin[idx] = 0
	next_spin[idx] = 0


func remove_at(idx):
	life_time.remove_at(idx)
	
	aim_target.remove_at(idx)
	lock_target.remove_at(idx)
	
	linear_initial_speed.remove_at(idx)
	linear_final_speed.remove_at(idx)
	linear_acceleration.remove_at(idx)
	linear_pingpong.remove_at(idx)
	
	angular_initial_speed.remove_at(idx)
	angular_final_speed.remove_at(idx)
	angular_acceleration.remove_at(idx)
	angular_pingpong.remove_at(idx)
	
	spin_initial_speed.remove_at(idx)
	spin_final_speed.remove_at(idx)
	spin_acceleration.remove_at(idx)
	spin_pingpong.remove_at(idx)
	
	target.remove_at(idx)
	
	linear_current_speed.remove_at(idx)
	angular_current_speed.remove_at(idx)
	spin_current_speed.remove_at(idx)
	
	target_position.remove_at(idx)
	
	velocity.remove_at(idx)
	
	current_position.remove_at(idx)
	previous_position.remove_at(idx)
	next_position.remove_at(idx)
	
	current_rotation.remove_at(idx)
	previous_rotation.remove_at(idx)
	next_rotation.remove_at(idx)

	current_spin.remove_at(idx)
	previous_spin.remove_at(idx)
	next_spin.remove_at(idx)


func swap_index_a_with_b(a,b):
	life_time[a] = life_time[b]
	
	aim_target[a] = aim_target[b]
	lock_target[a] = lock_target[b]
	
	linear_initial_speed[a] = linear_initial_speed[b]
	linear_final_speed[a] = linear_final_speed[b]
	linear_acceleration[a] = linear_acceleration[b]
	linear_pingpong[a] = linear_pingpong[b]
	
	angular_initial_speed[a] = angular_initial_speed[b]
	angular_final_speed[a] = angular_final_speed[b]
	angular_acceleration[a] = angular_acceleration[b]
	angular_pingpong[a] = angular_pingpong[b]
	
	spin_initial_speed[a] = spin_initial_speed[b]
	spin_final_speed[a] = spin_final_speed[b]
	spin_acceleration[a] = spin_acceleration[b]
	spin_pingpong[a] = spin_pingpong[b]
	
	target[a] = target[b]
	
	linear_current_speed[a] = linear_current_speed[b]
	angular_current_speed[a] = angular_current_speed[b]
	spin_current_speed[a] = spin_current_speed[b]
	
	target_position[a] = target_position[b]
	
	velocity[a] = velocity[b]
	
	current_position[a] = current_position[b]
	previous_position[a] = previous_position[b]
	next_position[a] = next_position[b]
	
	current_rotation[a] = current_rotation[b]
	previous_rotation[a] = previous_rotation[b]
	next_rotation[a] = next_rotation[b]

	current_spin[a] = current_spin[b]
	previous_spin[a] = previous_spin[b]
	next_spin[a] = next_spin[b]
