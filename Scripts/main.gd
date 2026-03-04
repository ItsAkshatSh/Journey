extends Node2D

@export var potion_scene : PackedScene
@export var gem_scene : PackedScene

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var container = $World/Collectibles

@onready var fuel_bar = $UI/FuelBar
@onready var gem_container = $UI/GemContainer
@onready var gem_label = $UI/GemContainer/GemLabel
@onready var fade_timer = $UI/FadeTimer

var gem_count = 0

var fuel_frame_width = 230
var fuel_frame_height = 180


func _ready():
	spawn_timer.timeout.connect(spawn_random)
	fade_timer.timeout.connect(hide_gem_ui)


func spawn_random():

	var spawn_position = Vector2(
		randf_range(100, 900),
		player.position.y + randf_range(200, 800)
	)

	if randi() % 2 == 0:
		var potion = potion_scene.instantiate()
		container.add_child(potion)
		potion.position = spawn_position
	else:
		var gem = gem_scene.instantiate()
		container.add_child(gem)
		gem.position = spawn_position
		gem.gem_collected.connect(on_gem_collected)


func on_gem_collected(value):

	gem_count += value
	gem_label.text = str(gem_count)

	show_gem_ui()


func show_gem_ui():
	gem_container.modulate.a = 1
	fade_timer.start()


func hide_gem_ui():
	var tween = create_tween()
	tween.tween_property(gem_container, "modulate:a", 0, 1.0)


func _process(delta):
	update_fuel_bar()


func update_fuel_bar():

	var percent = player.fuel / player.max_fuel
	var frame = 4 

	if percent == 1:
		frame = 4
	elif percent == 0.75:
		frame = 3
	elif percent == 0.50:
		frame = 2
	elif percent == 0.25:
		frame = 1
	else:
		frame = 0

	fuel_bar.region_rect = Rect2(
		frame * fuel_frame_width,
		0,
		fuel_frame_width,
		fuel_frame_height
	)
