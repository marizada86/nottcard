class_name CombatScreen
extends UiScreen
## game/app.py::CombateScreen (versão sem dados 3D nem batidas animadas): a UI de um combate sobre o CombatSession. Desenha cenário, inimigos, grupo,
## mão, trilho de ações, log e números flutuantes; entrada: clicar a carta (seleciona/joga), clicar o inimigo (alvo), botões da direita.

const ENEMY_W := 200
const ENEMY_H := 300
const ENEMY_Y := 90
const RAIL_X := 1090
const RAIL_W := 170
const FLOAT_TIME := 1.5

var cs: CombatSession
var backdrop: String = ""
var on_win: Callable
var selected: int = -1
var floaters: Array = []   # [{"text","pos","color","age","size","big"}]
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

## Converte os efeitos do core em números flutuantes.
func _consume_fx() -> void:
	for f in cs.fx:
		var pos := Vector2(Gfx.W / 2.0, 470)
		var target: String = f["target"]
		if target.begins_with("enemy:"):
			var idx := int(target.split(":")[1])
			if idx < cs.slots.size():
				var r := _slot_rect(idx)
				pos = r.get_center() + Vector2(0, -20)
		elif target.begins_with("ally:"):
			var r2: Rect2 = _member_rects()[int(target.split(":")[1])]
			pos = r2.get_center()
		var color := UiTheme.TEXT_COLOR
		match f["kind"]:
			"damage":
				color = UiTheme.card_text_color(f["color"]) if f["color"] != "" else UiTheme.TEXT_COLOR
				floaters.append({"text": str(f["value"]), "pos": pos, "color": color, "age": 0.0, "size": 46})
			"player_damage":
				floaters.append({"text": str(f["value"]), "pos": Vector2(Gfx.W / 2.0, 455), "color": Color8(255, 140, 130), "age": 0.0, "size": 46})
			"heal":
				floaters.append({"text": "+%d" % f["value"], "pos": Vector2(Gfx.W / 2.0, 455), "color": UiTheme.HEAL_COLOR, "age": 0.0, "size": 42})
			_:
				color = UiTheme.card_text_color(f["color"]) if f["color"] != "" else UiTheme.BLOCKED_COLOR
				var n := 0
				for g in floaters:
					if g["pos"].distance_to(pos) < 26 and g["age"] < 0.5:
						n += 1
				floaters.append({"text": f["text"], "pos": pos + Vector2(0, 34 * n), "color": color, "age": 0.0, "size": 22})
	cs.fx.clear()

func _pick_rect(i: int) -> Rect2:
	var n := cs.picking.size()
	var w := 220.0
	var gap := 30.0
	var total := n * w + (n - 1) * gap
	return Rect2((Gfx.W - total) / 2.0 + i * (w + gap), 190, w, 320)

func update(dt: float) -> void:
	_t += dt
	for f in floaters:
		f["age"] += dt
	floaters = floaters.filter(func(f): return f["age"] < FLOAT_TIME)
	for i in range(cs.slots.size()):
		var e: Enemy = cs.slots[i].enemy
		var cur: float = _shown_hp.get(e, float(e.hp))
		_shown_hp[e] = move_toward(cur, float(maxi(0, e.hp)), 60.0 * dt)
	app.run.stats.seconds += dt
	if cs.finished and _finished_timer < 0.0:
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
	for f in floaters:
		var t: float = f["age"] / FLOAT_TIME
		var col: Color = f["color"]
		col.a = 1.0 - maxf(0.0, (t - 0.6) / 0.4)
		Gfx.text_outlined(ci, f["text"], f["pos"] + Vector2(0, -50 * t), f["size"], col, UiTheme.TEXT_OUTLINE, "center", UiTheme.card_title_font())
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
		var alpha := 1.0 if e.is_alive() else 0.25
		var tex := UiAssets.texture(e.slug, "enemies")
		if tex != null:
			ci.draw_texture_rect(tex, r, false, Color(1, 1, 1, alpha))
		else:
			Gfx.image(ci, e.slug, "enemies", r, Color(1, 1, 1, alpha))
		if not e.is_alive():
			continue
		var bar := Rect2(r.position.x, r.position.y - 30, r.size.x, 14)
		Gfx.bar(ci, bar, _shown_hp.get(e, float(e.hp)) / float(e.max_hp), UiTheme.HP_BAR_FG, UiTheme.HP_BAR_BG, 4)
		Gfx.outline(ci, bar, UiTheme.CARD_BORDER, 2, 4)
		var label := e.name if cs.slots.size() == 1 else String(e.name).split(" ")[0]
		Gfx.text_outlined(ci, "%s  %d/%d" % [label, maxi(0, e.hp), e.max_hp], Vector2(r.get_center().x, bar.position.y - 4), 18, UiTheme.TEXT_COLOR, UiTheme.TEXT_OUTLINE, "midbottom", UiTheme.card_text_font(true), 1)
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
		var active := i == cs.party.active
		Gfx.rect(ci, r, Color8(20, 20, 28, 215), 10, 3 if active else 2, UiTheme.SELECTED_BORDER if active else UiTheme.CARD_BORDER)
		Gfx.image(ci, mb.character.id, "portraits", Rect2(r.position.x + 6, r.position.y + 6, 72, 72))
		Gfx.text(ci, mb.character.name, Vector2(r.position.x + 86, r.position.y + 6), 20, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_text_font(true))
		var bar := Rect2(r.position.x + 86, r.position.y + 32, 152, 14)
		Gfx.bar(ci, bar, float(maxi(0, p.hp)) / p.max_hp, Color8(60, 170, 80) if p.hp > 0 else UiTheme.HP_BAR_FG, UiTheme.HP_BAR_BG, 4)
		Gfx.text(ci, "PV %d/%d" % [maxi(0, p.hp), p.max_hp], Vector2(r.position.x + 86, r.position.y + 50), 16, UiTheme.TEXT_COLOR, "topleft")
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
	Gfx.text(ci, "Ação %s · Bônus %s · Reação %s" % ["●" if t.actions_available > 0 else "○", "●" if t.bonus_available else "○", "●" if t.reaction_available else "○"],
		Vector2(RAIL_X + RAIL_W / 2.0, 548), 16, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_text_font(true))
	Gfx.button(ci, action_draw_button, "Comprar 1 (Ação)", action_draw_button.has_point(m))
	Gfx.button(ci, bonus_button, "Comprar 1 (Bônus)", bonus_button.has_point(m))
	Gfx.button(ci, end_button, "Encerrar turno (Enter)", end_button.has_point(m))
	if cs.can_mulligan:
		Gfx.button(ci, mulligan_button, "Trocar a mão", mulligan_button.has_point(m))

func _draw_pick(ci: CanvasItem, m: Vector2) -> void:
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 200)
	Gfx.text(ci, "Comunhão: escolha 1 carta para a mão", Vector2(Gfx.W / 2.0, 110), 34, UiTheme.TEXT_COLOR, "center")
	for i in range(cs.picking.size()):
		var r := _pick_rect(i)
		CardView.draw_card(ci, cs.picking[i], r, r.has_point(m), true)
