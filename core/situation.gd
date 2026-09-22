class_name Situation
extends RefCounted
## game/core/exploration.py::Situation

var room_id: int = 0
var lines: Array = []
var options: Array = []
var title: String = ""

static func make(room_id_: int, lines_: Array, options_: Array, title_: String = "") -> Situation:
	var s := Situation.new()
	s.room_id = room_id_
	s.lines = lines_
	s.options = options_
	s.title = title_
	return s
