class_name WorldSupport
extends RefCounted
## Auxiliares dos testes de paridade de mundo/exploração/eventos.

static func mk_player(cid: String, level: int, seed_value: int, armor: Variant = null, items: Array = [], upgrades: Variant = null) -> Player:
	PyRandom.shared = PyRandom.new(seed_value)
	var p := Player.for_character(CharacterDefs.get_def(cid), level, 0, null, upgrades, null, armor)
	for i in items:
		p.backpack.add(i)
	return p

static func item(id: String) -> ItemDef:
	return GameData.module("items")["ITEMS"][id]

static func armor(id: String) -> Variant:
	return Equipment.by_id(id)

## Eventos do Walker → arrays como o golden: [tipo, campos...] (mesma ordem de dataclasses.astuple).
static func ev_arrays(events: Array) -> Array:
	var out: Array = []
	for e in events:
		match e["type"]:
			"Moved": out.append(["Moved", e["x"], e["y"], e["backward"]])
			"Turned": out.append(["Turned", e["facing"], e["delta"]])
			"Blocked": out.append(["Blocked", e["x"], e["y"]])
			"DoorOpened": out.append(["DoorOpened", e["x"], e["y"]])
			"EnteredRoom": out.append(["EnteredRoom", e["room"]])
	return out
