extends Node

signal money_changed_signal(new_money_amount : float)

var current_money = 0

func change_money(change):
	current_money += change
	money_changed_signal.emit(current_money)
