extends NavigationRegion3D

@onready var MapLoader = %MapLoader
signal baked_navigation

func _ready():
	MapLoader.loaded_map.connect(_on_map_loaded)

func _on_map_loaded():
	self.bake_navigation_mesh()
	emit_signal("baked_navigation")
	print("Navigation Region Rebuild")
