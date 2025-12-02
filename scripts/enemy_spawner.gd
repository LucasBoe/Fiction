extends Node3D

@export var location_number_to_enemy_emount_curve : Curve
@onready var shadowEnemy: PackedScene = preload("res://scenes/enemies/enemy_shadow.tscn")

const spawn_distance_to_center = 20

const night_duration = 45.0
var night_progression = 0.0

signal begin_night_signal
signal end_night_signal

func night_loop():
	begin_night_signal.emit()
	spawn_wave(Globals.map_loader.map_number)
	Globals.environment.set_day(night_duration, EnvironmentHolder.transition_duration)
	while night_progression < 1.0:
		night_progression += get_process_delta_time() / night_duration
		await get_tree().process_frame
		
	EntityHandler.kill_all()
	end_night_signal.emit()
	night_progression = 0.0

func spawn_wave(location_number) -> void:
	var target_amount = roundi(location_number_to_enemy_emount_curve.sample(location_number))
	print("spawn enemies: ", target_amount)
	
	
	for i in target_amount:
		var dir = Vector3(randf_range(-1, 1), 0, randf_range(-1,1)).normalized()
		var location = dir * spawn_distance_to_center
		spawn_enemy_at(location)
		await get_tree().create_timer(30.0 / float(target_amount)).timeout


func spawn_enemy_at(spawnpoint: Vector3) -> void:
	var enemy: Node3D = shadowEnemy.instantiate()
	add_child(enemy)
	enemy.global_position = spawnpoint
