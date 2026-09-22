class_name Economy
extends RefCounted
## game/core/economy.py — ouro da missão e moedas.

const CHARISMA_PCT_PER_MOD := 0.20
const GOLD_MULTIPLIER_CAP := 2.0

static func charisma_bonus(charisma_mod: int) -> float:
	return CHARISMA_PCT_PER_MOD * maxi(0, charisma_mod)

static func greed_bonus(upgrades: Variant) -> float:
	return Upgrades.COINS_PCT_PER_LEVEL * Upgrades.level(upgrades, Upgrades.GANANCIA)

static func gold_multiplier(upgrades: Variant, charisma_mod: int) -> float:
	return minf(GOLD_MULTIPLIER_CAP, 1 + charisma_bonus(charisma_mod) + greed_bonus(upgrades))

static func convert_bag(mission_gold: int, outcome: String) -> int:
	if mission_gold <= 0:
		return 0
	return int(mission_gold * ProgressRules.DEFEAT_XP_KEPT) if outcome == ProgressRules.DERROTA else mission_gold

static func spendable_gold(ledger: RunLedger, save: SaveState) -> int:
	return maxi(0, ledger.mission_gold) + maxi(0, save.coins)

static func spend_gold(ledger: RunLedger, save: SaveState, price: int) -> bool:
	if price <= 0:
		return true
	if spendable_gold(ledger, save) < price:
		return false
	var from_bag := mini(maxi(0, ledger.mission_gold), price)
	ledger.mission_gold -= from_bag
	save.coins -= price - from_bag
	return true

static func settle_coins(xp_coins: int, mission_gold: int, outcome: String, upgrades: Variant, charisma_mod: int) -> CoinSettlement:
	var bag := convert_bag(mission_gold, outcome)
	var base := maxi(0, xp_coins) + bag
	var multiplier := gold_multiplier(upgrades, charisma_mod)
	var s := CoinSettlement.new()
	s.xp_coins = maxi(0, xp_coins)
	s.bag_coins = bag
	s.multiplier = multiplier
	s.charisma_pct = Py.round_half_even(charisma_bonus(charisma_mod) * 100)
	s.greed_pct = Py.round_half_even(greed_bonus(upgrades) * 100)
	s.total = Py.ceil6(base * multiplier) if base > 0 else 0
	return s
