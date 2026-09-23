class_name CombatScreen
extends UiScreen
## UI de combate: as regras são resolvidas pelo CombatSession; esta tela revela
## seus eventos em batidas, com dados, impacto e PV visível no tempo certo.

const ENEMY_W := 200
const ENEMY_H := 300
const ENEMY_Y := 90
const RAIL_X := 1090
const RAIL_W := 170

var cs: CombatSession
var backdrop: String = ""
var on_win: Callable
var selected: int = -1
var sequence := CombatSequence.new()
var combat_fx := CombatFx.new()
var active_dice: Array = [] # [{"roll": DiceRollView, "center": Vector2}]
var dice_3d: Dice3dView
var announcement := ""
var _shakes: Dictionary = {}
var _death_fade: Dictionary = {}
var action_draw_button := Rect2(RAIL_X, 572, RAIL_W, 30)
var bonus_button := Rect2(RAIL_X, 606, RAIL_W, 30)
var end_button := Rect2(RAIL_X, 640, RAIL_W, 30)
var mulligan_button := Rect2(RAIL_X, 674, RAIL_W, 30)
var _enemies_init: Array
var _is_boss: bool
var _last_click_idx: int = -1
var _last_click_t: float = -10.0
var _t: float = 0.0
var _finished_timer: float = -1.0
var _shown_hp: Dictionary = {}

func _init(enemies: Array, is_boss: bool, backdrop_: String, on_win_: Callable = Callable()) -> void:
	_enemies_init = enemies
	_is_boss = is_boss
	backdrop = backdrop_
	on_win = on_win_

func enter() -> void:
	cs = CombatSession.new(app.run, _enemies_init, _is_boss)
	dice_3d = Dice3dView.new()
	app.add_child(dice_3d)
	for s in cs.slots:
		_shown_hp[s.enemy] = CombatFx.ShownValue.new(s.enemy.hp)
	for m in cs.party.members:
		_shown_hp[m.player] = CombatFx.ShownValue.new(m.player.hp)

func exit() -> void:
	if dice_3d != null and is_instance_valid(dice_3d):
		dice_3d.queue_free()
	dice_3d = null

func _slot_rect(i: int) -> Rect2:
	var n := cs.slots.size()
	var gap := 30
	var w := ENEMY_W if n <= 3 else 150
	var h := int(w * 1.5)
	var total := n * w + (n - 1) * gap
	var start := (Gfx.W - total) / 2.0
	return Rect2(start + i * (w + gap), ENEMY_Y + (ENEMY_H - h), w, h)

func _hand_rects() -> Array:
	var hand: Array = cs.player.hand
	var n := hand.size()
	var cw := 128.0
	var ch := 186.0
	var gap := 10.0
	var total := n * cw + (n - 1) * gap
	if total > 900:
		gap = (900.0 - n * cw) / maxf(1.0, n - 1)
		total = 900
	var start := (Gfx.W - total) / 2.0 - 40
	var out: Array = []
	for i in range(n):
		var lift := -22.0 if i == selected else 0.0
		out.append(Rect2(start + i * (cw + gap), Gfx.H - ch - 14 + lift, cw, ch))
	return out

func _member_rects() -> Array:
	var out: Array = []
	for i in range(cs.party.size):
		out.append(Rect2(16, 300 + i * 92, 250, 84))
	return out

