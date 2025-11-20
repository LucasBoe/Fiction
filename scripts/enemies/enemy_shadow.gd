extends Enemy

@export var speed: float = 1.0
@onready var agent = %NavigationAgent3D
@onready var placement_handler = %PlacementHandler

func _ready():
	EntityHandler._register_enemy(self)
	
	var target = Vector3(0, 0, 0)
	agent.target_position = target

func _physics_process(delta: float) -> void:
	
	var target = Globals.placement_handler.get_next_potential_target(global_position)
	
	if target != null:
		target = target.global_position
	else:
		target = Vector3.ZERO

	agent.target_position = target
	
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
