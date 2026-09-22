class_name SituationScreen
extends UiScreen
## game/app.py::SituacaoScreen — situações de exploração e eventos: opções com atributo e DC; o d20 é decidido no core e a tela só o revela.

const ROLL_TIME := 1.0
const ATTR_LABELS := {"forca": "Força", "inteligencia": "Inteligência", "constituicao": "Constituição", "carisma": "Carisma"}

var situation: Situation
var title: String = ""
var on_done: Callable
var rebuild: Callable
var option_buttons: Array = []   # [{"option", "rect"}]
var continue_button := Rect2((Gfx.W - 220) / 2.0, Gfx.H - 100, 220, 54)
var luck_button := Rect2(Gfx.W / 2.0 - 240, Gfx.H - 100, 220, 54)
var accept_button := Rect2(Gfx.W / 2.0 + 20, Gfx.H - 100, 220, 54)
var chip_rects: Array = []
var tester: int = 0
var chosen: Option = null
var check: CheckResult = null
var applied: Applied = null
var tester_player: Player = null
var luck_pending: bool = false
var roll_age: float = 0.0
var _roll_faces: int = 0

func _init(situation_: Situation, _unused: Callable = Callable(), title_: String = "", on_done_: Callable = Callable(), rebuild_: Callable = Callable()) -> void:
	situation = situation_
	title = title_
	on_done = on_done_
	rebuild = rebuild_

func enter() -> void:
	if title == "":
		var room := app.run.current_room()
		title = situation.title if situation.title != "" else "Sala %d: %s" % [room.id, room.name]
	if not on_done.is_valid():
		on_done = func(a): app.advance_room(false)
	_layout()
	for i in range(app.run.party.size):
		chip_rects.append(Rect2(Gfx.W / 2.0 - 300 + i * 204, Gfx.H - 184, 194, 30))

func _layout() -> void:
	option_buttons = []
	var options := situation.options
	var height := 78
	var spacing := 30
	var per_row := 3 if options.size() <= 3 else 4
	var width := 360 if per_row == 3 else 290
	var rows: Array = []
	for i in range(0, options.size(), per_row):
		rows.append(options.slice(i, i + per_row))
	for r in range(rows.size()):
		var row: Array = rows[r]
		var total := width * row.size() + spacing * (row.size() - 1)
		var x0 := (Gfx.W - total) / 2
		var y := Gfx.H - 150 - (rows.size() - 1 - r) * (height + 12)
		for i in range(row.size()):
			option_buttons.append({"option": row[i], "rect": Rect2(x0 + i * (width + spacing), y, width, height)})

var rolling: bool:
	get:
		return check != null and not chosen.auto and roll_age < ROLL_TIME

var resolved: bool:
	get:
		return check != null and not rolling

var reward_pending: bool:
	get:
		return applied != null and applied.pending != null

func choose(option: Option) -> void:
	if chosen != null:
		return
	if option.cost_gold > app.run.gold_available():
		return
	chosen = option
	if option.combat:
		var room := app.run.current_room()
		app.start_combat(room.make_enemies(), false, room.asset_id)
		return
	tester_player = app.run.party.members[tester].player
	roll_age = 0.0
	if option.auto:
		check = CheckResult.new()
		check.success = true
		roll_age = ROLL_TIME
	else:
		check = app.run.roll_situation(option, tester_player)
	_settle_or_offer_luck()

func _settle_or_offer_luck() -> void:
	if Exploration.can_use_luck(tester_player, check):
		luck_pending = true
		return
	luck_pending = false
	applied = app.run.apply_situation(chosen, tester_player, check)

func use_luck() -> void:
	if not (luck_pending and resolved and Exploration.can_use_luck(tester_player, check)):
		return
	luck_pending = false
	check = app.run.luck_reroll(chosen, tester_player, check)
	roll_age = 0.0
	applied = app.run.apply_situation(chosen, tester_player, check)

