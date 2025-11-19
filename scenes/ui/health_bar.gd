extends Control
class_name HealthBar

func _connect_to_signal(_signal : Signal):
	#_signal.connect(_on_took_damage())
	return

func _on_took_damage():
	_update_healthbar()

func _update_healthbar():
	print("Updated Healthbar")
	return
