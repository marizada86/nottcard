class_name Equipment
extends RefCounted
## game/core/equipment.py — armas e armaduras por personagem. `state` é um SaveState.

const ARMA := "arma"
const ARMADURA := "armadura"

static func all() -> Array:
	return GameData.module("equipment")["EQUIPMENT"]

static func by_id(item_id: String) -> Variant:
	for e in all():
		if e.id == item_id:
			return e
	return null

static func units(state: SaveState, item_id: String) -> int:
	if state.equipment_units.has(item_id):
		return maxi(0, int(state.equipment_units[item_id]))
	return 1 if state.owned.has(item_id) else 0

## Personagens com a peça equipada (menos `exclude`), na ordem do dicionário `equipped`.
static func in_use_by(state: SaveState, item_id: String, exclude: String = "") -> Array:
	var out: Array = []
	for cid in state.equipped:
		if cid != exclude and item_id in state.equipped[cid].values():
			out.append(cid)
	return out

static func free_units(state: SaveState, item_id: String, exclude: String = "") -> int:
	return units(state, item_id) - in_use_by(state, item_id, exclude).size()

static func add_unit(state: SaveState, item_id: String, count: int = 1) -> void:
	state.equipment_units[item_id] = units(state, item_id) + count
	state.owned[item_id] = true

static func migrate_units(state: SaveState) -> bool:
	var changed := false
	for item in all():
		if state.owned.has(item.id) and not state.equipment_units.has(item.id):
			state.equipment_units[item.id] = maxi(1, in_use_by(state, item.id).size())
			changed = true
	return changed

## {"arma": def|null, "armadura": def|null}
static func equipped_of(state: SaveState, character_id: String) -> Dictionary:
	var slots: Dictionary = state.equipped.get(character_id, {})
	var result := {ARMA: null, ARMADURA: null}
	for slot in result:
		var item = by_id(slots.get(slot, ""))
		if item != null and item.slot == slot and units(state, item.id) > 0 and state.owned.has(item.id):
			result[slot] = item
	return result

static func block_reason(state: SaveState, character_id: String, item_id: String) -> String:
	var item = by_id(item_id)
	if item == null or units(state, item_id) <= 0:
		return "Você não tem esta peça."
	if not item.usable_by(character_id):
		return "%s não tem proficiência com %s." % [String(CharacterDefs.get_def(character_id).name).split(" ")[0], String(item.nome).to_lower()]
	if state.equipped.get(character_id, {}).get(item.slot) != item.id and free_units(state, item_id) <= 0:
		return "Todas as unidades de %s estão em uso: compre outra ou passe uma." % String(item.nome).to_lower()
	return ""

static func equip(state: SaveState, character_id: String, item_id: String) -> bool:
	if block_reason(state, character_id, item_id) != "":
		return false
	var item = by_id(item_id)
	if not state.equipped.has(character_id):
		state.equipped[character_id] = {}
	state.equipped[character_id][item.slot] = item.id
	return true

static func transfer(state: SaveState, from_id: String, to_id: String, slot: String) -> bool:
	var item_id: Variant = state.equipped.get(from_id, {}).get(slot)
	var item = by_id(item_id if item_id != null else "")
	if item == null or from_id == to_id or not item.usable_by(to_id):
		return false
	state.equipped[from_id].erase(slot)
	if not state.equipped.has(to_id):
		state.equipped[to_id] = {}
	state.equipped[to_id][slot] = item.id
	return true

static func unequip(state: SaveState, character_id: String, slot: String) -> bool:
	var slots: Dictionary = state.equipped.get(character_id, {})
	if not slots.has(slot):
		return false
	slots.erase(slot)
	return true

static func owned_in_slot(state: SaveState, slot: String) -> Array:
	var out: Array = []
	for e in all():
		if e.slot == slot and units(state, e.id) > 0:
			out.append(e)
	return out

## [CA, CAM] que a armadura equipada soma.
static func armor_deltas(state: SaveState, character_id: String) -> Array:
	var armor = equipped_of(state, character_id)[ARMADURA]
	return [armor.ca, armor.cam] if armor != null else [0, 0]
