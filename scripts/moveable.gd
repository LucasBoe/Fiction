extends StaticBody3D
class_name Moveable

@export var grid_size : Vector2i

var rotation_in_degrees = 0

func rotate_step(degrees):
	rotation_in_degrees += degrees
	
	while rotation_in_degrees >= 180:
		rotation_in_degrees -= 360

func get_rotated_grid_size():
	if (abs(rotation_in_degrees) == 90):
		return Vector2i(grid_size.y, grid_size.x)
	else:
		return grid_size
