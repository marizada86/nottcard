class_name Combat
extends RefCounted
## game/core/combat.py — fórmula de dano, Corrente de Classe, resolução das cartas e do ataque inimigo.
## `Player` é o Player do core; os resultados são as classes *Result portadas.

const BOSS_DECISION_SECONDS := 45
const OFF_COLOR_FACTOR := 0.5
const AREA_CONTROL_FACTOR := 0.75
const AJUDA_HP := 5
const NORMAL := Dice.NORMAL
const ADVANTAGE := Dice.ADVANTAGE
const DISADVANTAGE := Dice.DISADVANTAGE

static func off_color(card: Card, class_color: String) -> bool:
	return (card.kind == "ataque" or card.kind == "controle") and not card.scroll and card.color != class_color

static func _d20() -> int:
	return Dice.roll("1d20")

## [mantido, descartado|null]; cada dado passa por _d20.
static func _roll_d20(state: String = NORMAL) -> Array:
	var first := _d20()
	return Dice.pick_d20(state, first, null if state == NORMAL else _d20())

static func roll_to_hit(bonus: int, defense: int, defense_name: String = "CA", ignored: int = 0, sneak: bool = false, state: String = NORMAL) -> HitResult:
	var kd := _roll_d20(state)
	var h := HitResult.new()
	h.d20 = kd[0]
	h.bonus = bonus
	h.defense = defense - ignored
	h.defense_name = defense_name
	h.ignored = ignored
	h.sneak = sneak
	h.d20_discarded = kd[1]
	h.state = state
	return h

static func reroll_with_disadvantage(hit: HitResult) -> HitResult:
	var fresh := _d20()
	var h := hit.copy()
	if hit.state == ADVANTAGE:
		h.d20 = fresh
		h.d20_discarded = hit.d20
		h.state = NORMAL
		return h
	h.d20 = mini(hit.d20, fresh)
	h.d20_discarded = maxi(hit.d20, fresh)
	h.state = DISADVANTAGE
	return h

## Teste de acerto de uma carta de ataque do jogador; null se a carta não rola acerto.
static func player_attack_hit(card: Card, player: Player, enemy: Enemy) -> Variant:
	if card.auto_hit:
		return null
	var attribute := player.character.hit_attribute(card)
	if attribute == "":
		return null
	var sneak := card.sneak_dice != "" and enemy.is_vulnerable
	var state := ADVANTAGE if (card.advantage_on_hit or sneak) else NORMAL
	var bonus := player.modifier_of(attribute) + player.hit_bonus + player.bless + enemy.consume_mark()
	if card.color == "Vermelho":
		return roll_to_hit(bonus, enemy.effective_ca, "CA", card.ignores_ca, sneak, state)
	return roll_to_hit(bonus, enemy.effective_cam, "CAM", card.ignores_cam, sneak, state)

static func roll_stun_check(card: Card, player: Player, enemy: Enemy) -> Variant:
	if not card.stun_on_hit or not enemy.can_be_stunned:
		return null
	var kd := _roll_d20(NORMAL)
	var s := StunCheck.new()
	s.d20 = kd[0]
	s.bonus = player.modifier_of("forca")
	s.dc = enemy.stun_dc
	s.d20_discarded = kd[1]
	return s

static func _dice_values(dice: String, crit: bool = false) -> Array:
	var parts := dice.to_lower().split("d")
	var out: Array = []
	for _i in range(int(parts[0]) * (2 if crit else 1)):
		out.append(Dice.roll("1d%s" % parts[1]))
	return out

static func _attack_outcome(card: Card, combo: ComboTracker, hit: Variant, mult: int, mystic: int = 0) -> AttackResult:
	var character := combo.character
	var compat := 1.0 if (card.scroll or card.color == character.class_color) else 0.5
	var attr_flat := 0 if card.scroll else character.color_modifier(card.color)
	var in_chain := character.counts_for_chain(card)
	var hit_attr := character.hit_attribute(card)
	var r := AttackResult.new()
	if hit != null and not hit.hit:
		r.dado_base = 0
		r.dano_carta = 0
		r.bonus_passiva = 0
		r.multiplicador = mult
		r.compat = compat
		r.hit = hit
		r.attr_flat = attr_flat
		r.em_corrente = in_chain
		r.hit_attr = hit_attr
		return r
	var crit: bool = hit != null and hit.crit
	var dice_text := card.chain_dice if (card.chain_dice != "" and mult >= 2) else card.dice
	var dados := _dice_values(dice_text, crit)
	var dados_extra: Array = _dice_values(card.sneak_dice, crit) if (card.sneak_dice != "" and hit != null and hit.sneak) else []
	if card.guard_dice != "" and combo.guard_full.is_valid() and combo.guard_full.call():
		dados_extra.append_array(_dice_values(card.guard_dice, crit))
	var base := Py.sum_int(dados) + Py.sum_int(dados_extra)
	var dmg_mult := 1.0 if card.scroll else combo.damage_mult
	var dano_carta := maxi(1, Py.ceil6(base * dmg_mult * mult * compat) + attr_flat)
	var dados_passiva: Array = []
	if in_chain and not card.scroll and character.chain_bonus_dice.has(mult):
		dados_passiva = _dice_values(character.chain_bonus_dice[mult], crit)
	r.dado_base = base
	r.dano_carta = dano_carta
	r.bonus_passiva = Py.sum_int(dados_passiva)
	r.multiplicador = mult
	r.compat = compat
	r.dados = dados
	r.dados_passiva = dados_passiva
	r.hit = hit
	r.attr_flat = attr_flat
	r.dmg_mult = dmg_mult
	r.em_corrente = in_chain
	r.hit_attr = hit_attr
	r.bonus_mistico = mystic
	r.dados_extra = dados_extra
	return r