func handle_input(event: InputEvent) -> void:
	if sequence.busy:
		return
	if cs.finished:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			app.return_to_menu()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if cs.reaction_pending != null:
				cs.react(-1)
			elif not cs.discarding and cs.picking.is_empty():
				cs.end_turn()
			_consume_fx()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			_click_card(event.keycode - KEY_1)
		return
	if not is_click(event):
		return
	var p: Vector2 = event.position
	# personagens do grupo
	if cs.party.size > 1:
		var mr := _member_rects()
		for i in range(mr.size()):
			if mr[i].has_point(p):
				var member: Member = cs.party.members[i]
				if cs.reaction_pending == null and member.alive and cs.party.activate(i):
					selected = -1
				return
	if cs.picking.size() > 0:
		for i in range(cs.picking.size()):
			if _pick_rect(i).has_point(p):
				cs.pick_from_top(i)
				_consume_fx()
				return
		return
	if end_button.has_point(p):
		if cs.reaction_pending != null:
			cs.react(-1)
		elif not cs.discarding:
			cs.end_turn()
		selected = -1
		_consume_fx()
		return
	if cs.reaction_pending == null and not cs.discarding:
		if action_draw_button.has_point(p):
			cs.action_draw()
			selected = -1
			_consume_fx()
			return
		if bonus_button.has_point(p):
			cs.bonus_draw()
			selected = -1
			_consume_fx()
			return
		if cs.can_mulligan and mulligan_button.has_point(p):
			cs.mulligan()
			_consume_fx()
			return
	var hr := _hand_rects()
	for i in range(hr.size()):
		if hr[i].has_point(p):
			_click_card(i)
			return
	# alvo
	if selected >= 0 and selected < cs.player.hand.size():
		for i in range(cs.slots.size()):
			if cs.slots[i].enemy.is_alive() and _slot_rect(i).has_point(p):
				_play(selected, i)
				return
	selected = -1

func _click_card(i: int) -> void:
	var hand: Array = cs.player.hand
	if i < 0 or i >= hand.size():
		return
	if cs.reaction_pending != null:
		cs.react(i)
		_consume_fx()
		return
	if cs.discarding:
		cs.discard_choice(i)
		_consume_fx()
		return
	var card: Card = hand[i]
	if not cs.turn.can_play(card):
		app.show_toast("%s não pode ser jogada agora." % card.name, 1.6)
		return
	var alive := cs.alive_slots()
	var needs_target := card.targets_enemy and alive.size() > 1
	var double := i == _last_click_idx and _t - _last_click_t < 0.35
	_last_click_idx = i
	_last_click_t = _t
	if needs_target and not double:
		selected = i
		return
	_play(i, cs.slots.find(alive[0]) if not alive.is_empty() else -1)

func _play(i: int, slot_index: int) -> void:
	var ally: Member = null
	cs.play_card(i, slot_index, ally)
	selected = -1
	_consume_fx()

## Enfileira resultados já resolvidos. Não cria novo RNG nem chama Combat.
func _queue_presentation() -> void:
	for raw in cs.presentation:
		var event: Dictionary = raw.duplicate(true)
		match String(event["kind"]):
			"announce":
				var announce := event.duplicate(true)
				sequence.add("anuncio", 0.45, func(): announcement = String(announce.get("text", "")), Callable(), func(): announcement = "")
			"hit":
				var d20_values: Array = [int(event.get("d20", 1))] + ([] if event.get("discarded", null) == null else [int(event["discarded"])])
				_queue_dice(event, 20, 1.7, "acerto", d20_values, String(event.get("label", "acerto")))
			"dice":
				var damage_values: Array = event.get("values", [])
				_queue_dice(event, int(event.get("sides", 6)), 2.1, "rolagem", damage_values, String(event.get("label", "")))
			"impact":
				var impact := event.duplicate(true)
				sequence.add("impacto", 1.5, func(): _show_impact(impact))
			"heal":
				var heal_values: Array = event.get("values", [])
				_queue_dice(event, int(event.get("sides", 4)), 2.1, "rolagem", heal_values, String(event.get("label", "cura")))
				var heal := event.duplicate(true)
				sequence.add("cura", 1.2, func(): _show_heal(heal))
			"miss":
				var miss := event.duplicate(true)
				sequence.add("erro", 0.9, func(): combat_fx.spawn(String(miss.get("text", "Errou")), _target_center(String(miss.get("target", "player"))), UiTheme.BLOCKED_COLOR, 42))
			"death":
				var death := event.duplicate(true)
				var dying_target := String(death.get("target", ""))
				sequence.add("morte-fade", 0.25,
					func(): _death_fade[dying_target] = 0.0,
					func(dt: float): _death_fade[dying_target] = minf(1.0, float(_death_fade.get(dying_target, 0.0)) + dt / 0.25))
				sequence.add("aviso-eliminado", 1.38, func(): combat_fx.banner = CombatFx.Banner.new(String(death.get("text", "foi eliminado"))))
	cs.presentation.clear()

