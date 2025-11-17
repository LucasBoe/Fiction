extends Node

@onready var camera_handler = $"../Camera"
@onready var cursor_3d = $Cursor

func _process(delta):
	var hit_pos = get_mouse_on_y0_plane()
	if hit_pos != null:
		print("Hit on y = 0 plane at: ", hit_pos)
		var x = round(hit_pos.x - .5) + .5
		var z = round(hit_pos.z - .5) + .5
		cursor_3d.global_position = Vector3(x, .025, z)
	else:
		print("No intersection with y = 0 plane.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var hit_pos = get_mouse_on_y0_plane()
		if hit_pos != null:
			print("Hit on y = 0 plane at: ", hit_pos)
		else:
			print("No intersection with y = 0 plane.")


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
