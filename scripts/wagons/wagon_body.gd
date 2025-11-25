extends StaticBody3D
class_name WagonBody

@onready var health : Health = $"../Health"
@onready var destroyedWagon = preload("res://scenes/wagons/wagon_1x2_debris.tscn")

func _ready() -> void:
	
	#make collision shape active
	await get_tree().process_frame
	$WagonShape.disabled = false
	health.is_empty.connect(on_health_is_empty)
	
func on_health_is_empty():
	var instance = destroyedWagon.instantiate() as Node3D
	instance.global_transform = global_transform
	get_tree().root.add_child(instance)
	
	self.get_parent().queue_free()