func _queue_dice(event: Dictionary, sides: int, duration: float, beat_name: String, values: Array, label: String) -> void:
	var saved := event.duplicate(true)
	var rolls: Array = values.duplicate()
	sequence.add(beat_name, duration,
		func(): _start_dice(sides, rolls, label, String(saved.get("target", "player")), duration),
		func(dt: float): _update_dice(dt),
		func(): active_dice.clear())
	sequence.add("pausa", 0.25)

func _start_dice(sides: int, values: Array, label: String, target: String, duration: float) -> void:
	active_dice.clear()
	if sides == 20 and dice_3d != null:
		dice_3d.start(values, duration)
		return
	var center := _target_center(target)
	var gap := minf(132.0, 760.0 / maxf(1.0, values.size()))
	for i in range(values.size()):
		active_dice.append({"roll": DiceRollView.new(sides, int(values[i]), label if i == 0 else "", duration, i), "center": center + Vector2((i - (values.size() - 1) / 2.0) * gap, -90)})

func _update_dice(dt: float) -> void:
	if dice_3d != null and dice_3d.active():
		dice_3d.advance(dt)
	for item in active_dice:
		item["roll"].update(dt)

func _target_center(target: String) -> Vector2:
	if target.begins_with("enemy:"):
		var idx := int(target.split(":")[1])
		if idx >= 0 and idx < cs.slots.size():
			return _slot_rect(idx).get_center()
	if target.begins_with("ally:"):
		var ally := int(target.split(":")[1])
		var rects := _member_rects()
		if ally >= 0 and ally < rects.size(): return rects[ally].get_center()
	return Vector2(Gfx.W / 2.0, 455)

func _shown(subject: Variant, fallback: float) -> CombatFx.ShownValue:
	if not _shown_hp.has(subject):
		_shown_hp[subject] = CombatFx.ShownValue.new(fallback)
	return _shown_hp[subject]

func _show_impact(event: Dictionary) -> void:
	var target := String(event.get("target", "player"))
	var to_value := float(event.get("to", 0))
	var subject: Variant = cs.player
	if target.begins_with("enemy:"):
		var idx := int(target.split(":")[1])
		if idx >= 0 and idx < cs.slots.size(): subject = cs.slots[idx].enemy
	_shown(subject, float(event.get("from", to_value))).animate_to(maxf(0.0, to_value), 0.62)
	_shakes[target] = 0.30
	var col := Color8(255, 140, 130) if String(event.get("color", "")) == "enemy" else UiTheme.card_text_color(String(event.get("color", "")))
	var damage := int(event.get("damage", 0))
	if damage > 0:
		combat_fx.spawn(str(damage), _target_center(target), col, 52)

func _show_heal(event: Dictionary) -> void:
	var target := String(event.get("target", "player"))
	var to_value := float(event.get("to", 0))
	var subject: Variant = cs.player
	if target.begins_with("ally:"):
		var ally := int(target.split(":")[1])
		if ally >= 0 and ally < cs.party.members.size(): subject = cs.party.members[ally].player
	_shown(subject, float(event.get("from", to_value))).animate_to(to_value, 0.62)
	var amount := int(event.get("amount", 0))
	if amount > 0:
		combat_fx.spawn("+%d" % amount, _target_center(target), UiTheme.HEAL_COLOR, 46)

