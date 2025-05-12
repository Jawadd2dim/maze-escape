extends Node

signal game_saved
signal game_loaded

# Constants
const SAVE_FILE_PATH = "user://savegame.save"

# Game state variables
var current_level: int = 1
var player_health: int = 100
var player_position: Vector2 = Vector2.ZERO
var is_game_paused: bool = false

# Level information
var level_info = {
	1: {"name": "Level 1", "difficulty": "Easy"},
	2: {"name": "Level 2", "difficulty": "Normal"},
	3: {"name": "Level 3", "difficulty": "Hard"},
	4: {"name": "Level 4", "difficulty": "Expert"},
	5: {"name": "Level 5", "difficulty": "Master"}
}

# Player settings and controls
var settings = {
	"controls": {
		"move_up": KEY_W,
		"move_down": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"interact": KEY_E
	},
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0
	}
}

func _ready():
	load_settings()

func pause_game():
	is_game_paused = true
	get_tree().paused = true

func resume_game():
	is_game_paused = false
	get_tree().paused = false

func start_new_game():	
	current_level = 1
	player_health = 100
	player_position = Vector2.ZERO
	load_level(current_level, false)  # false means this is not a level completion

func load_level(level_number: int, is_completion: bool = false):
	current_level = level_number
	var level_path = "res://Levels/Level_%d.tscn" % level_number
	
	# Clean up transitions
	for node in get_tree().root.get_children():
		if node is CanvasLayer and node.has_method("show_completion"):
			node.queue_free()
	
	if ResourceLoader.exists(level_path):
		var transition = load("res://ui/LevelTransition.tscn").instantiate()
		get_tree().root.add_child(transition)
		
		var level_data = level_info[level_number]
		if is_completion:
			# ADD THIS: Pass 'true' if it's Level 5 completion
			transition.show_completion(level_data.name, level_path, (level_number == 5))
		else:
			transition.show_level_start(level_data.name, level_data.difficulty, level_path)
	else:
		show_victory_screen()  # Only called for Level 5
		
		
func show_victory_screen():
	# Force unpause before showing victory screen
	resume_game()
	# Clean up all nodes except GameManager
	var root = get_tree().root
	for node in root.get_children():
		if node.name != "GameManager":
			node.queue_free()
	
	# Load victory screen
	resume_game()
	var victory_scene = load("res://ui/victory_screen.tscn").instantiate()
	victory_scene.z_index = 100
	root.add_child(victory_scene)
	
	# Check for error
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func restart_current_level():
	load_level(current_level, false)

func save_game() -> bool:
	var save_dict = {
		"current_level": current_level,
		"player_health": player_health,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		}
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_dict)
		file.close()
		emit_signal("game_saved")
		return true
	else:
		print("Error saving game: ", FileAccess.get_open_error())
		return false

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found")
		return false
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var save_dict = file.get_var()
		file.close()
		
		current_level = save_dict.current_level
		player_health = save_dict.player_health
		player_position = Vector2(save_dict.player_position.x, save_dict.player_position.y)
		
		emit_signal("game_loaded")
		load_level(current_level, false)
		return true
	else:
		print("Error loading game: ", FileAccess.get_open_error())
		return false

func save_settings():
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if file:
		file.store_var(settings)
		file.close()
	else:
		print("Error saving settings: ", FileAccess.get_open_error())

func load_settings():
	if not FileAccess.file_exists("user://settings.save"):
		save_settings()  # Create default settings file
		return
	
	var file = FileAccess.open("user://settings.save", FileAccess.READ)
	if file:
		var loaded_settings = file.get_var()
		file.close()
		
		# Merge loaded settings with defaults to ensure all keys exist
		for category in loaded_settings:
			if settings.has(category):
				for key in loaded_settings[category]:
					if settings[category].has(key):
						settings[category][key] = loaded_settings[category][key]
	else:
		print("Error loading settings: ", FileAccess.get_open_error())

func update_control(action: String, key_code: int):
	if settings.controls.has(action):
		settings.controls[action] = key_code
		save_settings()
		
func has_save_game() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)
	
func update_player_position(pos: Vector2):
	player_position = pos
	
func update_player_health(health: int):
	player_health = health
	
func exit_to_main_menu():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # For menu navigation
	resume_game()
	
	# Clean up all nodes
	var root = get_tree().root
	for node in root.get_children():
		if node.name != "GameManager":
			node.queue_free()
	
	# Load main menu
	var main_menu = load("res://ui/MainMenu.tscn").instantiate()
	root.add_child(main_menu)
	
func quit_game():
	# Proper quit handling
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
