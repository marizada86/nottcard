class_name Outcome
extends RefCounted
## game/core/exploration.py::Outcome — efeito de um desfecho (custos e ganhos leves).

var text: String = ""
var xp: int = 0
var hp_loss: Variant = null   # [mín, máx] ou null
var discard: bool = false
var draw: int = 0
var item: String = ""
var gold: int = 0
var temp_card: String = ""
var temp_item: String = ""
var heal_pct: int = 0
var bless: int = 0
var dishonor: bool = false
var clear_dishonor: bool = false
var fight: String = ""
var remain: bool = false
var effect: String = ""

static func make(text_: String = "", fields: Dictionary = {}) -> Outcome:
	var o := Outcome.new()
	o.text = text_
	for k in fields:
		o.set(k, fields[k])
	return o
