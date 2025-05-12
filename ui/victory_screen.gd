extends Control

func _ready():
	$AnimationPlayer.play("fade_in")
	
	# Ensure buttons are interactable
	$VBoxContainer/MainMenuButton.disabled = false
	$VBoxContainer/QuitButton.disabled = false
	
	# Force focus to first button
	$VBoxContainer/MainMenuButton.grab_focus()

func _on_main_menu_button_pressed():
	GameManager.exit_to_main_menu()

func _on_quit_button_pressed():
	GameManager.quit_game()
