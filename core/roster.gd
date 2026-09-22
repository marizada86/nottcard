class_name Roster
extends RefCounted
## game/core/roster.py — elenco, grupo e compra de personagens.

const CHARACTER_PRICE := 300
const SLOT_ACHIEVEMENTS := ["dupla", "concluir_m2", "m2_em_dupla"]
const BROOK_ACHIEVEMENT := "concluir_m2"
const GROUP_ACHIEVEMENTS := {2: "dupla", 3: "trio"}

static func has_character(save: SaveState, character_id: String) -> bool:
	return not save.roster_rules or save.unlocked_characters.has(character_id)

static func needs_starter(save: SaveState) -> bool:
	return save.roster_rules and save.unlocked_characters.is_empty()

static func choose_starter(save: SaveState, character_id: String) -> bool:
	if not needs_starter(save) or not (character_id in Missions.STARTERS):
		return false
	save.unlocked_characters = {character_id: true}
	return true

static func party_limit(save: SaveState) -> int:
	if not save.roster_rules:
		return 3
	var limit := 1
	if save.achievements.has(GROUP_ACHIEVEMENTS[2]):
		limit = 2
	if save.achievements.has(GROUP_ACHIEVEMENTS[3]):
		limit = 3
	return limit

static func group_hint(save: SaveState) -> String:
	var limit := party_limit(save)
	if limit >= 3:
		return ""
	return "Conquista: %s" % ("Dupla" if limit == 1 else "Trio")

static func open_slots(save: SaveState) -> int:
	var n := 0
	for a in SLOT_ACHIEVEMENTS:
		if save.achievements.has(a):
			n += 1
	return n

static func bought_starters(save: SaveState) -> int:
	var n := 0
	for s in Missions.STARTERS:
		if save.unlocked_characters.has(s):
			n += 1
	return maxi(0, n - 1)

static func can_buy(save: SaveState, character_id: String) -> bool:
	if not save.roster_rules or has_character(save, character_id):
		return false
	if character_id == Missions.BROOK:
		return save.achievements.has(BROOK_ACHIEVEMENT)
	if character_id in Missions.STARTERS:
		return bought_starters(save) < open_slots(save)
	return false

static func buy_hint(save: SaveState, character_id: String) -> String:
	if character_id == Missions.BROOK:
		return "Conclua a M2 (A Praça da Loucura)"
	if bought_starters(save) >= open_slots(save):
		var hints := {0: "Conquista: Dupla", 1: "Conclua a M2", 2: "Conclua a M2 com um grupo de dois"}
		return hints.get(open_slots(save), "Nenhuma vaga aberta")
	return "Vaga aberta"

static func unlock(save: SaveState, character_id: String) -> void:
	save.unlocked_characters[character_id] = true

static func can_play(mission: MissionDef, save: SaveState, character_id: String) -> bool:
	if not has_character(save, character_id):
		return false
	return not save.roster_rules or save.missions_completed.has(mission.id) or character_id in mission.cast

static func why_not(mission: MissionDef, save: SaveState, character_id: String) -> String:
	if not has_character(save, character_id):
		return "Bloqueado"
	if not can_play(mission, save, character_id):
		return "Fora do elenco (conclua a missão antes)"
	return ""

## [pode, motivo]
static func can_field(mission: MissionDef, save: SaveState, character_ids: Array) -> Array:
	if character_ids.is_empty():
		return [false, "Escolha um personagem"]
	if character_ids.size() > party_limit(save):
		var hint := group_hint(save)
		return [false, hint if hint != "" else "Grupo cheio"]
	for cid in character_ids:
		if not can_play(mission, save, cid):
			return [false, why_not(mission, save, cid)]
	return [true, ""]
