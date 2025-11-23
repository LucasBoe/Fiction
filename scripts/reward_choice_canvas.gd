extends CanvasLayer
class_name RewardChoiceCanvas

@onready var choice_dummy = $Control/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/ChoiceDummy
var choice_instances : Array


signal on_picked_reward_signal

func _ready():
	choice_dummy.visible = false
	visible = false

func show_choice(reward : RewardBuilding.RewardType):
	visible = true
	
	if reward == RewardBuilding.RewardType.WAGON_MAKER:
		
		create_button("Repair All", 20)
		create_button("Simple Wagon", 30, "res://scenes/wagons/wagon_barricade.tscn")
	
		await on_picked_reward_signal
	
	visible = false
	
func create_button(title, price, wagon = ""):
	var instance = choice_dummy.duplicate()
	instance.visible = true
	choice_dummy.get_parent().add_child(instance)	
	
	var button = instance.get_node("Button")
	button.disabled = MoneyHandler.current_money < price
	button.pressed.connect(pick.bind(price, wagon))
	instance.find_child("NameLabel", true, false).text = title
	instance.find_child("PriceLabel", true, false).text = str(price, "$")
	choice_instances.append(instance)

func pick(price, wagon):
	if MoneyHandler.current_money < price:
		return
		
	MoneyHandler.change_money(-price)
		
	for choice in choice_instances:
		choice.queue_free()
	choice_instances.clear()
	
	if wagon.is_empty():
		for existing_wagon : Wagon in Globals.placement_handler.active_holder.get_children():
			print(existing_wagon)
			existing_wagon.body.health.current_health = existing_wagon.body.health.max_health
	else:
		var scene = ResourceLoader.load(wagon)
		var instance = scene.instantiate()
		Globals.placement_handler.active_holder.add_child(instance)
	
	on_picked_reward_signal.emit()
	
