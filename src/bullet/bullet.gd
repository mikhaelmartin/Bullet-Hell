extends Area2D
class_name Bullet

var data:BulletData

@onready var animated_sprite_2d = $AnimatedSprite2D

func _process(_delta):
	if BulletManager.use_interpolation and Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		var weight = Engine.get_physics_interpolation_fraction()
		
		data.current_position = lerp(
			data.previous_position,
			data.next_position,
			weight
		)
		
		data.current_rotation = lerp_angle(
			data.previous_rotation,
			data.next_rotation,
			weight
		)
		
		data.current_spin = lerp_angle(
			data.previous_spin,
			data.next_spin,
			weight
		)
	
	global_position = data.current_position
	global_rotation = data.current_rotation
	animated_sprite_2d.global_rotation = data.current_rotation + data.current_spin

func _physics_process(delta):
	data.life_time -= delta
	if data.life_time <= 0:
		queue_free()
		return
	
	# linear
	if data.linear_acceleration!= 0 and data.linear_current_speed != data.linear_final_speed:
		data.linear_current_speed = move_toward(data.linear_current_speed, data.linear_final_speed, data.linear_acceleration * delta)
	
		if data.linear_pingpong and is_equal_approx(data.linear_current_speed, data.linear_final_speed):
			data.linear_final_speed = data.linear_initial_speed
			data.linear_initial_speed = data.linear_current_speed
	
	data.velocity = Vector2.from_angle(data.current_rotation) * data.linear_current_speed
	if data.velocity != Vector2.ZERO:
		data.next_position = data.current_position + data.velocity * delta
	
	# angular
	if data.angular_acceleration !=0 and data.angular_current_speed != data.angular_final_speed:
		data.angular_current_speed = move_toward(data.angular_current_speed, data.angular_final_speed, data.angular_acceleration * delta)
	
		if data.angular_pingpong and is_equal_approx(data.angular_current_speed, data.angular_final_speed):
			data.angular_final_speed = data.angular_initial_speed
			data.angular_initial_speed = data.angular_current_speed
	
	if data.aim_target and data.target:
		if data.lock_target:
			data.target_position = data.target.global_position
			
		var desired_direction = data.current_position.direction_to(data.target_position)
		var delta_angle = data.velocity.angle_to(desired_direction)
		
		if abs(delta_angle) != 0:
			var desired_rotation = data.current_rotation + delta_angle
			data.next_rotation = move_toward(data.current_rotation, desired_rotation, abs(data.angular_current_speed) * delta)
		
		if not data.lock_target and is_equal_approx(delta_angle, 0.0):
			data.aim_target = false
			data.angular_current_speed = 0
			data.angular_acceleration = 0
	elif data.angular_current_speed != 0:
		data.next_rotation = data.current_rotation + data.angular_current_speed * delta
	
	# spin
	if data.spin_acceleration != 0 and data.spin_current_speed != data.spin_final_speed:
		data.spin_current_speed = move_toward(data.spin_current_speed, data.spin_final_speed, data.spin_acceleration * delta)
		
		if data.spin_pingpong and is_equal_approx(data.spin_current_speed, data.spin_final_speed):
			data.spin_final_speed = data.spin_initial_speed
			data.spin_initial_speed = data.spin_current_speed
	
	if data.spin_current_speed != 0:
		data.next_spin = data.current_spin + data.spin_current_speed * delta
		
	if BulletManager.use_interpolation and Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		data.previous_position = data.current_position
		data.previous_rotation = data.current_rotation
		data.previous_spin = data.current_spin
	else:
		data.current_position = data.next_position
		data.current_rotation = data.next_rotation
		data.current_spin = data.next_spin


func set_up(p_position:Vector2, p_rotation:float, p_data:BulletData, p_target:Node2D = null):
	global_position = p_position
	global_rotation = p_rotation

	data = p_data.duplicate()
	data.set_up(p_position, p_rotation, p_target)


func _on_area_entered(_area):
	queue_free()
