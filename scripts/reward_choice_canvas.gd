extends CanvasLayer
class_name RewardChoiceCanvas

@onready var header_label = $Control/MarginContainer/MarginContainer/VBoxContainer/Label
@onready var choice_dummy = $Control/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/ChoiceDummy
var choice_instances : Array

signal on_picked_reward_signal

func _ready():
	choice_dummy.visible = false
	visible = false

func show_choice(reward : RewardBuilding.RewardType):
	visible = true
	
	if reward == RewardBuilding.RewardType.WAGON_MAKER:
		header_label.text = "The greatful wageon maker allows you to choose:"
		create_button_wagon_maker("Nothing")
		create_button_wagon_maker("Repair All", 20)
		create_button_wagon_maker("Simple Wagon", 30, "res://scenes/wagons/wagon_barricade.tscn")
	
		await on_picked_reward_signal
		
	if reward == RewardBuilding.RewardType.SMITH:
		header_label.text = "The greatful blacksmith allows you to choose:"
		create_button_wagon_maker("Nothing")
		
		#pool upgrades
		var pool : Array[WagonUpgrade]
		for wagon : Wagon in get_all_wagons():
			if wagon.upgrades.size() == 0:
				continue
				
			if pool.any(func(w : WagonUpgrade): return w.original_wagon.name == wagon.name):
				continue
				
			pool.append_array(wagon.upgrades)
		
		#pick random upgrades
		var i = 2 #max count
		while i > 0 and pool.size() > 0:
			var upgrade : WagonUpgrade = pool.pick_random()
			pool.erase(upgrade)
			create_button_smith(upgrade.upgrade_name, upgrade.upgrade_cost, upgrade.original_wagon, upgrade.upgrade_wagon.resource_path)
			i-=1
		
		await on_picked_reward_signal
			
	visible = false
	
func create_button_smith(title, price, original_wagon, new_wagon):
	var button = create_button(title, price)
	button.pressed.connect(pick.bind(price, new_wagon, original_wagon))
	
func create_button_wagon_maker(title, price = -10, wagon = ""):
	var button = create_button(title, price)
	button.pressed.connect(pick.bind(price, wagon))

func create_button(title, price):
	var instance = choice_dummy.duplicate()
	instance.visible = true
	choice_dummy.get_parent().add_child(instance)	
	
	var button = instance.get_node("Button")
	button.disabled = MoneyHandler.current_money < price
	instance.find_child("NameLabel", true, false).text = title
	instance.find_child("PriceLabel", true, false).text = str(price, "$")
	choice_instances.append(instance)
	return button

func pick(price, wagon, original_wagon = null):
	if MoneyHandler.current_money < price:
		return
		
	MoneyHandler.change_money(-price)
		
	for choice in choice_instances:
		choice.queue_free()
	choice_instances.clear()
	
	if not wagon.is_empty():
		var scene = ResourceLoader.load(wagon)
		var instance = scene.instantiate()
		Globals.placement_handler.active_holder.add_child(instance)
		
		if original_wagon != null:
			original_wagon.queue_free()
		
	elif price > 0:
		for existing_wagon : Wagon in get_all_wagons():
			existing_wagon.body.health.current_health = existing_wagon.body.health.max_health
	
	on_picked_reward_signal.emit()
	
func get_all_wagons():
	return Globals.placement_handler.active_holder.get_children()
