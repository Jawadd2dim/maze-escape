extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var rotation_speed: float = 5.0  # Adjust in inspector

var player_in_range: bool = false
var current_player: Node2D = null

func update_facing_direction(player_position: Vector2):
	var target_direction = (player_position - global_position).normalized()
	var current_direction = Vector2(
		cos(animated_sprite.rotation),
		sin(animated_sprite.rotation)
	)
	var _new_direction = current_direction.lerp(target_direction, rotation_speed * get_process_delta_time())

	var direction = (player_position - global_position).normalized()
	
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("Idle_Right" if direction.x > 0 else "Idle_Left")
	else:
		animated_sprite.play("Idle_Front" if direction.y > 0 else "Idle_Back")

# NPC Properties
@export var display_name: String = "Gronak"

# Healing settings
@export var heal_amount: int = 30
@export var max_heals: int = 3

# Speed boost settings
@export var speed_boost_multiplier: float = 1.5
@export var speed_boost_duration: float = 10.0
@export var max_speed_boosts: int = 3

# Dialogue
var speed_boosts_used = 0
var heals_used = 0

# Dictionary containing all dialogue for this NPC
var dialogue_tree = {
	"start": {
		"text": "Greetings, traveler! What can I do for you?",
		"first_meeting": {
			"text": "Greetings, traveler! I am Gronak, guardian of this maze. You look weary from your journey.",
			"next_node": "first_meeting_options"
		},
		"next_node": "returning_options"
	},
	"first_meeting_options": {
		"text": "I can offer you assistance if you need it. What would you like?",
		"choices": [
			{
				"text": "I need healing",
				"next_node": "offer_healing"
			},
			{
				"text": "Can you help me move faster?",
				"next_node": "offer_speed"
			},
			{
				"text": "Who are you again?",
				"next_node": "explain_self"
			},
			{
				"text": "Nothing, thanks",
				"next_node": "goodbye"
			}
		]
	},
	"returning_options": {
		"text": "What can I help you with this time?",
		"choices": [
			{
				"text": "I need healing",
				"next_node": "offer_healing"
			},
			{
				"text": "Can you help me move faster?",
				"next_node": "offer_speed"
			},
			{
				"text": "Nothing, thanks",
				"next_node": "goodbye"
			}
		]
	},
	"offer_healing": {
		"text": "You look injured. Let me help restore your health.",
		"choices": [
			{
				"text": "Yes, please heal me",
				"action": "heal_player",
				"next_node": "after_healing"
			},
			{
				"text": "No thanks",
				"next_node": "no_healing"
			}
		]
	},
	"after_healing": {
		"text": "There you go! Your wounds are healing nicely. Is there anything else you need?",
		"choices": [
			{
				"text": "Can you help me move faster?",
				"next_node": "offer_speed"
			},
			{
				"text": "No, that's all",
				"next_node": "goodbye"
			}
		]
	},
	"no_healing": {
		"text": "As you wish. The offer stands if you change your mind.",
		"next_node": "returning_options"
	},
	"offer_speed": {
		"text": "I can cast a spell to increase your speed temporarily. Would you like me to?",
		"choices": [
			{
				"text": "Yes, make me faster",
				"action": "apply_speed_boost",
				"next_node": "after_speed"
			},
			{
				"text": "No thanks",
				"next_node": "no_speed"
			}
		]
	},
	"no_speed_boosts": {
		"text": "I'm sorry, but I've used all my energy and cannot cast the speed spell anymore.",
		"next_node": "returning_options"
	},
	"no_healing_left": {
		"text": "I'm sorry, but I've used all my healing energy.",
		"next_node": "returning_options"
	},
	"after_speed": {
		"text": "The spell is cast! You'll move faster for a short time. Use it wisely!",
		"next_node": "goodbye"
	},
	"no_speed": {
		"text": "As you wish. The offer stands if you change your mind.",
		"next_node": "returning_options"
	},
	"explain_self": {
		"text": "I am Gronak, an orc healer. I was once a fearsome warrior, but now I dedicate my life to helping travelers like yourself navigate these dangerous mazes.",
		"next_node": "returning_options"
	},
	"goodbye": {
		"text": "Farewell for now. Be careful as you journey deeper into the maze. I'll be here if you need me again."
	}
}

func _ready():
	animated_sprite.play("Idle_Front")  # Default animation
	add_to_group("npc")

func _process(_delta):
	if player_in_range and current_player:
		update_facing_direction(current_player.global_position)

func interact():
	var speed_boosts_remaining = max_speed_boosts - speed_boosts_used
	var heals_remaining = max_heals - heals_used
	
	if speed_boosts_remaining <= 0:
		dialogue_tree["offer_speed"] = dialogue_tree["no_speed_boosts"]
	else:
		dialogue_tree["offer_speed"]["text"] = "I can cast a spell to increase your speed temporarily. I can do this %d more time%s. Would you like me to?" % [speed_boosts_remaining, "s" if speed_boosts_remaining != 1 else ""]
	
	if heals_remaining <= 0:
		dialogue_tree["offer_healing"] = dialogue_tree["no_healing_left"]
	else:
		dialogue_tree["offer_healing"]["text"] = "You look injured. I can heal you %d more time%s. Would you like me to help?" % [heals_remaining, "s" if heals_remaining != 1 else ""]
	
	var has_met = DialogueManager.has_met_npc(self)
	var starting_node = "start"
	DialogueManager.start_dialogue(self, dialogue_tree, starting_node)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		update_facing_direction(player.global_position)

func heal_player():
	if heals_used < max_heals:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("heal"):
			player.heal(heal_amount)
			heals_used += 1
			#print("Orc healed player for ", heal_amount, " health")

func apply_speed_boost():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_speed_boost"):
		if speed_boosts_used < max_speed_boosts:
			player.apply_speed_boost(speed_boost_multiplier, speed_boost_duration)
			speed_boosts_used += 1
			print("Orc applied speed boost to player. Boosts used: ", speed_boosts_used, "/", max_speed_boosts)
		else:
			print("No more speed boosts available")

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		current_player = body
		update_facing_direction(body.global_position)

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		current_player = null
		animated_sprite.play("Idle_Front")
