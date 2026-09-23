class_name MenuScreen
extends UiScreen
## game/app.py::MenuScreen — o menu principal.

const CONFIRM_PANEL := Rect2(420, 220, 440, 250)
const MAX_BUTTONS_PER_ROW := 6

var buttons: Array = []   # [{"label", "rect": Rect2, "cb": Callable}]
var confirming: bool = false
var player_button := Rect2(Gfx.W - 192, 44, 180, 36)
var motion_button := Rect2(12, 14, 210, 36)
var playtester_button := Rect2(12, 102, 210, 36)
var fps_button := Rect2(12, 146, 210, 36)
var flicker_button := Rect2(12, 190, 210, 36)
var bob_button := Rect2(12, 234, 210, 36)
var erase_button := Rect2(CONFIRM_PANEL.position.x + 24, CONFIRM_PANEL.end.y - 74, 180, 50)
var cancel_button := Rect2(CONFIRM_PANEL.end.x - 204, CONFIRM_PANEL.end.y - 74, 180, 50)

## Botões centralizados; passando de 6 viram duas fileiras (game/app.py::_centered_buttons).
static func centered_buttons(labels_and_cbs: Array, center_y: float) -> Array:
	var total_count := labels_and_cbs.size()
	var rows := 1 if total_count <= MAX_BUTTONS_PER_ROW else 2
	var per_row := int(ceil(float(total_count) / rows))
	var spacing := 30
	var row_pitch := 66
	var out: Array = []
	for r in range(rows):
		var chunk: Array = labels_and_cbs.slice(r * per_row, (r + 1) * per_row)
		var count := chunk.size()
		if count == 0:
			continue
		var width: int = mini(220, (Gfx.W - 40 - spacing * (count - 1)) / count)
		var total := width * count + spacing * (count - 1)
		var start_x := (Gfx.W - total) / 2
		var y := center_y + Py.round_half_even((r - (rows - 1) / 2.0) * row_pitch)
		for i in range(count):
			out.append({"label": chunk[i][0], "cb": chunk[i][1], "rect": Rect2(start_x + i * (width + spacing), y - 27, width, 54)})
	return out

func enter() -> void:
	var st := app.save_state
	var has_progress := st.has_progress
	var options: Array = [["Continuar" if has_progress else "Iniciar", func(): app.open_character_select()]]
	if has_progress:
		options.append(["Novo jogo", func(): confirming = true])
	options.append_array([["Cartas", func(): app.show_toast("Coleção: em porte", 2.0)], ["Loja", func(): app.show_toast("Loja: em porte", 2.0)],
		["Baralho", func(): app.show_toast("Baralho: em porte", 2.0)], ["Equipamento", func(): app.show_toast("Equipamento: em porte", 2.0)]])
	if BuildConfig.playtest_enabled():
		options.append_array([["Guia do playtest (F1)", func(): app.show_playtest_guide()], ["Nota (F5)", func(): app._open_notepad()], ["Print (F6)", func(): app._capture_print()], ["Gerar ZIP (F7)", func(): app._export_evidence()]])
	if BuildConfig.qa_tools_enabled():
		options.append(["Ferramentas de teste", func(): app.open_qa_navigator()])
	buttons = centered_buttons(options, Gfx.H / 2.0 + 60)

func handle_input(event: InputEvent) -> void:
	if confirming:
		if is_key(event, KEY_ESCAPE):
			confirming = false
		elif is_click(event):
			if erase_button.has_point(event.position):
				app.save_store.clear()
				Collection.ensure_collection(app.save_state)
				app.save_store.save(app.save_state)
				app.open_menu()
			elif cancel_button.has_point(event.position):
				confirming = false
		return
	if not is_click(event):
		return
	var p: Vector2 = event.position
	if motion_button.has_point(p):
		app.reduce_motion = not app.reduce_motion
		app.profile.set_reduce_motion(app.reduce_motion)
		return
	if fps_button.has_point(p):
		app.fps_cap = 30 if app.fps_cap == 60 else 60
		app.profile.set_fps_cap(app.fps_cap)
		Engine.max_fps = app.fps_cap
		return
	if flicker_button.has_point(p):
		app.torch_flicker = not app.torch_flicker
		app.profile.set_torch_flicker(app.torch_flicker)
		return
	if bob_button.has_point(p):
		app.walk_bob = not app.walk_bob
		app.profile.set_walk_bob(app.walk_bob)
		return
	if playtester_button.has_point(p):
		app.playtester_mode = not app.playtester_mode
		app.profile.set_playtester(app.playtester_mode)
		return
	for b in buttons:
		if b["rect"].has_point(p):
			b["cb"].call()
			return

func draw(ci: CanvasItem) -> void:
	Gfx.screen_background(ci, "menu")
	Gfx.scrim(ci, Rect2(0, Gfx.H / 2.0 - 110, Gfx.W, 220))
	Gfx.text(ci, "M1 — A Fechadura da Fenda nas Docas (solo)", Vector2(Gfx.W / 2.0, Gfx.H / 2.0 - 10), 20, UiTheme.TEXT_MUTED, "center")
	Gfx.text(ci, GameApp.VERSION_LABEL, Vector2(Gfx.W - 12, Gfx.H - 10), 16, UiTheme.TEXT_MUTED, "bottomright")
	var m := mouse()
	for b in buttons:
		Gfx.button(ci, b["rect"], b["label"], b["rect"].has_point(m) and not confirming)
	Gfx.button(ci, motion_button, "Câmera: " + ("reduzida" if app.reduce_motion else "normal"), motion_button.has_point(m) and not confirming)
	Gfx.button(ci, fps_button, "Quadros por segundo: %d" % app.fps_cap, fps_button.has_point(m) and not confirming)
	Gfx.button(ci, flicker_button, "Tremulação da luz: " + ("ligada" if app.torch_flicker else "desligada"), flicker_button.has_point(m) and not confirming)
	Gfx.button(ci, bob_button, "Movimento suave: " + ("ligado" if app.walk_bob else "desligado"), bob_button.has_point(m) and not confirming)
	Gfx.button(ci, playtester_button, "Modo playtester: " + ("ligado" if app.playtester_mode else "desligado"), playtester_button.has_point(m) and not confirming)
	if confirming:
		ci.draw_rect(Rect2(0, 0, Gfx.W, Gfx.H), Color8(6, 6, 10, 190))
		var panel := CONFIRM_PANEL
		Gfx.rect(ci, panel, UiTheme.PANEL_COLOR, 14, 3, UiTheme.CARD_BORDER)
		Gfx.text(ci, "Apagar o save?", Vector2(panel.get_center().x, panel.position.y + 24), 28, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
		var i := 0
		for line in ["O nível e o XP de todos os", "personagens voltam ao zero."]:
			Gfx.text(ci, line, Vector2(panel.get_center().x, panel.position.y + 80 + i * 28), 22, UiTheme.TEXT_MUTED, "midtop", UiTheme.card_text_font())
			i += 1
		Gfx.button(ci, erase_button, "Apagar e recomeçar", erase_button.has_point(m))
		Gfx.button(ci, cancel_button, "Cancelar", cancel_button.has_point(m))
