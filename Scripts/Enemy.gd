extends CharacterBody2D
var previous_position := Vector2.ZERO

# Enemy main controller script

# State Machine
@onready var state_machine = $StateMachine
@onready var animated_sprite = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var player_detection = $PlayerDetection
@onready var attack_range = $AttackRange
@onready var patrol_timer = $PatrolTimer

# Export variables for tuning
@export var move_speed: float = 50.0
@export var chase_speed: float = 80.0
@export var patrol_wait_time: float = 3.0
@export var patrol_range: float = 150.0
@export var wander_radius: float = 100.0
@export var detection_radius: float = 150.0
@export var attack_radius: float = 30.0
@export var health: int = 100
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

# State tracking
var player = null
var can_attack: bool = true
var original_position: Vector2
var patrol_point: Vector2
var last_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false

func _ready():
	original_position = global_position
	patrol_timer.wait_time = patrol_wait_time
	
	# Setup collision areas
	player_detection.monitoring = true
	player_detection.monitorable = false
	attack_range.monitoring = true
	attack_range.monitorable = false
	
	# Initialize the state machine after delay
	await get_tree().process_frame  # Critical fix
	
	# Start with patrol point
	set_random_patrol_point()
	
	# Set collision shapes
	var player_detection_shape = CircleShape2D.new()
	player_detection_shape.radius = detection_radius
	player_detection.get_node("CollisionShape2D").shape = player_detection_shape
	
	var attack_shape = CircleShape2D.new()
	attack_shape.radius = attack_radius
	attack_range.get_node("CollisionShape2D").shape = attack_shape
	

func _physics_process(_delta):
	# Let the state machine handle most of the behavior
	pass

func move_along_path(target_speed: float) -> void:
	if navigation_agent.is_navigation_finished():
		return
		
	var next_path_pos = navigation_agent.get_next_path_position()
	var _adjusted_pos = next_path_pos + Vector2(randf_range(-5,5), randf_range(-5,5)) # Prevent gridlock
	var next_path_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	last_direction = direction
	velocity = direction * target_speed
	move_and_slide()
	update_animation(direction)
	
	velocity = direction * target_speed
	move_and_slide()

func update_animation(direction: Vector2) -> void:
	if is_attacking:
		play_attack_animation(direction)
		return
	
	var animation_prefix = "idle_"
	
	if velocity.length() > 10:
		animation_prefix = "walk_"
	
	if state_machine.current_state_name == "Chase":
		animation_prefix = "run_"
	
	var animation_suffix = "front"
	
	if abs(direction.x) > abs(direction.y):
		animation_suffix = "right" if direction.x > 0 else "left"
	else:
		animation_suffix = "back" if direction.y < 0 else "front"
	
	animated_sprite.play(animation_prefix + animation_suffix)

func play_attack_animation(direction: Vector2) -> void:
	var animation_suffix = "front"
	
	if abs(direction.x) > abs(direction.y):
		animation_suffix = "right" if direction.x > 0 else "left"
	else:
		animation_suffix = "back" if direction.y < 0 else "front"
	
	animated_sprite.play("Attack_" + animation_suffix)

func set_target_position(target: Vector2) -> void:
	navigation_agent.target_position = target

func get_player() -> Node2D:
	return player

func can_see_player() -> bool:
	if player == null || player.is_in_group("safe_zone"):
		return false
	
	$RayCast2D.target_position = player.global_position - global_position
	$RayCast2D.force_raycast_update()
	return (
		player_detection.overlaps_body(player) and 
		$RayCast2D.get_collider() == player
	)

func can_attack_player() -> bool:
	return player != null && attack_range.overlaps_body(player) && can_attack

func start_attack() -> void:
	is_attacking = true
	can_attack = false
	
	var current_animation = "Attack_" + animated_sprite.animation.split("_")[1]
	var frame_count = animated_sprite.sprite_frames.get_frame_count(current_animation)
	var fps = animated_sprite.sprite_frames.get_animation_speed(current_animation)
	var animation_duration = frame_count / fps
	
	var damage_timer = get_tree().create_timer(animation_duration * 0.5)
	damage_timer.timeout.connect(func():
		if player and attack_range.overlaps_body(player):
			player.take_damage(attack_damage))
	
	var attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = animation_duration
	attack_timer.timeout.connect(func(): 
		is_attacking = false
		var cooldown_timer = Timer.new()
		cooldown_timer.one_shot = true
		cooldown_timer.wait_time = attack_cooldown
		cooldown_timer.timeout.connect(func(): can_attack = true)
		add_child(cooldown_timer)
		cooldown_timer.start()
	)
	add_child(attack_timer)
	attack_timer.start()

func set_random_patrol_point() -> Vector2:
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var distance = randf_range(50, wander_radius)
	var new_point = original_position + (random_direction * distance)
	
	patrol_point = new_point
	return new_point

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body
		if state_machine.current_state_name != ("Attack"):
			state_machine.transition_to("Chase")

func _on_player_detection_body_exited(body):
	if body.is_in_group("player") && body == player:
		player = null

func _on_attack_range_body_entered(body):
	if body.is_in_group("player") && body == player:
		if state_machine.current_state_name == ("Chase"):
			state_machine.transition_to("Attack")

func _on_attack_range_body_exited(body):
	if body.is_in_group("player") && body == player:
		if state_machine.current_state_name == ("Attack"):
			state_machine.transition_to("Chase")

func _notification(what):
	if what == NOTIFICATION_PAUSED:
		set_process(false)
		set_physics_process(false)
