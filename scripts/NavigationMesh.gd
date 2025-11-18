extends NavigationRegion3D

@onready var MapLoader = %MapLoader

func _ready():
	MapLoader.loaded_map.connect(_on_map_loaded)

func _on_map_loaded():
	self.bake_navigation_mesh()
	print("Navigation Region Rebuild")
