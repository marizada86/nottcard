class_name ShopItem
extends RefCounted
## Porte de game/core/shop.py::ShopItem. Gerado por tools/gen_dataclasses.py; métodos à mão.

var id: String = ""
var nome: String = ""
var preco: int = 0
var titulo_requerido = null
var tipo: String = "layout"

const LAYOUT := "layout"
const UPGRADE := "upgrade"
const EQUIPAMENTO := "equipamento"
const PERSONAGEM := "personagem"

## Layout e equipamento se compram uma vez; o upgrade sobe de nível até o teto.
var unique: bool:
	get:
		return tipo != UPGRADE

var efeito: String:
	get:
		return Upgrades.by_id(id).efeito if tipo == UPGRADE else ""
