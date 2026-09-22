class_name Lore
extends RefCounted
## game/core/lore_m1.py e lore_m2.py — sabor de lore (dado puro). `mod` = "lore_m1" | "lore_m2".

static func room_intro(mod: String, room_id: int) -> String:
	return GameData.module(mod)["ROOM_INTRO"].get(room_id, "")

static func enemy_flavor(mod: String, enemy_name: String) -> String:
	return GameData.module(mod)["ENEMY_FLAVOR"].get(enemy_name, "")

static func run_end(mod: String, outcome: String) -> String:
	return GameData.module(mod)["RUN_END"].get(outcome, "")
