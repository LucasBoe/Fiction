extends Node3D
class_name Health

@export var max_health = 100
@export var is_enemy = false
var current_health

signal took_damage(amount : int)
signal health_changed(health : Health)
signal is_empty

func _ready():
	current_health = max_health
	HealthBarCanvas._create_bar_for(self)

func take_damage(amount: int):
	current_health -= amount
	took_damage.emit(amount)
	health_changed.emit(self)
	
	if current_health <= 0:
		is_empty.emit()
