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
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action("kill_all"):
			for e in enemies:
				if is_instance_valid(e):
					e.queue_free()
			enemies.clear()
			all_enemies_unregistered.emit()
