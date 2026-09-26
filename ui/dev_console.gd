class_name DevConsole
extends Control

const PANEL := Rect2(300, 20, 680, 370)
const QA_BUTTON := Rect2(330, 318, 290, 42)
const TAB_LOG := Rect2(330, 52, 120, 34)
const TAB_COMMANDS := Rect2(460, 52, 170, 34)

var app: GameApp
var log: DevLog
var command_input: LineEdit = null

func open_for(game: GameApp, dev_log: DevLog) -> void:
	app = game
	log = dev_log
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func handle_input(event: InputEvent) -> bool:
	if command_input != null and command_input.visible and event is InputEventKey and event.keycode != KEY_F12:
		return true
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return false
	var p: Vector2 = event.position
	if TAB_LOG.has_point(p):
		log.commands_tab = false
		_hide_command_input()
		queue_redraw()
		return true
	if BuildConfig.qa_tools_enabled() and TAB_COMMANDS.has_point(p):
		log.commands_tab = true
		_show_command_input()
		queue_redraw()
		return true
	if BuildConfig.qa_tools_enabled() and QA_BUTTON.has_point(p):
		app.open_qa_navigator()
		return true
	return false

func _show_command_input() -> void:
	if command_input != null:
		command_input.show()
		command_input.grab_focus()
		return
	command_input = LineEdit.new()
	command_input.position = Vector2(PANEL.position.x + 30, 226)
	command_input.size = Vector2(590, 36)
	command_input.placeholder_text = "list · start <id-do-cenário>"
	command_input.text_submitted.connect(_run_command)
	add_child(command_input)
	command_input.grab_focus()

func _hide_command_input() -> void:
	if command_input != null:
		command_input.hide()

func _run_command(command: String) -> void:
	var parts := command.strip_edges().split(" ", false)
	if parts.is_empty():
		return
	match parts[0].to_lower():
		"list":
			var ids: Array = []
			for scenario in QaScenarios.all():
				ids.append(scenario.id)
			log.add("Cenários: " + ", ".join(ids))
		"start":
			if parts.size() < 2:
				log.add("Uso: start <id-do-cenário>")
			else:
				for scenario in QaScenarios.all():
					if scenario.id == parts[1]:
						app.start_qa_scenario(scenario, ["durvall"], 1)
						log.add("Cenário iniciado por comando: " + scenario.id)
						command_input.clear()
						return
				log.add("Cenário não encontrado: " + parts[1])
		_:
			log.add("Comandos seguros: list · start <id-do-cenário>")
	command_input.clear()
	queue_redraw()

func _draw() -> void:
	Gfx.scrim(self, PANEL, 218)
	Gfx.rect(self, PANEL, Color8(12, 12, 18, 240), 10, 2, UiTheme.CARD_BORDER)
	Gfx.button(self, TAB_LOG, "Log", TAB_LOG.has_point(get_local_mouse_position()))
	if BuildConfig.qa_tools_enabled():
		Gfx.button(self, TAB_COMMANDS, "Comandos", TAB_COMMANDS.has_point(get_local_mouse_position()))
	if log.commands_tab and BuildConfig.qa_tools_enabled():
		Gfx.text_fit(self, "Comandos seguros", Rect2(PANEL.position.x + 24, 104, PANEL.size.x - 48, 34), 25, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_title_font(), 16, 0)
		Gfx.wrapped_fit(self, "Os cenários substituem comandos de código livre. Digite ‘list’ ou ‘start <id>’; ou abra a lista visual.", Rect2(PANEL.position.x + 24, 144, PANEL.size.x - 48, 62), 19, UiTheme.TEXT_MUTED, false, 2, null, 14, 0)
		Gfx.button(self, QA_BUTTON, "Abrir Navegador QA", QA_BUTTON.has_point(get_local_mouse_position()))
		return
	var y := 106.0
	var lines: Array = log.recent(12)
	if lines.is_empty():
		Gfx.text_fit(self, "Ainda não há eventos no log.", Rect2(PANEL.position.x + 24, y, PANEL.size.x - 48, 20), 19, UiTheme.TEXT_MUTED, "topleft", null, 14, 0)
	for line in lines:
		Gfx.text_fit(self, line, Rect2(PANEL.position.x + 24, y, PANEL.size.x - 48, 18), 16, UiTheme.TEXT_COLOR, "topleft", null, 12, 0)
		y += 20
	Gfx.text_fit(self, "F12 fecha · o log também acompanha o ZIP", Rect2(PANEL.position.x + 16, PANEL.end.y - 32, PANEL.size.x - 32, 22), 16, UiTheme.TEXT_MUTED, "bottomleft", null, 12, 0)
