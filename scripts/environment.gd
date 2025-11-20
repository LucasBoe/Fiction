extends Node
class_name EnvironmentHolder

@onready var omni_light = $OmniLight3D
@onready var directional_light = $DirectionalLight3D
@onready var world_environment : WorldEnvironment = $WorldEnvironment

func _ready():
	Globals.environment = self

func set_day():
	omni_light.visible = false
	directional_light.shadow_enabled = true
	world_environment.environment.background_energy_multiplier = 1.0
	
func set_night():
	omni_light.visible = true
	directional_light.shadow_enabled = false
	world_environment.environment.background_energy_multiplier = 0.5
	
