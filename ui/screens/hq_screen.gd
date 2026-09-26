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
		Gfx.text_fit(ci, hq.title, Rect2(160, 120, 960, 72), 36, UiTheme.TEXT_COLOR, "center", UiTheme.card_title_font(), 20)
		Gfx.text(ci, "Este interlúdio não possui painéis visuais.", Vector2(Gfx.W / 2.0, 220), 22, UiTheme.TEXT_MUTED, "center")
		return
	var panel: HqPanel = hq.panels[panel_index]
	if panel.image != "":
		Gfx.image(ci, panel.image, "hq", Rect2(170, 76, 940, 360))
	var story_rect := Rect2(150, 446, 980, 188)
	Gfx.scrim(ci, story_rect, 210)
	Gfx.text_fit(ci, hq.title, Rect2(160, 12, 960, 52), 34, UiTheme.TEXT_COLOR, "center", UiTheme.card_title_font(), 20)
	if panel.speaker != "":
		Gfx.text_fit(ci, panel.speaker, Rect2(174, 460, 932, 28), 22, UiTheme.SELECTED_BORDER, "topleft", UiTheme.card_text_font(true), 14, 0)
	var text_top := 492.0 if panel.speaker != "" else 462.0
	Gfx.wrapped_fit(ci, panel.text, Rect2(166, text_top, 948, 136 if panel.speaker != "" else 162), 22, UiTheme.TEXT_COLOR, true, 2, UiTheme.card_text_font(), 14, 8)
	var label := "Próximo" if panel_index + 1 < hq.panels.size() else "Menu"
	Gfx.button(ci, next_button, label, next_button.has_point(mouse()))
	Gfx.text(ci, "%d/%d · CENÁRIO DE TESTE" % [panel_index + 1, hq.panels.size()], Vector2(20, Gfx.H - 20), 17, UiTheme.TEXT_MUTED, "bottomleft")
