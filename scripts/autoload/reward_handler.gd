extends Node3D

@onready var reward_dummy : MeshInstance3D = $RewardDummy
@onready var reward_choice_canvas : RewardChoiceCanvas = $RewardChoiceCanvas

var reward_instances : Array[MeshInstance3D]
var reward_triggers : Array[RewardTrigger]

signal all_rewards_chose_signal
signal all_rewards_given_signal

func _ready():
	reward_dummy.visible = false
	
func register_trigger(trigger):
	reward_triggers.append(trigger)
	
func unregister_trigger(trigger):
	reward_triggers.erase(trigger)

func give_rewards():
	var map = Globals.map_loader.currently_loaded_map
	
	var money_cart = Globals.placement_handler.active_holder.find_child("Wagon_Money") as WagonMoney
	
	if money_cart == null:
		return
	
	var total_reward = 0
	
	#var reward_buildings : Array[RewardBuilding]
	
	for child in map.houses:
		if child is not Building:
			continue
			
		var building = child as Building
		if not building.can_be_damaged_by_enemy:
			continue
		
		# filter out specific reward buildings
		#if building is RewardBuilding:
			#if not building.health._is_empty():
				#reward_buildings.append(building)	
				
		if building.reward_trigger != null:
			if (not building.health._is_empty()):
				building.reward_trigger.visible = true
			else:
				reward_triggers.erase(building.reward_trigger)
			
		## apply genereal reward based on destruction	
		#var reward_amount = float(building.health.current_health) / float(building.health.max_health) * building.reward_amount_base
		#for i in reward_amount / 3.0:
			#var reward_instance = reward_dummy.duplicate()
			#add_child(reward_instance)
			#reward_instance.visible = true
			#reward_instance.name = str(3.0)
			#reward_instance.global_position = child.global_position + Vector3.UP
			#reward_instance.scale = Vector3.ZERO	
			#reward_instances.append(reward_instance)
			#var tween := reward_instance.create_tween()
			#tween.set_ease(Tween.EASE_IN_OUT)
			#tween.tween_property(reward_instance, "global_position", child.global_position + Vector3(randf_range(-.5,.5), 1, randf_range(-.5,.5)), 0.5)
			#tween.parallel().tween_property(reward_instance, "scale", Vector3.ONE * .3, 0.5)
			#
		#total_reward += reward_amount
		#print(total_reward)
		
	#await get_tree().create_timer(.5).timeout
		#
	#var curve_fly_duration = 1.0
	#var curve_fly_step_delay = 0.05
	#
	#var delay = 0.0
	#for reward in reward_instances:
		#animate_over_time(reward, money_cart.global_position, curve_fly_duration, null, delay)
		#delay += curve_fly_step_delay
		#
	#await get_tree().create_timer(curve_fly_duration + curve_fly_step_delay * reward_instances.size()).timeout	
		#
	#for reward in reward_instances:
		#reward.queue_free()
	#reward_instances.clear()
	
	#for building in reward_buildings:
		#await reward_choice_canvas.show_choice(building.reward)
		#
	
	while reward_triggers.size() > 0 or reward_choice_canvas.visible:
		await get_tree().process_frame
		
	await get_tree().create_timer(2).timeout
		
	all_rewards_given_signal.emit()

func animate_over_time(node, p2, duration = 1.0, complete_function = null, delay = 0.0):
	var points : Array[Vector3]
		
	var p1 = node.global_position + Vector3.UP
	var distance = p1.distance_to(p2)
	
	var t = 1.0
	
	await get_tree().create_timer(delay).timeout
	
	while t > 0.0:
		var l = ease_in_out_sine(1.0-t)
		var lerp_height = (l - pow(l, 2)) * 4
		var pos = lerp(p1, p2, l) + Vector3(0, lerp_height * distance / 2,0)
		node.global_position = pos
		
		t -= get_process_delta_time() / duration
		await get_tree().process_frame
		
	SoundPlayer.play3D(SoundPlayer.coin, node.global_position)
	MoneyHandler.change_money(node.name.to_float())

func ease_in_out_sine(x: float) -> float:
	return -(cos(PI * x) - 1.0) / 2.0
	
func _process(delta: float) -> void:
	for i in len(reward_instances):
		var reward = reward_instances[i]
		var movement = (Vector3(1.0 + (PI * i) / 7.0, 2.0 + PI * i * 2.0, PI * i * 5.0).normalized())
		reward.rotate(movement, delta)
