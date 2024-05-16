extends Area2D
class_name Player

@export var target:Node2D
@export var auto_shoot:bool
@export var speed = 200.0
@export var acceleration = 1000.0
@export var deceleration = 500.0
@export var use_interpolation = true

var velocity = Vector2.ZERO
var previous_position = Vector2.ZERO
var next_position = Vector2.ZERO

@onready var shoot_cooldown_timer = $ShootCooldownTimer
@onready var shooter = $Shooter
@onready var animated_sprite_2d = $AnimatedSprite2D


func _ready():
	previous_position = self.global_position
	next_position = self.global_position


func _process(_delta):
	if not use_interpolation:
		return
	
	if Engine.get_frames_per_second() <= Engine.physics_ticks_per_second:
		return
	
	self.global_position = lerp(
		previous_position,
		next_position,
		Engine.get_physics_interpolation_fraction(),
	)
	
	
func _physics_process(delta):
	var horizontal = Input.get_axis("ui_left", "ui_right")
	var vertical = Input.get_axis("ui_up", "ui_down")
	var direction = Vector2(horizontal,vertical).normalized()
	
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	next_position = self.global_position + velocity * delta

	if use_interpolation and Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		previous_position = self.global_position
	else:
		self.global_position = next_position

	if auto_shoot or Input.is_action_pressed("shoot"):
		if shoot_cooldown_timer.time_left <= 0:
			shooter.shoot(target)
			shoot_cooldown_timer.start()
