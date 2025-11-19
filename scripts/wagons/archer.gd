extends Node3D

@export var shooting_range: float = 10.0
@export var shooting_cooldown : float = 2.0

@export var projectile_speed: float = 4.0
@export var projectile_damage: int = 1

@onready var shooting_origin: Node3D
@onready var bolt = preload("res://scenes/projectiles/bolt.tscn")


func _ready() -> void:
	shooting_origin = get_child(0)
	start_shoot_loop()

func _process(delta: float) -> void:
	var enemy := _get_enemy_in_range(shooting_range)
	
	if enemy != null:
		_look_at(enemy)

func start_shoot_loop() -> void:
	while true:
		var enemy := _get_enemy_in_range(shooting_range)
		
		if enemy != null:
			_shoot(enemy)
			await get_tree().create_timer(shooting_cooldown).timeout
		else:
			await get_tree().process_frame   # try again next frame

func _get_enemy_in_range(range: float) -> Node3D:
	var enemies: Array[Node3D] = EntityHandler._get_enemies()

	var closest_enemy: Node3D = null
	var closest_dist := range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var dist := global_position.distance_to(enemy.global_position)

		if dist <= closest_dist:
			closest_dist = dist
			closest_enemy = enemy

	return closest_enemy

func _look_at(target: Node3D):
	var target_position = target.global_position
	target_position.y = global_position.y
	look_at(target_position, Vector3.UP, true)

func _shoot(target: Node3D):
	#print("shooting at" + target.name)
	var projectile := bolt.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = shooting_origin.global_position
	projectile._set_target(projectile_speed, target, projectile_damage)
