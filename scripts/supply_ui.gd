extends Control

@onready var amount_label = $MarginContainer/MarginContainer2/HBoxContainer/Label

func _ready():
	MoneyHandler.money_changed_signal.connect(on_money_changed)
	
func on_money_changed(amount_after):
	amount_label.text = str(amount_after,"$")
