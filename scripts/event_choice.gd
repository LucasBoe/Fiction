extends Resource
class_name EventChoice

@export var button_text : String
@export var opt_next_event : NarrativeEvent
@export var opt_effects : Array[EventChoiceEffects] = []
@export var opt_text : String
@export var opt_difficultiy_change : int
@export var opt_location_keywords : Array[LocationKeyword] = []

enum EventChoiceEffects {
	LOOSE_MONEY_SMALL,
	LOOSE_MONEY_BIG,
	REDUCED_LAYOUT_TIME
}

enum LocationKeyword {
	HAS_SMITH_OR_IS_CASTLE,
	HAS_WAGNER,
	FIRE,
	STARVING,
	BANDITS
}
