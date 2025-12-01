extends Wagon
class_name Wagon_Spikes

@onready var area = $Area3D

@export var attack_speed = 2.0
const damage_per_attack = 0.6

var t = 0

func _ready() -> void:
	super._ready()
	damage_loop()
	
func damage_loop():
	while (true):
		await get_tree().create_timer(1.0 / attack_speed).timeout
		try_make_damage()
		
func try_make_damage():
	for body in area.get_overlapping_bodies():
		if body is Enemy:
			print_debug("do ", damage_per_attack ," damage to enemy ", body)
			body.health.take_damage(damage_per_attack)
			
