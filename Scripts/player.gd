class_name Player
extends CharacterBody2D

@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite2D
static var bones = 0
static var skulls = 0
static var teeth = 0
static var max_stamina = 100;
static var recharge = 1
@onready var stamina = get_node("../CanvasLayer/Stamina")

# Track the last direction the player faced (defaults to down)
var current_direction: String = "down"

func _ready() -> void:
	AnimatedSprite.play("idle_down")
	stamina.max_value = max_stamina
	stamina.value = max_stamina
	bones = 0
	skulls = 0
	teeth = 0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		if Input.is_action_pressed("Sprint") and stamina.value > 0:
			velocity = direction * 200
			$Noise/CollisionShape2D.shape.radius = 2000
			stamina.value -= 1.7;
		else:
			velocity = direction * 80
			$Noise/CollisionShape2D.shape.radius = 1000
			if stamina.value > 1:
				stamina.value += .3 * recharge
			
		update_direction_string(direction)
	else:
		velocity = Vector2.ZERO
		if !Input.is_action_pressed("Dig"):
			$Noise/CollisionShape2D.shape.radius = 500
		if !(Input.is_action_pressed("Dig") and stamina.value <= 1):
			stamina.value += .5 * recharge
		
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Levels/market.tscn")
