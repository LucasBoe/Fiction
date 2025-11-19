extends CanvasLayer

@export var camera_path: NodePath
@export var healthbar_wagon: PackedScene = preload("res://scenes/ui/Healthbar_Wagons.tscn")

@onready var camera: Camera3D = %MainCamera

var wagon_to_healthbar: = {}  
