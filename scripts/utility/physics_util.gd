extends RefCounted
class_name PhysicsUtil

## Returns all colliders inside an axis-aligned box in world space.
## - origin: any Node3D in the same World3D (usually `self`)
## - center: world position of the box center
## - size: full width/height/depth (not half-extents)
static func boxcast_for_objects(
	space_state,
	center: Vector3,
	size: Vector3,
	exclude = null,
	collision_mask: int = 0xFFFFFFFF,
	max_results: int = 32
) -> Array[Dictionary]:

	# Safety: avoid invalid boxes
	if size.x <= 0.0 or size.y <= 0.0 or size.z <= 0.0:
		return []

	var box := BoxShape3D.new()
	box.size = size   # full size, not half-extents

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = box
	params.transform = Transform3D(Basis(), center)  # axis-aligned box at `center`
	params.collision_mask = collision_mask
	params.collide_with_bodies = true
	params.collide_with_areas = true
	params.exclude = exclude
	
	# Returns Array[Dictionary] with keys: "collider", "rid", "shape", "collider_id"
	return space_state.intersect_shape(params, max_results)

static  func raycast_for_object(space_state, mouse_pos, cam, target_class_type):
	var origin = cam.project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	
	if (result.size() > 0 and is_instance_of(result.collider, target_class_type)):
		return result.collider
		
static func raycast_for_all_and_find(space_state, mouse_pos, cam, target_class_type):
	var origin = cam.project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * 100.0

	var exclude: Array = []

	for i in 8:
		var query := PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		query.exclude = exclude  # can be colliders or RIDs; both are supported :contentReference[oaicite:3]{index=3}

		var result: Dictionary = space_state.intersect_ray(query)
		if result.is_empty():
			return null

		# Check class
		if is_instance_of(result.collider, target_class_type):
			return result.collider

		# Exclude this collider for the next iteration
		if not exclude.has(result.collider):
			exclude.append(result.collider)

	return null
	
static func collect_all_collision_rids(root) -> Array:
	var exclude: Array = []
	_collect_collision_rids(root, exclude)
	return exclude
	
static func _collect_collision_rids(root: Node, into: Array) -> void:
	if root is CollisionObject3D: # PhysicsBody3D, Area3D, etc.
		into.append(root.get_rid())

	for child in root.get_children():
		_collect_collision_rids(child, into)