## Converte os efeitos textuais restantes do core. Dano principal já é criado
## pelo beat de impacto, para não aparecer antes do dado.
func _consume_fx() -> void:
	_queue_presentation()
	var captions: Array = []
	for f in cs.fx:
		var pos := _target_center(String(f["target"]))
		var target: String = f["target"]
		if target.begins_with("ally:"):
			var r2: Rect2 = _member_rects()[int(target.split(":")[1])]
			pos = r2.get_center()
		var color := UiTheme.TEXT_COLOR
		match f["kind"]:
			"damage":
				pass
			"player_damage":
				pass
			"heal":
				# As curas normais entram em `presentation`; este fallback cobre
				# efeitos especiais que não alteram o PV do personagem ativo.
				if not sequence.busy:
					combat_fx.spawn("+%d" % f["value"], pos, UiTheme.HEAL_COLOR, 42)
			_:
				color = UiTheme.card_text_color(f["color"]) if f["color"] != "" else UiTheme.BLOCKED_COLOR
				captions.append({"text": String(f["text"]), "pos": pos + Vector2(0, 28), "color": color})
	cs.fx.clear()
	if not captions.is_empty():
		var delayed: Array = captions.duplicate(true)
		sequence.add("modificadores", 1.2, func():
			for caption in delayed:
				combat_fx.spawn(caption["text"], caption["pos"], caption["color"], 24, 0.12))

func _pick_rect(i: int) -> Rect2:
	var n := cs.picking.size()
	var w := 220.0
	var gap := 30.0
	var total := n * w + (n - 1) * gap
	return Rect2((Gfx.W - total) / 2.0 + i * (w + gap), 190, w, 320)

func update(dt: float) -> void:
	_t += dt
	sequence.update(dt)
	combat_fx.update(dt)
	for target in _shakes.keys():
		_shakes[target] = maxf(0.0, float(_shakes[target]) - dt)
	for subject in _shown_hp:
		_shown_hp[subject].update(dt)
	app.run.stats.seconds += dt
	if cs.finished and not sequence.busy and _finished_timer < 0.0:
		_finished_timer = 1.2
		app.show_toast("Vitória!" if cs.victory else "O grupo caiu...", 2.0)
	if _finished_timer >= 0.0:
		_finished_timer -= dt
		if _finished_timer < 0.0:
			_finished_timer = 9999.0
			app.combat_finished(cs.victory, on_win)

func draw(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, Gfx.W, Gfx.H), UiTheme.BACKGROUND_COLOR)
	if backdrop != "":
		Gfx.image(ci, backdrop + "/bg", "rooms", Rect2(0, 0, Gfx.W, Gfx.H))
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 70)
	var m := mouse()
	_draw_enemies(ci, m)
	_draw_party(ci)
	_draw_resources(ci)
	_draw_log(ci)
	_draw_hand(ci, m)
	_draw_rail(ci, m)
	combat_fx.draw(ci)
	if dice_3d != null and dice_3d.active():
		Gfx.scrim(ci, Rect2(390, 128, 500, 362), 120)
		var die_texture := dice_3d.texture()
		if die_texture != null:
			ci.draw_texture_rect(die_texture, Rect2(430, 150, 420, 320), false)
	for item in active_dice:
		item["roll"].draw(ci, item["center"])
	if announcement != "":
		Gfx.scrim(ci, Rect2(250, 398, 780, 34), 190)
		Gfx.text(ci, announcement, Vector2(Gfx.W / 2.0, 415), 22, UiTheme.SELECTED_BORDER, "center", UiTheme.card_text_font(true))
	if cs.reaction_pending != null:
		Gfx.scrim(ci, Rect2(0, 396, Gfx.W, 30), 200)
		Gfx.text(ci, "Reagir? Escolha uma carta de Reação (ou Enter para não reagir)", Vector2(Gfx.W / 2.0, 411), 20, UiTheme.SELECTED_BORDER, "center", UiTheme.card_text_font(true))
	if cs.discarding:
		Gfx.scrim(ci, Rect2(0, 396, Gfx.W, 30), 200)
		Gfx.text(ci, cs.discard_prompt, Vector2(Gfx.W / 2.0, 411), 20, UiTheme.SELECTED_BORDER, "center", UiTheme.card_text_font(true))
	if cs.picking.size() > 0:
		_draw_pick(ci, m)

