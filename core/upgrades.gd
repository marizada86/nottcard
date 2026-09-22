class_name Upgrades
extends RefCounted
## game/core/upgrades.py — upgrades permanentes da loja.

const FORCA_BRUTA := "forca_bruta"
const VITALIDADE := "vitalidade"
const MAO_CHEIA := "mao_cheia"
const RERROLAGEM := "rerrolagem"
const SORTE := "sorte"
const BOLSO_FUNDO := "bolso_fundo"
const GANANCIA := "ganancia"
const MAO_MAIOR := "mao_maior"
const BASE_MAX_HAND := 5
const DAMAGE_PCT_PER_LEVEL := 0.04
const HP_PER_LEVEL := 2
const COINS_PCT_PER_LEVEL := 0.10

static func all() -> Array:
	return GameData.module("upgrades")["UPGRADES"]

static func by_id(upgrade_id: String) -> Variant:
	for u in all():
		if u.id == upgrade_id:
			return u
	return null

## Nível dentro do teto (um save adulterado não passa dele). `upgrades` pode ser null/vazio.
static func level(upgrades: Variant, upgrade_id: String) -> int:
	if upgrades == null or upgrades.is_empty():
		return 0
	var u = by_id(upgrade_id)
	if u == null:
		return 0
	return maxi(0, mini(u.max_level, int(upgrades.get(upgrade_id, 0))))

static func is_maxed(upgrades: Variant, upgrade_id: String) -> bool:
	return level(upgrades, upgrade_id) >= by_id(upgrade_id).max_level

## Custo do próximo nível; -1 no teto (a origem devolve None).
static func cost_of_next(upgrades: Variant, upgrade_id: String) -> int:
	var u = by_id(upgrade_id)
	var current := level(upgrades, upgrade_id)
	return -1 if current >= u.max_level else int(u.custos[current])

static func damage_multiplier(upgrades: Variant) -> float:
	return 1 + DAMAGE_PCT_PER_LEVEL * level(upgrades, FORCA_BRUTA)

static func bonus_hp(upgrades: Variant) -> int:
	return HP_PER_LEVEL * level(upgrades, VITALIDADE)

static func hand_limit(upgrades: Variant) -> int:
	return BASE_MAX_HAND + level(upgrades, MAO_MAIOR)

static func extra_hand(upgrades: Variant) -> int:
	return level(upgrades, MAO_CHEIA)

static func rerolls(upgrades: Variant) -> int:
	return level(upgrades, RERROLAGEM)

static func extra_luck(upgrades: Variant) -> int:
	return level(upgrades, SORTE)

static func extra_bag_slots(upgrades: Variant) -> int:
	return level(upgrades, BOLSO_FUNDO)

static func coins_with_greed(upgrades: Variant, gained: int) -> int:
	if gained <= 0:
		return gained
	return Py.ceil6(gained * (1 + COINS_PCT_PER_LEVEL * level(upgrades, GANANCIA)))
