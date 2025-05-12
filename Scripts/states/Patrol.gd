extends State

class_name PatrolState

var current_patrol_point: Vector2
var reached_patrol_point: bool = false
var wait_timer: Timer

func enter() -> void:
	var enemy = get_enemy()
	current_patrol_point = enemy.set_random_patrol_point()
	enemy.set_target_position(current_patrol_point)
	reached_patrol_point = false
	
	# Create fresh timer
	if wait_timer:
		wait_timer.queue_free()
	
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	add_child(wait_timer)

func physics_process(_delta: float) -> void:
	var enemy = get_enemy()
	
	if enemy.navigation_agent.is_navigation_finished() && !reached_patrol_point:
		reached_patrol_point = true
		enemy.velocity = Vector2.ZERO
		wait_timer.wait_time = enemy.patrol_wait_time
		wait_timer.start()

	elif !reached_patrol_point:
		enemy.move_along_path(enemy.move_speed)

func get_next_state() -> String:
	var enemy = get_enemy()
	
	# Priority 1: Player detection
	if enemy.player != null && enemy.can_see_player():
		return "Chase"
	
	# Priority 2: Wait timer completion
	if reached_patrol_point && wait_timer.is_stopped():
		return "Idle"
	
	return ""

func exit() -> void:
	if wait_timer:
		wait_timer.stop()