func _draw_enemies(ci: CanvasItem, m: Vector2) -> void:
	for i in range(cs.slots.size()):
		var s: Dictionary = cs.slots[i]
		var e: Enemy = s.enemy
		var r := _slot_rect(i)
		r.position += _shake_offset("enemy:%d" % i)
		var alpha := 1.0 if e.is_alive() else 1.0 - float(_death_fade.get("enemy:%d" % i, 0.0))
		var tex := UiAssets.texture(e.slug, "enemies")
		if tex != null:
			ci.draw_texture_rect(tex, r, false, Color(1, 1, 1, alpha))
		else:
			Gfx.image(ci, e.slug, "enemies", r, Color(1, 1, 1, alpha))
		if not e.is_alive():
			continue
		var bar := Rect2(r.position.x, r.position.y - 30, r.size.x, 14)
		Gfx.bar(ci, bar, _shown(e, e.hp).value / float(e.max_hp), UiTheme.HP_BAR_FG, UiTheme.HP_BAR_BG, 4)
		Gfx.outline(ci, bar, UiTheme.CARD_BORDER, 2, 4)
		var label := e.name if cs.slots.size() == 1 else String(e.name).split(" ")[0]
		Gfx.text_outlined(ci, "%s  %d/%d" % [label, maxi(0, roundi(_shown(e, e.hp).value)), e.max_hp], Vector2(r.get_center().x, bar.position.y - 4), 18, UiTheme.TEXT_COLOR, UiTheme.TEXT_OUTLINE, "midbottom", UiTheme.card_text_font(true), 1)
		var tags: PackedStringArray = []
		if e.stunned: tags.append("atordoado")
		if e.effective_ca != e.ca or e.effective_cam != e.cam: tags.append("CA %d/CAM %d" % [e.effective_ca, e.effective_cam])
		if e.next_attack_reduction > 0: tags.append("ataque −%d" % e.next_attack_reduction)
		if e.marked_bonus > 0: tags.append("marcado")
		if not tags.is_empty():
			Gfx.text_outlined(ci, ", ".join(tags), Vector2(r.get_center().x, r.end.y + 4), 15, UiTheme.SELECTED_BORDER, UiTheme.TEXT_OUTLINE, "midtop", UiTheme.card_text_font(true), 1)
		var targetable := selected >= 0 and r.has_point(m)
		if targetable:
			Gfx.outline(ci, r.grow(4), UiTheme.AIM_LINE_COLOR, 3, 8)

func _draw_party(ci: CanvasItem) -> void:
	var rects := _member_rects()
	for i in range(cs.party.size):
		var mb: Member = cs.party.members[i]
		var p: Player = mb.player
		var r: Rect2 = rects[i]
		r.position += _shake_offset("player" if i == cs.party.active else "ally:%d" % i)
		var active := i == cs.party.active
		Gfx.rect(ci, r, Color8(20, 20, 28, 215), 10, 3 if active else 2, UiTheme.SELECTED_BORDER if active else UiTheme.CARD_BORDER)
		Gfx.image(ci, mb.character.id, "portraits", Rect2(r.position.x + 6, r.position.y + 6, 72, 72))
		Gfx.text(ci, mb.character.name, Vector2(r.position.x + 86, r.position.y + 6), 20, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_text_font(true))
		var bar := Rect2(r.position.x + 86, r.position.y + 32, 152, 14)
		Gfx.bar(ci, bar, _shown(p, p.hp).value / p.max_hp, Color8(60, 170, 80) if p.hp > 0 else UiTheme.HP_BAR_FG, UiTheme.HP_BAR_BG, 4)
		Gfx.text(ci, "PV %d/%d" % [maxi(0, roundi(_shown(p, p.hp).value)), p.max_hp], Vector2(r.position.x + 86, r.position.y + 50), 16, UiTheme.TEXT_COLOR, "topleft")
		Gfx.text(ci, "CA %d · CAM %d" % [p.ca, p.cam], Vector2(r.position.x + 86, r.position.y + 66), 15, UiTheme.TEXT_MUTED, "topleft")
		if mb.dead:
			Gfx.text(ci, "morto", Vector2(r.end.x - 8, r.position.y + 8), 16, UiTheme.BLOCKED_COLOR, "topright")
		elif mb.downed:
			Gfx.text(ci, "caído", Vector2(r.end.x - 8, r.position.y + 8), 16, Color8(230, 90, 80), "topright")
		var tstate := mb.turn
		var ind := ("A" if tstate.actions_available > 0 else "·") + ("B" if tstate.bonus_available else "·") + ("R" if tstate.reaction_available else "·")
		Gfx.text(ci, ind, Vector2(r.end.x - 8, r.end.y - 6), 16, UiTheme.SELECTED_BORDER, "bottomright", UiTheme.card_text_font(true))

