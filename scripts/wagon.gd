extends Moveable
class_name Wagon

@onready var body = $WagonBody

@export var display_name = ""

func _ready():
	var lights = find_child("LanternLight")
	if lights != null:
		Globals.environment.set_day_signal.connect(on_set_day)
		Globals.environment.set_night_signal.connect(on_set_night)

func on_set_day():
	var lights = find_child("LanternLight")
	if lights != null:
		print("hide lights on ", self)
		lights.hide()

func on_set_night():
	var lights = find_child("LanternLight")
	if lights != null:
		print("show lights on ", self)
		lights.show()
