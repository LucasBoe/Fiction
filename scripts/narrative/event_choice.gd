extends Resource
class_name EventChoice

@export var button_text : String
@export var cost : int = 0
@export_multiline var feedback_text : String
@export_multiline var final_text : String
@export var effects : Array[EventChoiceEffects] = []
@export var location_keywords : Array[MapData.LocationKeyword] = []

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

func get_print_string():
	var thisScript: GDScript = self.get_script()
	var string = ""
	for propertyInfo in thisScript.get_script_property_list():
		var propertyName: String = propertyInfo.name
		var propertyValue = get(propertyName)
		string += str(propertyName, ": ", propertyValue, ", ")
		
	string.trim_suffix(", ")
	return string
