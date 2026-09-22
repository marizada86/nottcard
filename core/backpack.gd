class_name Backpack
extends RefCounted
## game/core/items.py::Backpack — 1 arma + 1 acessório equipados e uma mochila de slots.

const BAG_SLOTS := 3

var weapon: ItemDef = null
var slots: int = BAG_SLOTS
var accessory: ItemDef = null
var bag: Array = []
var pending_check_bonus: int = 0

func _init(weapon_: ItemDef = null, slots_: int = BAG_SLOTS) -> void:
	weapon = weapon_
	slots = slots_

static func for_character(character, extra_slots: int = 0) -> Backpack:
	var starting: Dictionary = GameData.module("items")["STARTING_WEAPONS"]
	var id: String = character.id if character != null else ""
	return Backpack.new(starting.get(id, null), BAG_SLOTS + extra_slots)

var is_full: bool:
	get:
		return bag.size() >= slots

func add(item: ItemDef) -> bool:
	if is_full:
		return false
	bag.append(item)
	return true

func discard(item: ItemDef) -> bool:
	var i := bag.find(item)
	if i < 0:
		return false
	bag.remove_at(i)
	return true

func equip(item: ItemDef) -> bool:
	var index := bag.find(item)
	if index < 0 or not item.equippable:
		return false
	var previous := accessory
	accessory = item
	if previous != null:
		bag[index] = previous
	else:
		bag.remove_at(index)
	return true

func unequip() -> bool:
	if accessory == null or is_full:
		return false
	bag.append(accessory)
	accessory = null
	return true

func give(item: ItemDef, other: Backpack) -> bool:
	if other == self or other.is_full:
		return false
	var i := bag.find(item)
	if i >= 0:
		bag.remove_at(i)
	elif accessory == item:
		accessory = null
	else:
		return false
	other.bag.append(item)
	return true

func use(item: ItemDef) -> bool:
	var i := bag.find(item)
	if i < 0 or not item.usable:
		return false
	bag.remove_at(i)
	pending_check_bonus += item.next_check_bonus
	return true

func check_bonus(attribute: String) -> int:
	return accessory.bonus_for(attribute) if accessory != null else 0

func take_pending_bonus() -> int:
	var b := pending_check_bonus
	pending_check_bonus = 0
	return b

func give_target_has_room() -> bool:
	return not is_full

var has_actions: bool:
	get:
		for i in bag:
			if i.equippable or i.usable:
				return true
		return false

var has_anything: bool:
	get:
		return not bag.is_empty() or accessory != null or weapon != null
