extends Node
class_name GameLoopHandler

@onready var map_loader = %MapLoader
@onready var placement_handler = %PlacementHandler
@onready var enemy_spawner = %EnemySpawner

@onready var end_placement_button = %CanvasLayer/ContinueButtons/EndPlacementButton
@onready var end_reward_button = %CanvasLayer/ContinueButtons/EndRewardButton

func _ready() -> void:
	end_placement_button.hide()
	end_reward_button.hide()
	await _game_loop()

func _game_loop() -> void:
	await get_tree().process_frame
	Globals.tutorial.hide()
	MoneyHandler.change_money(250)
	await _reset_placement()
	MusicPlayer.play_track(MusicPlayer.music_travel)
	FadeEffectCanvas.fade_out()
	await _run_narrative_popups(true)
	Globals.tutorial.show()
	
	while true:
		await _load_next_map()		
		MusicPlayer.play_track(MusicPlayer.music_day)
		await _wait_for_placement()
		Globals.tutorial.hide()
		MusicPlayer.play_track(MusicPlayer.music_night)
		await _run_wave_phase()
		MusicPlayer.play_track(MusicPlayer.music_day)
		await _reward_phase()
		await FadeEffectCanvas.fade_in_out()
		await _unload_current_map()
		await _reset_placement()		
		MusicPlayer.play_track(MusicPlayer.music_travel)		
		await _run_narrative_popups()
		
	await FadeEffectCanvas.fade_in_out()
		

func _unload_current_map() -> void:
	map_loader.unload_current_map()
	print("unloaded current map")

func _load_next_map() -> void:
	Globals.current_camera.get_parent_node_3d().rotate_y(deg_to_rad(90))
	map_loader.load_map_based_on_keywords(NarrativeCanvas.chosen_keywords)
	Globals.environment.set_evening(.1)	

func _wait_for_placement() -> void:
	placement_handler.run_placement_phase()
	RaycastHandler.set_modifications_allowed(true)
	RewardHandler.preview_rewards_signal.emit()
	await await_button(end_placement_button)
	RewardHandler.hide_rewards_signal.emit()
	RaycastHandler.set_modifications_allowed(false)
	Globals.environment.set_night()
	print("placement finished")
	
func _reset_placement() -> void:
	placement_handler.reset_placement()
	print("placement reset")
	
func _run_wave_phase() -> void:
	await enemy_spawner.night_loop()
	print("wave cleared reset")

func _reward_phase() -> void:
	for house in Globals.map_loader.currently_loaded_map.houses:
		if is_instance_valid(house) and house.health != null:
			house.health.heal()
			
	Globals.reward_phase_begin_signal.emit()
	Globals.environment.set_day()
	RewardHandler.show_rewards_signal.emit()
	RewardHandler.give_rewards()
	await await_button(end_reward_button)
	Globals.reward_phase_end_signal.emit()
	print("rewards given")

func _run_narrative_popups(introduction_narrative = false) -> void:
	Globals.camera_manager.set_camera(CameraManager.camera_mode.NARRATIVE)
	NarrativeCanvas.begin_travel(introduction_narrative)
	await NarrativeCanvas.travel_finished_signal
	Globals.camera_manager.set_camera(CameraManager.camera_mode.PERSPECTIVE)

func await_button(button):
	button.show()
	await button.pressed
	button.hide()
