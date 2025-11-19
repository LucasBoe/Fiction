extends Node3D

@onready var mesh: MeshInstance3D = $Visualization

var _target: Node3D
var _target_position: Vector3
var _speed: float = 5.0
var _damage : int

var _start_pos: Vector3
var _distance_travelled := 0.0
var _total_distance := 1.0
var _base_height := .3
var _moving := false

func _ready() -> void:
	$Area3D.enemy_damaged.connect(_on_enemy_damaged)

func _on_enemy_damaged(enemy : Enemy):
	enemy.take_damage(_damage)
	self.queue_free()

func _set_target(speed: float, target: Node3D, damage : int) -> void:
	_target = target
	_speed = speed
	_damage = damage

	_start_pos = global_position
	_distance_travelled = 0.0

	if not is_instance_valid(_target):
		_moving = false
		return

	# Calculate horizontal distance (Z is up)
	var start_h := Vector3(_start_pos.x, _start_pos.y, 0.0)
	var end_h := Vector3(_target.global_position.x, _target.global_position.y, 0.0)
	_total_distance = start_h.distance_to(end_h)

	if _total_distance <= 0.001 or _speed <= 0:
		_moving = false
		return

	# Slower speed -> higher arc
	_base_height = max(0.5, (_total_distance / _speed) * 5.0)

	_moving = true



func _physics_process(delta: float) -> void:
	if not _moving:
		queue_free()

	# Move horizontally based on speed
	_distance_travelled += _speed * delta
	var t: float = clamp(_distance_travelled / _total_distance, 0.0, 1.0)

	if t >= 1.0:
		t = 1.0
		_moving = false

	if is_instance_valid(_target):
		_target_position = _target.global_position

	# Linear movement along the path
	var next_pos := _start_pos.lerp(_target_position, t)

	# Parabolic arc (Z up or Y up depending on engine settings — you used Y here)
	var arc: float = 1.5 * t * (1.0 - t)
	next_pos.y += arc * _base_height

	# Calculate direction BEFORE we update position
	var direction := -(next_pos - global_position).normalized()

	# Move projectile
	global_position = next_pos

	# Rotate the mesh to face the movement direction
	if direction.length() > 0.001:
		mesh.look_at(global_position + direction, Vector3.UP)
