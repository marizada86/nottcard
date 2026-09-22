class_name Option
extends RefCounted
## game/core/exploration.py::Option — uma opção de situação: atributo + DC + desfechos.

const FACIL := 10
const MEDIO := 15
const DIFICIL := 20

var label: String = ""
var attribute: Variant = null   # String ou null (opção de combate / automática)
var dc: int = MEDIO
var success: Outcome = null
var failure: Outcome = null
var combat: bool = false
var bonus_hooks: Array = []   # [[gancho, bônus], ...]
var stealth: bool = false
var critical: Variant = null   # Outcome ou null
var auto: bool = false
var cost_gold: int = 0

static func make(label_: String, fields: Dictionary = {}) -> Option:
	var o := Option.new()
	o.label = label_
	o.success = Outcome.new()
	o.failure = Outcome.new()
	for k in fields:
		o.set(k, fields[k])
	return o

## Texto do botão: "Força · DC 15"; vazio para a opção de combate.
var check_label: String:
	get:
		if attribute == null:
			if auto and cost_gold != 0:
				return "Sem teste · %d de ouro" % cost_gold
			return "Sem teste" if auto else ""
		return "%s · DC %d" % [CharacterDefs.attribute_names()[attribute], dc]
