class_name HqScreen
extends UiScreen
## Visualizador QA dos interlúdios já existentes nos dados da campanha.

var hq: Hq
var panel_index: int = 0
var next_button := Rect2(Gfx.W - 244, Gfx.H - 72, 220, 46)

func _init(hq_: Hq) -> void:
	hq = hq_

func handle_input(event: InputEvent) -> void:
	if is_key(event, KEY_ESCAPE):
		app.return_to_menu()
	elif is_key(event, KEY_ENTER) or is_click(event) and next_button.has_point(event.position):
		if panel_index + 1 < hq.panels.size():
			panel_index += 1
		else:
			app.return_to_menu()

func draw(ci: CanvasItem) -> void:
	Gfx.screen_background(ci, "menu")
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 185)
	if hq.panels.is_empty():
		Gfx.text(ci, hq.title, Vector2(Gfx.W / 2.0, 160), 36, UiTheme.TEXT_COLOR, "center", UiTheme.card_title_font())
		Gfx.text(ci, "Este interlúdio não possui painéis visuais.", Vector2(Gfx.W / 2.0, 220), 22, UiTheme.TEXT_MUTED, "center")
		return
	var panel: HqPanel = hq.panels[panel_index]
	if panel.image != "":
		Gfx.image(ci, panel.image, "hq", Rect2(170, 76, 940, 360))
	Gfx.scrim(ci, Rect2(150, 458, 980, 170), 210)
	Gfx.text(ci, hq.title, Vector2(Gfx.W / 2.0, 28), 34, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
	if panel.speaker != "":
		Gfx.text(ci, panel.speaker, Vector2(180, 474), 22, UiTheme.SELECTED_BORDER, "topleft", UiTheme.card_text_font(true))
	var y := 510.0
	for line in Gfx.wrap_lines(panel.text, 22, 900):
		Gfx.text(ci, line, Vector2(Gfx.W / 2.0, y), 22, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_text_font())
		y += 28
	var label := "Próximo" if panel_index + 1 < hq.panels.size() else "Menu"
	Gfx.button(ci, next_button, label, next_button.has_point(mouse()))
	Gfx.text(ci, "%d/%d · CENÁRIO DE TESTE" % [panel_index + 1, hq.panels.size()], Vector2(20, Gfx.H - 20), 17, UiTheme.TEXT_MUTED, "bottomleft")
