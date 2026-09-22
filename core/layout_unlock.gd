class_name LayoutUnlock
extends RefCounted
## game/core/layout_unlocks.py::LayoutUnlock (class_name → class_label na importação)

const ROMAN := ["I", "II", "III"]

var layout_id: String = ""
var achievement_id: String = ""
var class_id: String = ""
var character_id: String = ""
var class_label: String = ""
var grade: int = 0
var kills_needed: int = 0

var name: String:
	get:
		return "%s %s" % [class_label, ROMAN[grade - 1]]

var available: bool:
	get:
		return grade in LayoutUnlocks.AVAILABLE_GRADES

var description: String:
	get:
		return "Derrote %d inimigos com uma classe %s, somando as tentativas." % [kills_needed, class_label]
