extends CharacterBody2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if (Input.is_action_pressed("Sprint")):
		velocity = direction * 200
	else:
		velocity = direction * 80
	move_and_slide()
