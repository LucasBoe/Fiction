extends Node3D

#2D
@onready var ui_text_beep = $UiTextBeep
@onready var ui_click = $UiClick
@onready var treasure = $Treasure

#3D
@onready var wagon_pick_up = $WagonPickUp
@onready var wagon_place = $WagonPlace
@onready var wagon_destroy = $WagonDestroy
@onready var arrow_shot = $ArrowShot
@onready var mortar_shoot = $MortarShot
@onready var mortar_impact = $MortarImpact
@onready var ghost_talk = $GhostTalk
@onready var enemy_attack = $EnemyAttack
@onready var coin = $Coin
@onready var building_destroy = $BuildingDestroy

@onready var ghost_talks = ["res://audio/sounds/ghost_talk_1.wav", "res://audio/sounds/ghost_talk_2.wav", "res://audio/sounds/ghost_talk_3.wav", "res://audio/sounds/ghost_talk_4.wav", "res://audio/sounds/ghost_talk_5.wav", "res://audio/sounds/ghost_talk_6.wav"]

func play(audio : AudioStreamPlayer, random_pitch_scale = .2):
	apply_random_pitch_scale(audio, random_pitch_scale)
	audio.play()

func play3D(audio : AudioStreamPlayer3D, position, random_pitch_scale = .2):
	apply_random_pitch_scale(audio, random_pitch_scale)
	audio.global_position = position
	audio.play()

func apply_random_pitch_scale(audio, random_pitch_scale):
	audio.pitch_scale = .9 - random_pitch_scale / 2.0 + randf() * random_pitch_scale

func play_ghost_talk(position):
	var stream = load(ghost_talks.pick_random())
	ghost_talk.stream = stream
	play3D(ghost_talk, position)
