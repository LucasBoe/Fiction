extends Node3D

@onready var cursor_3d = $Cursor

var currently_hovered_moveable
var currently_dragging : Moveable
var pickup_offset : Vector3
var pickup_location : Vector3

var are_modifications_allowed = false

func set_modifications_allowed(allowed):
	are_modifications_allowed = allowed
	cursor_3d.visible = allowed
	
	if not allowed and currently_dragging:
		currently_dragging.global_position = pickup_location
		currently_dragging = null

func _process(delta):
	
	if not are_modifications_allowed:
		return
	
	var space_state = get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var cam = Globals.current_camera
	
	currently_hovered_moveable = PhysicsUtil.raycast_for_all_and_find(space_state, mouse_pos, cam, Moveable)
	
	var raw_pos = get_mouse_on_y0_plane()
	var grid_pos = raycast_for_position_on_grid()
	if grid_pos != null:
		cursor_3d.global_position = grid_pos + Vector3(0, .025, 0)
	
	cursor_3d.visible = currently_dragging == null
	
	var lmb_pressed = Input.is_mouse_button_pressed(1)
	
	if currently_dragging:
			
		var grid_size = currently_dragging.get_rotated_grid_size()
		var size = Vector3(grid_size.x - .1, 1, grid_size.y - .1)
		var check_pos : Vector3 = (raw_pos + pickup_offset)
		var check_offset = - Vector3(grid_size.x / 2.0, 0, grid_size.y / 2.0)
		
		var exclude = PhysicsUtil.collect_all_collision_rids(currently_dragging)
		var count = PhysicsUtil.boxcast_for_objects(space_state, check_pos, size, exclude).size()
		var obstructed = count > 0
		
		if not obstructed:
			currently_dragging.global_position = grid_pos + pickup_offset
		else:
			currently_dragging.global_position = raw_pos + pickup_offset
		
		DebugDraw3D.draw_box(check_pos + check_offset, Quaternion.IDENTITY,size, Color.RED if obstructed else Color.GREEN)
		
		if Input.is_action_just_pressed("rotate_dragging"):
			pickup_offset = Vector3(pickup_offset.z, pickup_offset.y, pickup_offset.x)
			currently_dragging.rotate_step(90)
			var rot = deg_to_rad(currently_dragging.rotation_in_degrees)
			currently_dragging.rotation = Vector3(0,rot,0)
			
		
		if not lmb_pressed:
			
			if obstructed:
				currently_dragging.global_position = pickup_location
				
			JuiceUtil.apply_juice_tween(currently_dragging, Tween.TransitionType.TRANS_BOUNCE)
			currently_dragging = null
			
	elif currently_hovered_moveable and lmb_pressed:
		pickup_location = currently_hovered_moveable.global_position
		pickup_offset = currently_hovered_moveable.global_position - grid_pos
		currently_dragging = currently_hovered_moveable
		JuiceUtil.apply_juice_tween(currently_dragging, Tween.TransitionType.TRANS_BOUNCE)

func raycast_for_position_on_grid():
	var hit_pos = get_mouse_on_y0_plane()
	
	if hit_pos != null:
		var x = round(hit_pos.x - .5) + .5
		var z = round(hit_pos.z - .5) + .5
		return Vector3(x,0,z)

	return null	

func get_mouse_on_y0_plane():
	var camera = Globals.current_camera
	
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
