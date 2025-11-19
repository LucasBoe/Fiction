extends StaticBody3D
class_name WagonBody

@export var health := 200

signal took_damage(amount: int)

func _ready() -> void:
	#make collision shape active
	await get_tree().process_frame
	$WagonShape.disabled = false
	HealthBarCanvas._create_bar_for_wagon(self)

func take_damage(amount: int):
	health -= amount
	print("Wagon took damage")
	emit_signal("took_damage", amount)

	if health <= 0:
		queue_free()
