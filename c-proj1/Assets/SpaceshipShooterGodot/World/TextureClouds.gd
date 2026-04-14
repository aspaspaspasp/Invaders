extends Sprite2D

@export var speed = 100.0

func _ready():
	scale = Vector2(1.875, 1.875)

func _process(delta):
	global_position.y += speed * delta
	if global_position.y > 750:
		global_position.y = randi_range(-250, -50)
