extends Node3D

@onready var canvas_layer = $CanvasLayer
@onready var tooltip_root = $CanvasLayer/Control/MarginContainer
@onready var label = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/Label
@onready var healthbar_root = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthBar

@onready var healthbar_background_rect = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthBar/MarginContainer/ColorRect
@onready var healthbar_fill_rect = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthBar/MarginContainer/ColorRect/ColorRect

var currently_hovered
var current_health

func _ready():
	canvas_layer.visible = false
	
func _process(delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var cam = Globals.current_camera
	
	var hovered_before = currently_hovered
	
	currently_hovered = PhysicsUtil.raycast_for_all_and_find(space_state, mouse_pos, cam, Wagon, true)
	
	if not currently_hovered:
		currently_hovered = PhysicsUtil.raycast_for_all_and_find(space_state, mouse_pos, cam, Building, true)
	
	if currently_hovered:
		tooltip_root.position = tooltip_root.get_global_mouse_position() + Vector2(0,8)
		
	if current_health:
		update_health(current_health)
		
	if currently_hovered == hovered_before:
		return
		
	if currently_hovered == null:
		canvas_layer.visible = false
		current_health = null
	else:
		canvas_layer.visible = true
		label.text = currently_hovered.name
		
		if currently_hovered is Wagon:
			current_health = currently_hovered.body.health
			healthbar_root.visible = true
		elif currently_hovered is Building:
			current_health = currently_hovered.health
			healthbar_root.visible = true
		else:
			healthbar_root.visible = false
		
func update_health(health : Health):
	healthbar_root.visible = health != null
	if health:
		healthbar_fill_rect.size = Vector2(float(health.current_health) / float(health.max_health),1) * healthbar_background_rect.size