func _draw_resources(ci: CanvasItem) -> void:
	var p := cs.player
	var c := p.combo
	var panel := Rect2(16, 110, 220, 178)
	Gfx.rect(ci, panel, Color8(20, 20, 28, 200), 10, 2, UiTheme.CARD_BORDER)
	var y := panel.position.y + 8
	if c.charge_mode:
		Gfx.text(ci, "Poder Místico %d/%d" % [c.mystic_power, c.charge_cap], Vector2(panel.position.x + 10, y), 20, UiTheme.card_text_color("Roxo"), "topleft", UiTheme.card_text_font(true))
	else:
		var col := UiTheme.SELECTED_BORDER if c.streak > 0 else UiTheme.TEXT_MUTED
		Gfx.text(ci, "Corrente x%d" % [c.multiplier_for(p.hand[0]) if false else mini(c.streak + c.boost, p.character.chain_cap) + 1], Vector2(panel.position.x + 10, y), 22, col, "topleft", UiTheme.card_text_font(true))
	y += 28
	if c.last_event == "quebrou" and c.streak == 0:
		Gfx.text(ci, "quebrada (era %d)" % c.broken_from, Vector2(panel.position.x + 10, y), 16, Color8(200, 50, 50), "topleft")
	y += 22
	Gfx.text(ci, "Compra %d · Descarte %d" % [p.draw_pile.size(), p.discard.size()], Vector2(panel.position.x + 10, y), 16, UiTheme.TEXT_MUTED, "topleft")
	y += 20
	Gfx.text(ci, "HC gastas %d · Gastas %d" % [p.spent_class.size(), p.exhausted.size()], Vector2(panel.position.x + 10, y), 16, UiTheme.TEXT_MUTED, "topleft")
	y += 22
	if p.guard_cap > 0:
		Gfx.text(ci, "Guarda %d/%d%s" % [p.guard, p.guard_cap, "  (Desonra)" if p.dishonored else ""], Vector2(panel.position.x + 10, y), 18, UiTheme.card_text_color("Azul"), "topleft", UiTheme.card_text_font(true))
		y += 22
	if p.clone_max_hp != null:
		Gfx.text(ci, "Cópia %d/%d" % [int(p.clone_hp), int(p.clone_max_hp)], Vector2(panel.position.x + 10, y), 18, UiTheme.card_text_color("Roxo"), "topleft", UiTheme.card_text_font(true))
		y += 22
	Gfx.text(ci, "Turno %d" % cs.turn_number, Vector2(panel.position.x + 10, panel.end.y - 22), 16, UiTheme.TEXT_MUTED, "topleft")

func _draw_log(ci: CanvasItem) -> void:
	var msgs: Array = cs.messages
	var lines: Array = msgs.slice(maxi(0, msgs.size() - 6))
	var panel := Rect2(RAIL_X - 380, 16, 540, 24 * lines.size() + 14)
	panel.position.x = Gfx.W - panel.size.x - 16
	Gfx.scrim(ci, panel, 150)
	var y := panel.position.y + 8
	for ln in lines:
		Gfx.text(ci, ln, Vector2(panel.position.x + 10, y), 18, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_text_font())
		y += 24

