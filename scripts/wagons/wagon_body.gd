extends StaticBody3D
class_name WagonBody

@export var max_health := 200
var health : int

signal took_damage(health : int, max_healt : int)

func _ready() -> void:
	health = max_health
	
	#make collision shape active
	await get_tree().process_frame
	$WagonShape.disabled = false
	HealthBarCanvas._create_bar_for_wagon(self)

func take_damage(amount: int):
	health -= amount
	#print("Wagon took damage")
	took_damage.emit(health, max_health)

	if health <= 0:
		self.get_parent_node_3d().queue_free()
