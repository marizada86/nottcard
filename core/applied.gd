class_name Applied
extends RefCounted
## game/core/exploration.py::Applied — o que o desfecho fez ao jogador.

var text: String = ""
var xp: int = 0
var hp_lost: int = 0
var discarded: Card = null
var drawn: int = 0
var item: ItemDef = null
var item_stored: bool = true
var critical: bool = false
var lost_card: Card = null
var lost_item: ItemDef = null
var pending: PendingReward = null
var declined: bool = false
var gold: int = 0
var temp_card: Card = null
var limit_hit: bool = false
var healed: int = 0
var bless: int = 0
var dishonor: bool = false
var clear_dishonor: bool = false
var fight: String = ""
var remain: bool = false
var effect: String = ""

func copy_with(changes: Dictionary = {}) -> Applied:
	var a := Applied.new()
	for p in get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			a.set(p.name, get(p.name))
	for k in changes:
		a.set(k, changes[k])
	return a
