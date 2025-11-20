extends Node3D
class_name Health

@export var max_health = 100
@export var is_enemy = false
var current_health

signal took_damage(amount : int)
signal health_changed(health : Health)

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	took_damage.emit(amount)
	health_changed.emit(self)
