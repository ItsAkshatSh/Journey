extends Node2D

@export var potion_scene: PackedScene
@export var gem_scene: PackedScene
@export var low_fuel_threshold_ratio := 0.15
@export var low_fuel_pulse_speed := 6.0

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var container = $World/Collectibles

@onready var fuel_bar = $UI/FuelBar
@onready var gem_container = $UI/GemContainer
@onready var gem_label = $UI/GemContainer/GemLabel
@onready var fade_timer = $UI/FadeTimer

var gem_count := 0


func _ready():
	spawn_timer.timeout.connect(spawn_random)
	fade_timer.timeout.connect(hide_gem_ui)

	fuel_bar.max_value = player.max_fuel
	update_fuel_bar()


func spawn_random():
	var spawn_position = get_random_spawn_position()
	if spawn_position == null:
		return

	if randi() % 2 == 0:
		var potion := potion_scene.instantiate()
		container.add_child(potion)
		potion.position = spawn_position
	else:
		var gem := gem_scene.instantiate()
		container.add_child(gem)
		gem.position = spawn_position
		gem.gem_collected.connect(on_gem_collected)


func get_random_spawn_position():
	var spawn_points := get_tree().get_nodes_in_group("spawn_point")

	if spawn_points.is_empty():
		return null

	var index := randi() % spawn_points.size()
	var point = spawn_points[index]

	if point is Node2D:
		return point.global_position

	return null


func on_gem_collected(value):
	gem_count += value
	gem_label.text = str(gem_count)
	show_gem_ui()


func show_gem_ui():
	gem_container.modulate.a = 1
	fade_timer.start()


func hide_gem_ui():
	var tween := create_tween()
	tween.tween_property(gem_container, "modulate:a", 0, 1.0)


func _process(delta):
	update_fuel_bar()


func update_fuel_bar():
	fuel_bar.value = player.fuel
	update_low_fuel_feedback()


func update_low_fuel_feedback() -> void:
	if player.max_fuel <= 0:
		fuel_bar.modulate = Color.WHITE
		return

	var ratio := float(player.fuel) / float(player.max_fuel)
	if ratio <= low_fuel_threshold_ratio and ratio > 0.0:
		var t := Time.get_ticks_msec() / 1000.0
		var pulse := 0.55 + 0.45 * (0.5 + 0.5 * sin(t * low_fuel_pulse_speed))
		fuel_bar.modulate = Color(1.0, pulse, pulse, 1.0)
	else:
		fuel_bar.modulate = Color.WHITE
