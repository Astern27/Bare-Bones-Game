extends CharacterBody2D

@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite2D
static var bones = 0
static var skulls = 0
static var teeth = 0
static var max_stamina = 100;

# Track the last direction the player faced (defaults to down)
var current_direction: String = "down"

func _ready() -> void:
	AnimatedSprite.play("idle_down")
	get_node("../CanvasLayer/Stamina").max_value = max_stamina

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		if Input.is_action_pressed("Sprint") and get_node("../CanvasLayer/Stamina").value > 0:
			velocity = direction * 200
			get_node("../CanvasLayer/Stamina").value -= 1.7;
		else:
			velocity = direction * 80
			if get_node("../CanvasLayer/Stamina").value > 1:
				get_node("../CanvasLayer/Stamina").value += .3
			
		update_direction_string(direction)
	else:
		velocity = Vector2.ZERO
		if !(Input.is_action_pressed("Dig") and get_node("../CanvasLayer/Stamina").value <= 1):
			get_node("../CanvasLayer/Stamina").value += .5
		
	move_and_slide()
	update_animation(direction)

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

func update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		AnimatedSprite.play("idle_" + current_direction)
	else:
		AnimatedSprite.play("walk_" + current_direction)
