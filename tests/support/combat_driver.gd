class_name CombatDriver
extends RefCounted
## Espelho de tools/golden_sections/combat_sim.py::run_fight — a mesma política fixa, para comparar traços com o Python.

static func snap(player: Player, enemies: Array) -> Dictionary:
	var c := player.combo
	var hand: Array = []
	for x in player.hand:
		hand.append(x.name)
	var en: Array = []
	for e in enemies:
		en.append([e.name, e.hp, e.stunned, e.stun_left, e.ca_penalty, e.cam_penalty, e.marked_bonus, e.next_attack_reduction, e.thunder_mark])
	return {"hp": player.hp, "max_hp": player.max_hp, "ca": player.ca, "cam": player.cam, "streak": c.streak, "boost": c.boost,
		"mystic": c.mystic_power, "guard": player.guard, "dish": player.dishonored, "clone": player.clone_hp, "hand": hand,
		"draw": player.draw_pile.size(), "disc": player.discard.size(), "exh": player.exhausted.size(), "spent": player.spent_class.size(),
		"luck": player.luck, "en": en}

static func _factory(n: String) -> Enemy:
	match n:
		"guardiao": return Enemies.guardiao_verdadeiro()
		"slime": return Enemies.slime_corrosivo()
		"cultista": return Enemies.cultista_adaga()
		"cajado": return Enemies.cultista_cajado()
		"zumbi": return Enemies.zumbi()
		"sacerdote": return Enemies.sacerdote_mente_derretida()
		"mimico": return Enemies.mimico(12, 11, 10)
		_: return Enemies.guardiao_copia()

static func run_fight(character_id: String, level: int, enemy_names: Array, seed_value: int, turns: int, upgrades: Variant = null, extra_cards: Array = []) -> Array:
	PyRandom.shared = PyRandom.new(seed_value)
	var enemies: Array = []
	for n in enemy_names:
		enemies.append(_factory(n))
	var player := Player.for_character(CharacterDefs.get_def(character_id), level, 0, null, upgrades)
	if not extra_cards.is_empty():
		player.add_scrolls(extra_cards)
	var trace: Array = [["start", snap(player, enemies)]]
	for t in range(turns):
		var alive: Array = _alive(enemies)
		if alive.is_empty() or not player.is_alive():
			break
		var turn := TurnState.new()
		turn.actions_available += player.take_extra_actions()
		var loops := 0
		while loops < 12:
			loops += 1
			alive = _alive(enemies)
			if alive.is_empty():
				break
			var playable: Array = []
			for c in player.hand:
				if turn.can_play(c):
					playable.append(c)
			if playable.is_empty():
				break
			var card: Card = playable[0]
			player.hand.erase(card)
			var target: Enemy = alive[0]
			var entry := {"card": card.name}
			match card.kind:
				"ataque":
					if card.area:
						var hits: Array = []
						for e in alive:
							hits.append(Combat.player_attack_hit(card, player, e))
						var results := Combat.resolve_area_attack(card, player.combo, hits)
						var any := false
						for i in range(alive.size()):
							if results[i].acertou:
								alive[i].hp -= results[i].total
								any = true
						entry["res"] = Golden.plain(results)
						if any:
							turn.hit_this_turn = true
					else:
						var hit: Variant = Combat.player_attack_hit(card, player, target)
						var r := Combat.resolve_attack(card, player.combo, hit)
						var eff := Combat.apply_card_effects(card, r, player, target)
						var stun: Variant = null
						if r.acertou:
							target.hp -= r.total
							turn.hit_this_turn = true
							stun = Combat.roll_stun_check(card, player, target)
							if stun != null:
								if stun.success:
									target.try_stun()
								else:
									player.combo.break_chain()
							if card.drain_frac != 0.0:
								player.heal(int(r.total * card.drain_frac))
						entry["res"] = Golden.plain(r)
						entry["eff"] = Golden.plain(eff)
						entry["stun"] = Golden.plain(stun)
				"cura":
					var mod := player.modifier_of(card.modifier_attr) if card.modifier_attr != "" else 0
					var r := Combat.resolve_heal(card, player.combo, mod, player)
					var healed := player.heal_clone(r.total, true) if card.heals_clone else player.heal(r.total)
					entry["res"] = Golden.plain(r)
					entry["healed"] = healed
				"controle":
					var r := Combat.resolve_control(card, player.combo)
					for e in (alive if card.area else [target]):
						e.next_attack_reduction += r.reduction
					entry["res"] = Golden.plain(r)
				"surto":
					entry["res"] = Combat.resolve_surge(card, player.combo)
				"atordoamento":
					Combat.resolve_stun(card, player.combo, target)
				"canalizar":
					entry["res"] = Combat.resolve_channel(card, player.combo, player)
				"protecao":
					entry["res"] = Combat.resolve_protect(card, player.combo, player)
				"localizar":
					entry["res"] = Golden.plain(Combat.resolve_locate(card, player.combo, target))
				"enfraquecer":
					entry["res"] = Combat.resolve_weaken(card, player.combo, target)
				"comunhao":
					Combat.resolve_communion(card, player.combo)
					var top := player.peek_top(card.reveals)
					var names: Array = []
					for x in top:
						names.append(x.name)
					entry["top"] = names
					if not top.is_empty():
						player.hand.append(top[0])
						player.draw_pile.erase(top[0])
				"magia":
					entry["res"] = Golden.plain(Combat.resolve_scroll_buff(card, player.combo, player))
				_:
					Combat.resolve_equip(card, player.combo)
			turn.spend_for(card)
			if card.single_use:
				player.exhausted.append(card)
			elif card.class_ability:
				player.spent_class.append(card)
			else:
				player.discard.append(card)
			var i := 0
			while i < enemies.size():
				var e: Enemy = enemies[i]
				if e.enc_script != null:
					var spawned := e.enc_script.check(e)
					if not spawned.is_empty():
						enemies.append_array(spawned)
						entry["spawn"] = spawned.size()
				i += 1
			entry["snap"] = snap(player, enemies)
			trace.append(["play", entry])
			if turn.should_end:
				break
		for e in _alive(enemies):
			if not player.is_alive():
				break
			var th: Variant = Combat.resolve_thunder(e)
			if th != null:
				trace.append(["thunder", Golden.plain(th)])
				if th.killed:
					continue
			if e.stunned:
				e.consume_stun()
				trace.append(["stunned", e.name])
				continue
			e.tick_stun_immunity()
			var pending := Combat.roll_enemy_attack(player, e, true)
			var reaction: Variant = null
			var rt := TurnState.new()
			for c in player.hand:
				if rt.can_react(c, pending.kind, pending.hit != null):
					reaction = c
					break
			if reaction != null:
				player.hand.erase(reaction)
				player.discard.append(reaction)
			player.clone_targeted = player.clone_alive and (trace.size() % 2 == 0)
			var res := Combat.resolve_enemy_attack(player, e, pending, reaction)
			var entry := {"pending": Golden.plain(pending), "res": Golden.plain(res)}
			if e.grapples and res.acertou and res.damage >= 0:
				entry["grapple"] = Combat.resolve_grapple(player, e)
			entry["snap"] = snap(player, enemies)
			trace.append(["enemy", entry])
			if not player.is_alive():
				break
		player.start_turn()
		if player.is_alive():
			player.draw()
			player.discard_excess()
		trace.append(["end", snap(player, enemies)])
	return trace

static func _alive(enemies: Array) -> Array:
	var out: Array = []
	for e in enemies:
		if e.is_alive():
			out.append(e)
	return out
