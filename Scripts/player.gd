extends CharacterBody2D

@export var speed = 220
@export var acceleration = 900
@export var friction = 700

@export var max_fuel = 100.0
var fuel = max_fuel

var alive = true

@onready var sprite = $AnimatedSprite2D


func _physics_process(delta):

	if !alive:
		return

	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
		fuel -= delta * 5
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		fuel -= delta * 2

	move_and_slide()

	if fuel <= 0:
		die()


func add_fuel(amount):
	fuel = clamp(fuel + amount, 0, max_fuel)


func die():
	alive = false
	velocity = Vector2.ZERO
	sprite.play("death")
