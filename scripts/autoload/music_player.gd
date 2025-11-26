extends Node

@onready var music_night : AudioStreamPlayer = $NightMusic
@onready var music_day : AudioStreamPlayer = $DayMusic
@onready var music_travel : AudioStreamPlayer = $TravelMusic

@export var music_night_volume : float = 0.0
@export var music_day_volume  : float = 0.0   # added
@export var music_travel_volume : float = 0.0 # added
@export var crossfade_time : float = 1.5      # how long the crossfade takes (seconds)

var current_track : AudioStreamPlayer
var fade_tween : Tween

const SILENT_DB := -80.0

func play_track(new_track: AudioStreamPlayer) -> void:
	
	# If already on this track and it's playing, do nothing
	if new_track == current_track and new_track.playing:
		return

	# If nothing is currently playing, play instantly at "full" volume
	if current_track == null or not current_track.playing:
		_apply_full_volume(new_track)
		new_track.play()
		current_track = new_track
		return

	# Kill previous audio tween(s)
	if fade_tween != null and is_instance_valid(fade_tween):
		fade_tween.kill()

	var old_track := current_track
	current_track = new_track

	# Prepare new track at silence, then start it
	new_track.volume_db = SILENT_DB
	new_track.play(new_track.stream.get_length() * randf())

	# Create a new crossfade tween
	fade_tween = create_tween()

	# Fade old track out
	fade_tween.tween_property(
		old_track, "volume_db", SILENT_DB, crossfade_time
	).set_delay(crossfade_time / 2)

	# Fade new track in in parallel
	fade_tween.parallel().tween_property(
		new_track, "volume_db", _get_default_volume(new_track), crossfade_time
	).set_ease(Tween.EASE_IN)

	# Stop the old track when fade is done
	fade_tween.finished.connect(func():
		if is_instance_valid(old_track):
			old_track.stop()
	)


func _get_default_volume(track: AudioStreamPlayer) -> float:
	if track == music_night:
		return music_night_volume
	elif track == music_day:
		return music_day_volume
	elif track == music_travel:
		return music_travel_volume
	return 0.0


func _apply_full_volume(track: AudioStreamPlayer) -> void:
	track.volume_db = _get_default_volume(track)
