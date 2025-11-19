extends Node

var enemies: Array[Node3D] = []

signal all_enemies_unregistered

func _register_enemy(enemy: Node3D):
	enemies.append(enemy)

func _unregister_enemy(enemy: Node3D):
	enemies.erase(enemy)
	
	if enemies.is_empty():
		all_enemies_unregistered.emit()

func _get_enemies() -> Array[Node3D]:
	return enemies
	
func any_enemies_left():
	return enemies.size() > 0
