extends Node
class_name GameLoopHandler

@onready var map_loader = %MapLoader
@onready var placement_handler = %PlacementHandler
@onready var enemy_spawner = %EnemySpawner

func _ready() -> void:
	await _game_loop()

func _game_loop() -> void:
	await get_tree().process_frame
	while true:
		await _load_random_map()
		await _wait_for_placement()
		await _run_wave_phase()
		await _reward_phase()
		await _run_narrative_popups()
		
func _load_random_map() -> void:
	map_loader.load_random_map()

func _wait_for_placement() -> void:
	placement_handler.run_placement_phase()
	await placement_handler.placement_finished
	print("placement finished")

func _run_wave_phase() -> void:
	enemy_spawner.spawn_wave(4,1)
	await EntityHandler.all_enemies_unregistered

func _reward_phase() -> void:
	print("Reward phase – TODO: implement real rewards")
	await get_tree().create_timer(0.5).timeout


func _run_narrative_popups() -> void:
	print("Travel phase – TODO: implement real popups")
	await get_tree().create_timer(0.5).timeout
