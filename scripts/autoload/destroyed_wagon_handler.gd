extends Node3D

@onready var repair_trigger_dummy = preload("res://scenes/repair_trigger.tscn")
var wagons : Array
var repair_triggers : Array

func _ready():
	hide()
	
	Globals.reward_phase_begin_signal.connect(_on_reward_phase_begin)
	Globals.reward_phase_end_signal.connect(_on_reward_phase_end)

func handover(wagon):
	wagons.append(wagon)
	wagon.global_position =+ Vector3(0, -10, 0)
	wagon.reparent(self)
	
func _on_reward_phase_begin():
	
	#append all slidely damaged wagons
	#for wagon in Wagon.get_all_active_wagons():
		#if wagon.body.health.current_health < wagon.body.health.max_health:
			#wagons.append(wagon)
	
	for wagon in wagons:
		var instance : RepairTrigger = repair_trigger_dummy.instantiate()
		Globals.map_loader.get_tree().root.add_child(instance)
		instance.on_click_signal.connect(try_repair.bind(instance, wagon))
		instance.global_position = Vector3(wagon.global_position.x, 2, wagon.global_position.z)
		
func try_repair(trigger, wagon):
	
	var price = RepairTrigger.COST
	if MoneyHandler.current_money < price:
		return
		
	MoneyHandler.change_money(-price)
	trigger.hide()
	
	wagon.reparent(Globals.placement_handler.active_holder)
	wagon.global_position = Vector3(wagon.global_position.x, 0, wagon.global_position.z)
	wagon.body.health.heal()
	
	repair_triggers.erase(trigger)
	wagons.erase(wagon)
	trigger.queue_free()
		
func _on_reward_phase_end():
	for wagon in wagons:
		wagon.queue_free()
	wagons.clear()
	for trigger in repair_triggers:
		trigger.queue_free()
	repair_triggers.clear()
