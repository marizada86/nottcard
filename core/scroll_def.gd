class_name ScrollDef
extends RefCounted
## game/core/scrolls.py::ScrollDef

var id: String = ""
var name: String = ""
var tier: int = 0
var card: Card = null

var card_name: String:
	get:
		return card.name
