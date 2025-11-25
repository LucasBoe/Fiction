extends Resource
class_name EventChoice

@export var button_text : String
@export var opt_next_event : NarrativeEvent
@export var opt_effects : Array[EventChoiceEffects] = []
@export_multiline var opt_text : String
@export var opt_difficultiy_change : int
@export var opt_location_keywords : Array[MapData.LocationKeyword] = []

enum EventChoiceEffects {
	LOOSE_MONEY_SMALL,
	LOOSE_MONEY_BIG,
	REDUCED_LAYOUT_TIME
enum EventChoiceEffects { 
	GET_SUPPLIES_SMALL, 
	GET_SUPPLIES_BIG, 
	LOOSE_SUPPLIES_SMALL, 
	LOOSE_SUPPLIES_BIG,  
	REDUCED_LAYOUT_TIME, 
	DAMAGE_WAGON_RANDOM, 
	GET_WAGON_WINDOW, 
	REPAIR_ALL_WAGONS,
	 GET_UPGRADE_WINDOW
}
