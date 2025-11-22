extends Enemy

@export var speed: float = 1.0
@onready var agent = %NavigationAgent3D
@onready var placement_handler = %PlacementHandler

var target_node
var target_position

func _ready():
	super._ready()
	
	while true:
		await refresh()

func refresh():
	
	#update target
	target_node = get_closest_potential_target()
	
	if target_node != null:
		target_position = target_node.global_position
	else:
		target_position = Vector3.ZERO

	agent.target_position = target_position
	
	#damage potential targets in range
	var radius = 1.5
	var objects = PhysicsUtil.boxcast_for_objects(get_world_3d().direct_space_state, global_position, Vector3.ONE * radius, [self])
	for object in objects:
		var target = object.collider
		
		var is_wagon = target is WagonBody
		var is_house = (target.get_parent() is Building and (target.get_parent() as Building).can_be_damaged_by_enemy)
		
		if is_house:
			target = target.get_parent()
		
		if is_wagon or is_house:
			target.health.take_damage(10)
			print("damage ", target, ": ", 10)
	
	await get_tree().create_timer(1).timeout

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
