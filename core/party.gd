class_name Party
extends RefCounted
## game/core/party.py — até 3 personagens em cena: economia de turno por membro, ativo, alvo dos inimigos, cura de aliados.

const PARTY_MAX := 3

var members: Array = []
var active: int = 0

## Devolve null (e `last_error`) se o tamanho do grupo é inválido — a origem levanta ValueError.
static var last_error: String = ""

static func create(players: Array) -> Party:
	last_error = ""
	if players.size() < 1 or players.size() > PARTY_MAX:
		last_error = "o grupo tem de 1 a %d personagens" % PARTY_MAX
		return null
	var p := Party.new()
	for pl in players:
		p.members.append(Member.new(pl))
	return p

var lead: Player:
	get:
		return members[0].player

var size: int:
	get:
		return members.size()

var active_member: Member:
	get:
		return members[active]

func alive_members() -> Array:
	var out: Array = []
	for m in members:
		if m.alive: out.append(m)
	return out

func downed_members() -> Array:
	var out: Array = []
	for m in members:
		if m.downed: out.append(m)
	return out

func dead_members() -> Array:
	var out: Array = []
	for m in members:
		if m.dead: out.append(m)
	return out

var all_down: bool:
	get:
		return alive_members().is_empty()

func index_of(player: Player) -> int:
	for i in range(members.size()):
		if members[i].player == player:
			return i
	return -1

func new_round() -> void:
	for member in members:
		var t := TurnState.new()
		t.actions_available = 1 + member.player.take_extra_actions()
		member.turn = t
		if member.player.grappled:
			member.turn.actions_available = 0
			member.player.grappled = false
	active = first_alive()

func first_alive() -> int:
	for i in range(members.size()):
		if members[i].alive:
			return i
	return 0

func activate(index: int) -> bool:
	if 0 <= index and index < members.size() and members[index].alive:
		active = index
		return true
	return false

func round_done() -> bool:
	for m in alive_members():
		if not m.turn.should_end:
			return false
	return true

## Índice do próximo personagem vivo (circular, depois do ativo) com Ação ou Bônus; -1 se ninguém (a origem devolve None).
func next_with_actions() -> int:
	for step in range(1, size):
		var index := (active + step) % size
		var member: Member = members[index]
		if member.alive and not member.turn.should_end:
			return index
	return -1

func choose_target(_enemy: Enemy, rng: PyRandom = null) -> Member:
	var r := rng if rng != null else PyRandom.shared
	var alive := alive_members()
	if alive.is_empty():
		alive = [members[0]]
	for member in members:
		member.player.clone_targeted = false
	var candidates: Array = []
	for m in alive:
		candidates.append([m, false])
	for m in alive:
		if m.player.clone_alive:
			candidates.append([m, true])
	var pick: Array = r.choice(candidates)
	pick[0].player.clone_targeted = pick[1]
	return pick[0]

func heal_targets(caster: Member, card: Card) -> Array:
	if card.self_only or size <= 1:
		return [caster]
	var out: Array = []
	for m in members:
		if not m.dead and m.player.hp < m.player.max_hp:
			out.append(m)
	return out

## [PV curados, levantou]
func apply_heal_to(target: Member, result: HealResult) -> Array:
	var was_down: bool = target.player.hp <= 0
	var healed := target.player.heal(result.total)
	var raised: bool = was_down and target.player.hp > 0
	if raised:
		var t := TurnState.new()
		t.actions_available = 0
		t.bonus_available = false
		target.turn = t
	return [healed, raised]

## [HealResult, PV curados, levantou]; null se o alvo não pode receber (AllyHealRefused).
func heal_ally(caster: Member, target: Member, card: Card) -> Variant:
	if not (target in heal_targets(caster, card)):
		return null
	var player := caster.player
	var modifier := player.modifier_of(card.modifier_attr) if card.modifier_attr != "" else 0
	var result := Combat.resolve_heal(card, player.combo, modifier, player)
	var hr := apply_heal_to(target, result)
	return [result, hr[0], hr[1]]

func attack_targets(enemy: Enemy, rng: PyRandom = null) -> Array:
	if enemy.peek_is_area():
		return alive_members()
	return [choose_target(enemy, rng)]
