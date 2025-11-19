extends CharacterBody3D
class_name Enemy

@export var health = 2

func _damage(amount: int):
	health -= amount
	_check_for_death()

func _check_for_death():
	if health <= 0 :
		self.queue_free()
