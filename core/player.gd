class_name Player
extends RefCounted
## game/core/state.py::Player — o estado de UM personagem numa tentativa (mão, pilhas, PV, Corrente, Cópia, Guarda).
## `hooks` e conjuntos são Dictionary {id: true}. `clone_hp`/`clone_max_hp` são null em quem não tem a Cópia Sombria.

const STARTING_HAND_SIZE := 3
const LUCK_BASE := 1

var character: CharacterDef
var upgrades: Dictionary = {}
var damage_mult: float = 1.0
var armor = null
var luck: int = 0
var level: int = 1
var hooks: Dictionary = {}
var last_stand_used: bool = false
var shadow_return_used: bool = false
var clone_return_pending: bool = false
var clone_chain_healed: bool = false
var clone_targeted: bool = false
var attributes: Dictionary = {}
var hp: int = 0
var max_hp: int = 0
var death_saves: DeathSaves = DeathSaves.new()
var next_attack_penalty: int = 0
var ca_penalty: int = 0
var draw_pile: Array = []
var hand: Array = []
var discard: Array = []
var exhausted: Array = []
var spent_class: Array = []
var clone_max_hp: Variant = null
var clone_hp: Variant = null
var combo: ComboTracker
var bless: int = 0
var grappled: bool = false
var dead: bool = false
var ca_bonus: int = 0
var hit_bonus: int = 0
var ward: bool = false
var death_ward: bool = false
var extra_actions_next: int = 0
var guard: int = 0
var dishonored: bool = false
var dishonor_ignored_used: bool = false
var exposed: bool = false
var _backpack: Backpack = null

func _init(deck: Array = [], max_hp_: Variant = null, attributes_: Variant = null, character_: CharacterDef = null, level_: int = 1,
		upgrades_: Variant = null, armor_ = null) -> void:
	character = character_ if character_ != null else CharacterDefs.durvall()
	upgrades = upgrades_.duplicate() if upgrades_ != null else {}
	damage_mult = Upgrades.damage_multiplier(upgrades)
	armor = armor_
	luck = LUCK_BASE + (1 if level_ >= 3 else 0) + (1 if level_ >= 5 else 0) + Upgrades.extra_luck(upgrades)
	level = level_
	hooks = character.hooks_at(level_)
	attributes = (character.attributes if attributes_ == null else attributes_).duplicate()
	var mhp: int = character.max_hp if max_hp_ == null else int(max_hp_)
	hp = mhp
	max_hp = mhp
	draw_pile = deck.duplicate()
	PyRandom.shared.shuffle(draw_pile)
	if character.clone_fraction != 0.0:
		clone_max_hp = int(mhp * character.clone_fraction)
	clone_hp = clone_max_hp
	combo = new_combo()
	for _i in range(mini(hand_limit, STARTING_HAND_SIZE + Upgrades.extra_hand(upgrades))):
		draw()

static func for_character(character_: CharacterDef, level_: int = 1, bonus_hp: int = 0, deck_names: Variant = null, upgrades_: Variant = null,
		weapon = null, armor_ = null, bonus_luck: int = 0, damage_bonus: float = 0.0) -> Player:
	var deck: Array = character_.deck_at(level_) if deck_names == null else Collection.run_deck(character_, deck_names, level_)
	if weapon != null and weapon.carta != null:
		deck = deck + [weapon.carta]
	var p := Player.new(deck, character_.hp_at(level_) + bonus_hp + Upgrades.bonus_hp(upgrades_), character_.attributes_at(level_), character_, level_, upgrades_, armor_)
	p.luck += bonus_luck
	if damage_bonus != 0.0:
		p.damage_mult = Py.round_n(p.damage_mult * (1 + damage_bonus), 6)
		p.combo.damage_mult = p.damage_mult
	return p

func new_combo() -> ComboTracker:
	return ComboTracker.new(character, charge_cap, Callable(self, "_on_chain_advance"), damage_mult, Callable(self, "_on_chain_break"),
		func(): return guard_cap > 0 and guard >= guard_cap)

var charge_cap: int:
	get:
		return character.charge_cap + (2 if hooks.has("charge_cap_plus2") else 0)

