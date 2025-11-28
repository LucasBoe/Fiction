extends Node

var current_camera : Camera3D
var map_loader : MapLoader
var placement_handler : PlacementHandler
var environment : EnvironmentHolder
var camera_manager : CameraManager

const MAX_LOCATIONS = 8

signal reward_phase_begin_signal
signal reward_phase_end_signal
signal before_rebuild_navigation
signal after_rebuild_navigation
