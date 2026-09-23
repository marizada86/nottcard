class_name CombatSession
extends RefCounted
## A lógica de UM combate (o que o CombateScreen do app.py decide, sem animação): turnos do grupo, cartas, ataques e reações dos inimigos,
## mortes, reforços, descarte e fim. A UI só chama estes métodos e desenha `fx` (efeitos) e `messages`.
## Fluxo do turno do jogador: play_card / action_draw / bonus_draw / end_turn → (descarte, se preciso) → run_enemy_phase.
## O ataque inimigo é em duas metades (janela de reação): begin_enemy_attack() e finish_enemy_attack(pending, carta_de_reação).

var run: RunSession
var party: Party
var slots: Array = []            # [{"enemy": Enemy, "eliminated": bool}]
var is_boss: bool = false
var messages: Array = []
var fx: Array = []               # efeitos a mostrar: {"kind","target","value","text","color"}; a UI consome e limpa
var turn_number: int = 0
var finished: bool = false
var victory: bool = false
var end_requested: bool = false
var discarding: bool = false
var reaction_pending: Variant = null      # PendingEnemyAttack
var picking: Array = []                    # Comunhão com Sendrinah: cartas do topo à espera da escolha
var _pick_card: Card = null
var acting: Variant = null                 # slot que ataca agora
var _enemy_queue: Array = []
var _area_rest: Array = []
var _area_action: Variant = null
var turn_started_msec: int = 0

func _init(run_: RunSession, enemies: Array, is_boss_: bool = false) -> void:
	run = run_
	party = run_.party
	is_boss = is_boss_
	for e in enemies:
		slots.append({"enemy": e, "eliminated": false})
	for m in party.members:
		var p: Player = m.player
		p.combo = p.new_combo()
		p.restore_class_abilities()
		p.strip_scrolls()
		p.add_scrolls(Scrolls.stock_cards(run.save_state, m.character.id))
	if slots.size() == 1:
		messages.append("Combate: %s (%d PV)" % [slots[0].enemy.name, slots[0].enemy.hp])
	else:
		var total := 0
		for s in slots: total += s.enemy.hp
		messages.append("Combate: %d inimigos (%d PV)" % [slots.size(), total])
	start_turn()

# -- consulta ------------------------------------------------------------------------------------------------

var player: Player:
	get:
		return party.active_member.player

var turn: TurnState:
	get:
		return party.active_member.turn

var who: String:
	get:
		return player.character.name

func alive_slots() -> Array:
	var out: Array = []
	for s in slots:
		if s.enemy.is_alive() and not s.eliminated:
			out.append(s)
	return out

func card_playable(card: Card) -> bool:
	if reaction_pending != null:
		return turn.can_react(card, reaction_pending.kind, reaction_pending.hit != null)
	return turn.can_play(card)

func _say(text: String) -> void:
	messages.append(text)

func _fx(kind: String, target: String, value: Variant = 0, text: String = "", color: String = "") -> void:
	fx.append({"kind": kind, "target": target, "value": value, "text": text, "color": color})

func activate(index: int) -> void:
	party.activate(index)

# -- turno do jogador ------------------------------------------------------------------------------------------

func start_turn() -> void:
	turn_number += 1
	run.stats.turns += 1
	for m in party.alive_members():
		m.player.draw()
	party.new_round()
	end_requested = false
	turn_started_msec = Time.get_ticks_msec()
	for m in party.alive_members():
		if m.player.start_turn():
			_say("Sombra Persistente: a Cópia Sombria volta com 5 PV.")
	_death_saves()

func _death_saves() -> void:
	if party.size <= 1:
		return
	for m in party.downed_members():
		var roll := DeathSaves.roll_d20()
		var p: Player = m.player
		if not p.is_downed:
			continue
		var o := p.death_saves.apply_roll(roll)
		var name: String = m.character.name
		if o["natural20"]:
			_say("%s: teste de morte 20 (natural): se levanta com 1 PV" % name)
		elif o["revived"]:
			_say("%s: teste de morte %d, sucesso (3/3): se levanta com 1 PV" % [name, roll])
		elif o["died"]:
			_say("%s: teste de morte %d, falha (3/3): morreu" % [name, roll])
		elif o["success"]:
			_say("%s: teste de morte %d, sucesso (%d/3)" % [name, roll, o["successes"]])
		else:
			_say("%s: teste de morte %d, falha (%d/3)" % [name, roll, o["failures"]])
		if o["revived"]:
			p.revive(1)
			var t := TurnState.new()
			t.actions_available = 0
			t.bonus_available = false
			m.turn = t
			_say("%s se levanta com 1 PV." % name)
		elif o["died"]:
			p.dead = true
			_say("%s morreu." % name)

