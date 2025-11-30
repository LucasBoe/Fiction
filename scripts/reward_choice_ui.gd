extends MarginContainer
class_name RewardChoiceUI

@onready var button = $Button
@onready var name_label = $MarginContainer/NameLabel
@onready var icon_rect = $MarginContainer/IconRect
@onready var price_label = $MarginContainer/PriceLabel


var canvas : RewardChoiceCanvas
var price
var new_wagon_path : String
var original_wagon_instance : Wagon

func fill(_canvas : RewardChoiceCanvas, _title, _icon, _price, _new_wagon_path = "", _original_wagon_instance = null):
	canvas = _canvas
	name_label.text = _title
	price = _price
	icon_rect.texture = _icon
	price_label.text = str(-price, " Supplies")
	button.pressed.connect(try_choose)
	refresh()

func try_choose():
	if MoneyHandler.current_money < price:
		return
		
	MoneyHandler.change_money(-price)
	
	#heal
	if new_wagon_path.is_empty() and price > 0:
		for existing_wagon : Wagon in Wagon.get_all_active_wagons():
			existing_wagon.body.health.heal()
		canvas.try_remove_choice(self)
	#execute wagon changes
	else:
		if not new_wagon_path.is_empty():
			var scene = ResourceLoader.load(new_wagon_path)
			var instance = scene.instantiate()
			Globals.placement_handler.active_holder.add_child(instance)
			instance.global_position = Vector3(0,-10,0)
		
		canvas.try_remove_choice(self)
			
		if original_wagon_instance != null:
			original_wagon_instance.queue_free()		

func refresh():
	button.disabled = MoneyHandler.current_money < price
	#refresh displayed information
