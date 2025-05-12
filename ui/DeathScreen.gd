extends Control

@onready var try_again_button = $PanelContainer/VBoxContainer/HBoxContainer/TryAgainButton
@onready var main_menu_button = $PanelContainer/VBoxContainer/HBoxContainer/MainMenuButton

func _ready():
	# Connect button signals
	try_again_button.pressed.connect(_on_try_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Hide by default
	hide()

func show_death_screen():
	# Show death screen
	show()

func _on_try_again_pressed():
	# Restart the current level
	hide()
	GameManager.restart_current_level()

func _on_main_menu_pressed():
	# Return to main menu
	hide()
	GameManager.exit_to_main_menu()
