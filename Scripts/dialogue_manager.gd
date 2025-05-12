extends Node

signal dialogue_started
signal dialogue_ended
signal dialogue_choice_made(choice_index)

var level_npc_limits = {
	"Level_Easy": {
		"speed_boosts": 5,
		"heals": 5
	},
	"Level_Normal": {
		"speed_boosts": 3,
		"heals": 3
	},
	"Level_Hard": {
		"speed_boosts": 2,
		"heals": 2
	},
	"Level_VeryHard": {
		"speed_boosts": 1,
		"heals": 1
	},
	"Level_Extreme": {
		"speed_boosts": 1,
		"heals": 1
	}
}

var npc_meeting_history = {}
var npc_heal_counts = {}
var current_dialogue_tree = null
var current_dialogue_node = null
var current_npc = null
var is_dialogue_active = false
var dialogue_ui = null

func _ready():
	# Wait a frame to allow scene tree to setup
	await get_tree().process_frame
	
	# Create and add DialogueUI if it doesn't exist
	if not dialogue_ui:
		var scene = load("res://ui/DialogueUI.tscn")
		if scene:
			dialogue_ui = scene.instantiate()
			# Add to root to ensure it persists across scene changes
			get_tree().root.add_child(dialogue_ui)
			dialogue_ui.hide()
		else:
			push_error("DialogueManager: Failed to load DialogueUI scene!")

func start_dialogue(npc, dialogue_tree, starting_node = "start"):
	if dialogue_ui == null:
		push_error("DialogueManager: DialogueUI not initialized!")
		return false
	
	# Don't pause the game, just set dialogue as active
	is_dialogue_active = true
	
	dialogue_ui.visible = true
	current_npc = npc
	current_dialogue_tree = dialogue_tree
	current_dialogue_node = starting_node
	
	# Disconnect existing signals to prevent duplicates
	if dialogue_ui.is_connected("dialogue_continued", _on_dialogue_continued):
		dialogue_ui.disconnect("dialogue_continued", _on_dialogue_continued)
	
	if dialogue_ui.is_connected("dialogue_choice_selected", _on_dialogue_choice_selected):
		dialogue_ui.disconnect("dialogue_choice_selected", _on_dialogue_choice_selected)
	
	# Connect signals without CONNECT_ONE_SHOT to allow multiple dialogue continuations
	dialogue_ui.connect("dialogue_continued", _on_dialogue_continued)
	dialogue_ui.connect("dialogue_choice_selected", _on_dialogue_choice_selected)
	
	var npc_key = get_npc_key(npc)
	var first_meeting = !npc_meeting_history.has(npc_key) or !npc_meeting_history[npc_key]
	
	process_dialogue_node(current_dialogue_node, first_meeting)
	
	npc_meeting_history[npc_key] = true
	
	emit_signal("dialogue_started")
	return true

func get_npc_key(npc):
	var current_level = get_tree().current_scene.name
	return npc.name + "_" + current_level

func process_dialogue_node(node_id, first_meeting = false):
	if current_dialogue_tree == null or !current_dialogue_tree.has(node_id):
		end_dialogue()
		return
	
	var node = current_dialogue_tree[node_id]
	
	if first_meeting and node.has("first_meeting"):
		node = node["first_meeting"]
	
	if node.has("text"):
		dialogue_ui.show_dialogue(current_npc.display_name, node["text"])
		
		if node.has("choices") and node["choices"].size() > 0:
			var choices = []
			for choice in node["choices"]:
				choices.append(choice["text"])
			dialogue_ui.show_choices(choices)
		else:
			dialogue_ui.hide_choices()
	else:
		push_warning("DialogueManager: Dialogue node has no text: " + node_id)
		end_dialogue()

func _on_dialogue_continued():
	if current_dialogue_tree == null or current_dialogue_node == null:
		end_dialogue()
		return
	
	var node = current_dialogue_tree[current_dialogue_node]
	
	if node.has("next_node"):
		current_dialogue_node = node["next_node"]
		process_dialogue_node(current_dialogue_node)
	else:
		end_dialogue()

func _on_dialogue_choice_selected(choice_index):
	if current_dialogue_tree == null or current_dialogue_node == null:
		end_dialogue()
		return
	
	var node = current_dialogue_tree[current_dialogue_node]
	
	if node.has("choices") and choice_index < node["choices"].size():
		var choice = node["choices"][choice_index]
		
		if choice.has("action") and choice["action"] != "":
			if current_npc.has_method(choice["action"]):
				current_npc.call(choice["action"])
		
		emit_signal("dialogue_choice_made", choice_index)
		
		if choice.has("next_node"):
			current_dialogue_node = choice["next_node"]
			process_dialogue_node(current_dialogue_node)
		else:
			end_dialogue()
	else:
		push_warning("DialogueManager: Invalid choice index: " + str(choice_index))
		end_dialogue()

func end_dialogue():
	is_dialogue_active = false
	
	if dialogue_ui:
		dialogue_ui.hide_dialogue()
		
		# Properly disconnect signals when dialogue ends
		if dialogue_ui.is_connected("dialogue_continued", _on_dialogue_continued):
			dialogue_ui.disconnect("dialogue_continued", _on_dialogue_continued)
		
		if dialogue_ui.is_connected("dialogue_choice_selected", _on_dialogue_choice_selected):
			dialogue_ui.disconnect("dialogue_choice_selected", _on_dialogue_choice_selected)
	
	current_dialogue_tree = null
	current_dialogue_node = null
	current_npc = null
	
	emit_signal("dialogue_ended")

func get_speed_boosts_for_level(level_name):
	if level_npc_limits.has(level_name):
		return level_npc_limits[level_name]["speed_boosts"]
	return 3

func get_heals_for_level(level_name):
	if level_npc_limits.has(level_name):
		return level_npc_limits[level_name]["heals"]
	return 3

func get_heal_count(npc):
	var npc_key = get_npc_key(npc)
	if !npc_heal_counts.has(npc_key):
		npc_heal_counts[npc_key] = 0
	return npc_heal_counts[npc_key]

func increment_heal_count(npc):
	var npc_key = get_npc_key(npc)
	if !npc_heal_counts.has(npc_key):
		npc_heal_counts[npc_key] = 0
	npc_heal_counts[npc_key] += 1

func has_met_npc(npc):
	var npc_key = get_npc_key(npc)
	return npc_meeting_history.has(npc_key) and npc_meeting_history[npc_key]

func save_dialogue_state():
	print("Dialogue state: ", npc_meeting_history)

func load_dialogue_state():
	npc_meeting_history = {}
	npc_heal_counts = {}
