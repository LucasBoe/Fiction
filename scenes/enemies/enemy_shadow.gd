extends CharacterBody3D

@export var speed: float = 5.0
@onready var agent = %NavigationAgent3D

func _ready():
	var target = Vector3(10, 0, 10)
	agent.target_position = target

func _physics_process(delta: float) -> void:
	# If there's no path or we're already there, stop
	if not agent.is_navigation_finished():
		var next_point: Vector3 = agent.get_next_path_position()
		var direction: Vector3 = (next_point - global_position)
		direction.y = 0.0  # keep movement flat on the ground

		if direction.length() > 0.01:
			direction = direction.normalized()
			velocity = direction * speed
		else:
			velocity = Vector3.ZERO
	else:
		velocity = Vector3.ZERO

	move_and_slide()
