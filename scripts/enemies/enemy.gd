extends CharacterBody3D
class_name Enemy

@export var health = 6
@export var damage_per_tick := 10
@export var damage_interval := 1.0   # 1 second

signal took_damage(amount : int)

var _wagon: Node3D = null
var _damaging := false

func _ready():
	$HitArea.body_entered.connect(_on_body_entered)
	$HitArea.body_exited.connect(_on_body_exited)
	EntityHandler._register_enemy(self)

#checks if it hits a wagon
func _on_body_entered(body: Node3D):
	if body is WagonBody:
		_wagon = body
		if not _damaging:
			_start_damage_loop()

func _on_body_exited(body: Node3D) -> void:
	if body == WagonBody:
		_wagon = null
		_damaging = false

func _start_damage_loop() -> void:
	_damaging = true

	while _damaging and is_instance_valid(_wagon):
		_wagon.take_damage(damage_per_tick)
		await get_tree().create_timer(damage_interval).timeout

#Ability to damage the enemy
func take_damage(amount: int):
	health -= amount
	emit_signal("took_damage", amount)
	JuiceUtil.apply_juice_tween(self, Tween.TransitionType.TRANS_BOUNCE)
	_check_for_death()

func _check_for_death():
	if health <= 0 :
		EntityHandler._unregister_enemy(self)
		self.queue_free()
