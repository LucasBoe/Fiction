extends Node3D

@onready var grid_root = $MeshRoot
@onready var dummy = $MeshRoot/MeshDummy

const GRID_SIZE = 18.0
const GRID_OFFSET = 0.5

var cells : Dictionary[Vector2i, Node]

func _ready():
	
	#create grid mesh instances
	for x : int in GRID_SIZE:
		for y : int in GRID_SIZE:
			var instance = dummy.duplicate()
			dummy.get_parent().add_child(instance)
			instance.global_position = grid_to_world_position(x,y)
			cells[Vector2i(x,y)] = instance
	
	dummy.visible = false
	hide_grid()
	
func refresh_blocked(blocked_cell_positions : Array):
	for position in cells:
		cells[position].visible = not blocked_cell_positions.has(position)
	
func grid_to_world_position(x : float,y : float):
	var xx : int = (-GRID_SIZE * 0.5) + x
	var yy : int = (-GRID_SIZE * 0.5) + y
	return Vector3(GRID_OFFSET + xx,0,GRID_OFFSET + yy)
	
func world_to_grid_position(world_pos: Vector3) -> Vector2i:
	var x := int(round(world_pos.x - GRID_OFFSET + GRID_SIZE * 0.5))
	var y := int(round(world_pos.z - GRID_OFFSET + GRID_SIZE * 0.5))
	return Vector2i(x, y)

func show_grid():
	grid_root.show()
	
func hide_grid():
	grid_root.hide()
