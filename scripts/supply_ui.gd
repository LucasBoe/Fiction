extends Control
class_name SupplyUI

@onready var amount_label = $MarginContainer/HBoxContainer/MarginContainer/Label

func _ready():
	MoneyHandler.money_changed_signal.connect(on_money_changed)
	hide()
	
func on_money_changed(amount_after):
	amount_label.text = str(roundi(amount_after))
