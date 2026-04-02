extends Sprite2D

@export var speed = 100.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#loop sprite position
	global_position.y += speed * delta
	if global_position.y > 400:
		global_position.y = -200 + randi_range(0, -200)
