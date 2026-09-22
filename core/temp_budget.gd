class_name TempBudget
extends RefCounted
## game/core/temporaries.py::TempBudget — quantos temporários a missão já deu.

var cards: int = 0
var items: int = 0

var can_card: bool:
	get:
		return cards < Temporaries.MAX_TEMP_CARDS

var can_item: bool:
	get:
		return items < Temporaries.MAX_TEMP_ITEMS
