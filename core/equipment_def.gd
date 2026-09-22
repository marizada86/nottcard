class_name EquipmentDef
extends RefCounted
## game/core/equipment.py::EquipmentDef

const ARMA := "arma"
const ARMADURA := "armadura"
const NORMAL := "normal"
const PENALIDADE := "penalidade"
const DESVANTAGEM := "desvantagem"
const STEALTH_PENALTY := -2

var id: String = ""
var nome: String = ""
var slot: String = ""
var preco: int = 0
var ca: int = 0
var cam: int = 0
var furtividade: String = "normal"
var carta: Card = null
var titulo_requerido = null
var allowed: Array = []   # ids dos personagens com proficiência (vazio = todos)

func usable_by(character_id: String) -> bool:
	return allowed.is_empty() or character_id in allowed

## Nomes curtos de quem tem proficiência (loja e menu).
var users_text: String:
	get:
		var chars: Dictionary = CharacterDefs.all()
		var who: PackedStringArray = []
		for c in chars:
			if usable_by(c):
				who.append(String(chars[c].name).split(" ")[0])
		return "Todos" if who.size() == chars.size() else ", ".join(who)

var stealth_text: String:
	get:
		match furtividade:
			NORMAL: return "furtividade normal"
			PENALIDADE: return "%d nos testes furtivos" % STEALTH_PENALTY
			_: return "desvantagem nos testes furtivos"

var effect_text: String:
	get:
		if slot == ARMA:
			return "carta %s (%s)" % [carta.name, carta.dice] if carta != null else ""
		return "CA %+d · CAM %+d · %s" % [ca, cam, stealth_text]
