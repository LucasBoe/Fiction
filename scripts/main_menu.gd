extends CanvasLayer

@onready var start_game_button = $Control/HBoxContainer/VSplitContainer/VBoxContainer/Button
@onready var music_slider: HSlider = $Control/HBoxContainer/VSplitContainer/VBoxContainer/HBoxContainer_Music/HSlider
@onready var sfx_slider: HSlider = $Control/HBoxContainer/VSplitContainer/VBoxContainer/HBoxContainer_Sounds/HSlider

const MUSIC_BUS_NAME := "Music"
const SFX_BUS_NAME := "SFX"

signal started_game_signal

func _ready() -> void:
	# Update Game Version
	var version = ProjectSettings.get_setting("application/config/version")
	$Control/VersionLabel.text = "Version: %s" % version

	# Connect slider signals (if not already connected in the editor)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

	# Initialize sliders from current bus volumes
	var music_bus := AudioServer.get_bus_index(MUSIC_BUS_NAME)
	var sfx_bus := AudioServer.get_bus_index(SFX_BUS_NAME)

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	show()
	await start_game_button.pressed
	started_game_signal.emit()
	hide()
	queue_free()


func _on_music_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
