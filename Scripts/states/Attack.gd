extends State

# Attack state for the enemy

func enter() -> void:
	var enemy = get_enemy()
	enemy.velocity = Vector2.ZERO
	
	# Start the attack
	enemy.start_attack()

func physics_process(_delta: float) -> void:
	var enemy = get_enemy()
	var player = enemy.get_player()
	
	if player == null:
		state_machine.transition_to("Idle")
		return
	
	# Face the player during attack
	var direction = enemy.global_position.direction_to(player.global_position)
	enemy.last_direction = direction
	
	# If we can attack again, do it
	if enemy.can_attack && !enemy.is_attacking:
		enemy.start_attack()

func get_next_state() -> String:
	if enemy.player == null:
		return "Idle"
	
	# Allow exiting attack state even during animation
	if !enemy.can_attack_player() and enemy.can_see_player():
		return "Chase"
		
	return ""
		
	# If player moved out of attack range but still visible
	if !enemy.can_attack_player() && enemy.can_see_player() && !enemy.is_attacking:
		return "Chase"
	if !enemy.can_attack_player() and enemy.can_see_player():
		return "Chase"
		
	return ""  # Stay in current state
