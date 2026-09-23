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
	Gfx.text(self, "Obrigado por testar, %s!" % name, Vector2(panel.get_center().x, 122), 34, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
	var lines := [
		"1. Escolha uma task e reproduza o cenário pedido.",
		"2. F6 guarda um print no pacote; F5 escreve uma nota com o print do instante.",
		"3. F7 gera um único ZIP. Anexe-o manualmente na conversa da task.",
		"4. O ZIP inclui contexto, estado e log para ajudar a reproduzir o caso.",
	]
	var y := 202.0
	for line in lines:
		Gfx.text(self, line, Vector2(panel.position.x + 54, y), 22, UiTheme.TEXT_COLOR, "topleft", UiTheme.card_text_font())
		y += 54
	Gfx.scrim(self, Rect2(panel.position.x + 42, 432, panel.size.x - 84, 76), 160)
	Gfx.text(self, "F5 nota · F6 print · F7 gera ZIP · F11 tela cheia · F12 log", Vector2(panel.get_center().x, 454), 20, UiTheme.SELECTED_BORDER, "midtop", UiTheme.card_text_font(true))
	Gfx.text(self, "Enter, Esc ou clique para começar", Vector2(panel.get_center().x, 566), 20, UiTheme.TEXT_MUTED, "center")
