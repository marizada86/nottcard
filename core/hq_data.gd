class_name HqData
extends RefCounted
## game/core/hq.py — HQs de transição (dado puro).

static func all() -> Dictionary:
	return GameData.module("hq")["HQS"]

static func by_mission() -> Dictionary:
	return GameData.module("hq")["HQ_BY_MISSION"]
