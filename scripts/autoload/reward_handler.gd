extends Node3D

@onready var reward_dummy : MeshInstance3D = $RewardDummy

var reward_instances : Array[MeshInstance3D]

signal all_rewards_given_signal

func _ready():
	reward_dummy.visible = false

func give_rewards():
	var map = Globals.map_loader.currently_loaded_map
	
	var money_cart = Globals.placement_handler.active_holder.find_child("Wagon_Money") as WagonMoney
	
	var house_root = map.find_child("Houses")	
	for child in house_root.get_children():
		for i in 7:
			var reward_instance = reward_dummy.duplicate()
			add_child(reward_instance)
			reward_instance.visible = true
			reward_instance.global_position = child.global_position + Vector3.UP
			reward_instance.scale = Vector3.ZERO	
			reward_instances.append(reward_instance)
			var tween := reward_instance.create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(reward_instance, "global_position", child.global_position + Vector3(randf_range(-.5,.5), 1, randf_range(-.5,.5)), 0.5)
			tween.parallel().tween_property(reward_instance, "scale", Vector3.ONE * .3, 0.5)
			
	await get_tree().create_timer(.5).timeout
		
	var curve_fly_duration = 1.0
	for reward in reward_instances:
		animate_over_time(reward, money_cart.global_position, curve_fly_duration)
	await get_tree().create_timer(curve_fly_duration).timeout		
	MoneyHandler.change_money(10)
		
	await get_tree().create_timer(2).timeout
	
	for reward in reward_instances:
		reward.queue_free()
	reward_instances.clear()
		
	all_rewards_given_signal.emit()

func animate_over_time(node, p2, duration = 1.0, complete_function = null):
	var points : Array[Vector3]
		
	var p1 = node.global_position + Vector3.UP
	var distance = p1.distance_to(p2)
	
	var t = 1.0
	
	while t > 0.0:
		var l = ease_in_out_sine(1.0-t)
		var lerp_height = (l - pow(l, 2)) * 4
		var pos = lerp(p1, p2, l) + Vector3(0, lerp_height * distance / 2,0)
		node.global_position = pos
		
		t -= get_process_delta_time() / duration
		await get_tree().process_frame

func ease_in_out_sine(x: float) -> float:
	return -(cos(PI * x) - 1.0) / 2.0
	
func _process(delta: float) -> void:
	for i in len(reward_instances):
		var reward = reward_instances[i]
		var movement = Vector3((PI * i) / 7, PI * i * 2, PI * i * 5).normalized()
		reward.rotate(movement, delta)
