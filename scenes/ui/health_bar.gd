extends Control
class_name HealthBar

@onready var back_rect : ColorRect = $ColorRect
@onready var fill_rect : ColorRect = $ColorRect/ColorRect

var has_damage = false

func _on_took_damage(health, max_health):	
	print("health: ", health)
	has_damage = health < max_health
	fill_rect.size = back_rect.size * Vector2(health / max_health, 1)