func boss_timed_out() -> bool:
	return Combat.boss_timeout_expired((Time.get_ticks_msec() - turn_started_msec) / 1000.0, is_boss)

## Joga a carta `index` da mão do personagem ativo. `target_slot` (índice em `slots`) e `ally` (Member) são opcionais.
## Devolve true se a carta foi gasta.
func play_card(index: int, target_slot: int = -1, ally: Member = null) -> bool:
	if finished or reaction_pending != null or discarding or not picking.is_empty():
		return false
	var p := player
	if index < 0 or index >= p.hand.size():
		return false
	var card: Card = p.hand[index]
	if not turn.can_play(card):
		return false
	var heal_target: Member = null
	if card.targets_ally and party.size > 1:
		heal_target = ally if ally != null else party.active_member
		if not (heal_target in party.heal_targets(party.active_member, card)):
			_say("%s: %s %s." % [card.name, heal_target.character.name, "morreu" if heal_target.dead else "já está com PV cheio"])
			return false
	p.hand.remove_at(index)
	var target: Dictionary = {}
	var alive := alive_slots()
	if target_slot >= 0 and target_slot < slots.size() and slots[target_slot].enemy.is_alive():
		target = slots[target_slot]
	elif not alive.is_empty():
		target = alive[0]
	else:
		target = slots[0]
	if is_boss and card.action_type == "acao" and boss_timed_out():
		p.hand.insert(index, card)
		turn.spend_action()
		_say("%s hesita — tempo esgotado, Ação perdida." % who)
		_after_player_action()
		return true
	turn.spend_for(card)
	if card.scroll and Scrolls.consume(run.save_state, p.character.id, card):
		run.save_store.save(run.save_state)
	run.stats.cards_played += 1
	run.stats.note_multiplier(p.combo.multiplier_for(card))
	if card.single_use:
		p.exhausted.append(card)
		_say("%s é de uso único — removida do baralho." % card.name)
	elif card.class_ability:
		p.spent_class.append(card)
		_say("%s (HC) usada — só volta no próximo combate." % card.name)
	else:
		p.discard.append(card)
	_say("%s usa %s" % [who, card.name])
	_resolve(card, target, heal_target)
	_after_player_action()
	return true

func _slot_id(slot: Dictionary) -> String:
	return "enemy:%d" % slots.find(slot)

