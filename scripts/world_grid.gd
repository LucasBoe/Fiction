extends GridMap

const sizeX = 12
const sizeY = 12

func _ready():
	for x in sizeX:
		for y in sizeY:
			
			var xx = x - sizeX / 2
			var yy = y - sizeY / 2
			
			var pos = Vector3i(xx, 0, yy)
			set_cell_item(pos, 0)
	
