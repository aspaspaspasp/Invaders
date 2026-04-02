extends Area2D

var speed = 70

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y += speed * delta
	
	
func reset_position():

	global_position.y = -32

func _on_visible_on_screen_notifier_2d_screen_exited():
	reset_position()