func _resolve(card: Card, target: Dictionary, heal_target: Member) -> void:
	var p := player
	var grouped := slots.size() > 1
	var enemy: Enemy = target.enemy
	match card.kind:
		"ataque":
			if card.area:
				_play_area_attack(card)
			else:
				var hit: Variant = Combat.player_attack_hit(card, p, enemy)
				run.stats.record_hit(hit)
				var result := Combat.resolve_attack(card, p.combo, hit)
				var effects := Combat.apply_card_effects(card, result, p, enemy)
				if result.acertou:
					turn.hit_this_turn = true
					_impact_on_enemy(card, result, target)
					if enemy.hp > 0:
						var check: Variant = Combat.roll_stun_check(card, p, enemy)
						if check != null:
							_stun_check(card, target, check)
				else:
					_miss_on_enemy(card, result, target)
					if hit != null and hit.fumble:
						_critical_failure(card)
				if effects.exposed or effects.stunned != 0 or effects.thunder or effects.unbalanced != 0 or effects.ward_broken != 0:
					_show_card_effects(card, effects, target)
		"controle":
			if card.area:
				var targets := alive_slots()
				var r := Combat.resolve_control(card, p.combo)
				for s in targets:
					s.enemy.next_attack_reduction += r.reduction
					_fx("text", _slot_id(s), 0, "Próximo ataque −%d" % r.reduction, "Azul")
				_say("%s vai reduzir o próximo ataque de todos em %d." % [card.name, r.reduction])
			else:
				var r2 := Combat.resolve_control(card, p.combo)
				enemy.next_attack_reduction += r2.reduction
				_say("%s vai reduzir o próximo ataque em %d." % [card.name, r2.reduction])
				_fx("text", _slot_id(target), 0, "Próximo ataque −%d" % r2.reduction, card.color)
		"atordoamento":
			Combat.resolve_stun(card, p.combo, enemy)
			if enemy.stunned:
				_say("%s atordoa %s: perde o próximo ataque." % [card.name, enemy.name])
				_fx("text", _slot_id(target), 0, "Atordoado", card.color)
			else:
				_say("%s não consegue atordoar %s." % [card.name, enemy.name])
		"cura":
			var mod := p.modifier_of(card.modifier_attr) if card.modifier_attr != "" else 0
			var heal := Combat.resolve_heal(card, p.combo, mod, p)
			_apply_heal(card, heal, heal_target)
		"localizar":
			var located := Combat.resolve_locate(card, p.combo, enemy)
			_say("%s revela o próximo ataque de %s: %s (%s)." % [card.name, enemy.name, located.attack_name, located.attack_dice])
			_fx("text", _slot_id(target), 0, "%s (+%d no acerto)" % [located.attack_name, located.bonus], card.color)
		"enfraquecer":
			var dropped := Combat.resolve_weaken(card, p.combo, enemy)
			_say("%s: CA −%d, CAM −%d em %s (CA %d, CAM %d)." % [card.name, dropped[0], dropped[1], enemy.name, enemy.effective_ca, enemy.effective_cam])
			_fx("text", _slot_id(target), 0, "CA −%d / CAM −%d" % [dropped[0], dropped[1]], card.color)
		"comunhao":
			Combat.resolve_communion(card, p.combo)
			var seen := p.peek_top(card.reveals)
			if seen.is_empty():
				_say("%s: não há cartas para ver." % card.name)
			else:
				picking = seen
				_pick_card = card
		"surto":
			var extra := Combat.resolve_surge(card, p.combo)
			p.extra_actions_next += card.grants_next_action
			_say("%s: +%d Ação neste turno." % [card.name, extra])
			_fx("text", "player", 0, "+%d Ação" % extra, card.color)
		"canalizar":
			var lg := Combat.resolve_channel(card, p.combo, p)
			_say("%s: +%d Poder Místico%s" % [card.name, lg[1], (", −%d PV" % lg[0]) if lg[0] != 0 else ""])
			_fx("text", "player", 0, "+%d Poder" % lg[1], "Roxo")
		"protecao":
			var gained := Combat.resolve_protect(card, p.combo, p)
			_say("%s: +%d de Guarda (%d/%d)." % [card.name, gained, p.guard, p.guard_cap])
			_fx("text", "player", 0, "Guarda +%d" % gained, "Azul")
		"magia":
			var buff := Combat.resolve_scroll_buff(card, p.combo, p)
			_say("%s: %s" % [card.name, buff.text])
			_fx("text", "player", 0, buff.text, card.color)
		_:
			Combat.resolve_equip(card, p.combo)
			_say("%s já está equipada." % card.name)
	if grouped and card.kind == "ataque" and not card.area:
		pass

func pick_from_top(choice: int) -> void:
	if picking.is_empty():
		return
	var chosen := player.pick_from_top(_pick_card.reveals, choice)
	_say("%s leva %s para a mão." % [who, chosen.name])
	picking = []
	_pick_card = null
	_after_player_action()

func _play_area_attack(card: Card) -> void:
	var p := player
	var targets := alive_slots()
	var hits: Array = []
	for s in targets:
		var h: Variant = Combat.player_attack_hit(card, p, s.enemy)
		run.stats.record_hit(h)
		hits.append(h)
	var results := Combat.resolve_area_attack(card, p.combo, hits)
	var any := false
	var total := 0
	var n_hit := 0
	for i in range(targets.size()):
		var r: AttackResult = results[i]
		if r.acertou:
			any = true
			n_hit += 1
			total += r.total
			_impact_on_enemy(card, r, targets[i], false)
		else:
			_miss_on_enemy(card, r, targets[i], false)
	if any:
		turn.hit_this_turn = true
	_say("%s acerta %d de %d inimigos: %d de dano no total." % [who, n_hit, targets.size(), total])