var clone_alive: bool:
	get:
		return clone_hp != null and clone_hp != 0

var guard_cap: int:
	get:
		return character.guard_cap

func gain_guard(amount: int) -> int:
	if guard_cap <= 0 or amount <= 0:
		return 0
	if dishonored:
		amount = maxi(1, Py.fdiv(amount, 2))
	var before := guard
	guard = mini(guard_cap, before + amount)
	return guard - before

## [absorvido, restante]
func absorb_guard(damage: int) -> Array:
	var absorbed := mini(guard, maxi(0, damage))
	guard -= absorbed
	return [absorbed, damage - absorbed]

func dishonor() -> bool:
	if guard_cap <= 0 or dishonored:
		return false
	if hooks.has("dishonor_ward") and not dishonor_ignored_used:
		dishonor_ignored_used = true
		return false
	dishonored = true
	return true

func redeem() -> bool:
	var was := dishonored
	dishonored = false
	return was

func _on_chain_break(streak: int) -> void:
	if streak >= 2:
		dishonor()

func _on_chain_advance(reached: int) -> void:
	if reached >= 2:
		gain_guard(reached - 1)
	if reached >= 3 and clone_alive and not clone_chain_healed:
		clone_chain_healed = true
		heal_clone(reached)

## [dano na Cópia, dano em PV, a Cópia caiu agora]
func take_damage(damage: int) -> Array:
	if clone_targeted and clone_alive:
		clone_targeted = false
		var absorbed := mini(int(clone_hp), damage)
		clone_hp = int(clone_hp) - absorbed
		var fell: bool = clone_hp == 0
		if fell and hooks.has("shadow_return") and not shadow_return_used:
			shadow_return_used = true
			clone_return_pending = true
		return [absorbed, 0, fell]
	clone_targeted = false
	hp -= damage
	return [0, damage, false]

func take_area_damage(damage: int) -> Array:
	var absorbed := mini(int(clone_hp) if clone_hp != null else 0, damage)
	var fell := false
	if absorbed != 0:
		clone_hp = int(clone_hp) - absorbed
		fell = clone_hp == 0
		if fell and hooks.has("shadow_return") and not shadow_return_used:
			shadow_return_used = true
			clone_return_pending = true
	hp -= damage
	return [absorbed, damage, fell]

func heal_clone(amount: int, revive: bool = false) -> int:
	if clone_max_hp == null or (not clone_alive and not revive):
		return 0
	var before: int = int(clone_hp) if clone_hp != null else 0
	clone_hp = mini(int(clone_max_hp), before + maxi(0, amount))
	return int(clone_hp) - before

func start_turn() -> bool:
	exposed = false
	clone_chain_healed = false
	ward = false
	if clone_return_pending:
		clone_return_pending = false
		clone_hp = mini(int(clone_max_hp) if clone_max_hp != null else 0, 5)
		return true
	return false

func modifier_of(attribute: String) -> int:
	return Attributes.modifier(attributes[attribute])

var backpack: Backpack:
	get:
		if _backpack == null:
			_backpack = Backpack.for_character(character, Upgrades.extra_bag_slots(upgrades))
		return _backpack

func view() -> ResourceView:
	return ResourceView.new(combo.view(), clone_max_hp, clone_hp, guard_cap, guard, dishonored)

## [[origem, valor], ...] cuja soma é ca/cam.
func defense_breakdown(def_name: String) -> Array:
	if def_name == "CA":
		return [["base", 10], ["Força", Attributes.modifier(attributes["forca"])], ["treino de defesa", character.defense_bonus_ca],
			["armadura", armor.ca if armor != null else 0], ["efeitos", ca_bonus], ["corrosão", -ca_penalty]]
	return [["base", 10], ["Inteligência", Attributes.modifier(attributes["inteligencia"])], ["treino de defesa", character.defense_bonus_cam],
		["armadura", armor.cam if armor != null else 0]]

var ca: int:
	get:
		return Attributes.armor_class(attributes) - ca_penalty + ca_bonus + character.defense_bonus_ca + (armor.ca if armor != null else 0)

