extends CharacterBody2D

@export var speed = 160
@export var gravity = 650.0
@export var thrust_power = 900.0
@export var max_rise_speed = 260.0
@export var max_fall_speed = 900.0
@export var horizontal_accel = 900.0
@export var horizontal_decel = 1200.0
@export var fuel_burn_rate = 4.0
@export var fuel_regen_rate = 2.0
@export var thrust_buffer_time = 0.12
@export var thrust_coyote_time = 0.10

var max_fuel = 100
var fuel = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead := false

var _thrust_buffer := 0.0
var _coyote := 0.0


func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_thrust_buffer = maxf(_thrust_buffer - delta, 0.0)
	_coyote = maxf(_coyote - delta, 0.0)
	if is_on_floor():
		_coyote = thrust_coyote_time
	if Input.is_action_just_pressed("move_up"):
		_thrust_buffer = thrust_buffer_time

	# Apply gravity
	velocity.y += gravity * delta

	var pressed_thrust := Input.is_action_pressed("move_up")
	var buffered_takeoff := (_thrust_buffer > 0.0 and _coyote > 0.0)
	var is_thrusting := (pressed_thrust or buffered_takeoff) and fuel > 0.0
	if is_thrusting:
		if buffered_takeoff:
			_thrust_buffer = 0.0
		velocity.y -= thrust_power * delta
		consume_fuel(delta)

	var horizontal_input := 0.0
	# Allow directional control while airborne or thrusting
	if is_thrusting or not is_on_floor():
		if Input.is_action_pressed("move_left"):
			horizontal_input -= 1.0

		if Input.is_action_pressed("move_right"):
			horizontal_input += 1.0

	velocity.y = clampf(velocity.y, -max_rise_speed, max_fall_speed)
	var target_x := horizontal_input * speed
	var rate := horizontal_accel if absf(target_x) > absf(velocity.x) else horizontal_decel
	if is_zero_approx(target_x):
		rate = horizontal_decel
	velocity.x = move_toward(velocity.x, target_x, rate * delta)

	move_and_slide()

	if is_on_floor() and not pressed_thrust and fuel_regen_rate > 0.0:
		fuel = clamp(fuel + fuel_regen_rate * delta, 0, max_fuel)

	var anim_direction := Vector2.ZERO
	anim_direction.x = horizontal_input
	if is_thrusting:
		anim_direction.y = -1.0
	elif velocity.y > 0.0:
		anim_direction.y = 1.0

	update_animation(anim_direction)


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
	fuel -= fuel_burn_rate * delta
	fuel = clamp(fuel, 0, max_fuel)


func add_fuel(amount):
	fuel += amount
	fuel = clamp(fuel, 0, max_fuel)


func die() -> void:
	if is_dead:
		return
	is_dead = true
	sprite.play("death")
