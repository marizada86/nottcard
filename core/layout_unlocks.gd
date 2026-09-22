class_name LayoutUnlocks
extends RefCounted
## game/core/layout_unlocks.py — layouts de carta por classe, desbloqueados por mortes.

const CLASSIC_LAYOUT := "classico"
const MIST_LAYOUT := "nevoa"
const ALWAYS_OWNED := ["classico", "nevoa"]
const MILESTONES := [10, 20, 30]
const AVAILABLE_GRADES := [1, 2, 3]

static func all() -> Array:
	return GameData.module("layout_unlocks")["UNLOCKS"]

static func by_layout(layout_id: String) -> Variant:
	for u in all():
		if u.layout_id == layout_id:
			return u
	return null

static func by_achievement(achievement_id: String) -> Variant:
	for u in all():
		if u.achievement_id == achievement_id:
			return u
	return null

static func kills_of(save: SaveState, character_id: String) -> int:
	var p: Variant = save.progress.get(character_id)
	return p.kills if p != null else 0

static func missing_kills(save: SaveState, unlock: LayoutUnlock) -> int:
	return maxi(0, unlock.kills_needed - kills_of(save, unlock.character_id))

## Os marcos que as mortes acumuladas acabam de cruzar.
static func evaluate(save: SaveState) -> Array:
	var out: Array = []
	for u in all():
		if not save.achievements.has(u.achievement_id) and missing_kills(save, u) == 0:
			out.append(u)
	return out

static func owned_layouts(save: SaveState) -> Array:
	var out: Array = ALWAYS_OWNED.duplicate()
	for u in all():
		if u.available and save.achievements.has(u.achievement_id):
			out.append(u.layout_id)
	return out

static func unlock_all(save: SaveState) -> void:
	for u in all():
		save.achievements[u.achievement_id] = true
