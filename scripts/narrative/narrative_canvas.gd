extends CanvasLayer

@onready var fade_black_color_rect = $Control/ColorRect
@onready var popup_parent = $Control/NarrativePopup

@onready var text_beep_audio = $UiTextBeep

@onready var narrative_text_label = $Control/NarrativePopup/MarginContainer/VBoxContainer/MarginContainer/RichTextLabel
@onready var choice_button_1 = $Control/NarrativePopup/MarginContainer/VBoxContainer/HBoxContainer/Button1
@onready var choice_button_2 = $Control/NarrativePopup/MarginContainer/VBoxContainer/HBoxContainer/Button2
@onready var choice_button_1_label = $Control/NarrativePopup/MarginContainer/VBoxContainer/HBoxContainer/Button1/Label
@onready var choice_button_2_label = $Control/NarrativePopup/MarginContainer/VBoxContainer/HBoxContainer/Button2/Label

@onready var intro_event = load("res://data/travel/intro.tres")
@onready var parser = $TextFileParser

var event_choice_buttons : Array[Button]
var event_choice_button_labels : Array[RichTextLabel]

var narrative_event_folder_path = "res://data/travel/"
var narrative_event_pool : Array[NarrativeEvent]

var _skip_text_animation = false
var chosen_keywords : Array

var previous_feedback_text
var final_text

signal travel_finished_signal

func _ready() -> void:
	visible = false
	fade_black_color_rect.visible = false
	popup_parent.visible = false
	
	event_choice_buttons.append(choice_button_1)
	event_choice_buttons.append(choice_button_2)
	
	event_choice_button_labels.append(choice_button_1_label)
	event_choice_button_labels.append(choice_button_2_label)
	
	#load all narrative events
	#var paths = FileUtil.get_all_file_paths(narrative_event_folder_path)
	#for path in paths:
		#var event_data = ResourceLoader.load(path)
		#narrative_event_pool.append(event_data)

func _input(event: InputEvent) -> void:
	# Any mouse button press will trigger a skip
	if event is InputEventMouseButton and event.pressed:
		_skip_text_animation = true
		
func begin_travel(introduction_narrative = true):
	chosen_keywords.clear()
	
	#pick next event
	var event : NarrativeEvent = intro_event if introduction_narrative else parser.get_events(NarrativeEvent.EventType.MAIN).pick_random()
	#var event : NarrativeEvent = parser.get_events(NarrativeEvent.EventType.MAIN).pick_random()
	#narrative_event_pool.erase(event)
	
	_show_event(event)
	
func _show_event(event):	
	
	#show		
	visible = true
	fade_black_color_rect.visible = true
	popup_parent.visible = false
	
	await FadeEffectCanvas.finished_signal
	
	#fill content
	narrative_text_label.text = try_merge(previous_feedback_text, event.text)
	try_create_button(0, event)
	try_create_button(1, event)
	_animate_text(narrative_text_label)
	
	popup_parent.visible = true

func try_create_button(index, event):	
	var button : Button = event_choice_buttons[index]
	var label = event_choice_button_labels[index]
	
	if (event.choices.size() <= index):
		label = ""
		return
	
	populate_button(button, label, index, event)
	
func populate_button(button : Button, label : RichTextLabel, index, event):
	var choice =  event.choices[index]
	button.show()
	if (choice.cost > 0):
		label.text = str(choice.button_text	, " ([color=yellow]",choice.cost,"$[/color])")
	else:
		label.text = choice.button_text	
	button.disabled = MoneyHandler.current_money < choice.cost
	button.pressed.connect(execute_choice.bind(event, choice))
	
func _animate_text(label : RichTextLabel):	
	_skip_text_animation = false
	
	for n in event_choice_buttons:
		n.visible = false
		
	label.visible_characters = 0
	
	await get_tree().create_timer(.5).timeout
	
	for c in label.text:
		
		if _skip_text_animation:
			label.visible_ratio = 1
			break
		else:
			label.visible_characters+=1
			
		SoundPlayer.play(SoundPlayer.ui_text_beep)
		
		if c == ".":
			await get_tree().create_timer(.4).timeout
		else:
			await get_tree().create_timer(.05).timeout
			
	for i in event_choice_buttons.size():
		var l = event_choice_button_labels[i]
		var b = event_choice_buttons[i]
		if not l.text.is_empty():
			b.visible = true

