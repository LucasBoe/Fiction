extends Node
class_name Building

@export var is_enemy_target = false # will be actively focused
@export var can_be_damaged_by_enemy = false # not focused but will receive damage

var health : Health

func _ready():
	if is_enemy_target or can_be_damaged_by_enemy:
		health = $Health
