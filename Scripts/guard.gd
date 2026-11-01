extends CharacterBody2D

# Guard states: PATROL -> LOOK_AROUND -> CHASE
enum State { PATROL, LOOK_AROUND, CHASE }
var current_state = State.PATROL
var debug_timer: float = 0.0

@export var patrol_points : Array[Vector2] = []

@export var movement_speed : float = 50.0
@export var chase_speed : float = 120.0

# Drag a Node2D here whose children are Marker2D nodes placed along the path
@export var patrol_path: Node2D
@export var starting_point: int = 0

# How close the guard must be to grab the player
@export var catch_distance : float = 16.0
# How close the player can be before the guard notices regardless of noise
@export var close_range : float = 80.0
# Seconds the guard keeps chasing after losing sight
@export var lose_sight_time : float = 1.5
# Turn on to print what the guard is thinking
@export var debug : bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision_cone: Area2D = $VisionCone
@onready var raycast: RayCast2D = $RayCast2D

var target_point_index: int = starting_point
var look_timer: float = 0.0
var look_base_rotation: float = 0.0
var lose_sight_timer: float = 0.0
var player_ref: CharacterBody2D = null
var current_direction: String = "down"

@export var levels : Array[int] = []

func _ready() -> void:
	if levels.find(Player.level) == -1:
		queue_free()
	sprite.play("idle_down")
	player_ref = find_player()

	# Build the patrol route from the marker positions
	if patrol_path:
		patrol_points.clear()
		for child in patrol_path.get_children():
			if child is Marker2D:
				patrol_points.append(child.global_position)
	
	# Start on the first marker and head for the second
	if not patrol_points.is_empty():
		global_position = patrol_points[starting_point]
		target_point_index = starting_point % patrol_points.size()
		
	if debug:
		print("[Guard] player_ref = ", player_ref)
		print("[Guard] patrol points: ", patrol_points)


func _physics_process(delta: float) -> void:
	if debug:
		debug_timer -= delta
		if debug_timer <= 0.0:
			debug_timer = 1.0
			var tgt = patrol_points[target_point_index] if not patrol_points.is_empty() else Vector2.ZERO
			print("[Guard] ", State.keys()[current_state], " pos=", global_position.round(), " target=", tgt)
	# Retry finding the player if it wasn't ready yet
	if not player_ref:
		player_ref = find_player()

	match current_state:
		State.PATROL:
			check_for_player_detection()
			handle_patrol(delta)
		State.LOOK_AROUND:
			check_for_player_detection()
			handle_look_around(delta)
		State.CHASE:
			handle_chase(delta)

	move_and_slide()
	update_animation()

# --- FINDING THE PLAYER ---

func find_player() -> CharacterBody2D:
	# Preferred: the "Player" group
	var p = get_tree().get_first_node_in_group("Player")
	if p:
		return p
	# Fallback: search the scene for a node using the Player class
	var scene = get_tree().current_scene
	if scene:
		for n in scene.find_children("*", "CharacterBody2D", true, false):
			if n is Player:
				return n
	return null

# --- DETECTION ---

# True if the player's Noise area is overlapping our vision cone right now.
# Checked every frame, so it doesn't depend on enter/exit signals.
func noise_is_in_sight() -> bool:
	for area in vision_cone.get_overlapping_areas():
		if area.name == "Noise":
			return true
	return false

func check_for_player_detection() -> void:
	if not player_ref:
		return
	var noisy = noise_is_in_sight()
	var visible_now = can_see_player()
	if debug:
		print("[Guard] noise in sight: ", noisy, " | clear line: ", visible_now)
	if noisy:
		start_chase()

func can_see_player() -> bool:
	if not player_ref:
		return false

	raycast.target_position = raycast.to_local(player_ref.global_position)
	raycast.force_raycast_update()

	# Clear if nothing is hit, or the first thing hit is the player
	return not raycast.is_colliding() or raycast.get_collider() == player_ref

func start_chase() -> void:
	current_state = State.CHASE
	lose_sight_timer = lose_sight_time

# --- STATES ---

func handle_patrol(_delta: float) -> void:
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		return

	var target = patrol_points[target_point_index]
	var direction = (target - global_position).normalized()
	print(global_position)

	velocity = direction * movement_speed
	update_direction_string(direction)
	vision_cone.rotation = direction.angle() - PI / 2

	if global_position.distance_to(target) < 5.0:
		velocity = Vector2.ZERO
		current_state = State.LOOK_AROUND
		look_timer = 2.0
		look_base_rotation = vision_cone.rotation

func handle_look_around(delta: float) -> void:
	velocity = Vector2.ZERO
	look_timer -= delta
	if look_timer <= 0.0:
		if not patrol_points.is_empty():
			target_point_index = (target_point_index + 1) % patrol_points.size()
			if debug:
				print("[Guard] heading to P", target_point_index + 1, " at ", patrol_points[target_point_index])
		current_state = State.PATROL
	else:
		# Sweep around the original facing instead of drifting away from it
		vision_cone.rotation = look_base_rotation + sin(Time.get_ticks_msec() * 0.005) * 0.6

func handle_chase(delta: float) -> void:
	if not player_ref:
		current_state = State.PATROL
		return

	var dist = global_position.distance_to(player_ref.global_position)

	# Caught the player
	if dist <= catch_distance:
		on_player_caught()
		return

	if noise_is_in_sight():
		lose_sight_timer = lose_sight_time
	else:
		lose_sight_timer -= delta

	if lose_sight_timer <= 0.0:
		# Lost them: stop and look around before returning to patrol
		velocity = Vector2.ZERO
		current_state = State.LOOK_AROUND
		look_timer = 2.0
		look_base_rotation = vision_cone.rotation
		return

	var direction = (player_ref.global_position - global_position).normalized()
	velocity = direction * chase_speed
	vision_cone.rotation = direction.angle() - PI / 2
	update_direction_string(direction)

func on_player_caught() -> void:
	if debug:
		print("[Guard] caught the player!")
	# Player's _ready() resets bones/skulls/teeth, so reloading wipes the loot.
	# Swap this for a game over scene if you make one.
	get_tree().call_deferred("reload_current_scene")

# --- DIRECTION & ANIMATION ---

func update_direction_string(input: Vector2) -> void:
	if abs(input.x) > abs(input.y):
		current_direction = "right" if input.x > 0 else "left"
	else:
		current_direction = "down" if input.y > 0 else "up"

func update_animation() -> void:
	if velocity == Vector2.ZERO:
		sprite.play("idle_" + current_direction)
	else:
		sprite.play("walk_" + current_direction)
