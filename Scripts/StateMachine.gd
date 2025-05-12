extends Node
class_name StateMachine

const State = preload("res://Scripts/State.gd")

signal state_changed(state_name)

@export var initial_state: String = "Idle"

var current_state: State = null
var current_state_name: String = ""
var states: Dictionary = {}

func _ready():
	# Proper initialization sequence
	await get_tree().process_frame
	
	# Clear previous states
	states.clear()
	
	# Register state nodes
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child.get_enemy().state_machine = self
	
	print("Registered states: ", states.keys())
	
	if states.is_empty():
		push_error("StateMachine: No states found!")
		return  # Properly indented return
	
	# Initialize state machine
	if states.has(initial_state):
		initialize(initial_state)
	else:
		initialize(states.keys()[0])

func initialize(target_state: String = "") -> void:
	print("Initializing with state: ", target_state)
	
	# Handle empty target state
	if target_state.is_empty():
		if states.size() > 0:
			target_state = states.keys()[0]
		else:
			push_error("Can't initialize empty state machine")
			return
	
	if current_state:
		current_state.exit()
	
	if states.has(target_state):
		current_state = states[target_state]
		current_state_name = target_state
		current_state.enter()
		emit_signal("state_changed", current_state_name)
	else:
		push_error("Invalid initial state: ", target_state)

func _process(delta):
	if current_state:
		current_state.process(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_process(delta)
		handle_state_transition()

func handle_state_transition():
	var next_state = current_state.get_next_state()
	if next_state != "" && next_state != current_state_name:
		transition_to(next_state)

func transition_to(new_state_name: String) -> void:
	if !states.has(new_state_name):
		push_error("StateMachine: Invalid transition to '%s'" % new_state_name)
		return
	
	print("Transitioning from %s to %s" % [current_state_name, new_state_name])
	
	if current_state:
		current_state.exit()
	
	current_state = states[new_state_name]
	current_state_name = new_state_name
	current_state.enter()
	emit_signal("state_changed", current_state_name)
