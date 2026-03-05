extends CharacterBody2D

@export var speed = 300

var max_fuel = 100
var fuel = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead := false


func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if Input.is_action_pressed("move_left"):
		direction.x -= 1

	if Input.is_action_pressed("move_right"):
		direction.x += 1

	velocity = direction.normalized() * speed
	move_and_slide()

	update_animation(direction)
	consume_fuel(delta)


func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		if sprite.animation != "idle":
			sprite.play("idle")
		return

	# Use 'back' when moving up, 'forward' for other movement.
	if direction.y < 0.0:
		if sprite.animation != "back":
			sprite.play("back")
	else:
		if sprite.animation != "forward":
			sprite.play("forward")


func consume_fuel(delta):
	if velocity.length() > 0.0:
		fuel -= 5 * delta
		fuel = clamp(fuel, 0, max_fuel)


func add_fuel(amount):
	fuel += amount
	fuel = clamp(fuel, 0, max_fuel)


func die() -> void:
	if is_dead:
		return
	is_dead = true
	sprite.play("death")
