extends CharacterBody2D

# Guard states: PATROL - LOOK AROUND - CHASE
enum State { PATROL, LOOK_AROUND, CHASE }
var current_state: State = State.PATROL

# Empty list to type coordinates for the guard's walking path
@export var patrol_points : Array[Vector2] = []

# Patrol and chase speeds
@export var movement_speed : float = 50.0
@export var chase_speed : float = 120.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision_cone: Area2D = $VisionCone
@onready var raycast: RayCast2D = $RayCast2D

var target_point_index: int = 0
var look_timer:  float = 0.0
var player_ref: CharacterBody2D = null
var current_direction: String = "down"

func _ready() -> void:
	# Connect the VisionCone area signals to track when the player enters the field of view
	vision_cone.body_entered.connect(_on_vision_cone_body_entered)
	vision_cone.body_exited.connect(_on_vision_cone_body_exited)
	sprite.play("idle_down")

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			handle_patrol(delta)
		State.LOOK_AROUND:
			handle_look_around(delta)
		State.CHASE:
			handle_chase(delta)
			
	move_and_slide()
	update_animation()

# --- STATE MANAGEMENT ---

func handle_patrol(_delta: float) -> void:
	if patrol_points.is_empty():
		return
	
	var target = patrol_points[target_point_index]
	var direction = (target - global_position).normalized()
	
	velocity = direction * movement_speed
	update_direction_string(direction)
	
	# Rotate the vision triangle to point in the exact direction the guard walks
	vision_cone.rotation = direction.angle() - PI/2
	
	if global_position.distance_to(target) < 5.0:
		velocity = Vector2.ZERO
		current_state = State.LOOK_AROUND
		look_timer = 2.0 # Pause and look around for 2 seconds

func handle_look_around(delta: float) -> void:
	look_timer -= delta
	
	if look_timer <= 0.0:
		# Advance to the next coordinate point in the array loop
		target_point_index = (target_point_index + 1) % patrol_points.size()
		current_state = State.PATROL
	else:
		# Scan the vision cone back and forth subtly while standing still
		vision_cone.rotation += sin(Time.get_ticks_msec() * 0.005) * 0.01

func handle_chase(_delta: float) -> void:
	if player_ref and can_see_player():
		var direction = (player_ref.global_position - global_position).normalized()
		velocity = direction * chase_speed
		vision_cone.rotation = direction.angle() - PI/2
		update_direction_string(direction)
	else:
		# Lost line of sight, return immediately to the patrol pattern
		current_state = State.PATROL

# --- SIGHT LINE VERIFICATION ---

func can_see_player() -> bool:
	if not player_ref:
		return false
	
	# Aim the invisible laser beam directly at the player's center position
	raycast.target_position = raycast.to_local(player_ref.global_position)
	raycast.force_raycast_update()
	
	# Clear line of sight if it hits nothing or connects straight to the player (no walls in between)
	if not raycast.is_colliding() or raycast.get_collider() == player_ref:
		return true
	
	return false

# --- SIGNAL DETECTORS ---

func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_ref = body
		if can_see_player():
			current_state = State.CHASE

func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null

# --- DIRECTIONAL LOOKUP & ANIMATION ---

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
		sprite.play("idle_" + current_direction)
	else:
		sprite.play("walk_" + current_direction)
