extends Wagon
class_name WagonFire

@onready var area : Area3D = $Area3D
@onready var canon_mesh = $Visuals/wagon_fire_spinner

@export var damage_per_second = 1.0
@export var rotation_speed = 5.0

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body is not Enemy:
			continue
			
		var enemy = body as Enemy
		enemy.health.take_damage(damage_per_second * delta)	
	canon_mesh.rotate_y(delta * rotation_speed)
