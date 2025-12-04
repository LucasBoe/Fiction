extends CanvasLayer

@onready var fade_black_color_rect: ColorRect = $Fade
@onready var loading_label = $Label
const DURATION : float = 1.0

signal finished_signal

var fade_tween: Tween

func _ready():
	loading_label.hide()

func fade_in():
	await fade_to(1)
	
func fade_out():
	await fade_to(0)
	
func fade_in_out():
	await fade_to(1)
	fade_to(0)

func fade_to(opacity: float) -> void:
	# Clamp opacity between 0 and 1
	opacity = clamp(opacity, 0.0, 1.0)
	loading_label.visible = opacity > .5

	# Kill any previous fade tween
	if fade_tween != null and is_instance_valid(fade_tween):
		fade_tween.kill()

	# Prepare target color with new alpha
	var target_color: Color = fade_black_color_rect.color
	target_color.a = opacity

	# Create tween and animate the color change
	fade_tween = create_tween()
	fade_tween.tween_property(
		fade_black_color_rect,
		"color",
		target_color,
		DURATION
	)
	
	await fade_tween.finished
	finished_signal.emit()
	fade_black_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP if opacity > 0 else Control.MOUSE_FILTER_IGNORE
