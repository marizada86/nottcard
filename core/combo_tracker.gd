class_name ComboTracker
extends RefCounted
## game/core/combat.py::ComboTracker — a Corrente de Classe (e a carga de Poder Místico do Kayron).

var character: CharacterDef
var damage_mult: float = 1.0
var streak: int = 0
var mystic_power: int = 0
var charge_cap: int = 8
var on_advance: Callable = Callable()   # (reached: int)
var on_break: Callable = Callable()     # (streak: int)
var guard_full: Callable = Callable()   # () -> bool
var last_event: String = ""             # "avancou" | "quebrou" | "" (nada mudou ainda)
var broken_from: int = 0
var changes: int = 0
var boost: int = 0

func _init(character_: CharacterDef = null, charge_cap_: int = -1, on_advance_: Callable = Callable(), damage_mult_: float = 1.0,
		on_break_: Callable = Callable(), guard_full_: Callable = Callable()) -> void:
	character = character_ if character_ != null else CharacterDefs.durvall()
	damage_mult = damage_mult_
	charge_cap = character.charge_cap if charge_cap_ < 0 else charge_cap_
	on_advance = on_advance_
	on_break = on_break_
	guard_full = guard_full_

## Foto congelada (só leitura pela UI).
func view() -> ComboTracker:
	var c := ComboTracker.new(character, charge_cap, on_advance, damage_mult, on_break, guard_full)
	c.streak = streak
	c.mystic_power = mystic_power
	c.last_event = last_event
	c.broken_from = broken_from
	c.changes = changes
	c.boost = boost
	return c

func _counts(card: Variant) -> bool:
	if card is String:
		return card == character.class_color
	return character.counts_for_chain(card)

func multiplier_for(card: Variant) -> int:
	if not _counts(card) or character.chain_mode == "carga":
		return 1
	return [1, 2, 3, 4][mini(streak + boost, character.chain_cap)]

var charge_mode: bool:
	get:
		return character.chain_mode == "carga"

func gain_mystic(amount: int) -> int:
	var before := mystic_power
	mystic_power = mini(charge_cap, mystic_power + maxi(0, amount))
	return mystic_power - before

func mystic_to_spend(card: Card) -> int:
	return mini(card.spends_mystic, mystic_power) if charge_mode else 0

func spend_mystic(amount: int) -> int:
	var spent := mini(amount, mystic_power)
	mystic_power -= spent
	return spent

func break_chain() -> void:
	if streak > 0:
		broken_from = streak
		last_event = "quebrou"
		changes += 1
	streak = 0

func advance(card: Variant) -> void:
	if _counts(card):
		var reached := mini(streak + boost, character.chain_cap) + 1
		if charge_mode:
			gain_mystic(reached)
		if on_advance.is_valid():
			on_advance.call(reached)
		streak = mini(mini(streak + boost, character.chain_cap) + 1, character.chain_cap)
		boost = 0
		last_event = "avancou"
		changes += 1
	else:
		if streak > 0:
			broken_from = streak
			last_event = "quebrou"
			changes += 1
			if on_break.is_valid():
				on_break.call(streak)
		streak = 0
	if not (card is String) and card.grants_mystic != 0 and charge_mode:
		gain_mystic(card.grants_mystic)
