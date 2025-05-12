extends Area2D

@export_file("*.tscn") var next_scene: String
@export var cooldown: float = 1.0
@export var level_name: String = "Level 1"
@export var transition_scene: PackedScene

@onready var collision := $CollisionShape2D
@onready var animation := $AnimatedSprite2D

var can_trigger: bool = true

func _ready():
	body_entered.connect(_on_body_entered)
	animation.play("idle")
		
func _on_body_entered(body):
	if can_trigger and body.is_in_group("player"):
		can_trigger = false
		collision.set_deferred("disabled", true)
		
		var current_level = int(get_tree().current_scene.scene_file_path.get_file().split("_")[1])
		
		if current_level == 5:
			GameManager.load_level(current_level, true)
			await get_tree().create_timer(2.0).timeout
			
			# Directly show victory screen
			GameManager.show_victory_screen()
		else:
			GameManager.load_level(current_level, true)
			await get_tree().create_timer(2.0).timeout
			GameManager.load_level(current_level + 1, false)
