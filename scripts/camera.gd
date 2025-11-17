extends Node3D

@export var move_speed: float = 4.0
@onready var perspective_camera = $Perspective;
@onready var topdown_camera = $TopDown;

var zoomTarget : float = 1
var current_camera_mode : camera_mode = camera_mode.PERSPECTIVE

enum camera_mode {
	PERSPECTIVE,
	TOP_DOWN
}

func _ready():
	set_camera(camera_mode.PERSPECTIVE)

func _process(delta):
	handle_toggle()
	handle_zoom(delta)
	handle_move(delta)
	
func set_camera(mode):
	current_camera_mode = mode
	var cam = perspective_camera if mode == camera_mode.PERSPECTIVE else topdown_camera
	cam.current = true
	
func handle_toggle():
	if Input.is_action_just_pressed("toggle_camera"):
		var mode = camera_mode.TOP_DOWN if current_camera_mode == camera_mode.PERSPECTIVE else camera_mode.PERSPECTIVE
		set_camera(mode)
	
func handle_zoom(delta):
	if Input.is_action_just_pressed("zoom_in"):
		zoomTarget *= 1.1
		zoom_in_out();
		
	if Input.is_action_just_pressed("zoom_out"):
		zoomTarget *= 0.9
		zoom_in_out();
	
func _input(event):
	
	var delta = get_process_delta_time() 
	
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoomTarget *= 1.1
			zoom_in_out();
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoomTarget *= 0.9
			zoom_in_out();
		
	if event is InputEventPanGesture:
		if event.delta.y < 0:
			zoomTarget *= 1.005
			zoom_in_out();
		else:
			zoomTarget *= 0.99
			zoom_in_out();
		
func handle_move(delta):
	var move_dir: Vector3 = Vector3.ZERO

	# Get forward (look) and right directions from this node’s transform
	var forward: Vector3 = (-global_transform.basis.z -global_transform.basis.x).normalized()
	var right:   Vector3 = (-global_transform.basis.z +global_transform.basis.x).normalized()

	# Optional: comment these out if you WANT vertical movement when looking up/down
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	# Input
	if Input.is_action_pressed("move_forward"):
		move_dir += forward
	if Input.is_action_pressed("move_back"):
		move_dir -= forward
	if Input.is_action_pressed("move_left"):
		move_dir -= right
	if Input.is_action_pressed("move_right"):
		move_dir += right

	# Apply movement
	if move_dir != Vector3.ZERO:
		move_dir = move_dir.normalized()
		global_position += move_dir * move_speed * zoomTarget * delta

func zoom_in_out():
	perspective_camera.position = Vector3(4,6,4) * zoomTarget
	topdown_camera.position = 5 * zoomTarget * Vector3.UP
