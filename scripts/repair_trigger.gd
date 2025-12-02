extends TriggerBase
class_name RepairTrigger

const COST = 8

signal on_click_signal

func _ready():
	display_name = str("repair (-", COST, " supplies)")

func on_click():
	on_click_signal.emit()
