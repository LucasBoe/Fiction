extends Node3D

@export var location_number_to_enemy_emount_curve : Curve

@onready var shadowEnemy: PackedScene = preload("res://scenes/enemies/enemy_shadow.tscn")
const spawn_distance_to_center = 20

func spawn_wave(location_number) -> void:
	var target_amount = roundi(location_number_to_enemy_emount_curve.sample(location_number))
	print("spawn enemies: ", target_amount)
	
	
	for i in target_amount:
		var dir = Vector3(randf_range(-1, 1), 0, randf_range(-1,1)).normalized()
		var location = dir * spawn_distance_to_center
		spawn_enemy_at(location)
		await get_tree().create_timer(0.5).timeout


func spawn_enemy_at(spawnpoint: Vector3) -> void:
	var enemy: Node3D = shadowEnemy.instantiate()
	enemy.global_position = spawnpoint
	add_child.call_deferred(enemy)
