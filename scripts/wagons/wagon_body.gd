extends StaticBody3D
class_name WagonBody

@onready var health : Health = $"../Health"

func _ready() -> void:
	
	#make collision shape active
	await get_tree().process_frame
	$WagonShape.disabled = false
	health.is_empty.connect(on_health_is_empty)
	
func on_health_is_empty():
	self.get_parent().queue_free()