func _impact_on_enemy(card: Card, result: AttackResult, slot: Dictionary, log_it: bool = true) -> void:
	var enemy: Enemy = slot.enemy
	var hp_before := enemy.hp
	run.stats.damage_dealt += mini(result.total, hp_before)
	run.stats.record_damage(result.total)
	enemy.hp -= result.total
	if log_it:
		_say("%s acerta %s: %d de dano." % [who, enemy.name, result.total])
	_fx("damage", _slot_id(slot), result.dano_carta, "", card.color)
	if card.breaks_armor != 0:
		var dropped := enemy.break_armor(card.breaks_armor)
		if dropped != 0:
			_say("%s: a CA de %s cai %d (agora %d)." % [card.name, enemy.name, dropped, enemy.effective_ca])
			_fx("text", _slot_id(slot), 0, "CA −%d" % dropped, card.color)
		else:
			_say("%s: a CA de %s já está no mínimo." % [card.name, enemy.name])
	if result.bonus_passiva != 0:
		_fx("text", _slot_id(slot), 0, "+%d psiônico" % result.bonus_passiva, "Roxo")
	if result.bonus_mistico != 0:
		_say("%s gasta Poder Místico: +%d de dano." % [card.name, result.bonus_mistico])
		_fx("text", _slot_id(slot), 0, "+%d Poder" % result.bonus_mistico, "Roxo")
	if card.drain_frac != 0.0 and result.total > 0:
		var drained := player.heal(int(ceil(mini(result.total, hp_before) * card.drain_frac)))
		if drained != 0:
			run.stats.healing += drained
			_say("%s drena %d PV." % [card.name, drained])
			_fx("heal", "player", drained)
	var caps: Array = []
	if result.hit != null and result.hit.crit:
		caps.append("Crítico: dados dobrados")
	if result.dados_extra.size() > 0:
		caps.append("Ataque furtivo: +%d (dados extras)" % Py.sum_int(result.dados_extra))
	if result.multiplicador > 1:
		caps.append("Corrente %dx" % result.multiplicador)
	if result.compat < 1.0:
		caps.append("Cor diferente da classe ×%s" % Py.fmt_g(result.compat).replace(".", ","))
	for c in caps:
		_fx("text", _slot_id(slot), 0, c, "")

func _miss_on_enemy(_card: Card, _result: AttackResult, slot: Dictionary, log_it: bool = true) -> void:
	if log_it:
		_say("%s erra %s." % [who, slot.enemy.name])
	_fx("text", _slot_id(slot), 0, "Errou", "")

func _stun_check(card: Card, slot: Dictionary, check: StunCheck) -> void:
	var enemy: Enemy = slot.enemy
	if check.success:
		var ok := enemy.try_stun()
		_say("%s: d20 %d + Força = %d vs CD %d — atordoado!" % [card.name, check.d20, check.total, check.dc] if ok else "%s: o alvo resiste." % card.name)
		if ok:
			_fx("text", _slot_id(slot), 0, "Atordoado", card.color)
	else:
		player.combo.break_chain()
		_say("%s: d20 %d + Força = %d vs CD %d — falhou; a Corrente quebra." % [card.name, check.d20, check.total, check.dc])

func _show_card_effects(card: Card, effects: CardEffects, slot: Dictionary) -> void:
	if effects.exposed:
		_say("%s: os inimigos atacam com vantagem até o fim do próximo turno inimigo." % card.name)
	if effects.stunned != 0:
		_say("%s: %s perde os próximos %d ataques." % [card.name, slot.enemy.name, effects.stunned])
	if effects.thunder:
		_say("%s: %s sofrerá o trovão ao atacar." % [card.name, slot.enemy.name])
	if effects.unbalanced != 0:
		_say("%s: o próximo ataque de %s cai −%d." % [card.name, slot.enemy.name, effects.unbalanced])
	if effects.ward_broken != 0:
		_say("%s: a CAM de %s cai %d." % [card.name, slot.enemy.name, effects.ward_broken])