static func resolve_attack(card: Card, combo: ComboTracker, hit: Variant = null) -> AttackResult:
	var mystic := 0 if card.scroll else combo.mystic_to_spend(card)
	var result := _attack_outcome(card, combo, hit, 1 if card.scroll else combo.multiplier_for(card), mystic)
	if result.acertou:
		combo.spend_mystic(mystic)
		combo.advance(card)
	else:
		combo.break_chain()
	return result

static func resolve_area_attack(card: Card, combo: ComboTracker, hits: Array) -> Array:
	var mult := 1 if card.scroll else combo.multiplier_for(card)
	var mystic := 0 if card.scroll else combo.mystic_to_spend(card)
	var results: Array = []
	for hit in hits:
		results.append(_attack_outcome(card, combo, hit, mult, mystic))
	var any_hit := false
	for r in results:
		if r.acertou:
			any_hit = true
	if any_hit or results.is_empty():
		if any_hit:
			combo.spend_mystic(mystic)
		combo.advance(card)
	else:
		combo.break_chain()
	return results

static func apply_card_effects(card: Card, result: AttackResult, player: Player, enemy: Enemy) -> CardEffects:
	var e := CardEffects.new()
	e.exposed = card.exposes
	if e.exposed:
		player.exposed = true
	e.stunned = 0
	if result.acertou and card.stuns_attacks != 0 and enemy.try_stun(card.stuns_attacks):
		e.stunned = card.stuns_attacks
	e.thunder = result.acertou and card.thunder_dice != ""
	if e.thunder:
		enemy.thunder_mark = card.thunder_dice
	e.unbalanced = card.reduces_next_attack if (result.acertou and card.reduces_next_attack != 0) else 0
	if e.unbalanced != 0:
		enemy.next_attack_reduction += e.unbalanced
	e.ward_broken = enemy.break_ward(card.weakens_cam_on_hit) if (result.acertou and card.weakens_cam_on_hit != 0) else 0
	return e

static func resolve_thunder(enemy: Enemy) -> Variant:
	if enemy.thunder_mark == "":
		return null
	var dados := Enemy.roll_damage(enemy.thunder_mark)
	enemy.thunder_mark = ""
	var damage := Py.sum_int(dados)
	enemy.hp -= damage
	var t := ThunderResult.new()
	t.dados = dados
	t.damage = damage
	t.killed = not enemy.is_alive()
	return t

static func resolve_control(card: Card, combo: ComboTracker) -> ControlResult:
	var character := combo.character
	var mult := combo.multiplier_for(card)
	var compat := 1.0 if card.color == character.class_color else 0.5
	var attr_flat := character.color_modifier(card.color)
	var area_factor := AREA_CONTROL_FACTOR if card.area else 1.0
	var base := Dice.roll(card.dice)
	var reduction := maxi(1, Py.ceil6(base * mult * compat * area_factor) + attr_flat)
	combo.advance(card)
	var c := ControlResult.new()
	c.dado_base = base
	c.reduction = reduction
	c.multiplicador = mult
	c.compat = compat
	c.attr_flat = attr_flat
	c.area_factor = area_factor
	return c

static func resolve_heal(card: Card, combo: ComboTracker, modificador: int = 0, player: Player = null) -> HealResult:
	var mult := 1 if card.scroll else combo.multiplier_for(card)
	var dados := _dice_values(card.dice)
	var redimiu: bool = card.redeems and player != null and player.redeem()
	var desonra: bool = player != null and player.dishonored
	combo.advance(card)
	var h := HealResult.new()
	h.dado_base = Py.sum_int(dados)
	h.dados = dados
	h.modificador = modificador
	h.multiplicador = mult
	h.desonra = desonra
	h.redimiu = redimiu
	return h

