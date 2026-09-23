class_name EvidenceNotepad
extends Control
## Overlay de nota: o TextEdit nativo cuida de seleção, colagem e desfazer.

const PANEL := Rect2(160, 72, 960, 576)
const EDITOR_RECT := Rect2(190, 160, 900, 370)
const CLEAR_RECT := Rect2(190, 550, 220, 42)

var app: GameApp
var opening_png: PackedByteArray
var editor: TextEdit
var clear_armed: bool = false

func open_for(game: GameApp, png: PackedByteArray) -> void:
	app = game
	opening_png = png
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	editor = TextEdit.new()
	editor.position = EDITOR_RECT.position
	editor.size = EDITOR_RECT.size
	editor.placeholder_text = "Escreva o que aconteceu, o que pareceu estranho e como repetir. Não escreva senhas ou dados pessoais."
	editor.max_length = 1000
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	editor.tooltip_text = "Ctrl+Z desfaz · Ctrl+Y refaz · Ctrl+C/Ctrl+V copia e cola"
	add_child(editor)
	editor.text_changed.connect(queue_redraw)
	editor.grab_focus()
	queue_redraw()

func close_and_store() -> void:
	var text := editor.text
	if not text.strip_edges().is_empty():
		var result := app.evidence_store.add_note(opening_png, text, app.evidence_context())
		if result.ok:
			app.show_toast("Nota guardada (%s). F7 gera o ZIP." % app.evidence_store.summary(), 3.0)
			if result.near_limit:
				app.show_toast("Pacote quase cheio: gere o ZIP com F7.", 4.0)
		else:
			app.show_toast(result.error, 4.0)
	else:
		app.show_toast("Nota vazia descartada.", 2.0)
	if app.screen != null:
		app.screen.resume()
	queue_free()

func cancel() -> void:
	if app.screen != null:
		app.screen.resume()
	queue_free()

func handle_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and CLEAR_RECT.has_point(event.position):
		if clear_armed:
			editor.clear()
			clear_armed = false
			app.show_toast("Texto apagado. Ctrl+Z desfaz.", 2.0)
		else:
			clear_armed = true
			app.show_toast("Clique em ‘Apagar texto’ mais uma vez para confirmar.", 3.0)
		queue_redraw()
		return true
	return false

func _draw() -> void:
	Gfx.scrim(self, Rect2(0, 0, Gfx.W, Gfx.H), 225)
	Gfx.rect(self, PANEL, Color8(20, 20, 28, 245), 14, 3, UiTheme.CARD_BORDER)
	Gfx.text(self, "Nota de playtest", Vector2(PANEL.get_center().x, PANEL.position.y + 18), 32, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
	Gfx.text(self, "A nota será guardada com o print deste instante ao fechar (F5 ou Esc).", Vector2(PANEL.get_center().x, PANEL.position.y + 58), 18, UiTheme.TEXT_MUTED, "midtop")
	Gfx.button(self, CLEAR_RECT, "Confirmar apagar" if clear_armed else "Apagar texto", CLEAR_RECT.has_point(get_local_mouse_position()))
	var count := editor.text.length() if editor != null else 0
	Gfx.text(self, "%d/1000 · Guardado: %s" % [count, app.evidence_store.summary()], Vector2(PANEL.end.x - 24, PANEL.end.y - 24), 18, UiTheme.SELECTED_BORDER, "bottomright")
	Gfx.text(self, "Ctrl+Z desfaz · Ctrl+Y refaz · Ctrl+C/Ctrl+V · F5/Esc fecha", Vector2(PANEL.position.x + 28, PANEL.end.y - 24), 16, UiTheme.TEXT_MUTED, "bottomleft")
