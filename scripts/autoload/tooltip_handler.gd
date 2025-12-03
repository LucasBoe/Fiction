extends Node3D

@onready var canvas_layer = $CanvasLayer
@onready var tooltip_root = $CanvasLayer/Control/MarginContainer
@onready var label = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/NameLabel
@onready var description_label = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var healthbar_root = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthBar
@onready var health_amount_label = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthAmountLabel
@onready var reward_container = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/RewardContainer
@onready var reward_label = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/RewardContainer/HBoxContainer/RewardLabel
@onready var healthbar_background_rect = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthBar/MarginContainer/ColorRect
@onready var healthbar_fill_rect = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthBar/MarginContainer/ColorRect/ColorRect
@onready var healthbar_amount_label = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer/HealthAmountLabel

var currently_hovered
var current_health

func _ready():
	canvas_layer.visible = false
	
func _process(delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var cam = Globals.current_camera
	
	var hovered_before = currently_hovered
	
	if currently_hovered is Wagon:
		canvas_layer.visible = true
		if RaycastHandler.currently_dragging:
			canvas_layer.visible = false
			return
	
	currently_hovered = PhysicsUtil.raycast_for_all_and_find(space_state, mouse_pos, cam, TriggerBase)
	if currently_hovered != null and not currently_hovered.is_claimable():
		currently_hovered = null
	
	if not currently_hovered:
		currently_hovered = PhysicsUtil.raycast_for_all_and_find(space_state, mouse_pos, cam, Building, true)
		if currently_hovered and not currently_hovered.can_be_damaged_by_enemy:
			currently_hovered = null
			
	if not currently_hovered:
		currently_hovered = PhysicsUtil.raycast_for_all_and_find(space_state, mouse_pos, cam, Wagon, true)
			
	if currently_hovered:
		tooltip_root.position = tooltip_root.get_global_mouse_position() - tooltip_root.size * Vector2(0.5, 1) - Vector2(0,8)
		
	if current_health:
		update_health(current_health, currently_hovered)
		
	if currently_hovered == hovered_before:
		return
		
	if currently_hovered == null:
		canvas_layer.visible = false
		current_health = null
	else:
		canvas_layer.visible = true
		if not currently_hovered.display_name.is_empty():
			label.text = currently_hovered.display_name
		else:
			label.text = currently_hovered.name
		
		if not currently_hovered.display_description.is_empty():
			description_label.text = currently_hovered.display_description
		else:
			description_label.text = ""
		
		if currently_hovered is Wagon:
			current_health = currently_hovered.body.health
			reward_container.hide()
			tooltip_root.reset_size()
		elif currently_hovered is Building:
			current_health = currently_hovered.health
			reward_container.show()
		elif currently_hovered is RewardTrigger:
			current_health = null
			healthbar_root.visible = false
			healthbar_amount_label.visible = false
			reward_container.hide()
			tooltip_root.reset_size()
		
func update_health(health : Health, source):
	
	healthbar_root.visible = true
	healthbar_amount_label.visible = true
	
	var health_multiplier = clampf(float(health.current_health) / float(health.max_health),0,1)
	healthbar_fill_rect.size = Vector2(health_multiplier,1) * healthbar_background_rect.size
	healthbar_amount_label.text = str(health.current_health, "/", health.max_health)
	
	if reward_container.visible and source is Building:
		if (source as Building).reward_amount_base != 0:
			reward_label.text = str((source as Building).reward_amount_base)
		else:
			reward_label.text = ""
