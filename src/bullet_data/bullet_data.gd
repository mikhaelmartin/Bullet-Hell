class_name BulletData extends Resource

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

var target:Node2D

var linear_current_speed:float = linear_initial_speed
var angular_current_speed:float  = angular_initial_speed
var spin_current_speed:float = spin_initial_speed

var target_position:Vector2
var velocity:Vector2

var current_position:Vector2
var previous_position:Vector2
var next_position:Vector2

var current_rotation:float
var previous_rotation:float
var next_rotation:float

var current_spin:float
var previous_spin:float
var next_spin:float

func set_up(p_position:Vector2, p_rotation:float, p_target:Node2D):
	target = p_target
	
	if p_target:
		target_position = p_target.global_position
	
	linear_current_speed = linear_initial_speed
	angular_current_speed  = angular_initial_speed
	spin_current_speed = spin_initial_speed
	
	velocity = Vector2.from_angle(p_rotation) * linear_initial_speed
	
	current_position = p_position
	previous_position = p_position
	next_position = p_position
	
	current_rotation = p_rotation
	previous_rotation = p_rotation
	next_rotation = p_rotation

	current_spin = 0
	previous_spin = 0
	next_spin = 0
