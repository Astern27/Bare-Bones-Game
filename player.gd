extends CharacterBody2D

@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite2D

# Track the last direction the player faced (defaults to down)
var current_direction: String = "down"

func _ready() -> void:
	AnimatedSprite.play("idle_down")

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		if Input.is_action_pressed("Sprint"):
			velocity = direction * 200
		else:
			velocity = direction * 80
			
		update_direction_string(direction)
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	update_animation()
	
func update_direction_string(input: Vector2) -> void:
	if abs(input.x) > abs(input.y):
		if input.x > 0:
			current_direction = "right"
		else:
			current_direction = "left"
	else:
		if input.y > 0:
			current_direction = "down"
		else:
			current_direction = "up"

func update_animation() -> void:
	if velocity == Vector2.ZERO:
		AnimatedSprite.play("idle_" + current_direction)
	else:
		AnimatedSprite.play("walk_" + current_direction)
