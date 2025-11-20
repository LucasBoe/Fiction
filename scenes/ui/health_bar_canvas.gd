extends CanvasLayer

@export var camera_path: NodePath
@export var healthbar_wagon: PackedScene = preload("res://scenes/ui/Healthbar_Wagons.tscn")

@onready var camera: Camera3D

var health_to_healthbar: = {}  

func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	camera = Globals.current_camera

	for health in health_to_healthbar.keys():
		var bar: HealthBar = health_to_healthbar[health]

		# Remove bar if wagon is gone
		if not is_instance_valid(health):
			bar.queue_free()
			health_to_healthbar.erase(health)
			continue

		# 3D point above the wagon’s head
		var world_pos: Vector3 = health.global_transform.origin + Vector3(0, 2.0, 0)

		# Hide if behind camera
		if camera.is_position_behind(world_pos):
			bar.visible = false
			continue

		# Project 3D → 2D screen position
		var screen_pos: Vector2 = camera.unproject_position(world_pos)

		# Hide if off-screen (optional)
		if screen_pos.x < 0 or screen_pos.y < 0 or screen_pos.x > viewport_size.x or screen_pos.y > viewport_size.y:
			bar.visible = false
			continue

		bar.visible = bar.has_damage
		bar.position = screen_pos


func _create_bar_for(health: Health) -> void:
	var bar: HealthBar = healthbar_wagon.instantiate()
	add_child(bar)
	bar.fill_rect.color = Color.RED if health.is_enemy else Color.GREEN_YELLOW

	health.health_changed.connect(bar._on_health_changed)
	
	#Adds bar to dictionary
	health_to_healthbar[health] = bar
