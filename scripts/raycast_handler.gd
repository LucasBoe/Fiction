extends Node3D
class_name RaycastHandler

@onready var camera_handler = $"../Camera"
@onready var cursor_3d = $Cursor

var currently_hovered_moveable

func _process(delta):
	
	currently_hovered_moveable = raycast_for_object(Moveable)
	
	var grid_pos = raycast_for_position_on_grid()
	if grid_pos != null:
		cursor_3d.global_position = grid_pos + Vector3(0, .025, 0)
		
	if (currently_hovered_moveable != null):
		print("hover moveable")	

func raycast_for_object(target_class_type):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var cam = camera_handler.get_current_camera()
	var origin = cam.project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if (result.size() > 0 and is_instance_of(result.collider, target_class_type)):
		return result.collider

func raycast_for_position_on_grid():
	var hit_pos = get_mouse_on_y0_plane()
	
	if hit_pos != null:
		var x = round(hit_pos.x - .5) + .5
		var z = round(hit_pos.z - .5) + .5
		return Vector3(x,0,z)

	return null	

func get_mouse_on_y0_plane():
	var camera = camera_handler.get_current_camera()
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var direction: Vector3 = camera.project_ray_normal(mouse_pos)

	# If direction.y == 0, the ray is parallel to the plane (no intersection)
	if direction.y == 0.0:
		return null

	# Solve origin.y + direction.y * t = 0  →  t = -origin.y / direction.y
	var t: float = -origin.y / direction.y

	# If t < 0, intersection is *behind* the camera → ignore
	if t < 0.0:
		return null

	var hit_pos: Vector3 = origin + direction * t
	return hit_pos
