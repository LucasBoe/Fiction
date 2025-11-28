extends StaticBody3D
class_name RewardTrigger

@onready var building : Building = $".."

var reward_instances : Array
var triggered = false

func _ready() -> void:
	RewardHandler.register_trigger(self)
	
	if building is RewardBuilding:
		var mesh  : MeshInstance3D = $MeshInstance3D
		var mat = mesh.get_surface_override_material(0).duplicate()
		mat.albedo_color = Color.BLUE   # or Color(1, 0, 0)
		mesh.set_surface_override_material(0,mat)

func notify_enter():
	scale = Vector3(1.1, 1.1, 1.1)
	
func notify_exit():
	scale = Vector3.ONE

func trigger_reward():
	
	if triggered:
		return
		
	triggered = true
	
	if building.health._is_empty():
		queue_free()
		RewardHandler.unregister_trigger(self)
		return	
		
	if building is RewardBuilding:
		RewardHandler.reward_choice_canvas.show_choice(building.reward, on_close_reward_window)
	else:
		var reward_amount = float(building.health.current_health) / float(building.health.max_health) * building.reward_amount_base
		for i in reward_amount / 3.0:
			var reward_instance = get_child(3).duplicate()
			building.add_child(reward_instance)
			reward_instance.name = str(3.0)
			reward_instance.global_position = building.global_position
			reward_instance.scale = Vector3.ZERO	
			reward_instances.append(reward_instance)
			var tween := reward_instance.create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(reward_instance, "global_position", global_position + Vector3(randf_range(-.5,.5), 1, randf_range(-.5,.5)), 0.5)
			tween.parallel().tween_property(reward_instance, "scale", Vector3.ONE * 2, 0.5)
			
		visible = false
		
		await get_tree().create_timer(.5).timeout
		
		var target_position = Vector3.ZERO
		var money_cart = Globals.placement_handler.active_holder.find_child("Wagon_Money") as WagonMoney
		if money_cart != null:
			target_position = money_cart.global_position
			
		var curve_fly_duration = 1.0
		var curve_fly_step_delay = 0.05
		var delay = 0.0
		
		for reward in reward_instances:
			animate_over_time(reward, target_position, curve_fly_duration, null, delay)
			delay += curve_fly_step_delay
			
		await get_tree().create_timer(curve_fly_duration + curve_fly_step_delay * reward_instances.size()).timeout
		
		queue_free()
		RewardHandler.unregister_trigger(self)
	
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
	
func _process(delta: float) -> void:
	for i in len(reward_instances):
		var reward = reward_instances[i]
		var movement = (Vector3(1.0 + (PI * i) / 7.0, 2.0 + PI * i * 2.0, PI * i * 5.0).normalized())
		reward.rotate(movement, delta)

func ease_in_out_sine(x: float) -> float:
	return -(cos(PI * x) - 1.0) / 2.0
	
func on_close_reward_window(chose_reward):
	if chose_reward:
		queue_free()
		RewardHandler.unregister_trigger(self)
	else:
		triggered = false
