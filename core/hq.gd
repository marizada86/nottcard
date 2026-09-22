class_name Hq
extends RefCounted
## Porte de game/core/hq.py::Hq. Gerado por tools/gen_dataclasses.py; métodos à mão.

var id: String = ""
var title: String = ""
var panels: Array = []

var word_count: int:
	get:
		var n := 0
		for p in panels:
			n += String(p.text).split(" ", false).size()
		return n
