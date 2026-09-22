class_name Upgrade
extends RefCounted
## Porte de game/core/upgrades.py::Upgrade. Gerado por tools/gen_dataclasses.py; métodos à mão.

var id: String = ""
var nome: String = ""
var efeito: String = ""
var custos: Array = []
var titulo_requerido = null

var max_level: int:
	get:
		return custos.size()
