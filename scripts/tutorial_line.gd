extends HBoxContainer
class_name TutorialLine

@onready var box_unchecked_tex = preload("res://ui/travel/location_undone.png")
@onready var box_checked_tex = preload("res://ui/travel/location_done.png")

@onready var box_texture_rect = $TextureRect
@onready var text_label = $Label

var is_done = false

func _ready():
	box_texture_rect.texture = box_unchecked_tex
	
func set_done():
	if is_done:
		return
		
	is_done = true
	SoundPlayer.play(SoundPlayer.tutorial_done)
	box_texture_rect.texture = box_checked_tex
