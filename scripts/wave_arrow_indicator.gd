extends Node3D
class_name ArrowIndicator

const pulse_speed = 4.0
const pulse_amount = 0.15

const base_scale = Vector3(1.0, 1.0, 1.0)

func _ready() -> void:
	look_at(Vector3(0,global_position.y,0))

func _process(delta):
	var pulse = sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * pulse_amount
	scale = base_scale * (1.0 + pulse)
