class_name PlaytestGuide
extends Control

var app: GameApp
var mark_seen: bool = false

func open_for(game: GameApp, should_mark_seen: bool) -> void:
	app = game
	mark_seen = should_mark_seen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func close() -> void:
	if mark_seen:
		app.profile.mark_welcome_seen()
	queue_free()

func handle_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_F1):
		close()
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()
		return true
	return false

func _draw() -> void:
	var panel := Rect2(150, 90, 980, 540)
	Gfx.scrim(self, Rect2(0, 0, Gfx.W, Gfx.H), 225)
	Gfx.rect(self, panel, Color8(20, 20, 28, 248), 14, 3, UiTheme.CARD_BORDER)
	var name := app.profile.name if app.profile.name != "" else "playtester"
	Gfx.text_fit(self, "Obrigado por testar, %s!" % name, Rect2(panel.position.x + 42, 110, panel.size.x - 84, 46), 34, UiTheme.TEXT_COLOR, "center", UiTheme.card_title_font(), 18, 0)
	var lines := [
		"1. Escolha uma task e reproduza o cenário pedido.",
		"2. F6 guarda um print no pacote; F5 escreve uma nota com o print do instante.",
		"3. F7 gera um único ZIP. Anexe-o manualmente na conversa da task.",
		"4. O ZIP inclui contexto, estado e log para ajudar a reproduzir o caso.",
	]
	var y := 182.0
	for line in lines:
		var used := Gfx.wrapped_fit(self, line, Rect2(panel.position.x + 48, y, panel.size.x - 96, 48), 22, UiTheme.TEXT_COLOR, false, 2, UiTheme.card_text_font(), 15, 0)
		y += maxf(54.0, used + 8.0)
	Gfx.scrim(self, Rect2(panel.position.x + 42, 432, panel.size.x - 84, 76), 160)
	Gfx.text_fit(self, "F5 nota · F6 print · F7 gera ZIP · F11 tela cheia · F12 log", Rect2(panel.position.x + 54, 446, panel.size.x - 108, 30), 20, UiTheme.SELECTED_BORDER, "center", UiTheme.card_text_font(true), 14, 0)
	Gfx.text_fit(self, "Enter, Esc ou clique para começar", Rect2(panel.position.x + 54, 548, panel.size.x - 108, 34), 20, UiTheme.TEXT_MUTED, "center", null, 14, 0)
