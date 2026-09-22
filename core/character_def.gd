class_name CharacterDef
extends RefCounted
## game/core/characters.py::CharacterDef — personagem como dado (atributos, cor de classe, passiva, baralho, PV).
## Campos renomeados na importação (GameData.RENAME): class_name → class_label; build_deck → deck_result (o baralho já montado).

const HP_GAME_SCALE := 10
const HP_LEVEL_SCALE := 0.5
const ATTRIBUTE_CAP := 18

var id: String = ""
var name: String = ""
var class_label: String = ""
var class_color: String = ""
var attributes: Dictionary = {}
var hit_die: int = 0
var deck_result: Array = []
var build_deck_fn: Variant = null
var passive_text: String = ""
var passive_name: String = ""
var chain_elements: Array = []
var chain_element_kinds: Array = []
var chain_bonus_dice: Dictionary = {}
var hit_attr_by_element: Dictionary = {}
var level_rewards: Dictionary = {}
var chain_mode: String = "multiplicador"
var charge_cap: int = 8
var chain_cap: int = 3
var guard_cap: int = 0
var clone_fraction: float = 0.0
var defense_bonus_ca: int = 0
var defense_bonus_cam: int = 0

func build_deck() -> Array:
	return deck_result.duplicate()

func _sorted_levels() -> Array:
	var keys := level_rewards.keys()
	keys.sort()
	return keys

## [[carta, nível que a libera], ...], uma vez cada.
func catalog() -> Array:
	var seen := {}
	var cards: Array = []
	for card in build_deck():
		if not seen.has(card.name):
			seen[card.name] = true
			cards.append([card, 1])
	for lvl in _sorted_levels():
		for card in level_rewards[lvl].cards:
			if not seen.has(card.name):
				cards.append([card, lvl])
	return cards

func deck_at(level: int) -> Array:
	var deck := build_deck()
	for lvl in _sorted_levels():
		if 2 <= lvl and lvl <= level:
			deck.append_array(level_rewards[lvl].cards)
	return deck

func hp_at(level: int) -> int:
	var con := Attributes.modifier(attributes_at(level)["constituicao"])
	var gain := maxi(1, int((hit_die / 2 + 1 + con) * HP_LEVEL_SCALE + 0.5))
	return HP_GAME_SCALE + hit_die + con + (maxi(1, level) - 1) * gain

var max_hp: int:
	get:
		return hp_at(1)

func attributes_at(level: int) -> Dictionary:
	var attrs := attributes.duplicate()
	for lvl in _sorted_levels():
		if lvl <= level:
			var bonus: Dictionary = level_rewards[lvl].attr_bonus
			for attribute in bonus:
				attrs[attribute] = mini(ATTRIBUTE_CAP, attrs[attribute] + bonus[attribute])
	return attrs

## Conjunto (Dictionary) dos ganchos liberados até `level`.
func hooks_at(level: int) -> Dictionary:
	var out := {}
	for lvl in level_rewards:
		if lvl <= level:
			for h in level_rewards[lvl].hooks:
				out[h] = true
	return out

## [[nome, descrição], ...] das passivas de nível já liberadas.
func unlocked_passives(level: int) -> Array:
	var out: Array = []
	for lvl in _sorted_levels():
		var r: LevelReward = level_rewards[lvl]
		if lvl <= level and r.passive != "":
			out.append([r.passive, r.passive_text])
	return out

func reward_texts(level: int) -> Array:
	if not level_rewards.has(level):
		return []
	var reward: LevelReward = level_rewards[level]
	var texts: Array = []
	for card in reward.cards:
		texts.append("Nova carta: %s" % card.name)
	if reward.passive != "":
		texts.append("Passiva: %s" % reward.passive)
	var names: Dictionary = GameData.module("characters")["ATTRIBUTE_NAMES"]
	for attribute in reward.attr_bonus:
		texts.append("+%d %s" % [reward.attr_bonus[attribute], names[attribute]])
	return texts

func modifier_of(attribute: String) -> int:
	return Attributes.modifier(attributes[attribute])

func color_modifier(color: String) -> int:
	return modifier_of(Attributes.color_attribute(color))

func counts_for_chain(card: Card) -> bool:
	if card.color == class_color:
		return true
	if not chain_element_kinds.is_empty() and not (card.kind in chain_element_kinds):
		return false
	for e in card.elements:
		if e in chain_elements:
			return true
	return false

## Atributo do teste de acerto da carta; "" (None na origem) se a carta não rola acerto.
func hit_attribute(card: Card) -> String:
	if card.color == "Vermelho":
		return "forca"
	if card.color == "Roxo":
		return "carisma"
	if card.color == "Amarelo":
		for element in card.elements:
			if hit_attr_by_element.has(element):
				return hit_attr_by_element[element]
		return "inteligencia"
	return ""
