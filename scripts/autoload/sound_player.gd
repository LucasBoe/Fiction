extends Node3D

@onready var ui_text_beep = $UiTextBeep
@onready var ui_click = $UiClick

@onready var wagon_pick_up = $WagonPickUp
@onready var wagon_place = $WagonPlace

func play(audio : AudioStreamPlayer, random_pitch_scale = .2):
	apply_random_pitch_scale(audio, random_pitch_scale)
	audio.play()

func play3D(audio : AudioStreamPlayer3D, position, random_pitch_scale = .2):
	apply_random_pitch_scale(audio, random_pitch_scale)
	audio.global_position = position
	audio.play()

func apply_random_pitch_scale(audio, random_pitch_scale):
	audio.pitch_scale = .9 - random_pitch_scale / 2.0 + randf() * random_pitch_scale
