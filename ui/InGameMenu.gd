extends Control

@onready var resume_button = $PanelContainer/VBoxContainer/ResumeButton
@onready var save_button = $PanelContainer/VBoxContainer/SaveButton
@onready var main_menu_button = $PanelContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $PanelContainer/VBoxContainer/QuitButton
@onready var confirmation_dialog = $ConfirmationDialog
@onready var save_confirmation_label = $SaveConfirmationLabel

func _ready():
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect confirmation dialog signals
	confirmation_dialog.confirmed.connect(_on_save_and_exit_confirmed)
	confirmation_dialog.canceled.connect(_on_exit_without_save)
	
	# Hide menu by default (will be shown when paused)
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if GameManager.is_game_paused:
			_on_resume_pressed()
		else:
			show()
			GameManager.pause_game()

func _on_resume_pressed():
	# Hide menu and resume game
	hide()
	GameManager.resume_game()

func _on_save_pressed():
	# Save game
	if GameManager.save_game():
		# Show save confirmation message
		save_confirmation_label.show()
		
		# Hide after 2 seconds
		var tween = create_tween()
		tween.tween_property(save_confirmation_label, "modulate:a", 0.0, 2.0)
		tween.tween_callback(func(): 
			save_confirmation_label.hide()
			save_confirmation_label.modulate.a = 1.0
		)

func _on_main_menu_pressed():
	# Ask if player wants to save before exiting
	confirmation_dialog.popup_centered()

func _on_save_and_exit_confirmed():
	# Save game and return to main menu
	GameManager.save_game()
	GameManager.exit_to_main_menu()

func _on_exit_without_save():
	# Return to main menu without saving
	GameManager.exit_to_main_menu()

func _on_quit_pressed():
	# Quit the game
	GameManager.quit_game()