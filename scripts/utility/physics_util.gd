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
