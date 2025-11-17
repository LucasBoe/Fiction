extends GridMap

const sizeX = 64
const sizeY = 64

func _ready():
	for x in sizeX:
		for y in sizeY:
			
			var xx = x - sizeX / 2
			var yy = y - sizeY / 2
			
			var pos = Vector3i(xx, 0, yy)
			
			if get_cell_item(pos) == INVALID_CELL_ITEM:
				set_cell_item(pos, 0)
	
