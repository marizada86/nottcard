class_name TurnState
extends RefCounted
## game/core/turn.py — a economia do turno: 1 Ação + 1 Ação Bônus (+ Reação fora do turno).

var actions_available: int = 1
var bonus_available: bool = true
var reaction_available: bool = true
var hit_this_turn: bool = false

func can_play(card: Card) -> bool:
	if card.action_type == "reacao":
		return false
	if card.requires_hit and not hit_this_turn:
		return false
	if card.action_type == "bonus":
		return bonus_available
	return actions_available > 0

func spend_for(card: Card) -> void:
	if card.action_type == "bonus":
		bonus_available = false
	else:
		actions_available -= 1
	actions_available += card.grants_action

func spend_action() -> bool:
	if actions_available <= 0:
		return false
	actions_available -= 1
	return true

func spend_bonus() -> bool:
	if not bonus_available:
		return false
	bonus_available = false
	return true

func can_react(card: Card, attack_kind: String, has_roll: bool = true) -> bool:
	return (reaction_available and card.action_type == "reacao"
		and card.reacts_to in [attack_kind, "qualquer"] and (has_roll or not card.forces_disadvantage))

func spend_reaction() -> void:
	reaction_available = false

var should_end: bool:
	get:
		return actions_available <= 0 and not bonus_available
