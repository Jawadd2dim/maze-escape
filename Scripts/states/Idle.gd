extends State

class_name IdleState

@export var idle_duration_min: float = 1.0
@export var idle_duration_max: float = 3.0

var idle_timer: Timer
var idle_duration: float

func enter() -> void:
	var enemy = get_enemy()
	enemy.velocity = Vector2.ZERO
	enemy.update_animation(enemy.last_direction)
	
	# Create fresh timer each time to avoid scene tree issues
	if idle_timer:
		idle_timer.queue_free()
	
	idle_timer = Timer.new()
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)
	
	idle_duration = randf_range(idle_duration_min, idle_duration_max)
	idle_timer.wait_time = idle_duration
	idle_timer.start()

func exit() -> void:
	if idle_timer:
		idle_timer.stop()

func get_next_state() -> String:
	var enemy = get_enemy()
	
	# Priority 1: Player detection
	if enemy.player != null && enemy.can_see_player():
		return "Chase"
	
	# Priority 2: Timer completion
	if idle_timer.is_stopped():
		return "Patrol"
	
	return ""

func _on_idle_timer_timeout() -> void:
	print("Idle timer finished")
