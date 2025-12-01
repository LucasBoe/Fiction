extends CanvasLayer
class_name RewardChoiceCanvas

@onready var margin_root = $Control/MarginContainer
@onready var header_label = $Control/MarginContainer/VBoxContainer/MarginContainer/MarginContainer/VBoxContainer/Label
@onready var choice_dummy : RewardChoiceUI = $Control/MarginContainer/VBoxContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/ChoiceDummy
@onready var close_button = $Control/MarginContainer/VBoxContainer/Control/CloseButton
@onready var fallback_label = $Control/MarginContainer/VBoxContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/NoChoicesLeftFallback

@onready var supply_icon = preload("res://ui/supplies_icon.png")
@onready var fire_wagon_icon = preload("res://ui/fire_icon.png")
@onready var archer_wagon_icon = preload("res://ui/archer_icon.png")
@onready var barricade_wagon_icon = preload("res://ui/barricade_icon.png")

const fire_wagon_scene_path = "res://scenes/wagons/wagon_fire.tscn"
const archer_wagon_scene_path = "res://scenes/wagons/wagon_archer.tscn"
const barricade_wagon_scene_path = "res://scenes/wagons/wagon_barricade.tscn"

var choice_instances : Dictionary[RewardBuilding.RewardType, Array]

func _ready():
	choice_dummy.hide()
	fallback_label.hide()
	hide()
	close_button.pressed.connect(close_window)
	#Globals.map_loader.loaded_map.connect(_on_loaded_map)
	
#func _on_loaded_map():
	##clear previous choices for repopulation
	#for array in choice_instances.values():
		#for e in array:
			#e.queue_free()
	#choice_instances.clear()

func populate_choices(reward : RewardBuilding.RewardType):
	
	#clear previous choices for repopulation
	if choice_instances.has(reward):
		choice_instances[reward].clear()
	
	if reward == RewardBuilding.RewardType.WAGON_MAKER:
		header_label.text = "The [color= orange]Wagon Maker [/color]can do something for you:"
		create_button_wagon_maker(
			"[color= orange]Repair[/color] all wagons",
			supply_icon,
			30)
			
		var pool = [0, 1, 2]
		pool.erase(pool.pick_random())
		
		if pool.has(0):
			create_button_wagon_maker(
				"Build a [color= orange]Fire Wagon[/color]",
				fire_wagon_icon,
				30,
				fire_wagon_scene_path)
				
		if pool.has(1):
			create_button_wagon_maker(
				"Build a [color= orange]Archer Wagon[/color]",
				archer_wagon_icon,
				50,
				archer_wagon_scene_path)
				
		if pool.has(2):
			create_button_wagon_maker(
				"Build a [color= orange]Barricade Wagon[/color]",
				barricade_wagon_icon,
				30,
				barricade_wagon_scene_path)
		
	elif reward == RewardBuilding.RewardType.SMITH:
		header_label.text = "The [color= orange]Smith [/color]can upgrade one of your wagons:"		
		#pool upgrades
		var pool = WagonUpgrade.get_all_possible_upgrades()
		
		#pick random upgrades
		var i = 3 #max count
		while i > 0 and pool.size() > 0:
			var upgrade : WagonUpgrade = pool.pick_random()
			pool.erase(upgrade)
			create_button_smith(upgrade)
			#create_button_smith(upgrade.upgrade_name, upgrade.upgrade_cost, upgrade.upgrade_icon, upgrade.original_wagon, upgrade.upgrade_wagon.resource_path)
			i-=1

func show_choice(reward : RewardBuilding.RewardType):
	for c in choice_instances[reward]:
		c.refresh()
		c.show()
		
	show()
	try_update_fallback_label()

func create_button_smith(upgrade : WagonUpgrade):
	var choice = create_choice(RewardBuilding.RewardType.SMITH)
	choice.fill(self, upgrade.upgrade_name, upgrade.upgrade_icon, upgrade.upgrade_cost, upgrade.upgrade_wagon.resource_path, upgrade.original_wagon)
	
	
func create_button_wagon_maker(title, icon, price = -10, new_wagon_path = ""):
	var choice = create_choice(RewardBuilding.RewardType.WAGON_MAKER)
	choice.fill(self, title, icon, price, new_wagon_path, null)

func create_choice(reward_type):
	
	if not choice_instances.has(reward_type):
		choice_instances[reward_type] = []
	
	var instance = choice_dummy.duplicate()
	choice_instances[reward_type].append(instance)
	choice_dummy.get_parent().add_child(instance)	
	return instance
	
func try_remove_choice(choice : RewardChoiceUI):
	for array in choice_instances.values():
		array.erase(choice)
		
		#is there another update that would affect the same wagon?
		if choice.original_wagon_instance != null:
			for e : RewardChoiceUI in array:
				if e.original_wagon_instance == choice.original_wagon_instance:
					e.queue_free()
					array.erase(e)
		
	choice.queue_free()
	refresh_all_choices()
	
func refresh_all_choices():
	for array in choice_instances.values():
		for e in array:
			e.refresh()
			
	try_update_fallback_label()

func try_update_fallback_label():
	var show_fallback = true
	for array in choice_instances.values():
		for e in array:
			if e.visible:
				show_fallback = false
				
	fallback_label.visible = show_fallback

func close_window():
	for array in choice_instances.values():
		for e in array:
			e.hide()
	hide()
