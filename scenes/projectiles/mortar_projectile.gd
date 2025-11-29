extends Node3D

@onready var mesh: MeshInstance3D = $Visualization

var _target: Node3D
var _target_position: Vector3
var _speed: float = 5.0
var _damage: int
var _impact_range: float

var _start_pos: Vector3
var _distance_travelled := 0.0
var _total_distance := 1.0
var _base_height := 0.2


func _set_target(speed: float, target: Node3D, damage: int, range) -> void:
	_target = target
	_speed = speed
	_damage = damage
	_impact_range = range

	_start_pos = global_position
	_distance_travelled = 0.0

	if not is_instance_valid(_target):
		queue_free()
		return

	_target_position = _target.global_position

	_total_distance = _start_pos.distance_to(_target_position)
	if _total_distance <= 0.001:
		_total_distance = 0.001

	# Slower speed -> higher arc
	_base_height = max(0.5, (_total_distance / _speed) * 5.0)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return

	_distance_travelled += _speed * delta
	var t: float = clamp(_distance_travelled / _total_distance, 0.0, 1.0)

	if t >= 1.0:
		var targets := get_enemies_in_range(_impact_range)
		for enemy in targets:
			if is_instance_valid(enemy):
				enemy.health.take_damage(_damage)

		queue_free()
		return

	# Move along the line from start -> target
	var next_pos := _start_pos.lerp(_target_position, t)

	# Parabolic arc
	var arc :=  t * (1.0 - t)
	next_pos.y += arc * _base_height

	global_position = next_pos


func get_enemies_in_range(range: float) -> Array[Node3D]:
	var enemies: Array[Node3D] = EntityHandler._get_enemies()
	var result: Array[Node3D] = []

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var dist := global_position.distance_to(enemy.global_position)
		if dist <= range:
			result.append(enemy)

	return result
