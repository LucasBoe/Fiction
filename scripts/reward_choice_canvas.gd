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
		header_label.text = "The [color= orange]Wagon Maker [/color]can do something for you:"
		create_button_wagon_maker(
			"Get his leftover  [color= orange] Supplies [/color]",
			load("res://ui/supplies_icon.png"))
		create_button_wagon_maker(
			" [color= orange] Repair [/color]all wagons",
			load("res://ui/supplies_icon.png"),
			30)
		create_button_wagon_maker(
			"Build a[color= orange] Simple Wagon [/color]",
			load("res://ui/basic_icon.png"),
			50)
	
		await on_picked_reward_signal
		
	if reward == RewardBuilding.RewardType.SMITH:
		header_label.text = "The [color= orange]Smith [/color]can upgrade one of your wagons:"
		create_button_wagon_maker(
			"Get his leftover  [color= orange] Supplies [/color]",
			load("res://ui/supplies_icon.png"))
		
		#pool upgrades
		var pool = WagonUpgrade.get_all_possible_upgrades()
		
		#pick random upgrades
		var i = 2 #max count
		while i > 0 and pool.size() > 0:
			var upgrade : WagonUpgrade = pool.pick_random()
			pool.erase(upgrade)
			create_button_smith(upgrade.upgrade_name, upgrade.upgrade_cost, upgrade.upgrade_icon, upgrade.original_wagon, upgrade.upgrade_wagon.resource_path)
			i-=1
		
		await on_picked_reward_signal
			
	visible = false
	


func create_button_smith(title, price, upgradeIcon, original_wagon, new_wagon):
	var button = create_button(title, price, upgradeIcon)
	button.pressed.connect(pick.bind(price, new_wagon, original_wagon))
	
func create_button_wagon_maker(title, icon, price = -10, wagon = ""):
	var button = create_button(title, price, icon)
	button.pressed.connect(pick.bind(price, wagon))

func create_button(title, price, icon):
	var instance = choice_dummy.duplicate()
	instance.visible = true
	choice_dummy.get_parent().add_child(instance)	
	
	var button = instance.get_node("Button")
	button.disabled = MoneyHandler.current_money < price
	instance.find_child("NameLabel", true, false).text = title
	if icon !=  null:
		instance.find_child("IconRect", true, false).texture = icon;
	instance.find_child("PriceLabel", true, false).text = str(-price, " Supplies")
	choice_instances.append(instance)
	return button

func pick(price, wagon, original_wagon = null):
	if MoneyHandler.current_money < price:
		return
		
	MoneyHandler.change_money(-price)
		
	for choice in choice_instances:
		choice.queue_free()
	choice_instances.clear()
	
	if wagon.is_empty() and price > 0:
		for existing_wagon : Wagon in Wagon.get_all_active_wagons():
			existing_wagon.body.health.heal()
	else:
		WagonUpgrade.execute_wagon_upgrade(wagon, original_wagon)
	
	on_picked_reward_signal.emit()
