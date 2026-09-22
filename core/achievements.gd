class_name Achievements
extends RefCounted
## game/core/achievements.py — conquistas e os benefícios que elas dão.

const MULLIGAN := "mulligan"
const BONUS_HP := "bonus_hp"
const KEEP_REACTION := "keep_reaction"
const EXTRA_LUCK := "extra_luck"
const GROUP_2 := "group_2"
const GROUP_3 := "group_3"
const BUY_SLOT := "buy_slot"
const BUY_BROOK := "buy_brook"
const LEVEL_FOR_GROUPS := 3
const BONUS_HP_AMOUNT := 2
const CRITS_FOR_LUCK := 3
const DAMAGE_BONUS := "damage_bonus"
const BIG_HIT := 30
const DAMAGE_BONUS_PCT := 0.10
const GRANT_CARD := "grant_card"
const LEVEL_FOR_VETERAN := 4
const ONES_FOR_UNLUCKY := 3

static func all() -> Array:
	return GameData.module("achievements")["ACHIEVEMENTS"]

static func by_id(achievement_id: String) -> Variant:
	for a in all():
		if a.id == achievement_id:
			return a
	return null

## A condição de cada conquista (o `earned` da origem), pelo id.
static func earned(achievement_id: String, save: SaveState, outcome: String, stats: RunStats) -> bool:
	match achievement_id:
		"veteranos":
			var owned: Array = []
			for cid in CharacterDefs.all():
				if save.unlocked_characters.has(cid):
					owned.append(cid)
			if owned.is_empty():
				return false
			for cid in owned:
				if not save.progress.has(cid) or save.progress[cid].level < ProgressRules.MAX_LEVEL:
					return false
			return true
		"fechadura", "_victory":
			return outcome == ProgressRules.VITORIA
		"sorte":
			return stats.crits >= CRITS_FOR_LUCK
		"infeliz":
			return stats.natural_ones >= ONES_FOR_UNLUCKY
		"dupla":
			for cid in save.progress:
				if save.unlocked_characters.has(cid) and save.progress[cid].level >= LEVEL_FOR_GROUPS:
					return true
			return false
		"trio":
			for cid in CharacterDefs.all():
				if not save.unlocked_characters.has(cid) or not save.progress.has(cid) or save.progress[cid].level < LEVEL_FOR_GROUPS:
					return false
			return true
		"veterano_durvall":
			return save.progress.has("durvall") and save.progress["durvall"].level >= LEVEL_FOR_VETERAN
		"golpe_devastador":
			return stats.max_hit >= BIG_HIT
		"concluir_m2":
			return outcome == ProgressRules.VITORIA and (stats.mission_id == "m2" or save.missions_completed.has("m2"))
		"m2_em_dupla":
			return outcome == ProgressRules.VITORIA and stats.mission_id == "m2" and stats.party_size >= 2
	return false

## As conquistas que a tentativa que acabou acaba de conquistar.
static func evaluate(save: SaveState, outcome: String, stats: RunStats) -> Array:
	var out: Array = []
	for a in all():
		if not save.achievements.has(a.id) and earned(a.id, save, outcome, stats):
			out.append(a)
	return out

static func has_benefit(save: SaveState, key: String) -> bool:
	for i in save.achievements:
		var a = by_id(i)
		if a != null and a.benefit_key == key:
			return true
	return false

static func unlock_all(save: SaveState) -> void:
	for a in all():
		save.achievements[a.id] = true

## Cartas das conquistas recém-ganhas vão para a coleção. Devolve os nomes.
static func grant_cards(save: SaveState, earned_list: Array) -> Array:
	var names: Array = []
	for a in earned_list:
		names.append_array(a.grants)
	if not names.is_empty():
		Collection.grant_cards(save, Collection.resolve(names))
	return names
