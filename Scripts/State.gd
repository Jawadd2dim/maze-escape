class_name State
extends Node

var state_machine: StateMachine
var enemy: CharacterBody2D

func _ready():
	enemy = get_parent().get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func get_next_state() -> String:
	return ""

func get_enemy() -> CharacterBody2D:
	return enemy
