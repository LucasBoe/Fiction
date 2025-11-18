extends Node3D

@onready var shadowEnemy: PackedScene = preload("res://scenes/enemies/enemy_shadow.tscn")

var spawnpoints: Array[Node3D] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

	# Collect all spawnpoints under the %SpawnPoints node
	for child: Node in %SpawnPoints.get_children():
		if child is Node3D:
			spawnpoints.append(child)
	
	%NavigationMesh.baked_navigation.connect(_on_navigation_baked)
	
func _on_navigation_baked():
	_spawn_wave(10,1)

func _spawn_wave(pack_amount: int, enemy_amount: int) -> void:
	# For each pack, choose a random spawnpoint and spawn enemy_amount enemies there
	for i in range(pack_amount):
		var spawnpoint: Node3D = spawnpoints[rng.randi_range(0, spawnpoints.size() - 1)]

		for j in range(enemy_amount):
			_spawn_enemy(spawnpoint)
			
			await get_tree().create_timer(0.5).timeout


func _spawn_enemy(spawnpoint: Node3D) -> void:
	var enemy: Node3D = shadowEnemy.instantiate()
	# Place enemy at the spawnpoint position
	enemy.global_transform = spawnpoint.global_transform
	# Add to the same parent as this spawner (or change to whatever container you want)
	get_tree().get_root().add_child.call_deferred(enemy)