var cam: int:
	get:
		return Attributes.magic_armor_class(attributes) + character.defense_bonus_cam + (armor.cam if armor != null else 0)

## Compra uma carta; null só se as duas pilhas estão vazias.
func draw() -> Variant:
	if draw_pile.is_empty():
		if discard.is_empty():
			return null
		draw_pile = discard
		discard = []
		PyRandom.shared.shuffle(draw_pile)
	var card: Card = draw_pile.pop_back()
	hand.append(card)
	return card

static func _grouped(cards: Array) -> Array:
	var counts := {}
	for c in cards:
		counts[c.name] = counts.get(c.name, 0) + 1
	var items: Array = []
	for k in counts:
		items.append([k, counts[k]])
	return Py.sorted_by(items, func(it): return String(it[0]).to_lower())

func pile_view() -> PileView:
	var v := PileView.new()
	v.compra = _grouped(draw_pile)
	v.descarte = _grouped(discard)
	v.gastas = _grouped(exhausted)
	v.hc = _grouped(spent_class)
	for pile in [draw_pile, discard, exhausted, spent_class]:
		for c in pile:
			v.cards[c.name] = c
	return v

func redraw_hand() -> void:
	var count := hand.size()
	draw_pile.append_array(hand)
	hand = []
	PyRandom.shared.shuffle(draw_pile)
	for _i in range(count):
		draw()

## As `n` cartas do topo, a próxima a ser comprada primeiro.
func peek_top(n: int) -> Array:
	if draw_pile.size() < n and not discard.is_empty():
		PyRandom.shared.shuffle(discard)
		draw_pile = discard + draw_pile
		discard = []
	var top: Array = draw_pile.slice(maxi(0, draw_pile.size() - n))
	top.reverse()
	return top

func pick_from_top(n: int, choice: int) -> Card:
	var top := peek_top(n)
	var chosen: Card = top[choice]
	var others: Array = []
	for i in range(top.size()):
		if i != choice:
			others.append(top[i])
	draw_pile.resize(draw_pile.size() - top.size())
	hand.append(chosen)
	others.reverse()
	draw_pile = others + draw_pile
	return chosen

func restore_class_abilities() -> void:
	last_stand_used = false
	ca_bonus = 0
	hit_bonus = 0
	extra_actions_next = 0
	ward = false
	death_ward = false
	shadow_return_used = false
	clone_return_pending = false
	clone_hp = clone_max_hp
	guard = 0
	dishonored = false
	dishonor_ignored_used = false
	if not spent_class.is_empty():
		draw_pile.append_array(spent_class)
		spent_class = []
		PyRandom.shared.shuffle(draw_pile)

func strip_scrolls() -> void:
	for pile_name in ["draw_pile", "hand", "discard", "exhausted", "spent_class"]:
		var kept: Array = []
		for c in get(pile_name):
			if not c.scroll:
				kept.append(c)
		set(pile_name, kept)

func add_scrolls(cards: Array) -> void:
	draw_pile.append_array(cards)
	PyRandom.shared.shuffle(draw_pile)

func take_extra_actions() -> int:
	var extra := extra_actions_next
	extra_actions_next = 0
	return extra

var hand_limit: int:
	get:
		return Upgrades.hand_limit(upgrades)

func excess_count() -> int:
	return maxi(0, hand.size() - hand_limit)

func discard_at(index: int) -> Card:
	var card: Card = hand.pop_at(index)
	discard.append(card)
	return card

func discard_excess() -> Array:
	var discarded: Array = []
	while hand.size() > hand_limit:
		var card: Card = hand.pop_back()
		discard.append(card)
		discarded.append(card)
	return discarded

func heal(amount: int) -> int:
	var before := hp
	hp = mini(max_hp, hp + amount)
	if before <= 0 and 0 < hp:
		death_saves.reset()
	return hp - before

func is_alive() -> bool:
	return hp > 0

var is_downed: bool:
	get:
		return hp <= 0 and not dead

func revive(hp_: int = 1) -> void:
	hp = maxi(1, mini(hp_, max_hp))
	dead = false
	death_saves.reset()
