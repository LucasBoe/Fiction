extends Node3D

@onready var grid_root = $MeshRoot
@onready var dummy = $MeshRoot/MeshDummy

func _ready():
	
	#create grid mesh instances
	var gridSize = 24.0
	for x in gridSize:
		for y in gridSize:
			
			var xx = -gridSize * .5 + x
			var yy = -gridSize * .5 + y
			
			var instance = dummy.duplicate()
			dummy.get_parent().add_child(instance)
			instance.global_position = Vector3(.5 + xx,0,.5 + yy)
	
	dummy.visible = false
	hide_grid()
	
func show_grid():
	grid_root.show()
	
func hide_grid():
	grid_root.hide()
	
