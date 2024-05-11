extends Marker2D
class_name Shooter

@export var bullet_scene:PackedScene
@export var bullet_pattern:BulletPattern
@export var bullet_data:BulletData

@export_group("Override Bullet Pattern")
@export var override_bullet_pattern_enabled:bool

@export_subgroup("Rotation")
@export var rotation_initial_speed:float
@export var rotation_final_speed:float
@export var rotation_acceleration:float
@export var rotation_speed_pingpong:bool

@export_subgroup("Spread")
@export var spread_count:int = 1
@export_range(0,360,0.01,"radians_as_degrees") var spread_angle:float = 0

@export_subgroup("Sub Spread")
@export var sub_spread_count:int = 1
@export_range(0,360,0.01,"radians_as_degrees") var sub_spread_angle:float = 0

@export_group("Override Bullet Data")
@export var override_bullet_data_enabled:bool

@export var life_time:float

@export_subgroup("Target")
@export var aim_target:bool
@export var lock_target:bool

@export_subgroup("Linear")
@export var linear_initial_speed:float
@export var linear_final_speed:float
@export var linear_acceleration:float
@export var linear_pingpong:bool

@export_subgroup("Angular")
@export var angular_initial_speed:float
@export var angular_final_speed:float
@export var angular_acceleration:float
@export var angular_pingpong:bool

@export_subgroup("Spin")
@export var spin_initial_speed:float
@export var spin_final_speed:float
@export var spin_acceleration:float
@export var spin_pingpong:bool

var rotation_speed:float

func _ready():
	if not override_bullet_pattern_enabled:
		rotation_initial_speed = bullet_pattern.rotation_initial_speed 
		rotation_final_speed = bullet_pattern.rotation_final_speed 
		rotation_acceleration = bullet_pattern.rotation_acceleration 
		rotation_speed_pingpong = bullet_pattern.rotation_speed_pingpong 
		spread_count = bullet_pattern.spread_count 
		spread_angle = bullet_pattern.spread_angle 
		sub_spread_count = bullet_pattern.sub_spread_count 
		sub_spread_angle = bullet_pattern.sub_spread_angle 
	
	rotation_speed = rotation_initial_speed

func _physics_process(delta):
	if rotation_acceleration != 0:
		rotation_speed = move_toward(
			rotation_speed,
			rotation_final_speed,
			rotation_acceleration * delta,
		)
		
	if rotation_speed_pingpong and is_equal_approx(rotation_speed, rotation_final_speed):
		rotation_final_speed = rotation_initial_speed
		rotation_initial_speed = rotation_speed
	
	if rotation_speed != 0:
		self.global_rotation += rotation_speed * delta 


func shoot(target=null):
	var active_bullet_data:BulletData
	
	if override_bullet_data_enabled:
		active_bullet_data = BulletData.new()
		active_bullet_data.aim_target = aim_target
		active_bullet_data.lock_target = lock_target
		active_bullet_data.life_time = life_time
		active_bullet_data.linear_initial_speed = linear_initial_speed
		active_bullet_data.linear_final_speed = linear_final_speed
		active_bullet_data.linear_acceleration = linear_acceleration
		active_bullet_data.linear_pingpong = linear_pingpong
		active_bullet_data.angular_initial_speed = angular_initial_speed
		active_bullet_data.angular_final_speed = angular_final_speed
		active_bullet_data.angular_acceleration = angular_acceleration
		active_bullet_data.angular_pingpong = angular_pingpong
		active_bullet_data.spin_initial_speed = spin_initial_speed
		active_bullet_data.spin_final_speed = spin_final_speed
		active_bullet_data.spin_acceleration = spin_acceleration
		active_bullet_data.spin_pingpong = spin_pingpong
	else:
		active_bullet_data = bullet_data
	
	var min_angle:float = -spread_angle/2 if spread_count > 1 else 0
	var delta_angle:float = spread_angle/(spread_count-1) if spread_count > 1 else 0
	var angle_array = []
	
	for i in spread_count:
		angle_array.append(min_angle + i*delta_angle)
		
	var sub_min_angle:float = -sub_spread_angle/2 if sub_spread_count > 1 else 0
	var sub_delta_angle:float = sub_spread_angle/(sub_spread_count-1) if sub_spread_count > 1 else 0
	var sub_angle_array = []
	
	for i in sub_spread_count:
		sub_angle_array.append(sub_min_angle + i*sub_delta_angle)
	
	for angle in angle_array:
		for sub_angle in sub_angle_array:
			var bullet = BulletManager.spawn(
				self.global_position,
				self.global_rotation + angle + sub_angle,
				bullet_scene,
				active_bullet_data,
				target,
			)
