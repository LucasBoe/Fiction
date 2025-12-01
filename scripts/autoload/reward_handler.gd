extends Node3D

@onready var reward_dummy : MeshInstance3D = $RewardDummy
@onready var reward_choice_canvas : RewardChoiceCanvas = $RewardChoiceCanvas
var reward_instances : Array[MeshInstance3D]

signal preview_rewards_signal
signal show_rewards_signal
signal hide_rewards_signal

func _ready():
	reward_dummy.visible = false

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
		if building is RewardBuilding:
			if not building.health._is_empty():
				reward_choice_canvas.populate_choices(building.reward)

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
