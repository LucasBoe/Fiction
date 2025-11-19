class_name JuiceUtil
extends Node

static func apply_juice_tween(target: Node3D, type: Tween.TransitionType, duration: float = 0.3) -> Tween:

	var tween: Tween = target.create_tween()

	var original_scale: Vector3 = target.scale
	var overshoot_scale: Vector3 = original_scale * 1.05

	tween.set_ease(Tween.EaseType.EASE_OUT)
	tween.set_trans(type)
	tween.tween_property(target, "scale", overshoot_scale, duration * 0.3)
	tween.tween_property(target, "scale", original_scale, duration * 0.7)
	
	return tween