func execute_choice(event : NarrativeEvent, choice : EventChoice):
	
	SoundPlayer.play(SoundPlayer.ui_click)
	
	# reset all buttons
	for button in event_choice_buttons:
		_disconnect_all_from(button)
		button.disabled = false
		
	choice_button_1.visible = false
	choice_button_2.visible = false
		
	await get_tree().create_timer(.5).timeout
	
	# append keywords
	chosen_keywords.append_array(choice.location_keywords)
	
	# remove cost
	if choice.cost >= 0:
		MoneyHandler.change_money(-choice.cost)
		
	if not choice.effects.is_empty():
		execute_effects(choice.effects)
	
	# append feedback text
	if not choice.feedback_text.is_empty():
		previous_feedback_text = choice.feedback_text
	elif event.type == NarrativeEvent.EventType.ENCOUNTER:
		previous_feedback_text = choice.final_text
	
	# append final text
	if event.type == NarrativeEvent.EventType.MAIN:
		final_text = choice.final_text
		var next_event = parser.get_events(NarrativeEvent.EventType.ENCOUNTER).pick_random()
		await FadeEffectCanvas.fade_in_out()
		_show_event(next_event)
	else:
		
		await FadeEffectCanvas.fade_in_out()
		narrative_text_label.text = try_merge(previous_feedback_text, final_text)
		choice_button_1.pressed.connect(_end_travel)
		choice_button_1_label.text = "continue"
		choice_button_2_label.text = ""	
		_animate_text(narrative_text_label)

func _end_travel():
	
	SoundPlayer.play(SoundPlayer.ui_click)
	
	for button in event_choice_buttons:
		_disconnect_all_from(button)
		
	choice_button_1.visible = false
	choice_button_2.visible = false
	
	await FadeEffectCanvas.fade_in_out()
	
	previous_feedback_text = ""
	final_text = ""
	
	visible = false
	fade_black_color_rect.visible = false
	popup_parent.visible = false
	travel_finished_signal.emit()
	
func _disconnect_all_from(button):
	for dict in button.pressed.get_connections():
		button.pressed.disconnect(dict.callable)

func try_merge(textA, textB):
	if textA == null or textA.is_empty():
		return textB
	elif textB == null or textB.is_empty():
		return textA
	
	return str(textA, "\n", "\n", textB)
	
func execute_effects(effects : Array[EventChoice.EventChoiceEffects]):
	for effect : EventChoice.EventChoiceEffects in effects:
		match effect:
			EventChoice.EventChoiceEffects.GET_SUPPLIES_SMALL:
				MoneyHandler.change_money(10)
			EventChoice.EventChoiceEffects.GET_SUPPLIES_BIG:
				MoneyHandler.change_money(25)
			EventChoice.EventChoiceEffects.LOOSE_SUPPLIES_SMALL:
				MoneyHandler.change_money(-5)
			EventChoice.EventChoiceEffects.LOOSE_SUPPLIES_BIG:
				MoneyHandler.change_money(-10)
			EventChoice.EventChoiceEffects.REDUCED_LAYOUT_TIME:
				print("missing: REDUCED_LAYOUT_TIME")
			EventChoice.EventChoiceEffects.DAMAGE_WAGON_RANDOM:
				Wagon.get_all_active_wagons().pick_random().body.health.take_damage(10)
			EventChoice.EventChoiceEffects.GET_WAGON_WINDOW:
				WagonUpgrade.execute_wagon_upgrade(Wagon.get_all_wagon_scene_paths().pick_random())
			EventChoice.EventChoiceEffects.REPAIR_ALL_WAGONS:
				for wagon : Wagon in Wagon.get_all_active_wagons():
					wagon.body.health.heal()
			EventChoice.EventChoiceEffects.GET_UPGRADE_WINDOW:
				var upgrades = WagonUpgrade.get_all_possible_upgrades()
				if not upgrades.is_empty():
					WagonUpgrade.execute(upgrades.pick_random())
		print("excuted choice effect: ", effect)
