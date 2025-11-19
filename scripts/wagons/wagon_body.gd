extends StaticBody3D

func _ready() -> void:
	#make collision shape active
	await get_tree().process_frame
	%WagonShape.disabled = false