func accept_result() -> void:
	if luck_pending and resolved:
		luck_pending = false
		applied = app.run.apply_situation(chosen, tester_player, check)

func take_reward(accept: bool) -> void:
	if resolved and reward_pending:
		applied = app.run.settle_situation_reward(applied, tester_player, accept)

func reopen() -> void:
	if rebuild.is_valid():
		situation = rebuild.call()
		if situation.title != "":
			title = situation.title
	_layout()
	chosen = null
	check = null
	applied = null
	luck_pending = false

func handle_input(event: InputEvent) -> void:
	if is_click(event):
		var p: Vector2 = event.position
		if chosen == null:
			for i in range(chip_rects.size()):
				if chip_rects[i].has_point(p):
					tester = i
					return
			for b in option_buttons:
				if b["rect"].has_point(p):
					choose(b["option"])
					return
			return
		if not resolved:
			return
		if luck_pending:
			if luck_button.has_point(p):
				use_luck()
			elif accept_button.has_point(p):
				accept_result()
			return
		if reward_pending:
			if luck_button.has_point(p):
				take_reward(true)
			elif accept_button.has_point(p):
				take_reward(false)
			return
		if applied != null and continue_button.has_point(p):
			_continue()
	elif is_key(event, KEY_ENTER) and applied != null and resolved and not reward_pending and not luck_pending:
		_continue()

func _continue() -> void:
	if applied.remain and rebuild.is_valid():
		reopen()
		return
	on_done.call(applied)

func update(dt: float) -> void:
	if check != null:
		roll_age += dt

