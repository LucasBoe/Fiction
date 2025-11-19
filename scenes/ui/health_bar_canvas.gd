extends CanvasLayer

@export var camera_path: NodePath
@export var healthbar_wagon: PackedScene = preload("res://scenes/ui/Healthbar_Wagons.tscn")

@onready var camera: Camera3D

var wagon_to_healthbar: = {}  

func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	camera = Globals.current_camera

	for wagon in wagon_to_healthbar.keys():
		var bar: Control = wagon_to_healthbar[wagon]

		# Remove bar if wagon is gone
		if not is_instance_valid(wagon):
			bar.queue_free()
			wagon_to_healthbar.erase(wagon)
			continue

		# 3D point above the wagon’s head
		var world_pos: Vector3 = wagon.global_transform.origin + Vector3(0, 2.0, 0)

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

		bar.visible = true
		bar.position = screen_pos


func _create_bar_for_wagon(wagon: Node3D) -> void:
	var bar: Control = healthbar_wagon.instantiate()
	add_child(bar)
	wagon_to_healthbar[wagon] = bar
