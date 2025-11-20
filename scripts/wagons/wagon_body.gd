extends StaticBody3D
class_name WagonBody

@onready var health : Health = $"../Health"

func _ready() -> void:
	
	#make collision shape active
	await get_tree().process_frame
	$WagonShape.disabled = false
	HealthBarCanvas._create_bar_for(health)
	health.took_damage.connect(_on_took_damage)
	
func _on_took_damage():
	if health.current_health <= 0:
		self.get_parent_node_3d().queue_free()
