extends Node3D

var enemies: Array[Node3D] = []


func _register_enemy(enemy: Node3D):
	enemies.append(enemy)

func _unregister_enemy(enemy: Node3D):
	enemies.erase(enemy)

func _get_enemies() -> Array[Node3D]:
	return enemies
