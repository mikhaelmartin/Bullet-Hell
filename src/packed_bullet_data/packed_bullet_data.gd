class_name PackedBulletData extends RefCounted

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
	
	aim_target[idx] = p_data.aim_target
	lock_target[idx] = p_data.lock_target
	
	linear_initial_speed[idx] = p_data.linear_initial_speed
	linear_final_speed[idx] = p_data.linear_final_speed
	linear_acceleration[idx] = p_data.linear_acceleration
	linear_pingpong[idx] = p_data.linear_pingpong
	
	angular_initial_speed[idx] = p_data.angular_initial_speed
	angular_final_speed[idx] = p_data.angular_final_speed
	angular_acceleration[idx] = p_data.angular_acceleration
	angular_pingpong[idx] = p_data.angular_pingpong
	
	spin_initial_speed[idx] = p_data.spin_initial_speed
	spin_final_speed[idx] = p_data.spin_final_speed
	spin_acceleration[idx] = p_data.spin_acceleration
	spin_pingpong[idx] = p_data.spin_pingpong
	
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


func size() -> int:
	return life_time.size()
