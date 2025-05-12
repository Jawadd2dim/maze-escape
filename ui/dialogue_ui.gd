extends CanvasLayer

signal dialogue_continued
signal dialogue_choice_selected(choice_index)

@onready var dialogue_panel = $DialoguePanel
@onready var npc_name_label = $DialoguePanel/MarginContainer/VBoxContainer/NPCName
@onready var dialogue_text = $DialoguePanel/MarginContainer/VBoxContainer/DialogueText
@onready var choices_container = $DialoguePanel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var continue_indicator = $DialoguePanel/MarginContainer/VBoxContainer/ContinueIndicator
@onready var typewriter_timer = $TypewriterTimer

var full_text = ""
var current_length = 0
var is_typing = false
var choice_buttons = []
var is_processing_input = false

func _ready():
	add_to_group("dialogue_ui")
	visible = false
	dialogue_panel.visible = false
	continue_indicator.visible = false
	choices_container.visible = false
	typewriter_timer.timeout.connect(_on_typewriter_timer_timeout)

func _input(event):
	if !visible or !dialogue_panel.visible or is_processing_input:
		return
	
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		is_processing_input = true
		
		if is_typing:
			current_length = full_text.length()
			dialogue_text.text = full_text
			is_typing = false
			continue_indicator.visible = true
		elif choices_container.visible and choice_buttons.size() > 0:
			pass
		else:
			emit_signal("dialogue_continued")
		
		await get_tree().create_timer(0.1).timeout
		is_processing_input = false

func show_dialogue(speaker_name, text):
	visible = true
	dialogue_panel.visible = true
	
	npc_name_label.text = speaker_name
	full_text = text
	current_length = 0
	is_typing = true
	
	dialogue_text.text = ""
	continue_indicator.visible = false
	choices_container.visible = false
	
	typewriter_timer.start()

func show_choices(choices):
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()
	
	for i in range(choices.size()):
		var button = Button.new()
		button.text = choices[i]
		button.pressed.connect(_on_choice_button_pressed.bind(i))
		
		button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_stylebox_override("normal", create_choice_style(false))
		button.add_theme_stylebox_override("hover", create_choice_style(true))
		
		choices_container.add_child(button)
		choice_buttons.append(button)
	
	choices_container.visible = true
	continue_indicator.visible = false

func create_choice_style(is_hover):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 1.0) if is_hover else Color(0.15, 0.15, 0.15, 1.0)
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.4, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func hide_choices():
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()
	choices_container.visible = false
	continue_indicator.visible = true

func hide_dialogue():
	is_processing_input = false
	if is_typing:
		is_typing = false
		typewriter_timer.stop()
	
	visible = false
	dialogue_panel.visible = false
	continue_indicator.visible = false
	choices_container.visible = false
	
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

func _on_typewriter_timer_timeout():
	if current_length < full_text.length():
		current_length += 1
		dialogue_text.text = full_text.substr(0, current_length)
		typewriter_timer.start()
	else:
		is_typing = false
		continue_indicator.visible = true

func _on_choice_button_pressed(choice_index):
	if !is_processing_input:
		is_processing_input = true
		emit_signal("dialogue_choice_selected", choice_index)
		await get_tree().create_timer(0.1).timeout
		is_processing_input = false