func _draw_hand(ci: CanvasItem, m: Vector2) -> void:
	var hand: Array = cs.player.hand
	var rects := _hand_rects()
	var hovered := -1
	for i in range(rects.size()):
		if rects[i].has_point(m):
			hovered = i
	for i in range(hand.size()):
		var ok := cs.card_playable(hand[i]) or cs.discarding
		CardView.draw_card(ci, hand[i], rects[i], i == hovered, ok, i == selected)
	Gfx.text(ci, "%s · %d PV" % [cs.who, maxi(0, cs.player.hp)], Vector2(20, Gfx.H - 20), 20, UiTheme.TEXT_COLOR, "bottomleft", UiTheme.card_text_font(true))

func _draw_rail(ci: CanvasItem, m: Vector2) -> void:
	var t := cs.turn
	_draw_turn_gem(ci, "ind_acao", "Ação", t.actions_available > 0, Vector2(RAIL_X + 10, 540), t.actions_available)
	_draw_turn_gem(ci, "ind_bonus", "Bônus", t.bonus_available, Vector2(RAIL_X + 66, 540))
	_draw_turn_gem(ci, "ind_reacao", "Reação", t.reaction_available, Vector2(RAIL_X + 122, 540))
	Gfx.button(ci, action_draw_button, "Comprar 1 (Ação)", action_draw_button.has_point(m))
	Gfx.button(ci, bonus_button, "Comprar 1 (Bônus)", bonus_button.has_point(m))
	_draw_button_gem(ci, "ind_acao", action_draw_button, t.actions_available > 0)
	_draw_button_gem(ci, "ind_bonus", bonus_button, t.bonus_available)
	Gfx.button(ci, end_button, "Encerrar turno (Enter)", end_button.has_point(m))
	if cs.can_mulligan:
		Gfx.button(ci, mulligan_button, "Trocar a mão", mulligan_button.has_point(m))

func _draw_turn_gem(ci: CanvasItem, slug: String, label: String, ready: bool, pos: Vector2, amount: int = 0) -> void:
	var tex := UiAssets.texture(slug, "hud")
	var tint := Color.WHITE if ready else Color(0.30, 0.27, 0.32, 1.0)
	if tex != null:
		ci.draw_texture_rect(tex, Rect2(pos, Vector2(28, 28)), false, tint)
	else:
		Gfx.circle(ci, pos + Vector2(14, 14), 11, UiTheme.SELECTED_BORDER if ready else UiTheme.BLOCKED_COLOR)
	Gfx.text(ci, label, pos + Vector2(14, 30), 12, UiTheme.TEXT_COLOR if ready else UiTheme.TEXT_MUTED, "midtop", UiTheme.card_text_font(true))
	if amount > 1:
		Gfx.text_outlined(ci, "x%d" % amount, pos + Vector2(28, 0), 14, UiTheme.SELECTED_BORDER, UiTheme.TEXT_OUTLINE, "topright", UiTheme.card_text_font(true), 1)

func _draw_button_gem(ci: CanvasItem, slug: String, r: Rect2, ready: bool) -> void:
	var tex := UiAssets.texture(slug, "hud")
	if tex != null:
		ci.draw_texture_rect(tex, Rect2(r.position + Vector2(5, 4), Vector2(22, 22)), false, Color.WHITE if ready else Color(0.3, 0.27, 0.32, 1.0))

func _shake_offset(target: String) -> Vector2:
	var left := float(_shakes.get(target, 0.0))
	return Vector2(sin(_t * 72.0) * 6.0 * (left / 0.30), 0) if left > 0.0 else Vector2.ZERO

func _draw_pick(ci: CanvasItem, m: Vector2) -> void:
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 200)
	Gfx.text(ci, "Comunhão: escolha 1 carta para a mão", Vector2(Gfx.W / 2.0, 110), 34, UiTheme.TEXT_COLOR, "center")
	for i in range(cs.picking.size()):
		var r := _pick_rect(i)
		CardView.draw_card(ci, cs.picking[i], r, r.has_point(m), true)
