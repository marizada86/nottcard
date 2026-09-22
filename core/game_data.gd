class_name GameData
extends RefCounted
## Carrega o conteúdo declarativo exportado do Python (data/core/<módulo>.json) e o hidrata em objetos tipados.
## Dicionários com "__type" viram instâncias (registro TYPES); chaves numéricas viram int; {"__fn": ...} fica como está.

const TYPES := {
	"Card": preload("res://core/card.gd"),
	"ItemDef": preload("res://core/item_def.gd"),
	"Upgrade": preload("res://core/upgrade.gd"),
	"EquipmentDef": preload("res://core/equipment_def.gd"),
	"ScrollDef": preload("res://core/scroll_def.gd"),
	"LevelReward": preload("res://core/level_reward.gd"),
	"CharacterDef": preload("res://core/character_def.gd"),
	"Outcome": preload("res://core/outcome.gd"),
	"Option": preload("res://core/option.gd"),
	"Situation": preload("res://core/situation.gd"),
	"EventDef": preload("res://core/event_def.gd"),
	"Room": preload("res://core/room.gd"),
	"ShopItem": preload("res://core/shop_item.gd"),
	"Achievement": preload("res://core/achievement.gd"),
	"LayoutUnlock": preload("res://core/layout_unlock.gd"),
	"Panel": preload("res://core/hq_panel.gd"),
	"Hq": preload("res://core/hq.gd"),
}

## Nomes de campo que colidem com propriedades nativas do Object.
const RENAME := {"script": "enc_script", "class_name": "class_label", "build_deck": "build_deck_fn", "build_deck__result": "deck_result"}

## Dataclasses imutáveis (frozen) na origem: valores iguais viram a MESMA instância, então `in`/`remove`/`==` por referência
## equivalem à igualdade por valor do Python.
const IMMUTABLE := ["Card", "ItemDef", "Upgrade", "LevelReward", "EquipmentDef", "ScrollDef", "ShopItem", "LayoutUnlock", "MissionDef", "Achievement", "CharacterDef", "Outcome", "Option", "Situation", "Panel", "Hq"]
static var _interned: Dictionary = {}
static var _cache: Dictionary = {}

static func module(name: String) -> Dictionary:
	if _cache.has(name):
		return _cache[name]
	var f := FileAccess.open("res://data/core/%s.json" % name, FileAccess.READ)
	assert(f != null, "data/core/%s.json ausente (rode tools/export_data.py)" % name)
	var raw: Variant = JSON.parse_string(f.get_as_text())
	var out := {}
	for k in raw:
		out[k] = hydrate(raw[k])
	_cache[name] = out
	return out

static func get_const(mod: String, name: String) -> Variant:
	return module(mod)[name]

static func hydrate(v: Variant) -> Variant:
	if v is Array:
		var a: Array = []
		for x in v:
			a.append(hydrate(x))
		return a
	if v is Dictionary:
		if v.has("__type"):
			var script = TYPES.get(v["__type"])
			assert(script != null, "tipo sem porte: %s" % v["__type"])
			var ikey := ""
			if v["__type"] in IMMUTABLE:
				ikey = JSON.stringify(v)
				if _interned.has(ikey):
					return _interned[ikey]
			var obj = script.new()
			for k in v:
				if k == "__type":
					continue
				# fábricas (funções) não viajam nos dados: o porte as reconstrói em código (ver Rooms)
				if (v[k] is Dictionary and v[k].has("__fn")) and not RENAME.has(k):
					continue
				if String(k).ends_with("__result") and not RENAME.has(k):
					continue
				obj.set(RENAME.get(k, k), hydrate(v[k]))
			if ikey != "":
				_interned[ikey] = obj
			return obj
		var d := {}
		for k in v:
			if k == "__tuplekeys":
				continue
			d[_key(k)] = hydrate(v[k]) if not (v[k] is Dictionary and v[k].has("__fn")) else v[k]
		return d
	# JSON lê todo número como float; inteiros exatos voltam a int
	if v is float and v == floorf(v) and absf(v) < 9.0e15:
		return int(v)
	return v

static func _key(k: String) -> Variant:
	if k.is_valid_int():
		return int(k)
	return k
