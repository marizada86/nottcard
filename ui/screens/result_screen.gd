class_name ResultScreen
extends UiScreen
## game/app.py::ResultadoScreen / InterludioScreen — o resultado da tentativa: XP, ajuste do desfecho, subida de nível, moedas e estatísticas.

var result: RunResult
var victory: bool = false
var age: float = 0.0
var buttons: Array = []
var scroll: float = 0.0

func _init(result_: RunResult, victory_: bool) -> void:
	result = result_
	victory = victory_

func enter() -> void:
	var options: Array = [["Jogar de novo", func(): app.start_run(app.last_party, app.last_mission)]]
	options.append_array([["Menu", func(): app.return_to_menu()]])
	buttons = MenuScreen.centered_buttons(options, Gfx.H - 56)

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll += 30.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll = maxf(0.0, scroll - 30.0)
	if is_click(event):
		for b in buttons:
			if b["rect"].has_point(event.position):
				b["cb"].call()
				return

func update(dt: float) -> void:
	age += dt

func draw(ci: CanvasItem) -> void:
	Gfx.screen_background(ci, "vitoria" if victory else "game_over")
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 225)
	var r := result
	var cx := Gfx.W / 2.0
	Gfx.text(ci, "Vitória!" if victory else ("Derrota" if r.outcome == ProgressRules.DERROTA else "Desistência"), Vector2(cx, 56), 46, UiTheme.SELECTED_BORDER if victory else Color8(230, 90, 80), "center", UiTheme.card_title_font())
	var who: String = app.run.character.name if app.run != null else ""
	Gfx.text(ci, "%s — nível %d%s" % [who, r.level_after, (" (subiu de %d!)" % r.level_before) if r.leveled_up else ""], Vector2(cx, 108), 26, UiTheme.TEXT_COLOR, "center")
	var y := 150.0 - scroll
	for l in r.lines:
		Gfx.text(ci, l.source, Vector2(cx - 240, y), 22, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_text_font())
		Gfx.text(ci, "+%d XP" % l.amount, Vector2(cx + 240, y), 22, UiTheme.SELECTED_BORDER, "topright", UiTheme.card_text_font(true))
		y += 26
	if r.adjustment != 0:
		Gfx.text(ci, "Ajuste do desfecho", Vector2(cx - 240, y), 22, UiTheme.BLOCKED_COLOR, "topleft", UiTheme.card_text_font())
		Gfx.text(ci, "%d XP" % r.adjustment, Vector2(cx + 240, y), 22, Color8(230, 90, 80), "topright", UiTheme.card_text_font(true))
		y += 26
	Gfx.text(ci, "Total: +%d XP (XP %d → %d)" % [r.gained, r.xp_before, r.xp_after], Vector2(cx, y + 8), 24, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_text_font(true))
	y += 44
	var s := r.stats
	var stat_lines: Array = ["Dano causado %d · recebido %d · cura %d" % [s.damage_dealt, s.damage_taken, s.healing],
		"Inimigos derrotados %d · cartas jogadas %d · turnos %d" % [s.enemies_defeated, s.cards_played, s.turns],
		"Acertos %d · erros %d · críticos %d · maior golpe %d" % [s.hits, s.misses, s.crits, s.max_hit],
		"Moedas ganhas: %d" % r.coins]
	for ln in stat_lines:
		Gfx.text(ci, ln, Vector2(cx, y), 20, UiTheme.TEXT_MUTED, "midtop", UiTheme.card_text_font())
		y += 24
	for lv in r.level_ups:
		for txt in lv.rewards:
			Gfx.text(ci, "Nível %d: %s" % [lv.level, txt], Vector2(cx, y), 20, UiTheme.HEAL_COLOR, "midtop", UiTheme.card_text_font(true))
			y += 24
	for a in r.achievements:
		Gfx.text(ci, "Conquista: %s" % a, Vector2(cx, y), 20, UiTheme.SELECTED_BORDER, "midtop", UiTheme.card_text_font(true))
		y += 24
	var m := mouse()
	for b in buttons:
		Gfx.button(ci, b["rect"], b["label"], b["rect"].has_point(m))