func _critical_failure(card: Card) -> void:
	_say("Falha crítica! %s: o turno acaba." % card.name)
	end_requested = true

func _apply_heal(card: Card, heal: HealResult, ally: Member) -> void:
	var p := player
	if ally != null and ally.player != p:
		var hr := party.apply_heal_to(ally, heal)
		run.stats.healing += hr[0]
		_say("%s cura %s em %d PV%s." % [card.name, ally.character.name, hr[0], " e o levanta" if hr[1] else ""])
		_fx("heal", "ally:%d" % party.index_of(ally.player), hr[0])
		return
	if card.heals_clone:
		var revived := not p.clone_alive
		var gained := p.heal_clone(heal.total, true)
		_say("%s: a Cópia Sombria %s %d PV." % [card.name, "volta com" if revived else "recupera", gained])
		_fx("text", "player", 0, "Cópia +%d" % gained, "Roxo")
		return
	var healed := p.heal(heal.total)
	run.stats.healing += healed
	_say("%s cura %d PV." % [card.name, healed])
	_fx("heal", "player", healed)
	if heal.desonra:
		_fx("text", "player", 0, "Em Desonra: cura pela metade", "")

func action_draw() -> void:
	if finished or reaction_pending != null:
		return
	if not turn.spend_action():
		_say("Nenhuma Ação sobrando pra comprar.")
		return
	var drawn := 1 if player.draw() != null else 0
	_say("%s compra %d carta%s (Ação)." % [who, drawn, "s" if drawn != 1 else ""])
	_after_player_action()

func bonus_draw() -> void:
	if finished or reaction_pending != null:
		return
	if not turn.spend_bonus():
		_say("Ação Bônus já usada neste turno.")
		return
	player.draw()
	_say("%s compra 1 carta extra (Ação Bônus)." % who)
	_after_player_action()

var can_mulligan: bool:
	get:
		return Achievements.has_benefit(run.save_state, Achievements.MULLIGAN) and not run.mulligan_used and turn_number == 1 and not finished \
			and turn.actions_available == 1 and turn.bonus_available and turn.reaction_available

func mulligan() -> void:
	run.mulligan_used = true
	player.redraw_hand()
	_say("%s troca a mão inicial." % who)

func end_turn() -> void:
	if finished or reaction_pending != null:
		return
	end_requested = true
	_say("%s encerra o turno." % who)
	_after_player_action()

func _check_scripts() -> void:
	for s in slots.duplicate():
		var script: Variant = s.enemy.enc_script
		if script == null or (not s.enemy.is_alive() and not script.phase.is_valid()):
			continue
		var successor: Variant = script.replace(s.enemy)
		if successor != null:
			s.enemy = successor
			_say(script.announce)
			_fx("text", _slot_id(s), 0, "Fase 2", "Roxo")
			continue
		var reinforcements: Array = script.check(s.enemy)
		if not reinforcements.is_empty():
			add_reinforcements(reinforcements, script.announce)

func add_reinforcements(enemies: Array, text: String = "") -> void:
	for e in enemies:
		slots.append({"enemy": e, "eliminated": false})
	if text != "":
		_say(text)

## Depois de cada gesto do jogador: reforços, mortes, e se o turno acabou.
func _after_player_action() -> void:
	_check_scripts()
	if not picking.is_empty():
		return
	var dying: Array = []
	for s in slots:
		if not s.enemy.is_alive() and not s.eliminated:
			dying.append(s)
	if not dying.is_empty():
		var everyone_down := alive_slots().is_empty()
		for s in dying:
			s.eliminated = true
			run.record_kill(s.enemy, player.character.id)
			_say("%s foi eliminado." % s.enemy.name)
		if everyone_down:
			_finish(true)
			return
	_continue_after_player()

func _continue_after_player() -> void:
	if end_requested or party.round_done():
		_finish_player_phase()
		return
	if turn.should_end:
		var following := party.next_with_actions()
		if following >= 0:
			activate(following)
			_say("%s age agora." % who)

