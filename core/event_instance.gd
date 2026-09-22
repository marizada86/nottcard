class_name EventInstance
extends RefCounted
## game/core/event_plan.py::EventInstance — um evento colocado numa sala nesta missão.

var event_id: String = ""
var room: int = 0
var cell: Variant = null   # Vector2i ou null
var state: Dictionary = {}

func _init(event_id_: String = "", room_: int = 0) -> void:
	event_id = event_id_
	room = room_
