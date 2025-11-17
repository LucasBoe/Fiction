extends Node3D

@export var move_speed: float = 10.0

func _physics_process(delta: float) -> void:
	var move_dir: Vector3 = Vector3.ZERO

	# Get forward (look) and right directions from this node’s transform
	var forward: Vector3 = (-global_transform.basis.z -global_transform.basis.x).normalized()
	var right:   Vector3 = (-global_transform.basis.z +global_transform.basis.x).normalized()

	# Optional: comment these out if you WANT vertical movement when looking up/down
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	# Input
	if Input.is_action_pressed("move_forward"):
		move_dir += forward
	if Input.is_action_pressed("move_back"):
		move_dir -= forward
	if Input.is_action_pressed("move_left"):
		move_dir -= right
	if Input.is_action_pressed("move_right"):
		move_dir += right

	# Apply movement
	if move_dir != Vector3.ZERO:
		move_dir = move_dir.normalized()
		global_position += move_dir * move_speed * delta