var discard_prompt: String:
	get:
		if not discarding:
			return ""
		var n := player.excess_count()
		return "Mão cheia: escolha %d carta%s para descartar" % [n, "s" if n != 1 else ""]

func _finish_player_phase() -> void:
	for i in range(party.members.size()):
		var m: Member = party.members[i]
		if m.alive and m.player.excess_count() > 0:
			activate(i)
			discarding = true
			return
	run_enemy_phase()

func discard_choice(index: int) -> void:
	if not discarding:
		return
	var p := player
	if index < 0 or index >= p.hand.size():
		return
	var card := p.discard_at(index)
	_say("%s descarta %s." % [who, card.name])
	if p.excess_count() <= 0:
		discarding = false
		_finish_player_phase()

# -- turno dos inimigos ---------------------------------------------------------------------------------------

## Inicia a fila de ataques: para no primeiro ataque que precise da UI (janela de reação) e devolve-se ao chamador;
## a UI continua com `continue_enemy_phase()`.
func run_enemy_phase() -> void:
	_enemy_queue = alive_slots()
	continue_enemy_phase()

func continue_enemy_phase() -> void:
	while not finished and reaction_pending == null:
		if _area_rest.is_empty() or acting == null:
			var next: Variant = _next_enemy_slot()
			if next == null:
				start_turn()
				return
			acting = next
			if not _prepare_enemy_attack(acting):
				# atordoado ou morto pelo trovão: passa
				if _after_enemy_attack():
					return
				continue
			_begin_attack(acting, null)
		else:
			var member: Member = _area_rest.pop_front()
			if member.alive:
				activate(party.index_of(member.player))
				_begin_attack(acting, _area_action)
			else:
				continue

func _next_enemy_slot() -> Variant:
	var q: Array = []
	for s in _enemy_queue:
		if s.enemy.is_alive() and not s.eliminated:
			q.append(s)
	_enemy_queue = q
	if _enemy_queue.is_empty():
		return null
	return _enemy_queue.pop_front()

## false se o ataque não acontece (atordoado ou morto pelo trovão).
func _prepare_enemy_attack(slot: Dictionary) -> bool:
	var enemy: Enemy = slot.enemy
	_say("Turno do inimigo · %s" % enemy.name)
	if enemy.stunned:
		enemy.consume_stun()
		_say("%s está atordoado e perde o ataque." % enemy.name)
		return false
	var th: Variant = Combat.resolve_thunder(enemy)
	if th != null:
		_say("%s sofre %d de trovão." % [enemy.name, th.damage])
		_fx("damage", _slot_id(slot), th.damage, "", "Amarelo")
		if th.killed:
			return false
	enemy.tick_stun_immunity()
	# A névoa do Amálgama incha junto com a própria carne. O dano é aplicado
	# uma vez por ação especial, antes da sequência de alvos de uma área.
	if enemy.peek_is_special() and enemy.special_self_damage > 0:
		var self_damage := mini(enemy.special_self_damage, maxi(0, enemy.hp - 1))
		if self_damage > 0:
			enemy.hp -= self_damage
			_say("%s é ferido pela própria névoa: %d de dano." % [enemy.name, self_damage])
			_fx("damage", _slot_id(slot), self_damage, "Névoa", "Verde")
	var targets := party.attack_targets(enemy)
	activate(party.index_of(targets[0].player))
	_area_rest = targets.slice(1)
	_area_action = null
	return true

func _begin_attack(slot: Dictionary, action: Variant) -> void:
	var enemy: Enemy = slot.enemy
	var pending := Combat.roll_enemy_attack(player, enemy, true, action)
	if not _area_rest.is_empty() and _area_action == null:
		_area_action = [pending.name, pending.dice]
	_say("%s usa %s%s" % [enemy.name, pending.name, (" em %s" % who) if party.size > 1 else ""])
	var options: Array = []
	for c in player.hand:
		if turn.can_react(c, pending.kind, pending.hit != null):
			options.append(c)
	if not pending.acertou or options.is_empty():
		finish_enemy_attack(pending, null)
		return
	reaction_pending = pending
	_say("Reagir? Escolha uma carta de Reação")

