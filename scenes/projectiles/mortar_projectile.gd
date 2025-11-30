extends Node3D

@onready var mesh: MeshInstance3D = $Visualization
@onready var particles: GPUParticles3D = $Particles
@onready var impact: GPUParticles3D = $Impact

var _target_position: Vector3
var _speed: float = 5.0
var _damage: int
var _impact_range: float

var _start_pos: Vector3
var _distance_travelled := 0.0
var _total_distance := 1.0
var _base_height := 0.2

var _landed = false


func _set_target(speed: float, target_position: Vector3, damage: int, range) -> void:
	_speed = speed
	_damage = damage
	_impact_range = range
	_start_pos = global_position
	_distance_travelled = 0.0

	_target_position = Vector3(target_position.x, 0, target_position.z)

	_total_distance = _start_pos.distance_to(_target_position)
	if _total_distance <= 0.001:
		_total_distance = 0.001

	# Slower speed -> higher arc
	_base_height = max(0.5, (_total_distance / _speed) * 5.0)


func _physics_process(delta: float) -> void:
	
	if _landed:
		return
	
	_distance_travelled += _speed * delta
	var t: float = clamp(_distance_travelled / _total_distance, 0.0, 1.0)

	if t >= 1.0:
		rotation = Vector3.ZERO

		var targets = get_enemies_in_range(_impact_range)
		for enemy in targets:
			if is_instance_valid(enemy):
				enemy.health.take_damage(_damage)
				enemy.set_burning()
		
		impact.emitting = true
		JuiceUtil.apply_juice_tween(self, Tween.TransitionType.TRANS_BOUNCE)
		SoundPlayer.play3D(SoundPlayer.mortar_impact, global_position)
		_landed = true
		await get_tree().create_timer(.4).timeout
		queue_free()
		return

	# Move along the line from start -> target
	var next_pos := _start_pos.lerp(_target_position, t)

	# Parabolic arc
	var arc :=  t * (1.0 - t)
	next_pos.y += arc * _base_height
	
	
	# Calculate direction BEFORE we update position
	var direction := -(next_pos - global_position).normalized()

	# Move projectile
	global_position = next_pos

	# Rotate the mesh to face the movement direction
	if direction.length() > 0.001:
		look_at(global_position + direction, Vector3.UP)


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
