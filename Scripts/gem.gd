extends Area2D

signal gem_collected(value)

@onready var sprite = $AnimatedSprite2D

var gem_value = 1


func _ready():
	body_entered.connect(_on_body_entered)
	randomize_gem()


func randomize_gem():

	var roll = randi() % 100

	# Weighted rarity system
	if roll < 40:
		sprite.play("green")
		gem_value = 1

	elif roll < 65:
		sprite.play("red")
		gem_value = 2

	elif roll < 80:
		sprite.play("purple")
		gem_value = 3

	elif roll < 93:
		sprite.play("lightPurple")
		gem_value = 4

	else:
		sprite.play("blue")
		gem_value = 5


func _on_body_entered(body):
	if body.name == "Player":
		gem_collected.emit(gem_value)
	queue_free()