## A escolha da janela de reação (índice na mão, ou -1 para não reagir).
func react(index: int) -> void:
	if reaction_pending == null:
		return
	var pending: PendingEnemyAttack = reaction_pending
	reaction_pending = null
	var card: Variant = null
	if index >= 0:
		var c: Card = player.hand[index]
		if not turn.can_react(c, pending.kind, pending.hit != null):
			reaction_pending = pending
			_say("%s não responde a este ataque." % c.name)
			return
		card = player.hand.pop_at(index)
		turn.spend_reaction()
		if card.single_use:
			player.exhausted.append(card)
		elif card.class_ability:
			player.spent_class.append(card)
		else:
			player.discard.append(card)
		_say("%s reage com %s." % [who, card.name])
	else:
		_say("%s não reage." % who)
	finish_enemy_attack(pending, card)
	continue_enemy_phase()

func finish_enemy_attack(pending: PendingEnemyAttack, reaction_card: Variant) -> void:
	var slot: Dictionary = acting
	var enemy: Enemy = slot.enemy
	var p := player
	var hp_before := p.hp
	var result := Combat.resolve_enemy_attack(p, enemy, pending, reaction_card)
	if result.acertou:
		run.stats.damage_taken += maxi(0, hp_before - maxi(0, p.hp))
		if result.negated:
			_say("%s anula o ataque." % result.reaction)
			_fx("text", "player", 0, "%s!" % result.reaction, "Azul")
		else:
			_say("%s acerta %s: %d de dano%s." % [enemy.name, who, result.damage, (" (%s)" % enemy.special_extra) if (result.is_special and enemy.special_extra != "") else ""])
			if result.damage > 0:
				_fx("player_damage", "player", result.damage, "", "")
			else:
				_fx("text", "player", 0, "Bloqueado", "")
			if result.total_reduction > 0 and result.raw_damage > 0:
				_fx("text", "player", 0, "−%d %s" % [result.total_reduction, result.reaction if result.reaction != "" else "redução"], "")
		if enemy.grapples and result.damage > 0 and p.is_alive():
			var g := Combat.resolve_grapple(p, enemy)
			_say("%s tenta se soltar (d20 %d + Força = %d vs %d): %s" % [who, g[0], g[1], enemy.grapple_dc, "preso! Perde a próxima Ação." if g[2] else "solta-se."])
		if result.clone_damage != 0:
			_say("A Cópia Sombria é atingida: −%d (%d/%d)." % [result.clone_damage, p.clone_hp, p.clone_max_hp])
			if result.clone_fell:
				_say("A Cópia Sombria caiu!")
		if result.guard_damage != 0:
			_say("A Guarda absorve %d (%d/%d)." % [result.guard_damage, p.guard, p.guard_cap])
		if result.corroded != 0:
			_say("%s corrói sua armadura: CA −%d (agora %d)." % [enemy.name, result.corroded, p.ca])
		if result.last_stand:
			_say("%s: você fica com 1 PV!" % result.last_stand_source)
		if result.counter_damage != 0:
			_say("%s devolve %d de dano a %s." % [result.reaction, result.counter_damage, enemy.name])
			run.stats.damage_dealt += result.counter_damage + mini(0, enemy.hp)
	else:
		_say("%s erra %s." % [enemy.name, who])
		_fx("text", "player", 0, "Errou", "")
	if _after_enemy_attack():
		return

## Devolve true se o combate acabou.
func _after_enemy_attack() -> bool:
	_check_scripts()
	if not player.is_alive():
		if party.size > 1:
			_say("%s caiu: faz um teste de morte a cada turno." % who)
		if party.all_down:
			_finish(false)
			return true
	var dying: Array = []
	for s in slots:
		if not s.enemy.is_alive() and not s.eliminated:
			dying.append(s)
	if not dying.is_empty():
		_area_rest = []
		var everyone_down := alive_slots().is_empty()
		for s in dying:
			s.eliminated = true
			run.record_kill(s.enemy, player.character.id)
			_say("%s foi eliminado." % s.enemy.name)
		if everyone_down:
			_finish(true)
			return true
	return false

func _finish(won: bool) -> void:
	finished = true
	victory = won
