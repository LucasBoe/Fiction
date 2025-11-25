extends Resource
class_name NarrativeEvent

@export var type : EventType
@export var choices: Array[EventChoice] = []
@export_multiline var text: String

enum EventType {
	MAIN,
	ENCOUNTER
}
