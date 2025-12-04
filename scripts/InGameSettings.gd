extends Control

@onready var music_slider: HSlider = $Settings/HBoxContainer_Music/HSlider
@onready var sfx_slider: HSlider = $Settings/HBoxContainer_Sounds/HSlider

const MUSIC_BUS_NAME := "Music"
const SFX_BUS_NAME := "SFX"

func _on_button_pressed() -> void:
	$Settings.visible = not $Settings.visible
	if $Settings.visible:
		$TextureRect.show()
	else: 
		$TextureRect.hide()
	
	var music_bus := AudioServer.get_bus_index(MUSIC_BUS_NAME)
	var sfx_bus := AudioServer.get_bus_index(SFX_BUS_NAME)

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

func _on_exit_pressed():
	FadeEffectCanvas.fade_in_out()
	await await get_tree().create_timer(1).timeout
	get_tree().quit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		_on_button_pressed()
	
	$FPS_Label.text = str(Engine.get_frames_per_second())

func _ready() -> void:
	Globals.in_game_menu = self
	
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

	# Initialize sliders from current bus volumes
	var music_bus := AudioServer.get_bus_index(MUSIC_BUS_NAME)
	var sfx_bus := AudioServer.get_bus_index(SFX_BUS_NAME)

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	

func _on_music_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_v_sync_toggled(toggled_on: bool) -> void:
	if toggled_on: 
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
