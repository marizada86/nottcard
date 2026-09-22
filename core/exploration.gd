class_name Exploration
extends RefCounted
## game/core/exploration.py — situações resolvidas por 1d20 + modificador contra uma DC (sem cartas).

const FACIL := 10
const MEDIO := 15
const DIFICIL := 20
const CRITICAL_MIN_HP_LOSS := 3
const HOOK_NAMES := {"mist_immune": "Em Casa na Névoa"}

static func _d20() -> int:
	return PyRandom.shared.randint(1, 20)

static func situations() -> Dictionary:
	return GameData.module("exploration")["SITUATIONS"]

static func attribute_labels() -> Dictionary:
	return CharacterDefs.attribute_names()

## Teste de d20. Natural 20 sempre passa, 1 sempre falha (crítica). Furtividade: cota −2, placa desvantagem.
static func resolve_check(player: Player, option: Option, roll_in: int = -1, second_roll: int = -1) -> CheckResult:
	assert(option.attribute != null, "opção de combate não tem teste")
	var armor = player.armor
	var stealth: bool = option.stealth and armor != null
	var disadvantage: bool = stealth and armor.furtividade == EquipmentDef.DESVANTAGEM
	var rolls: Array
	if roll_in < 0:
		rolls = [_d20(), _d20()] if disadvantage else [_d20()]
	else:
		rolls = [roll_in, second_roll] if (disadvantage and second_roll >= 0) else [roll_in]
	var kept: int = rolls.min()
	var mod := player.modifier_of(option.attribute)
	var bonus := 0
	for hv in option.bonus_hooks:
		if player.hooks.has(hv[0]):
			bonus += int(hv[1])
	bonus += player.backpack.check_bonus(option.attribute) + player.backpack.take_pending_bonus()
	if stealth and armor.furtividade == EquipmentDef.PENALIDADE:
		bonus += EquipmentDef.STEALTH_PENALTY
	return _finish_check(kept, mod, bonus, option, rolls, disadvantage)

static func check_preview(player: Player, option: Option) -> Variant:
	if option.attribute == null:
		return null
	var bonuses: Array = []
	for hv in option.bonus_hooks:
		if player.hooks.has(hv[0]):
			bonuses.append([HOOK_NAMES.get(hv[0], hv[0]), int(hv[1])])
	var backpack := player.backpack
	var accessory := backpack.accessory
	if accessory != null and accessory.bonus_for(option.attribute) != 0:
		bonuses.append([accessory.nome, accessory.bonus_for(option.attribute)])
	if backpack.pending_check_bonus != 0:
		bonuses.append(["consumível usado", backpack.pending_check_bonus])
	var armor = player.armor
	var stealth: bool = option.stealth and armor != null
	if stealth and armor.furtividade == EquipmentDef.PENALIDADE:
		bonuses.append([armor.nome, EquipmentDef.STEALTH_PENALTY])
	var p := CheckPreview.new()
	p.who = player.character.name
	p.attribute_label = attribute_labels()[option.attribute]
	p.modifier = player.modifier_of(option.attribute)
	p.bonuses = bonuses
	p.dc = option.dc
	p.disadvantage = stealth and armor.furtividade == EquipmentDef.DESVANTAGEM
	return p

static func _finish_check(kept: int, mod: int, bonus: int, option: Option, rolls: Array, disadvantage: bool) -> CheckResult:
	var total := kept + mod + bonus
	var natural := "20" if kept == 20 else ("1" if kept == 1 else "")
	var success: bool
	if natural == "20":
		success = true
	elif natural == "1":
		success = false
	else:
		success = total >= option.dc
	var r := CheckResult.new()
	r.roll = kept
	r.modifier = mod
	r.bonus = bonus
	r.total = total
	r.dc = option.dc
	r.success = success
	r.natural = natural
	r.rolls = rolls
	r.disadvantage = disadvantage
	return r

static func can_use_luck(player: Player, check: CheckResult) -> bool:
	return not check.success and player.luck > 0

static func reroll_with_luck(player: Player, option: Option, previous: CheckResult, roll_in: int = -1) -> CheckResult:
	assert(player.luck > 0, "sem Sorte")
	player.luck -= 1
	var second := _d20() if roll_in < 0 else roll_in
	return _finish_check(second, previous.modifier, previous.bonus, option, [previous.roll, second], false)

static func reward_kinds(outcome: Outcome) -> Array:
	var kinds: Array = []
	if outcome.xp != 0:
		kinds.append("XP")
	if outcome.draw != 0:
		kinds.append("carta")
	if outcome.item != "":
		kinds.append("item")
	return kinds

## [compradas, coube]
static func _grant(player: Player, draw: int, item: Variant) -> Array:
	var drawn := 0
	for _i in range(draw):
		if player.hand.size() >= player.hand_limit or player.draw() == null:
			break
		drawn += 1
	var stored := true
	if item != null:
		stored = player.backpack.add(item)
	return [drawn, stored]

