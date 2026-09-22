class_name ItemDef
extends RefCounted
## Porte de game/core/items.py::ItemDef. Gerado por tools/gen_dataclasses.py; métodos à mão.

var id: String = ""
var nome: String = ""
var tipo: String = ""
var descricao: String = ""
var asset_id: String = ""
var check_bonus: Array = []
var next_check_bonus: int = 0

const ACESSORIO := "acessorio"
const CONSUMIVEL := "consumivel"
const PISTA := "pista"
const ARMA := "arma"

var equippable: bool:
	get:
		return tipo == ACESSORIO

var usable: bool:
	get:
		return tipo == CONSUMIVEL

func bonus_for(attribute: String) -> int:
	var total := 0
	for pair in check_bonus:
		if pair[0] == attribute:
			total += int(pair[1])
	return total

var effect_text: String:
	get:
		if not check_bonus.is_empty():
			var names := {"forca": "Força", "inteligencia": "Inteligência", "constituicao": "Constituição", "carisma": "Carisma"}
			var parts: PackedStringArray = []
			for pair in check_bonus:
				parts.append("%+d nos testes de %s" % [int(pair[1]), names.get(pair[0], pair[0])])
			return ", ".join(parts)
		if next_check_bonus != 0:
			return "%+d no próximo teste de d20" % next_check_bonus
		return "sem efeito mecânico"
