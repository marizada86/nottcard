class_name Enemy
extends RefCounted
## game/core/enemies.py::Enemy (mutável: o combate altera PV, atordoamento, penalidades).

const MAX_CA_PENALTY := 4
const RENAME := {"script": "enc_script"}

var name: String = ""
var hp: int = 0
var base_attack: String = ""
var special_every: int = 0
var special_name: String = ""
var special_dice: String = ""
var special_extra: String = ""
var turns_taken: int = 0
var next_attack_reduction: int = 0
var stunned: bool = false
var stun_left: int = 0
var thunder_mark: String = ""
var stun_dc: int = 12
var stun_immunity: int = 0
var stun_immune: int = 0
var xp: int = 0
var ca_penalty: int = 0
var cam_penalty: int = 0
var marked_bonus: int = 0
var asset_id = null
var blood_color: Array = [140, 60, 170]
var ca: int = 10
var cam: int = 10
var attack_bonus: int = 0
var corrode_chance: float = 0.0
var corrode_amount: int = 1
var special_defense: String = "ca"
var special_area: bool = false
## Dano fixo ao próprio inimigo quando ele prepara uma ação especial.
## Usado somente pelo Amálgama de Willie; não cria uma aura recorrente.
var special_self_damage: int = 0
var grapples: bool = false
var grapple_dc: int = 12
var enc_script: EncounterScript = null
var max_hp: int = 0

## Equivalente ao construtor do dataclass: campos por nome + max_hp = hp.
static func make(fields: Dictionary) -> Enemy:
	var e := Enemy.new()
	for k in fields:
		e.set(RENAME.get(k, k), fields[k])
	e.max_hp = e.hp
	return e

var slug: String:
	get:
		return asset_id if asset_id != null and asset_id != "" else Card.slugify(name)

func is_alive() -> bool:
	return hp > 0

var effective_ca: int:
	get:
		return ca - ca_penalty

var effective_cam: int:
	get:
		return cam - cam_penalty

func break_ward(amount: int) -> int:
	var new_value := mini(MAX_CA_PENALTY, cam_penalty + amount)
	var dropped := new_value - cam_penalty
	cam_penalty = new_value
	return dropped

func break_armor(amount: int) -> int:
	var new_value := mini(MAX_CA_PENALTY, ca_penalty + amount)
	var dropped := new_value - ca_penalty
	ca_penalty = new_value
	return dropped

func mark(bonus: int) -> void:
	marked_bonus = maxi(marked_bonus, bonus)

func consume_mark() -> int:
	var bonus := marked_bonus
	marked_bonus = 0
	return bonus

## [nome, dado] do próximo ataque, sem avançar o contador.
func peek_action() -> Array:
	var upcoming := turns_taken + 1
	if special_every != 0 and upcoming % special_every == 0:
		return [special_name, special_dice]
	return ["ataque básico", base_attack]

func peek_is_special() -> bool:
	return special_every != 0 and (turns_taken + 1) % special_every == 0

func peek_is_magical() -> bool:
	return peek_is_special() and special_defense == "cam"

func peek_is_area() -> bool:
	return peek_is_special() and special_area

var can_be_stunned: bool:
	get:
		return is_alive() and not stunned and stun_immune <= 0

var is_vulnerable: bool:
	get:
		return stunned or ca_penalty > 0 or cam_penalty > 0 or marked_bonus > 0

func try_stun(attacks: int = 1) -> bool:
	if not can_be_stunned:
		return false
	stunned = true
	stun_left = maxi(1, attacks)
	return true

func consume_stun() -> void:
	stun_left = maxi(0, stun_left - 1)
	if stun_left > 0:
		return
	stunned = false
	stun_immune = stun_immunity

func tick_stun_immunity() -> void:
	if stun_immune > 0:
		stun_immune -= 1

func choose_action() -> Array:
	turns_taken += 1
	if special_every != 0 and turns_taken % special_every == 0:
		return [special_name, special_dice]
	return ["ataque básico", base_attack]

## Um valor por dado; crítico dobra o NÚMERO de dados.
static func roll_damage(dice: String, crit: bool = false) -> Array:
	var parts := dice.to_lower().split("d")
	var out: Array = []
	for _i in range(int(parts[0]) * (2 if crit else 1)):
		out.append(Dice.roll("1d%s" % parts[1]))
	return out

func act() -> Array:
	var a := choose_action()
	return [a[0], Py.sum_int(roll_damage(a[1]))]
