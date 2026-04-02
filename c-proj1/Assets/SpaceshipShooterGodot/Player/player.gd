extends CharacterBody2D


const SPEED = 120.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):

	# Handle shooting.
	if Input.is_action_just_pressed("ui_accept"):
		spawn_bullet()

	# Get the input direction and handle the movement.
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED

	move_and_slide()
	
	# keep the spaceship inside the screen
	if global_position.x < 16:
		global_position.x = 16
	elif global_position.x > 256 - 16:
		global_position.x = 256 - 16
	
	if global_position.y < 16:
		global_position.y = 16
	elif global_position.y > 340 - 16:
		global_position.y = 340 - 16
	
	# handle animation
	if velocity.x < 0:
		$AnimatedSprite2D.play("left")
	elif velocity.x > 0:
		$AnimatedSprite2D.play("right")
	else:
		$AnimatedSprite2D.play("default")
		
func spawn_bullet():
	var scene_to_spawn = preload("res://Bullet/bullet.tscn")
	var new_scene_instance = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(new_scene_instance)  # Add the instance as a child of the current scene
	new_scene_instance.global_position = global_position
