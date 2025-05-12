extends Control

# Nodes
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var new_game_button: Button = $CanvasLayer/MainMenuContainer/StartMenu/NewGameButton
@onready var load_game_button: Button = $CanvasLayer/MainMenuContainer/StartMenu/LoadGameButton
@onready var options_button: Button = $CanvasLayer/MainMenuContainer/StartMenu/OptionsButton
@onready var exit_button: Button = $CanvasLayer/MainMenuContainer/StartMenu/ExitButton
@onready var options_menu: Control = $OptionsMenu
@onready var main_menu_container: Control = $CanvasLayer/MainMenuContainer

func _ready():
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Play fade-in animation
	animation_player.play("fade_in")
	
	# Check if save game exists and enable/disable load button accordingly
	load_game_button.disabled = not GameManager.has_save_game()

func _on_new_game_pressed():
	# Start a new game
	GameManager.start_new_game()

func _on_load_game_pressed():
	# Load saved game
	if GameManager.has_save_game():
		GameManager.load_game()
	else:
		print("No save game found")

func _on_options_pressed():
	# Hide main menu and show options
	main_menu_container.hide()
	options_menu.show()

func _on_exit_pressed():
	# Quit the game
	GameManager.quit_game()
