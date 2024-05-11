class_name BulletPattern extends Resource

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
