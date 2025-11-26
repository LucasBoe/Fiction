extends Node
class_name GameLoopHandler

@onready var map_loader = %MapLoader
@onready var placement_handler = %PlacementHandler
@onready var enemy_spawner = %EnemySpawner

func _ready() -> void:
	await _game_loop()

func _game_loop() -> void:
	await get_tree().process_frame
	MoneyHandler.change_money(25)
	await _reset_placement()
	MusicPlayer.play_track(MusicPlayer.music_travel)
	await _run_narrative_popups(true)
	
	while true:
		await _load_next_map()		
		MusicPlayer.play_track(MusicPlayer.music_day)
		await _wait_for_placement()
		MusicPlayer.play_track(MusicPlayer.music_night)
		await _run_wave_phase()
		MusicPlayer.play_track(MusicPlayer.music_day)
		await _reward_phase()
		await _unload_current_map()
		await _reset_placement()		
		MusicPlayer.play_track(MusicPlayer.music_travel)
		await _run_narrative_popups()
		

func _unload_current_map() -> void:
	map_loader.unload_current_map()
	print("unloaded current map")

func _load_next_map() -> void:
	Globals.current_camera.get_parent_node_3d().rotate_y(deg_to_rad(90))
	map_loader.load_map_based_on_keywords(NarrativeCanvas.chosen_keywords)
	Globals.environment.set_evening()	
	print("loaded new map")

func _wait_for_placement() -> void:
	placement_handler.run_placement_phase()
	RaycastHandler.set_modifications_allowed(true)
	await placement_handler.placement_finished
	RaycastHandler.set_modifications_allowed(false)
	Globals.environment.set_night()
	print("placement finished")
	
func _reset_placement() -> void:
	placement_handler.reset_placement()
	print("placement reset")
	
func _run_wave_phase() -> void:
	enemy_spawner.spawn_wave(Globals.map_loader.map_number)
	await EntityHandler.all_enemies_unregistered
	print("wave cleared reset")

func _reward_phase() -> void:
	Globals.reward_phase_begin_signal.emit()
	Globals.environment.set_day()
	RewardHandler.give_rewards()
	await RewardHandler.all_rewards_given_signal
	Globals.reward_phase_end_signal.emit()
	print("rewards given")

func _run_narrative_popups(introduction_narrative = false) -> void:
	Globals.camera_manager.set_camera(CameraManager.camera_mode.NARRATIVE)
	NarrativeCanvas.begin_travel(introduction_narrative)
	await NarrativeCanvas.travel_finished_signal
	Globals.camera_manager.set_camera(CameraManager.camera_mode.PERSPECTIVE)
