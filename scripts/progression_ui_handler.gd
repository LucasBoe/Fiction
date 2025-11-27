extends CanvasLayer

@onready var root_control = $PopupRoot
@onready var name_label = $PopupRoot/MarginContainer/Root/MarginContainer/VBoxContainer/NameLabel

func _ready():
	await get_tree().process_frame
	Globals.map_loader.loaded_map.connect(on_loaded_map)
	root_control.visible = false
	
func on_loaded_map():
	await get_tree().create_timer(1).timeout
	var name = Globals.map_loader.currently_loaded_map.display_name
	name_label.text = name
	
	root_control.visible = true
	await fade_in(1)	
	await get_tree().create_timer(2).timeout
	await fade_out(2)
	
	root_control.visible = false

func fade_in(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(root_control, "modulate:a", 1.0, duration)
	await tween.finished 


func fade_out(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(root_control, "modulate:a", 0.0, duration)
	await tween.finished     
