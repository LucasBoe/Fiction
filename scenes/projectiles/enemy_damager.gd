extends Area3D

signal enemy_damaged (enemy : Enemy)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	print(body.name)
	if body is Enemy:
		print("Hit Enemy")
		emit_signal("enemy_damaged", body)
