class_name Enemies
extends RefCounted
## game/core/enemies.py — fábricas de inimigos.

const SLIME_CORRODE_CHANCE := 0.20
const MIMIC_HP_FACTOR := 1.3
const PRIEST_SUMMON_PCT := 0.5
const PRIEST_ZOMBIES := 4
const ASTHERION_PHASE_PCT := 0.5
const WILLIE_TENTACLES := 5

static func mimico(room_hp: int, ca: int, cam: int, xp: int = 20) -> Enemy:
	return Enemy.make({"name": "Mímico", "hp": maxi(1, Py.round_half_even(room_hp * MIMIC_HP_FACTOR)), "base_attack": "1d6",
		"asset_id": "mimico", "blood_color": [150, 100, 50], "ca": ca, "cam": cam, "attack_bonus": 2, "stun_dc": 12, "xp": xp,
		"grapples": true, "special_name": "Mordida que prende"})

static func mimico_espeto() -> Enemy:
	return Enemy.make({"name": "Mímico do Espeto", "hp": 36, "base_attack": "1d8", "special_every": 2,
		"special_name": "Mordida que prende", "special_dice": "1d8", "special_defense": "ca", "asset_id": "mimico",
		"blood_color": [150, 100, 50], "ca": 13, "cam": 12, "attack_bonus": 4, "stun_dc": 15, "xp": 45,
		"grapples": true, "grapple_dc": 14})

static func demonio_sedutor_vila() -> Enemy:
	return Enemy.make({"name": "Demônio Sedutor da Vila", "hp": 42, "base_attack": "1d8", "special_every": 2,
		"special_name": "Sussurro enfeitiçante", "special_dice": "1d6", "special_defense": "cam", "asset_id": "demonio_sedutor",
		"blood_color": [130, 70, 150], "ca": 12, "cam": 14, "attack_bonus": 4, "stun_dc": 16, "stun_immunity": 1, "xp": 50})

static func death_tyrant_altar() -> Enemy:
	return Enemy.make({"name": "Death Tyrant do Véu", "hp": 70, "base_attack": "1d8", "special_every": 2,
		"special_name": "Olhar do vazio", "special_dice": "1d6", "special_defense": "cam", "special_area": true, "asset_id": "death_tyrant",
		"blood_color": [95, 75, 150], "ca": 14, "cam": 15, "attack_bonus": 5, "stun_dc": 17, "stun_immunity": 2, "xp": 90})

static func beholder_do_templo() -> Enemy:
	return Enemy.make({"name": "Beholder da Raiz", "hp": 60, "base_attack": "1d8", "special_every": 2,
		"special_name": "Raio do olho", "special_dice": "1d6", "special_defense": "cam", "asset_id": "beholder",
		"blood_color": [110, 85, 150], "ca": 13, "cam": 15, "attack_bonus": 5, "stun_dc": 17, "stun_immunity": 2, "xp": 0,
		"enc_script": EncounterScript.new(0.5, Callable(), Callable(Enemies, "death_tyrant_altar"), "O Beholder se parte em luz fria — o Death Tyrant ocupa o altar!")})

static func kein_altar() -> Enemy:
	return Enemy.make({"name": "Kein no Altar", "hp": 52, "base_attack": "1d8", "special_every": 2,
		"special_name": "Golpe da raiz", "special_dice": "1d6", "special_defense": "ca", "asset_id": "kein_fase_1",
		"blood_color": [140, 70, 90], "ca": 13, "cam": 13, "attack_bonus": 4, "stun_dc": 16, "stun_immunity": 1, "xp": 0,
		"enc_script": EncounterScript.new(0.5, Callable(), Callable(Enemies, "beholder_do_templo"), "Kein se desfaz sob a raiz — um Beholder abre os olhos na escuridão!")})

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

static func gargula_corrompida() -> Enemy:
	return Enemy.make({"name": "Gárgula corrompida", "hp": 18, "base_attack": "1d8", "special_every": 2,
		"special_name": "Grito de pedra", "special_dice": "1d4", "special_defense": "cam",
		"asset_id": "gargula_corrompida", "blood_color": [116, 92, 142], "ca": 12, "cam": 12,
		"attack_bonus": 3, "stun_dc": 14, "stun_immunity": 1, "xp": 16})

static func rebelde_ponte() -> Enemy:
	return Enemy.make({"name": "Rebelde da ponte", "hp": 15, "base_attack": "1d6", "special_every": 3,
		"special_name": "Investida de escudo", "special_dice": "1d4", "special_defense": "ca",
		"asset_id": "rebelde_ponte", "blood_color": [138, 65, 55], "ca": 12, "cam": 11,
		"attack_bonus": 3, "stun_dc": 13, "stun_immunity": 0, "xp": 14})

static func notivago() -> Enemy:
	return Enemy.make({"name": "Notívago", "hp": 20, "base_attack": "1d6", "special_every": 2,
		"special_name": "Sopro da névoa", "special_dice": "1d4", "special_defense": "cam",
		"asset_id": "notivago", "blood_color": [85, 145, 95], "ca": 11, "cam": 12,
		"attack_bonus": 3, "stun_dc": 14, "stun_immunity": 1, "xp": 18})

static func astherion_fase_2() -> Enemy:
	return Enemy.make({"name": "Astherion — névoa absorvida", "hp": 52, "base_attack": "1d8", "special_every": 2,
		"special_name": "Ruptura da Tarn", "special_dice": "1d6", "special_defense": "cam", "special_area": true,
		"asset_id": "astherion_fase_2", "blood_color": [75, 140, 90], "ca": 14, "cam": 14,
		"attack_bonus": 5, "stun_dc": 17, "stun_immunity": 2, "xp": 55})

static func astherion_fase_1() -> Enemy:
	return Enemy.make({"name": "Astherion", "hp": 48, "base_attack": "1d8", "special_every": 2,
		"special_name": "Golpe de pressão", "special_dice": "1d6", "special_defense": "ca",
		"asset_id": "astherion_fase_1", "blood_color": [75, 140, 90], "ca": 13, "cam": 13,
		"attack_bonus": 4, "stun_dc": 16, "stun_immunity": 1, "xp": 0,
		"enc_script": EncounterScript.new(ASTHERION_PHASE_PCT, Callable(), Callable(Enemies, "astherion_fase_2"), "Astherion absorve a névoa da bacia — segunda fase!")})

static func tentaculo_willie() -> Enemy:
	return Enemy.make({"name": "Tentáculo de Willie", "hp": 16, "base_attack": "1d6", "special_every": 2,
		"special_name": "Chicote abissal", "special_dice": "1d4", "special_defense": "ca",
		"asset_id": "tentaculo_willie", "blood_color": [62, 113, 105], "ca": 10, "cam": 11,
		"attack_bonus": 2, "stun_dc": 13, "stun_immunity": 1, "xp": 12})

static func willie_amalgame() -> Enemy:
	return Enemy.make({"name": "Willie, o Amálgama Abissal", "hp": 70, "base_attack": "1d8", "special_every": 2,
		"special_name": "Aura de névoa verde", "special_dice": "1d6", "special_defense": "cam", "special_area": true,
		"special_self_damage": 6, "asset_id": "willie_amalgame", "blood_color": [67, 139, 102], "ca": 12, "cam": 13,
		"attack_bonus": 4, "stun_dc": 16, "stun_immunity": 2, "xp": 50})
