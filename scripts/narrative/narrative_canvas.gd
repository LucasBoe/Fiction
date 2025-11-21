extends CanvasLayer

@onready var fade_black_color_rect = $Control/ColorRect
@onready var popup_parent = $Control/NarrativePopup

@onready var narrative_text_label = $Control/NarrativePopup/MarginContainer/VBoxContainer/MarginContainer/RichTextLabel
@onready var choice_button_1 = $Control/NarrativePopup/MarginContainer/VBoxContainer/HBoxContainer/Button1
@onready var choice_button_2 = $Control/NarrativePopup/MarginContainer/VBoxContainer/HBoxContainer/Button2

var event_choice_buttons : Array[Button]

var narrative_event_folder_path = "res://data/travel/"
var narrative_event_pool : Array[NarrativeEvent]

var _skip_text_animation = false
var chosen_keywords : Array

signal travel_finished_signal

func _ready() -> void:
	visible = false
	fade_black_color_rect.visible = false
	popup_parent.visible = false
	
	event_choice_buttons.append(choice_button_1)
	event_choice_buttons.append(choice_button_2)
	
	#load all narrative events
	var paths = FileUtil.get_all_file_paths(narrative_event_folder_path)
	for path in paths:
		var event_data = ResourceLoader.load(path)
		narrative_event_pool.append(event_data)

func _input(event: InputEvent) -> void:
	# Any mouse button press will trigger a skip
	if event is InputEventMouseButton and event.pressed:
		_skip_text_animation = true
		
func begin_travel():
	chosen_keywords.clear()
	
	#pick next event
	var event : NarrativeEvent = narrative_event_pool.pick_random()
	narrative_event_pool.erase(event)
	
	_show_event(event)
	
func _show_event(event):	
	#fill content
	narrative_text_label.text = event.text
	try_create_button(0, event)
	try_create_button(1, event)
	_animate_text(narrative_text_label, event_choice_buttons)
	
	#show	
	visible = true
	fade_black_color_rect.visible = true
	popup_parent.visible = true

func try_create_button(index, event):	
	if (event.choices.size() <= index):
		return
	
	var choice =  event.choices[index]
	var button : Button = event_choice_buttons[index]
	button.visible = true
	button.text = choice.button_text	
	button.pressed.connect(execute_choice.bind(choice))
	
func _animate_text(label : RichTextLabel, elements : Array[Button]):	
	_skip_text_animation = false
	
	for n in elements:
		n.visible = false
		
	label.visible_characters = 0
	for c in label.text:
		
		if _skip_text_animation:
			label.visible_ratio = 1
			break
		else:
			label.visible_characters+=1
		
		if c == ".":
			await get_tree().create_timer(.2).timeout
		else:
			await get_tree().create_timer(.01).timeout
			
	for n in elements:
		if not n.text.is_empty():
			n.visible = true

func execute_choice(choice : EventChoice):	
	for button in event_choice_buttons:
		_disconnect_all_from(button)
		
	chosen_keywords.append_array(choice.opt_location_keywords)
	
	#show the consequences of the choice as text
	if not choice.opt_text.is_empty():
		narrative_text_label.text = choice.opt_text	
		choice_button_1.pressed.connect(_end_travel)
		choice_button_1.text = "continue"
		choice_button_2.text = ""	
		_animate_text(narrative_text_label, event_choice_buttons)
		
	#show followup event
	elif choice.opt_next_event != null:
		_show_event(choice.opt_next_event)
		
	else:
		_end_travel()

func _end_travel():
	
	for button in event_choice_buttons:
		_disconnect_all_from(button)
	
	visible = false
	fade_black_color_rect.visible = false
	popup_parent.visible = false
	travel_finished_signal.emit()
	
func _disconnect_all_from(button):
	for dict in button.pressed.get_connections():
		button.pressed.disconnect(dict.callable)
