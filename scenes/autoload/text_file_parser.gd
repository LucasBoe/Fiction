extends Node

@onready var text_source_file_path = "res://data/travel.txt"

var events : Dictionary

func _ready():
	var file = FileAccess.open(text_source_file_path, FileAccess.READ)
	var text = file.get_as_text().replace("\n", "")
	text = text.replace("§", "\n")
	var content = text.split("%", false)
	
	while content.size() > 0:
		var title = content[0]
		var body = parse_body(content[1])
		content.remove_at(0)
		content.remove_at(0)
		events[title] = body
		
	print("loaded ", events.size(), " events from txt file.")
		
func parse_body(content : String):
	
	var event = NarrativeEvent.new()
	
	#sort type e.g. #MAIN
	for type in NarrativeEvent.EventType.values():
		var key_string = str("#", NarrativeEvent.EventType.keys()[type])
		if content.contains(key_string):
			content = content.trim_prefix(key_string).strip_edges(true, false)
			event.type = type
			break
			
	# Split into main text and the "choices section"
	var first_choice_index := content.find("[")
	if first_choice_index == -1:
		event.text = apply_colors(content.strip_edges())
		return event

	# Parse choices: [ ... ] body text ... [ ... ] body text ...
	event.text = apply_colors(content.substr(0, first_choice_index).strip_edges())
	var choices_raw := content.substr(first_choice_index)
	var regex := RegEx.new()
	regex.compile("\\[([^\\]]*)\\]") # [ button label... ]
	var matches: Array = regex.search_all(choices_raw)

	for i in range(matches.size()):
		
		var choice = EventChoice.new()
		
		#split choice content raw
		var m: RegExMatch = matches[i]
		var header_text = m.get_string(1) # stuff inside [...]
		var body_text = _extract_choice_body(choices_raw, matches, i)
		var header_split = header_text.split("-")
		choice.button_text = header_split[0]
		
		#populate choice with parameters
		header_split.remove_at(0)
		if not header_split.is_empty():
			for parameter in header_split:
				_parse_parameter(parameter, choice)
		choice.final_text = apply_colors(body_text)
					
		event.choices.append(choice)
		#print(choice.get_print_string())
		
	return event

func _extract_choice_body(choices_raw: String, matches: Array, index: int) -> String:
	var m: RegExMatch = matches[index]

	var body_start := m.get_end(0)
	var body_end := choices_raw.length()

	if index + 1 < matches.size():
		var next_match: RegExMatch = matches[index + 1]
		body_end = next_match.get_start(0)

	return choices_raw.substr(body_start, body_end - body_start).strip_edges()
	
func _parse_parameter(p, choice : EventChoice):
	var split = p.split(":")
	var parameter_type : String = split[0]
	var parameter_value : String = split[1]
				
	if parameter_type == "KEY":
		var location_name = parameter_value.to_upper()
		var location_key = MapData.LocationKeyword[location_name]
		choice.location_keywords.append(location_key)
		
	elif parameter_type == "TEXT":
		choice.feedback_text = apply_colors(parameter_value)
		
	elif parameter_type == "COST":
		choice.cost = parameter_value.to_int()
		
	elif parameter_type == "EFFECT":
		var effect_name = parameter_value.to_upper()
		var effect_key = EventChoice.EventChoiceEffects[effect_name]
		choice.effects.append(effect_key)
		
func get_events(type):
	var filtered : Array
	for event in events.values():
		if event.type == type:
			filtered.append(event)
			
	return filtered
	
func apply_colors(text) -> String:
	return text.replace("<", "[color=orange]").replace(">", "[/color]")
