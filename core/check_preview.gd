class_name CheckPreview
extends RefCounted
## game/core/exploration.py::CheckPreview — o que o teste vale, sem rolar nem gastar nada.

var who: String = ""
var attribute_label: String = ""
var modifier: int = 0
var bonuses: Array = []   # [[origem, valor], ...]
var dc: int = 0
var disadvantage: bool = false

var total_bonus: int:
	get:
		var t := modifier
		for b in bonuses:
			t += int(b[1])
		return t

## O menor d20 que passa (2 a 20).
var needed: int:
	get:
		return maxi(2, mini(20, dc - total_bonus))

var chance_text: String:
	get:
		var raw := dc - total_bonus
		if raw > 20:
			return "só um 20 natural passa"
		if raw <= 2:
			return "só um 1 natural falha"
		return "precisa de %d ou mais no d20" % raw
