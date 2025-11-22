extends CharacterBody3D
class_name Enemy

@export var damage_per_tick := 10
@export var damage_interval := 1.0   # 1 second

@onready var health : Health = $Health

var _wagon: Node3D = null
var _damaging := false

func _ready():
	EntityHandler._register_enemy(self)
	HealthBarCanvas._create_bar_for(health)
	health.took_damage.connect(_on_took_damage)
	%AttackArea.body_entered.connect(_on_body_entered)
	%AttackArea.body_exited.connect(_on_body_exited)

#checks if it hits a wagon
func _on_body_entered(body: Node3D):
	print("Entered: " + body.name)
	if body is WagonBody:
		_wagon = body
		if not _damaging:
			_start_damage_loop()

func _on_body_exited(body: Node3D) -> void:
	print("Exited: " + body.name)
	if body is WagonBody:
		_wagon = null
		_damaging = false

func _start_damage_loop() -> void:
	_damaging = true

	while _damaging and is_instance_valid(_wagon):
		_wagon.health.take_damage(damage_per_tick)
		await get_tree().create_timer(damage_interval).timeout

func _on_took_damage(amount):
	JuiceUtil.apply_juice_tween(self, Tween.TransitionType.TRANS_BOUNCE)
	if health.current_health <= 0:
		EntityHandler._unregister_enemy(self)
		self.queue_free()

func get_closest_potential_target() -> Node3D:
	
	var all_targets : Array[Node3D]
	
	#get player wagon
	for child in Globals.placement_handler.active_holder.get_children():
		if child is WagonMoney:
			all_targets.append(child)
			
	#get buildings
	for child in Globals.map_loader.currently_loaded_map.houses:
		if child is Building:
			if (child as Building).is_enemy_target:
				all_targets.append(child)
	
	if all_targets.is_empty():
		return null
		
	#return closest
	var closestSquaredDistance = INF
	var closestNode = null
	for target in all_targets:
		var squaredDistance = target.global_position.distance_squared_to(position)
		if squaredDistance < closestSquaredDistance:
			closestSquaredDistance = squaredDistance
			closestNode = target

	return closestNode	
