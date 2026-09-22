class_name RunLedger
extends RefCounted
## game/core/progress.py::RunLedger

var lines: Array = []
var mission_gold: int = 0
var xp_mult: int = 1
var gold_mult: int = 1

func add(source: String, amount: int) -> void:
	if amount > 0:
		lines.append(XpLine.new(source, amount * xp_mult))

func add_gold(amount: int) -> void:
	if amount > 0:
		amount *= gold_mult
	mission_gold = maxi(0, mission_gold + amount)

var total: int:
	get:
		var t := 0
		for l in lines:
			t += l.amount
		return t
