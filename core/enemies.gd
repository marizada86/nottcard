class_name Enemies
extends RefCounted
## game/core/enemies.py — fábricas de inimigos.

const SLIME_CORRODE_CHANCE := 0.20
const MIMIC_HP_FACTOR := 1.3
const PRIEST_SUMMON_PCT := 0.5
const PRIEST_ZOMBIES := 4

static func mimico(room_hp: int, ca: int, cam: int, xp: int = 20) -> Enemy:
	return Enemy.make({"name": "Mímico", "hp": maxi(1, Py.round_half_even(room_hp * MIMIC_HP_FACTOR)), "base_attack": "1d6",
		"asset_id": "mimico", "blood_color": [150, 100, 50], "ca": ca, "cam": cam, "attack_bonus": 2, "stun_dc": 12, "xp": xp,
		"grapples": true, "special_name": "Mordida que prende"})

static func criatura_corrompida() -> Enemy:
	return Enemy.make({"name": "Criatura corrompida pela névoa", "hp": 10, "base_attack": "1d6", "asset_id": "criatura_corrompida",
		"blood_color": [110, 70, 150], "ca": 10, "cam": 10, "attack_bonus": 2, "stun_dc": 12, "xp": 10})

static func slime_corrosivo(xp: int = 5) -> Enemy:
	return Enemy.make({"name": "Slime corrosivo", "hp": 8, "base_attack": "1d4", "asset_id": "slime_corrosivo",
		"blood_color": [95, 135, 60], "ca": 9, "cam": 11, "attack_bonus": 1, "stun_dc": 10, "xp": xp,
		"corrode_chance": SLIME_CORRODE_CHANCE})

static func guardiao_copia() -> Enemy:
	return Enemy.make({"name": "Guardião alado (cópia)", "hp": 16, "base_attack": "1d8", "special_every": 2,
		"special_name": "Investida", "special_dice": "1d8", "asset_id": "guardiao_copia", "blood_color": [170, 130, 60],
		"ca": 12, "cam": 10, "attack_bonus": 3, "stun_dc": 14, "xp": 15})

static func guardiao_verdadeiro() -> Enemy:
	return Enemy.make({"name": "Guardião alado (verdadeiro)", "hp": 26, "base_attack": "1d8", "special_every": 2,
		"special_name": "Grito Abissal", "special_dice": "1d6", "special_extra": "próximo ataque de Durvall sofre -1",
		"asset_id": "guardiao_verdadeiro", "blood_color": [140, 60, 170], "ca": 13, "cam": 12, "attack_bonus": 4,
		"special_defense": "cam", "stun_dc": 16, "stun_immunity": 1, "xp": 25})

static func cultista_adaga() -> Enemy:
	return Enemy.make({"name": "Cultista", "hp": 11, "base_attack": "1d6", "asset_id": "cultista_adaga", "blood_color": [150, 60, 60],
		"ca": 11, "cam": 10, "attack_bonus": 2, "stun_dc": 12, "xp": 12})

static func cultista_cajado() -> Enemy:
	return Enemy.make({"name": "Cultista de cajado", "hp": 10, "base_attack": "1d6", "asset_id": "cultista_cajado",
		"blood_color": [130, 70, 150], "special_every": 2, "special_name": "Lampião de cera", "special_dice": "1d4",
		"special_defense": "cam", "ca": 10, "cam": 12, "attack_bonus": 2, "stun_dc": 12, "xp": 12})

static func cultista_arqueiro() -> Enemy:
	return Enemy.make({"name": "Arqueiro cultista", "hp": 8, "base_attack": "1d8", "asset_id": "cultista_arqueiro",
		"blood_color": [150, 60, 60], "ca": 9, "cam": 10, "attack_bonus": 3, "stun_dc": 11, "xp": 12})

static func zumbi() -> Enemy:
	return Enemy.make({"name": "Zumbi", "hp": 14, "base_attack": "1d6", "asset_id": "zumbi", "blood_color": [110, 120, 80],
		"ca": 9, "cam": 8, "attack_bonus": 1, "stun_dc": 10, "xp": 8})

static func _priest_summons() -> Array:
	var out: Array = []
	for _i in range(PRIEST_ZOMBIES):
		out.append(zumbi())
	return out

static func sacerdote_mente_derretida() -> Enemy:
	return Enemy.make({"name": "Sacerdote da Mente Derretida", "hp": 34, "base_attack": "1d8", "special_every": 3,
		"special_name": "Turíbulo de cera", "special_dice": "1d6", "special_defense": "cam", "special_area": true,
		"asset_id": "sacerdote_mente_derretida", "blood_color": [130, 70, 150], "ca": 12, "cam": 14, "attack_bonus": 4,
		"stun_dc": 15, "stun_immunity": 1, "xp": 30,
		"enc_script": EncounterScript.new(PRIEST_SUMMON_PCT, Callable(Enemies, "_priest_summons"))})
