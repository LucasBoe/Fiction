extends GridMap

const sizeX = 24
const sizeY = 24

func _ready():
	for x in sizeX:
		for y in sizeY:
			var pos = Vector3i(x - sizeX / 2, 0, y - sizeY / 2)
			set_cell_item(pos, 0)
	
