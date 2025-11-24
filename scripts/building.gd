extends Node
class_name Building

@export var is_enemy_target = false # will be actively focused
@export var can_be_damaged_by_enemy = false # not focused but will receive damage
@export var reward_amount_base = 10

@export var display_name = ""

var health : Health
var lights : Node3D

func _ready():
	if is_enemy_target or can_be_damaged_by_enemy:
		health = $Health
		
	var lights = find_child("Lights")
	if lights != null:
		Globals.environment.set_day_signal.connect(on_set_day)
		Globals.environment.set_night_signal.connect(on_set_night)

func on_set_day():
	var lights = find_child("Lights")
	if lights != null:
		print("hide lights on ", self)
		lights.hide()

func on_set_night():
	var lights = find_child("Lights")
	if lights != null:
		print("show lights on ", self)
		lights.show()