func draw(ci: CanvasItem) -> void:
	var run := app.run
	var room := run.current_room()
	ci.draw_rect(Rect2(0, 0, Gfx.W, Gfx.H), UiTheme.BACKGROUND_COLOR)
	Gfx.image(ci, room.asset_id + "/bg", "rooms", Rect2(0, 0, Gfx.W, Gfx.H))
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 110)
	Gfx.scrim(ci, Rect2(190, 60, 900, 250), 170)
	Gfx.text(ci, title, Vector2(Gfx.W / 2.0, 72), 34, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
	var y := 122.0
	for line in situation.lines:
		y += Gfx.wrapped_center(ci, line, 24, UiTheme.TEXT_COLOR, Gfx.W / 2.0, y, 820, 4, UiTheme.card_text_font())
	var m := mouse()
	if chosen == null:
		if run.party.size > 1:
			for i in range(chip_rects.size()):
				var member: Member = run.party.members[i]
				var sel := i == tester
				Gfx.rect(ci, chip_rects[i], Color8(52, 90, 60) if sel else UiTheme.BUTTON_COLOR, 6, 2, UiTheme.SELECTED_BORDER if sel else UiTheme.CARD_BORDER)
				Gfx.text(ci, member.character.name, chip_rects[i].get_center(), 19, UiTheme.TEXT_COLOR, "center", UiTheme.card_text_font(true))
		for b in option_buttons:
			_draw_option(ci, b["option"], b["rect"], m)
		return
	# resultado
	var who: String = tester_player.character.name
	var panel := Rect2(290, 330, 700, 210)
	Gfx.rect(ci, panel, Color8(20, 20, 28, 235), 14, 3, UiTheme.CARD_BORDER)
	Gfx.text(ci, "%s — %s" % [who, chosen.label], Vector2(panel.get_center().x, panel.position.y + 14), 24, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_text_font(true))
	if not chosen.auto:
		var shown: int
		if rolling:
			shown = 1 + int(roll_age * 30) % 20
		else:
			shown = check.roll
		Gfx.text(ci, str(shown), Vector2(panel.position.x + 120, panel.position.y + 110), 84, UiTheme.SELECTED_BORDER if not rolling else UiTheme.TEXT_MUTED, "center", UiTheme.card_title_font())
		if resolved:
			var extra := (" %+d" % check.bonus) if check.bonus != 0 else ""
			Gfx.text(ci, "d20 %d %+d%s = %d vs DC %d" % [check.roll, check.modifier, extra, check.total, check.dc], Vector2(panel.position.x + 230, panel.position.y + 78), 24, UiTheme.TEXT_COLOR, "topleft")
			var verdict := "Sucesso" if check.success else ("FALHA CRÍTICA" if check.critical else "Falha")
			Gfx.text(ci, verdict, Vector2(panel.position.x + 230, panel.position.y + 112), 34, UiTheme.HEAL_COLOR if check.success else Color8(230, 90, 80), "topleft")
	if resolved and applied != null:
		Gfx.wrapped_center(ci, applied.text, 22, UiTheme.TEXT_COLOR, panel.get_center().x, panel.position.y + 160, 640, 2, UiTheme.card_text_font())
		var bits: PackedStringArray = []
		if applied.xp != 0: bits.append("+%d XP" % applied.xp)
		if applied.hp_lost != 0: bits.append("−%d PV" % applied.hp_lost)
		if applied.gold != 0: bits.append("%+d ouro" % applied.gold)
		if applied.healed != 0: bits.append("+%d PV curados" % applied.healed)
		if applied.drawn != 0: bits.append("+%d carta" % applied.drawn)
		if applied.lost_card != null: bits.append("perdeu %s" % applied.lost_card.name)
		if not bits.is_empty():
			Gfx.text(ci, " · ".join(bits), Vector2(panel.get_center().x, panel.end.y + 10), 22, UiTheme.SELECTED_BORDER, "midtop", UiTheme.card_text_font(true))
	if resolved:
		if luck_pending:
			Gfx.button(ci, luck_button, "Usar Sorte (%d)" % tester_player.luck, luck_button.has_point(m))
			Gfx.button(ci, accept_button, "Aceitar", accept_button.has_point(m))
		elif reward_pending:
			var pr: PendingReward = applied.pending
			var what: PackedStringArray = []
			if pr.draw != 0: what.append("+%d carta" % pr.draw)
			if pr.item != null: what.append(pr.item.nome)
			if pr.temp_card != "": what.append("carta temporária")
			if pr.temp_item != "": what.append("item temporário")
			Gfx.text(ci, "Recompensa: " + ", ".join(what), Vector2(Gfx.W / 2.0, Gfx.H - 140), 22, UiTheme.SELECTED_BORDER, "midtop")
			Gfx.button(ci, luck_button, "Aceitar", luck_button.has_point(m))
			Gfx.button(ci, accept_button, "Recusar", accept_button.has_point(m))
		elif applied != null:
			Gfx.button(ci, continue_button, "Continuar", continue_button.has_point(m))

func _draw_option(ci: CanvasItem, o: Option, rect: Rect2, m: Vector2) -> void:
	var affordable := o.cost_gold <= app.run.gold_available()
	Gfx.rect(ci, rect, UiTheme.BUTTON_HOVER if (rect.has_point(m) and affordable) else UiTheme.BUTTON_COLOR, 10, 2, UiTheme.CARD_BORDER)
	Gfx.text(ci, o.label, Vector2(rect.get_center().x, rect.position.y + 10), 22, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_text_font(true))
	var sub := o.check_label if not o.combat else "Combate"
	Gfx.text(ci, sub, Vector2(rect.get_center().x, rect.position.y + 38), 19, UiTheme.SELECTED_BORDER, "midtop", UiTheme.card_text_font(true))
	if o.attribute != null:
		var pv: Variant = Exploration.check_preview(app.run.party.members[tester].player, o)
		if pv != null:
			Gfx.text(ci, pv.chance_text, Vector2(rect.get_center().x, rect.position.y + 58), 16, UiTheme.TEXT_MUTED, "midtop", UiTheme.card_text_font())
	if not affordable:
		Gfx.rect(ci, rect, Color8(8, 8, 12, 150), 10)
