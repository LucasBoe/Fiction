extends MeshInstance3D

func _ready() -> void:
	if(Engine.is_editor_hint()):
		self.queue_free()