static func resolve_protect(card: Card, combo: ComboTracker, player: Player) -> int:
	var gained := player.gain_guard(card.grants_guard)
	combo.advance(card)
	return gained

static func resolve_surge(card: Card, combo: ComboTracker) -> int:
	combo.advance(card)
	return card.grants_action

## [PV perdidos, PPM da carta]
static func resolve_channel(card: Card, combo: ComboTracker, player: Player) -> Array:
	var lost := mini(card.self_damage, maxi(0, player.hp - 1))
	player.hp -= lost
	combo.advance(card)
	return [lost, card.grants_mystic]

static func resolve_stun(card: Card, combo: ComboTracker, enemy: Enemy) -> void:
	enemy.try_stun(card.stuns_attacks if card.stuns_attacks != 0 else 1)
	combo.advance(card)
	combo.boost += card.boosts_chain

## [CA que caiu, CAM que caiu]
static func resolve_weaken(card: Card, combo: ComboTracker, enemy: Enemy) -> Array:
	var dropped := [enemy.break_armor(card.weakens), enemy.break_ward(card.weakens)]
	combo.advance(card)
	return dropped

static func resolve_locate(card: Card, combo: ComboTracker, enemy: Enemy) -> LocateResult:
	var action := enemy.peek_action()
	enemy.mark(card.marks_bonus)
	combo.advance(card)
	var l := LocateResult.new()
	l.attack_name = action[0]
	l.attack_dice = action[1]
	l.bonus = card.marks_bonus
	return l

static func resolve_communion(_card: Card, combo: ComboTracker) -> void:
	combo.advance(_card)

static func resolve_scroll_buff(card: Card, combo: ComboTracker, player: Player) -> ScrollBuff:
	var effect := card.scroll_effect
	var healed := 0
	var text := ""
	if effect == "escudo_arcano":
		player.ward = true
		text = "o próximo ataque que te acertar será anulado"
	elif effect == "escudo_da_fe":
		player.ca_bonus += 2
		text = "+2 CA até o fim do combate (agora %d)" % player.ca
	elif effect == "bencao":
		player.hit_bonus += 2
		text = "+2 no acerto das suas cartas até o fim do combate"
	elif effect == "restauracao":
		player.ca_penalty = 0
		text = "a CA corroída some (CA %d)" % player.ca
	elif effect == "ajuda":
		player.max_hp += AJUDA_HP
		healed = player.heal(AJUDA_HP)
		text = "+%d PV máximo até o fim da missão e cura %d" % [AJUDA_HP, healed]
	elif effect == "protecao_morte":
		player.death_ward = true
		text = "ao cair a 0 PV neste combate, você fica com 1 PV"
	combo.advance(card)
	var b := ScrollBuff.new()
	b.text = text
	b.healed = healed
	return b

static func resolve_equip(card: Card, combo: ComboTracker) -> void:
	combo.advance(card)

static func roll_enemy_attack(player: Player, enemy: Enemy, roll_hit: bool = false, action: Variant = null) -> PendingEnemyAttack:
	var na: Array = action if action != null else enemy.choose_action()
	var attack_name: String = na[0]
	var dice: String = na[1]
	var is_special := attack_name == enemy.special_name
	var magical := is_special and enemy.special_defense == "cam"
	var hit: Variant = null
	if roll_hit:
		hit = roll_to_hit(enemy.attack_bonus, player.cam if magical else player.ca, "CAM" if magical else "CA", 0, false,
			ADVANTAGE if player.exposed else NORMAL)
	var p := PendingEnemyAttack.new()
	p.name = attack_name
	p.dice = dice
	p.is_special = is_special
	p.kind = "magico" if magical else "fisico"
	p.hit = hit
	return p

static func _corrode(player: Player, enemy: Enemy) -> int:
	if enemy.corrode_chance <= 0 or Dice.roll("1d100") > Py.round_half_even(enemy.corrode_chance * 100):
		return 0
	var new_value := mini(Enemy.MAX_CA_PENALTY, player.ca_penalty + enemy.corrode_amount)
	var dropped := new_value - player.ca_penalty
	player.ca_penalty = new_value
	return dropped

static func _blank(attack_name: String, is_special: bool, hit: Variant) -> EnemyActionResult:
	var r := EnemyActionResult.new()
	r.name = attack_name
	r.raw_damage = 0
	r.damage = 0
	r.reduced_by = 0
	r.is_special = is_special
	r.hit = hit
	return r

