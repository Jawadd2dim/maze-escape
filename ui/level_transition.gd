extends CanvasLayer

@onready var label: Label = $Label
@onready var timer: Timer = $Timer
@onready var color_rect: ColorRect = $ColorRect
@onready var difficulty_label: Label = $DifficultyLabel


var next_scene: String
var is_final_level: bool = false

func show_level_start(level_name: String, difficulty: String, scene_path: String):
	# Pause game immediately
	get_tree().paused = true
	
	# Set up visuals
	label.text = level_name
	difficulty_label.text = "Difficulty - " + difficulty
	difficulty_label.show()
	next_scene = scene_path
	color_rect.modulate.a = 0  # Start transparent
	
	# Fade in animation
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.8, 0.5)
	await tween.finished
	
	# Start timer
	timer.start(2.0)

func show_completion(level_name: String, scene_path: String, is_final: bool = false):
	is_final_level = is_final
	# Pause game immediately
	get_tree().paused = true
	
	# Set up visuals
	label.text = level_name + " Complete!"
	difficulty_label.hide()
	next_scene = scene_path
	color_rect.modulate.a = 0  # Start transparent
	
	# Fade in animation
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.8, 0.5)
	await tween.finished
	
	# Start timer
	timer.start(2.0)

func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	get_tree().paused = false
	if is_final_level:
		# Let GameManager handle victory screen
		queue_free()
	elif ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	queue_free()
	
	
func _input(event):
	# Block all input during transition
	if visible:
		get_viewport().set_input_as_handled()
