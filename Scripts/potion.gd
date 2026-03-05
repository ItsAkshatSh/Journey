extends Area2D

@export var small_amount = 20
@export var big_amount = 50

var fuel_amount = 20

@onready var sprite = $AnimatedSprite2D


func _ready():
	body_entered.connect(_on_body_entered)
	randomize_potion()


func randomize_potion():

	var roll := randi() % 100

	# Small potions are more common than big ones
	if roll < 70:
		sprite.play("smallPotion")
		fuel_amount = small_amount
	else:
		sprite.play("bigPotion")
		fuel_amount = big_amount


func _on_body_entered(body):
	if body.has_method("add_fuel"):
		body.add_fuel(fuel_amount)
	queue_free()
