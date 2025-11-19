extends StaticBody3D
class_name WagonBody

@export var health := 200

func _ready() -> void:
	#make collision shape active
	await get_tree().process_frame
	$WagonShape.disabled = false

func take_damage(amount: int):
	health -= amount
	print("Barricade HP:", health)

	if health <= 0:
		queue_free()
