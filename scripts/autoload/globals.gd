extends Node

var current_camera : Camera3D
var map_loader : MapLoader
var placement_handler : PlacementHandler
var environment : EnvironmentHolder
var camera_manager : CameraManager

signal reward_phase_begin_signal
signal reward_phase_end_signal
