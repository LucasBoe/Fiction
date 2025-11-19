extends Node3D
class_name RaycastHandler

@onready var camera_handler = $"../Camera"
@onready var cursor_3d = $Cursor

var currently_hovered_moveable
var currently_dragging : Moveable
var pickup_offset : Vector3
var pickup_location : Vector3

func _process(delta):
	
	var space_state = get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var cam = camera_handler.get_current_camera()
	
	currently_hovered_moveable = PhysicsUtil.raycast_for_object(space_state, mouse_pos, cam, Moveable)
	
	var raw_pos = get_mouse_on_y0_plane()
	var grid_pos = raycast_for_position_on_grid()
	if grid_pos != null:
		cursor_3d.global_position = grid_pos + Vector3(0, .025, 0)
	
	cursor_3d.visible = currently_dragging == null
	
	var lmb_pressed = Input.is_mouse_button_pressed(1)
	
	if currently_dragging:
			
		var size = Vector3(currently_dragging.grid_size.x, 1, currently_dragging.grid_size.y)
		var check_pos : Vector3 = (grid_pos + pickup_offset)
		var check_offset = - Vector3(currently_dragging.grid_size.x / 2.0, 0, currently_dragging.grid_size.y / 2.0)
		
		var count = PhysicsUtil.boxcast_for_objects(space_state, check_pos, size).size()
		var obstructed = count > 1
		
		if not obstructed:
			currently_dragging.global_position = grid_pos + pickup_offset
		else:
			currently_dragging.global_position = raw_pos + pickup_offset
		
		#DebugDraw3D.draw_box(check_pos + check_offset, Quaternion.IDENTITY,size, Color.RED if obstructed else Color.GREEN)
		
		if not lmb_pressed:
			
			if obstructed:
				currently_dragging.global_position = pickup_location
				
			currently_dragging = null
			
	elif currently_hovered_moveable and lmb_pressed:
		pickup_location = currently_hovered_moveable.global_position
		pickup_offset = currently_hovered_moveable.global_position - grid_pos
		currently_dragging = currently_hovered_moveable

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
