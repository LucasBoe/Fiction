extends Node
class_name GameLoopHandler

@onready var map_loader = %MapLoader
@onready var placement_handler = %PlacementHandler
@onready var enemy_spawner = %EnemySpawner

func _ready() -> void:
	await _game_loop()

func _game_loop() -> void:
	await get_tree().process_frame
	MoneyHandler.change_money(10)
	await _reset_placement()
	
	while true:
		await _load_random_map()
		await _wait_for_placement()
		await _run_wave_phase()
		await _reward_phase()
		await _unload_current_map()
		await _reset_placement()
		await _run_narrative_popups()
		

func _unload_current_map() -> void:
	map_loader.unload_current_map()
	print("unloaded current map")

func _load_random_map() -> void:
	map_loader.load_random_map()
	print("loaded random map")

func _wait_for_placement() -> void:
	placement_handler.run_placement_phase()
	Globals.environment.set_day()
	await placement_handler.placement_finished
	Globals.environment.set_night()
	print("placement finished")
	
func _reset_placement() -> void:
	placement_handler.reset_placement()
	print("placement reset")
	
func _run_wave_phase() -> void:
	enemy_spawner.spawn_wave(1,1)
	await EntityHandler.all_enemies_unregistered
	print("wave cleared reset")

func _reward_phase() -> void:
	MoneyHandler.change_money(10)
	print("enter Reward phase – TODO: implement real rewards")
	await get_tree().create_timer(0.5).timeout


func _run_narrative_popups() -> void:
	NarrativeCanvas.begin_travel()
	await NarrativeCanvas.travel_finished_signal
