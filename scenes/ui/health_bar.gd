extends Control
class_name HealthBar

@onready var back_rect : ColorRect = $ColorRect
@onready var fill_rect : ColorRect = $ColorRect/ColorRect

var has_damage = false
var tween: Tween

func _on_health_changed(health: Health) -> void:

	has_damage = health.current_health < health.max_health

	# Calculate target width (clamped between 0 and full)
	var ratio = clampf(health.current_health / (float)(health.max_health), 0.0, 1.0)
	var target_size := back_rect.size * Vector2(ratio, 1.0)
	print("health: ", health.current_health, "/", health.max_health, " (", ratio, ")")

	# Stop old tween if still running
	if tween and tween.is_valid():
		tween.kill()

	# Create new tween for smooth animation
	tween = create_tween()
	tween.tween_property(
		fill_rect,
		"size",
		target_size,
		0.2		# duration in seconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
