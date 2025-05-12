extends Control

# Button references
@onready var move_up_button = $PanelContainer/VBoxContainer/GridContainer/MoveUpButton
@onready var move_down_button = $PanelContainer/VBoxContainer/GridContainer/MoveDownButton
@onready var move_left_button = $PanelContainer/VBoxContainer/GridContainer/MoveLeftButton
@onready var move_right_button = $PanelContainer/VBoxContainer/GridContainer/MoveRightButton
@onready var interact_button = $PanelContainer/VBoxContainer/GridContainer/InteractButton
@onready var save_button = $PanelContainer/VBoxContainer/ButtonsContainer/SaveButton
@onready var cancel_button = $PanelContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var key_remap_dialog = $KeyRemapDialog
@onready var key_remap_cancel_button = $KeyRemapDialog/VBoxContainer/CancelButton

# Temporary settings storage for current session
var temp_settings = {}
var current_button = null
var current_action = ""
var waiting_for_input = false

func _ready():
	print("OptionsMenu: Ready")
	# Connect signals
	move_up_button.pressed.connect(func(): _on_key_button_pressed("move_up", move_up_button))
	move_down_button.pressed.connect(func(): _on_key_button_pressed("move_down", move_down_button))
	move_left_button.pressed.connect(func(): _on_key_button_pressed("move_left", move_left_button))
	move_right_button.pressed.connect(func(): _on_key_button_pressed("move_right", move_right_button))
	interact_button.pressed.connect(func(): _on_key_button_pressed("interact", interact_button))
	save_button.pressed.connect(_on_save_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	key_remap_cancel_button.pressed.connect(_on_remap_cancel_pressed)
	
	# Load initial settings
	_load_current_settings()

func _load_current_settings():
	print("OptionsMenu: Loading current settings")
	# Copy current settings to temp settings
	temp_settings = GameManager.settings.controls.duplicate()
	
	# Update button text
	move_up_button.text = OS.get_keycode_string(temp_settings.move_up)
	move_down_button.text = OS.get_keycode_string(temp_settings.move_down)
	move_left_button.text = OS.get_keycode_string(temp_settings.move_left)
	move_right_button.text = OS.get_keycode_string(temp_settings.move_right)
	interact_button.text = OS.get_keycode_string(temp_settings.interact)
	print("OptionsMenu: Settings loaded and buttons updated")

func _on_key_button_pressed(action, button):
	print("OptionsMenu: Key button pressed - Action: ", action)
	# Store the current button and action being modified
	current_button = button
	current_action = action
	waiting_for_input = true
	
	# Show the key remapping dialog
	key_remap_dialog.popup_centered()
	print("OptionsMenu: Dialog shown, waiting for input")

func _input(event):
	if not waiting_for_input:
		return
		
	if event is InputEventKey:
		print("OptionsMenu: Processing input event: ", event)
		
		if event.pressed:
			print("OptionsMenu: Key pressed while waiting for input: ", OS.get_keycode_string(event.keycode))
			
			if event.keycode == KEY_ESCAPE:
				# Just close the dialog without changing the binding
				key_remap_dialog.hide()
				waiting_for_input = false
				get_viewport().set_input_as_handled()
				print("OptionsMenu: Remapping cancelled with Escape")
				return
			
			print("OptionsMenu: Updating key binding for action: ", current_action)
			# Update temporary settings with the new key
			temp_settings[current_action] = event.keycode
			
			# Update button text
			current_button.text = OS.get_keycode_string(event.keycode)
			
			# Update the input map
			var action_name = "ui_" + current_action.replace("move_", "")
			print("OptionsMenu: Updating input map for action: ", action_name)
			
			InputMap.action_erase_events(action_name)
			
			var new_event = InputEventKey.new()
			new_event.keycode = event.keycode
			InputMap.action_add_event(action_name, new_event)
			
			# Close dialog and stop waiting for input
			key_remap_dialog.hide()
			waiting_for_input = false
			get_viewport().set_input_as_handled()
			print("OptionsMenu: Key binding updated and dialog closed")

func _on_save_pressed():
	print("OptionsMenu: Saving settings")
	# Apply settings to GameManager
	for action in temp_settings:
		GameManager.settings.controls[action] = temp_settings[action]
	
	# Save settings
	GameManager.save_settings()
	
	# Hide options menu
	hide()
	
	# Show main menu
	var main_menu = get_tree().get_root().get_node_or_null("MainMenu")
	if main_menu:
		var menu_container = main_menu.get_node_or_null("CanvasLayer/MainMenuContainer")
		if menu_container:
			menu_container.show()
	print("OptionsMenu: Settings saved and menu closed")

func _on_cancel_pressed():
	print("OptionsMenu: Cancel pressed")
	# Hide options menu
	hide()
	
	# Show main menu
	var main_menu = get_tree().get_root().get_node_or_null("MainMenu")
	if main_menu:
		var menu_container = main_menu.get_node_or_null("CanvasLayer/MainMenuContainer")
		if menu_container:
			menu_container.show()

func _on_remap_cancel_pressed():
	print("OptionsMenu: Remap cancelled")
	# Cancel key remapping
	key_remap_dialog.hide()
	waiting_for_input = false
