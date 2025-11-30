extends Enemy

@export var speed: float = 1.0
@export var attack_speed = 1.0
@onready var agent = %NavigationAgent3D
@onready var death_particles = $DeathParticles
@onready var flames = $Flames
@onready var fire_damage_per_second = 1.0

var target_node
var target_position

var burning_time = 0.0
const burning_cooldown = 3.0

func _ready():
	super._ready()
	
	flames.emitting = false
	
	#create unique delay
	await get_tree().create_timer((1.0 / attack_speed) * randf()).timeout
	
	while true: 
		await get_tree().create_timer(1.0 / attack_speed).timeout
		refresh()

func set_burning():
	burning_time = burning_cooldown
	flames.emitting = true

func refresh():
	
	#update target
	target_node = get_closest_potential_target()
	
	if target_node != null:
		target_position = target_node.global_position
	else:
		target_position = Vector3.ZERO

	agent.target_position = target_position
	
	#damage potential targets in range
	var radius = 1.5
	var objects = PhysicsUtil.boxcast_for_objects(get_world_3d().direct_space_state, global_position, Vector3.ONE * radius, [self])
	
	for object in objects:
		var target = object.collider
		
		var is_wagon = target is WagonBody
		var is_house = (target.get_parent() is Building and (target.get_parent() as Building).can_be_damaged_by_enemy)
		
		if is_house:
			target = target.get_parent()
		
		var damage = damage_per_second / attack_speed
		
		if (is_wagon or is_house) and target.health.current_health > 0:
			target.health.take_damage(damage)
			DebugDraw3D.draw_line(global_position, target.global_position + Vector3.UP, Color.RED, .2)
			JuiceUtil.apply_juice_tween(self, Tween.TransitionType.TRANS_BOUNCE)
			SoundPlayer.play3D(SoundPlayer.enemy_attack, global_position)
			print("damage ", target, ": ", damage)

func _process(delta):
	
	if not check_burning():
		return
		
	var dmg = fire_damage_per_second * delta
	health.take_damage(dmg)
	
	burning_time -= delta
	if not check_burning():
		flames.emitting = false

func check_burning():
	return burning_time > 0.0

func _physics_process(delta: float) -> void:
	
	# If there's no path or we're already there, stop
	if not agent.is_navigation_finished():
		var next_point: Vector3 = agent.get_next_path_position()
		var direction: Vector3 = (next_point - global_position)
		direction.y = 0.0  # keep movement flat on the ground

		if direction.length() > 0.01:
			direction = direction.normalized()
			velocity = direction * speed
			#DebugDraw3D.draw_line(global_position, global_position + direction)
			var target_y = atan2(direction.x, direction.z) # yaw angle
			rotation.y = lerp_angle(rotation.y, target_y, 5.0 * delta)
			
		else:
			velocity = Vector3.ZERO
			#DebugDraw3D.draw_line(global_position, global_position + Vector3(0,2,0))
	else:
		velocity = Vector3.ZERO
		#DebugDraw3D.draw_line(global_position, global_position + Vector3(0,2,0))

	move_and_slide()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		death_particles.reparent(Globals.map_loader.currently_loaded_map)
		death_particles.emitting = true