static func settle_reward(player: Player, applied: Applied, accept: bool, budget: TempBudget = null, rng: PyRandom = null) -> Applied:
	var pending := applied.pending
	if pending == null:
		return applied
	if not accept:
		return applied.copy_with({"pending": null, "declined": true, "effect": ""})
	var ds := _grant(player, pending.draw, pending.item)
	var drawn: int = ds[0]
	var stored: bool = ds[1]
	var item: Variant = pending.item
	var temp_card: Variant = null
	var limit_hit := false
	if pending.temp_card != "" or pending.temp_item != "":
		var r := rng if rng != null else PyRandom.shared
		if pending.temp_card != "":
			temp_card = Temporaries.grant_card(player, budget, r, pending.temp_card) if budget != null else null
			limit_hit = temp_card == null
		if pending.temp_item != "":
			var got_pair: Array = Temporaries.grant_item(player, budget, r, pending.temp_item) if budget != null else [null, true]
			stored = got_pair[1]
			var got: Variant = got_pair[0]
			if got != null:
				item = got
			limit_hit = limit_hit or got == null
	var gold := applied.gold + (pending.gold if not limit_hit else 0)
	return applied.copy_with({"pending": null, "drawn": applied.drawn + drawn, "item": item, "item_stored": stored,
		"temp_card": temp_card, "limit_hit": limit_hit, "gold": gold, "effect": "" if limit_hit else applied.effect})

static func _applied_base(outcome: Outcome, hp_lost: int, discarded: Variant, healed: int) -> Applied:
	var a := Applied.new()
	a.text = outcome.text
	a.xp = outcome.xp
	a.hp_lost = hp_lost
	a.discarded = discarded
	a.gold = outcome.gold
	a.healed = healed
	a.bless = outcome.bless
	a.dishonor = outcome.dishonor
	a.clear_dishonor = outcome.clear_dishonor
	a.fight = outcome.fight
	a.remain = outcome.remain
	a.effect = outcome.effect
	return a

static func apply_outcome(player: Player, outcome: Outcome, offer: bool = false) -> Applied:
	var hp_lost := 0
	var discarded: Variant = null
	if outcome.hp_loss != null:
		var wanted := PyRandom.shared.randint(int(outcome.hp_loss[0]), int(outcome.hp_loss[1]))
		hp_lost = maxi(0, mini(wanted, player.hp - 1))
		player.hp -= hp_lost
	if outcome.discard and not player.hand.is_empty():
		discarded = player.hand.pop_at(PyRandom.shared.randrange(player.hand.size()))
		player.discard.append(discarded)
	var item: Variant = GameData.module("items")["ITEMS"].get(outcome.item) if outcome.item != "" else null
	var healed := 0
	if outcome.heal_pct != 0:
		healed = maxi(0, mini(player.max_hp - player.hp, Py.round_half_even(player.max_hp * outcome.heal_pct / 100.0)))
		player.hp += healed
	if outcome.temp_card != "" or outcome.temp_item != "":
		var a := _applied_base(outcome, hp_lost, discarded, healed)
		a.gold = maxi(0, outcome.gold)
		var pr := PendingReward.new()
		pr.draw = outcome.draw
		pr.item = item
		pr.temp_card = outcome.temp_card
		pr.temp_item = outcome.temp_item
		pr.gold = mini(0, outcome.gold)
		a.pending = pr
		return a
	if offer and (outcome.draw != 0 or item != null):
		var a2 := _applied_base(outcome, hp_lost, discarded, healed)
		var pr2 := PendingReward.new()
		pr2.draw = outcome.draw
		pr2.item = item
		a2.pending = pr2
		return a2
	var ds := _grant(player, outcome.draw, item)
	var a3 := _applied_base(outcome, hp_lost, discarded, healed)
	a3.drawn = ds[0]
	a3.item = item
	a3.item_stored = ds[1]
	return a3

static func apply_critical(player: Player, option: Option) -> Applied:
	if option.critical != null:
		var applied := apply_outcome(player, option.critical)
		return applied.copy_with({"critical": true})
	var failure := option.failure
	var worst: int = int(failure.hp_loss[1]) if failure.hp_loss != null else 0
	var hp_lost := maxi(0, mini(maxi(CRITICAL_MIN_HP_LOSS, 2 * worst), player.hp - 1))
	player.hp -= hp_lost
	var lost_card: Variant = null
	var piles: Array = []
	for pile in [player.draw_pile, player.hand, player.discard]:
		if not pile.is_empty():
			piles.append(pile)
	if not piles.is_empty():
		var weighted: Array = []
		for p in piles:
			for _c in p:
				weighted.append(p)
		var chosen: Array = PyRandom.shared.choice(weighted)
		lost_card = chosen.pop_at(PyRandom.shared.randrange(chosen.size()))
		player.exhausted.append(lost_card)
	var lost_item: Variant = null
	if not player.backpack.bag.is_empty():
		lost_item = PyRandom.shared.choice(player.backpack.bag)
		player.backpack.discard(lost_item)
	var a := Applied.new()
	a.text = failure.text
	a.xp = failure.xp
	a.hp_lost = hp_lost
	a.critical = true
	a.lost_card = lost_card
	a.lost_item = lost_item
	a.fight = failure.fight
	return a

static func apply_result(player: Player, option: Option, check: CheckResult, offer: bool = false) -> Applied:
	if check.success:
		return apply_outcome(player, option.success, offer)
	if check.critical:
		return apply_critical(player, option)
	return apply_outcome(player, option.failure)

## [CheckResult, Applied]
static func resolve_option(player: Player, option: Option, roll_in: int = -1) -> Array:
	var result := resolve_check(player, option, roll_in)
	return [result, apply_result(player, option, result)]
