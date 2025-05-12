extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D
@onready var death_screen = $CanvasLayer/DeathScreen

# Movement
@export var speed := 100
var last_direction = Vector2.DOWN
var speed_multiplier: float = 1.0

# Health
@export var max_health := 100
var health: int:
	set(value):
		health = clamp(value, 0, max_health)
		update_health_bar()
		if health <= 0:
			die()

# Animation
var is_alive: bool = true

# Interaction
var current_interactable: Node = null

@onready var health_bar = $HealthBar

func _ready():
	await get_tree().process_frame
	var tilemap = get_tree().get_first_node_in_group("maze_tilemaps")
	
	if tilemap:
	# Calculate maze size from TileMap data
		var used_rect = tilemap.get_used_rect()
		var cell_size = tilemap.tile_set.tile_size
		
		# Convert grid units to pixels
		var maze_width = used_rect.end.x * cell_size.x
		var maze_height = used_rect.end.y * cell_size.y
		
		# Set camera limits
		camera.limit_right = maze_width
		camera.limit_bottom = maze_height
	
	health = max_health
	# Initialize Dialogic variable
	add_to_group("player")
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = true
	
	var spawn_point = get_tree().get_first_node_in_group("player_spawn")
	if spawn_point:
		global_position = spawn_point.global_position
	else:
		push_warning("No spawn point found! Using default position.")
		global_position = Vector2.ZERO

func _physics_process(_delta):
	
	if !is_alive or DialogueManager.is_dialogue_active:
		return
	
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	elif Input.is_action_pressed("ui_left"):
		direction.x = -1
	
	if direction.x == 0:
		if Input.is_action_pressed("ui_down"):
			direction.y = 1
		elif Input.is_action_pressed("ui_up"):
			direction.y = -1
	
	velocity = direction * speed * speed_multiplier
	
	if direction != Vector2.ZERO:
		last_direction = direction
		play_walk_animation(direction)
	else:
		play_idle_animation(last_direction)
	
	move_and_slide()
	
func update_health_bar():
	health_bar.value = health

func take_damage(amount: int):
	if is_alive:
		health -= amount

func heal(amount: int):
	if is_alive:
		health += amount

func apply_speed_boost(multiplier: float = 1.5, duration: float = 10.0):
	speed_multiplier = multiplier
	$SpeedBoostTimer.wait_time = duration
	$SpeedBoostTimer.start()

func die():
	if !is_alive:
		return
	
	is_alive = false
	play_death_animation()
	show_game_over()

func play_death_animation():
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished

func show_game_over():
	get_tree().paused = true
	if death_screen:
		death_screen.show_death_screen()
	else:
		push_error("Death screen not found! Make sure DeathScreen is a child of CanvasLayer")

func play_walk_animation(dir: Vector2):
	if dir.x > 0:  # Right
		$AnimatedSprite2D.play("Side_walk")
		$AnimatedSprite2D.flip_h = false
	elif dir.x < 0:  # Left
		$AnimatedSprite2D.play("Side_walk")
		$AnimatedSprite2D.flip_h = true
	elif dir.y > 0:  # Down
		$AnimatedSprite2D.play("Front_walk")
	else:  # Up
		$AnimatedSprite2D.play("Back_walk")

func play_idle_animation(dir: Vector2):
	if dir.x != 0:
		$AnimatedSprite2D.play("Side_idle")
		$AnimatedSprite2D.flip_h = dir.x < 0
	elif dir.y > 0:
		$AnimatedSprite2D.play("Front_idle")
	else:
		$AnimatedSprite2D.play("Back_idle")

func _on_safe_zone_area_entered(_area):
	add_to_group("safe_zone")

func _on_safe_zone_area_exited(_area):
	remove_from_group("safe_zone")

func _on_speed_boost_timer_timeout():
	speed_multiplier = 1.0
	print("Speed boost wore off")

func _on_interaction_area_body_entered(body):
	if body.is_in_group("npc"):
		current_interactable = body

func _on_interaction_area_body_exited(body):
	if body == current_interactable:
		current_interactable = null

func _input(event):
	if event.is_action_pressed("interact") and current_interactable:
		current_interactable.interact()
