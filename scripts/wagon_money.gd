extends Wagon
class_name WagonMoney

var y_pos_min = 0.36
var y_pos_max = 0.864

var y_scale_min = 0.5
var y_scale_max = 1.0

var xz_scale_min = 0.7
var xz_scale_max = 1.0

@export var money_amount_lerp_curve : Curve
@onready var money_mesh = $Money

func _ready():
	MoneyHandler.money_changed_signal.connect(on_money_changed)
	
func on_money_changed(amount):
	var l = money_amount_lerp_curve.sample(amount)
	
	var pos_before = money_mesh.position
	var y_pos = lerp(y_pos_min, y_pos_max, l)
	money_mesh.position = Vector3(pos_before.x, y_pos,pos_before.z)
	
	var xz_scale = lerp(xz_scale_min, xz_scale_max, l)
	var y_scale = lerp(y_scale_min, y_scale_max, l)
	var scale = Vector3(xz_scale, y_scale, xz_scale)
	money_mesh.scale = scale
	
	print("lerp money vis: ", l, " scale:", scale)
	
	JuiceUtil.apply_juice_tween(self, Tween.TransitionType.TRANS_BOUNCE)