static func resolve_enemy_attack(player: Player, enemy: Enemy, pending: PendingEnemyAttack, reaction: Variant = null) -> EnemyActionResult:
	var attack_name := pending.name
	var dice := pending.dice
	var is_special := pending.is_special
	var hit: Variant = pending.hit
	if reaction != null and reaction.forces_disadvantage and hit != null:
		hit = reroll_with_disadvantage(hit)
	if hit != null and not hit.hit:
		return _blank(attack_name, is_special, hit)
	if player.ward:
		player.ward = false
		var w := _blank(attack_name, is_special, hit)
		w.reaction = "Escudo Arcano"
		w.negated = true
		return w
	if reaction != null and reaction.dice == "" and not reaction.halves_damage and not reaction.forces_disadvantage:
		var n := _blank(attack_name, is_special, hit)
		n.reaction = reaction.name
		n.negated = true
		return n
	var dados := Enemy.roll_damage(dice, hit != null and hit.crit)
	var raw_damage := Py.sum_int(dados)
	var reduced_by := enemy.next_attack_reduction
	var damage := maxi(0, raw_damage - reduced_by)
	enemy.next_attack_reduction = 0
	var reaction_name := ""
	var reaction_amount := 0
	var reaction_dice: Array = []
	var reaction_bonus := 0
	if reaction != null and reaction.halves_damage:
		reaction_name = reaction.name
		reaction_amount = damage - Py.fdiv(damage, 2)
		damage -= reaction_amount
	elif reaction != null and reaction.forces_disadvantage:
		reaction_name = reaction.name
	elif reaction != null:
		reaction_name = reaction.name
		reaction_dice = Enemy.roll_damage(reaction.dice)
		reaction_bonus = player.modifier_of(reaction.modifier_attr) if reaction.modifier_attr != "" else 0
		reaction_amount = mini(damage, Py.sum_int(reaction_dice) + reaction_bonus)
		damage -= reaction_amount
	var counter_dice: Array = []
	if reaction != null and reaction.counter_dice != "":
		counter_dice = Enemy.roll_damage(reaction.counter_dice)
		enemy.hp -= Py.sum_int(counter_dice)
	var corroded := _corrode(player, enemy)
	var g := player.absorb_guard(damage)
	var guard_damage: int = g[0]
	var td := player.take_damage(g[1])
	var clone_damage: int = td[0]
	var clone_fell: bool = td[2]
	var guard_gain := player.gain_guard(reaction.grants_guard) if (reaction != null and reaction.grants_guard != 0) else 0
	var mystic_gain := 0
	if reaction != null and reaction.grants_mystic != 0:
		mystic_gain = player.combo.gain_mystic(reaction.grants_mystic) if player.combo.charge_mode else 0
	var last_stand := false
	var last_stand_source := "Proteção de Sendrinah"
	if player.hp <= 0 and player.hooks.has("last_stand") and not player.last_stand_used:
		player.hp = 1
		player.last_stand_used = true
		last_stand = true
	elif player.hp <= 0 and player.death_ward:
		player.hp = 1
		player.death_ward = false
		last_stand = true
		last_stand_source = "Proteção contra a Morte"
	if is_special and enemy.special_extra.contains("próximo ataque de Durvall"):
		player.next_attack_penalty = 1
	var r := EnemyActionResult.new()
	r.name = attack_name
	r.raw_damage = raw_damage
	r.damage = damage
	r.reduced_by = reduced_by
	r.is_special = is_special
	r.hit = hit
	r.dados = dados
	r.reaction = reaction_name
	r.reaction_amount = reaction_amount
	r.reaction_dice = reaction_dice
	r.reaction_bonus = reaction_bonus
	r.counter_dice = counter_dice
	r.counter_damage = Py.sum_int(counter_dice)
	r.last_stand = last_stand
	r.corroded = corroded
	r.clone_damage = clone_damage
	r.clone_fell = clone_fell
	r.mystic_gain = mystic_gain
	r.last_stand_source = last_stand_source
	r.guard_damage = guard_damage
	r.guard_gain = guard_gain
	return r

## [d20, total, preso]
static func resolve_grapple(player: Player, enemy: Enemy, d20_in: int = -1) -> Array:
	var d20 := _d20() if d20_in < 0 else d20_in
	var total := d20 + player.modifier_of("forca")
	var held := d20 != 20 and (d20 == 1 or total < enemy.grapple_dc)
	if held:
		player.grappled = true
	return [d20, total, held]

static func apply_enemy_action(player: Player, enemy: Enemy, roll_hit: bool = false) -> EnemyActionResult:
	return resolve_enemy_attack(player, enemy, roll_enemy_attack(player, enemy, roll_hit))

static func boss_timeout_expired(elapsed_seconds: float, is_boss: bool) -> bool:
	return is_boss and elapsed_seconds > BOSS_DECISION_SECONDS
