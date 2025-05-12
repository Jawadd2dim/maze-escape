extends State

class_name ChaseState

var path_update_timer: Timer
var stuck_timer: Timer

func enter() -> void:
	var enemy = get_enemy()
	
	# Immediately update path when entering chase
	if enemy.player:
		enemy.set_target_position(enemy.player.global_position)
	
	# Configure path updates
	path_update_timer = Timer.new()
	path_update_timer.wait_time = 0.1  # Update 10x/sec for responsiveness
	path_update_timer.timeout.connect(
		func():
			if enemy.player:
				enemy.set_target_position(enemy.player.global_position)
	)
	enemy.add_child(path_update_timer)
	path_update_timer.start()
	
	# Add stuck timer
	stuck_timer = Timer.new()
	stuck_timer.wait_time = 5.0  # 5 seconds timeout
	stuck_timer.one_shot = true
	stuck_timer.timeout.connect(
		func(): 
			if get_enemy().navigation_agent.is_navigation_finished():
				state_machine.transition_to("Patrol")
	)
	get_enemy().add_child(stuck_timer)
	stuck_timer.start()

func exit() -> void:
	if stuck_timer and stuck_timer.is_inside_tree():
		stuck_timer.queue_free()

func physics_process(_delta: float) -> void:
	var enemy = get_enemy()
	enemy.move_along_path(enemy.chase_speed)

func get_next_state() -> String:
	var enemy = get_enemy()
	
	if !enemy.player:
		return "Idle"
		
	if enemy.can_attack_player():
		return "Attack"
		
	# Only exit chase if player is COMPLETELY lost
	if !enemy.can_see_player() and !enemy.player_detection.overlaps_body(enemy.player):
		return "Idle"
		
	return ""
