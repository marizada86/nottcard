class_name QaNavigator
extends Control

const PANEL := Rect2(90, 42, 1100, 636)
const START_BUTTON := Rect2(900, 606, 250, 44)
const PARTY_BUTTON := Rect2(600, 606, 280, 44)
const SEED_BUTTON := Rect2(300, 606, 280, 44)

var app: GameApp
var scenarios: Array = []
var group: String = "M1"
var party_index: int = 0
var seed_index: int = 0
var selected: QaScenario = null
var group_buttons: Array = []
var row_buttons: Array = []
const PARTIES := [["durvall"], ["durvall", "maelor"], ["durvall", "maelor", "sylas"], ["kayron", "brook"]]
const SEEDS := [1, 42, 20260923]

func open_for(game: GameApp) -> void:
	app = game
	scenarios = QaScenarios.all()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_select_first()
	queue_redraw()

func _groups() -> Array:
	var out: Array = []
	for scenario in scenarios:
		if not (scenario.group in out):
			out.append(scenario.group)
	return out

func _select_first() -> void:
	for scenario in scenarios:
		if scenario.group == group:
			selected = scenario
			return

func handle_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			queue_free()
			return true
		if event.keycode == KEY_ENTER and selected != null:
			_start()
			return true
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP:
			return true
		if event.button_index != MOUSE_BUTTON_LEFT:
			return false
		var p: Vector2 = event.position
		for button in group_buttons:
			if button.rect.has_point(p):
				group = button.group
				_select_first()
				queue_redraw()
				return true
		for button in row_buttons:
			if button.rect.has_point(p):
				selected = button.scenario
				queue_redraw()
				return true
		if PARTY_BUTTON.has_point(p):
			party_index = (party_index + 1) % PARTIES.size()
			queue_redraw()
			return true
		if SEED_BUTTON.has_point(p):
			seed_index = (seed_index + 1) % SEEDS.size()
			queue_redraw()
			return true
		if START_BUTTON.has_point(p) and selected != null:
			_start()
			return true
	return false

func _start() -> void:
	app.start_qa_scenario(selected, PARTIES[party_index], SEEDS[seed_index])
	queue_free()

func _draw() -> void:
	Gfx.scrim(self, Rect2(0, 0, Gfx.W, Gfx.H), 225)
	Gfx.rect(self, PANEL, Color8(20, 20, 28, 248), 14, 3, UiTheme.CARD_BORDER)
	Gfx.text(self, "Navegador QA", Vector2(PANEL.position.x + 28, PANEL.position.y + 20), 34, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_title_font())
	Gfx.text(self, "Cenários usam save isolado; o progresso normal não será alterado.", Vector2(PANEL.position.x + 28, PANEL.position.y + 62), 18, UiTheme.TEXT_MUTED, "topleft")
	group_buttons = []
	var x := PANEL.position.x + 24
	for name in _groups():
		var width := 72 if name.begins_with("M") else 108
		var rect := Rect2(x, PANEL.position.y + 94, width, 34)
		group_buttons.append({"group": name, "rect": rect})
		Gfx.button(self, rect, name, rect.has_point(get_local_mouse_position()) or name == group)
		x += width + 8
	row_buttons = []
	var y := PANEL.position.y + 148
	for scenario in scenarios:
		if scenario.group != group:
			continue
		var rect := Rect2(PANEL.position.x + 28, y, 1044, 54)
		row_buttons.append({"scenario": scenario, "rect": rect})
		Gfx.rect(self, rect, UiTheme.BUTTON_HOVER if scenario == selected else UiTheme.BUTTON_COLOR, 8, 2, UiTheme.SELECTED_BORDER if scenario == selected else UiTheme.CARD_BORDER)
		Gfx.text(self, scenario.title, Vector2(rect.position.x + 14, rect.position.y + 8), 21, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_text_font(true))
		Gfx.text(self, scenario.description, Vector2(rect.position.x + 14, rect.position.y + 31), 16, UiTheme.TEXT_MUTED, "topleft")
		y += 62
		if y > 572:
			break
	Gfx.button(self, SEED_BUTTON, "Seed: %d" % SEEDS[seed_index], SEED_BUTTON.has_point(get_local_mouse_position()))
	var party_names: Array = []
	for cid in PARTIES[party_index]:
		party_names.append(String(cid).capitalize())
	Gfx.button(self, PARTY_BUTTON, "Grupo: " + ", ".join(party_names), PARTY_BUTTON.has_point(get_local_mouse_position()))
	Gfx.button(self, START_BUTTON, "Iniciar cenário (Enter)", START_BUTTON.has_point(get_local_mouse_position()))
	Gfx.text(self, "Esc fecha · Ctrl+O+P também abre este painel", Vector2(PANEL.position.x + 28, PANEL.end.y - 18), 16, UiTheme.TEXT_MUTED, "bottomleft")
