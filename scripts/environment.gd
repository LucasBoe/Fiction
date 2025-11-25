extends Node
class_name EnvironmentHolder

@onready var directional_light: DirectionalLight3D = $DirectionalLight3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment

@export var day_rotation := Vector3(270,-25,0)
@export var evening_rotation := Vector3(335,-25,0)
@export var night_rotation := Vector3(450,-25,0)

@export var day_energy := 1.0
@export var evening_energy := 0.7
@export var night_energy := 0.0

# Background brightness (you can tweak these in the inspector)
@export var day_background_multiplier := 1.0
@export var evening_background_multiplier := 0.75
@export var night_background_multiplier := 0.5

# How long each transition should take
@export var transition_duration := 3

signal set_day_signal
signal set_evening_signal
signal set_night_signal

var _current_tween: Tween


func _ready():
	Globals.environment = self


func _kill_tween():
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = null


func _make_tween() -> Tween:
	_kill_tween()
	_current_tween = create_tween()
	return _current_tween


func set_day():
	set_day_signal.emit()

	#directional_light.visible = true

	var tween := _make_tween()
	tween.tween_property(directional_light, 
		"rotation_degrees", 
		day_rotation, 
		transition_duration)
	
	tween.parallel().tween_property(
		directional_light, 
		"light_energy", 
		day_energy, 
		transition_duration)
		
	tween.parallel().tween_property(
		world_environment.environment,
		"background_energy_multiplier",
		day_background_multiplier,
		transition_duration
	)


func set_evening():
	set_evening_signal.emit()

	directional_light.visible = true

	var tween := _make_tween()
	
	tween.tween_property(directional_light, 
		"rotation_degrees", 
		evening_rotation, 
		transition_duration)
	
	tween.parallel().tween_property(
		directional_light,
		"light_energy",
		evening_energy,
		transition_duration)
		
	tween.parallel().tween_property(
		world_environment.environment,
		"background_energy_multiplier",
		evening_background_multiplier,
		transition_duration)


func set_night():
	set_night_signal.emit()

	# Keep it visible while we fade/rotate it out
	directional_light.visible = true

	var tween := _make_tween()
	tween.tween_property(
		directional_light, 
		"rotation_degrees", 
		night_rotation, 
		transition_duration)

	tween.parallel().tween_property(
		directional_light,
		"light_energy", 
		night_energy, 
		transition_duration)

	tween.parallel().tween_property(
		world_environment.environment,
		"background_energy_multiplier",
		night_background_multiplier,
		transition_duration)
	
	tween.finished.connect(func():
		directional_light.rotation_degrees = Vector3(0,0,0))
