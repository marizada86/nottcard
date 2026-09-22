class_name MissionSelectScreen
extends UiScreen
## game/app.py::MissionSelectScreen — as missões liberadas, o briefing e o caminho até a seleção de personagem.

var entries: Array = []
var rects: Array = []
var back_button := Rect2((Gfx.W - 220) / 2.0, Gfx.H - 90, 220, 54)
var hovered: int = -1

func _init() -> void:
	entries = Missions.all().values()
	var width := 560
	var height := 62
	var gap := 14
	var top := 190
	for i in range(entries.size()):
		rects.append(Rect2((Gfx.W - width) / 2.0, top + i * (height + gap), width, height))

func _unlocked(mission: MissionDef) -> bool:
	return Missions.is_unlocked(mission, app.save_state.missions_completed)

func label(mission: MissionDef) -> String:
	var done: bool = app.save_state.missions_completed.has(mission.id)
	return "%s · %s%s" % [mission.id.to_upper(), mission.title, " (rejogar)" if done else ("" if _unlocked(mission) else " (bloqueada)")]

func handle_input(event: InputEvent) -> void:
	if is_key(event, KEY_ESCAPE):
		app.return_to_menu()
	elif is_click(event):
		if back_button.has_point(event.position):
			app.return_to_menu()
			return
		for i in range(entries.size()):
			if rects[i].has_point(event.position) and _unlocked(entries[i]):
				app.open_character_select(entries[i].id)
				return

func draw(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, Gfx.W, Gfx.H), UiTheme.BACKGROUND_COLOR)
	Gfx.text(ci, "Missões", Vector2(Gfx.W / 2.0, 70), 40, UiTheme.TEXT_COLOR, "center")
	var m := mouse()
	hovered = -1
	for i in range(rects.size()):
		if rects[i].has_point(m):
			hovered = i
	for i in range(entries.size()):
		var unlocked := _unlocked(entries[i])
		Gfx.button(ci, rects[i], label(entries[i]), rects[i].has_point(m) and unlocked)
		if not unlocked:
			Gfx.rect(ci, rects[i], Color8(8, 8, 12, 150), 10)
	var text := "Escolha a missão."
	if hovered >= 0:
		var shown: MissionDef = entries[hovered]
		text = shown.briefing
		if not _unlocked(shown):
			var reqs: PackedStringArray = []
			for r in shown.requires: reqs.append(String(r).to_upper())
			text = "Conclua %s para liberar esta missão." % ", ".join(reqs)
	Gfx.wrapped_center(ci, text, 22, UiTheme.TEXT_MUTED, Gfx.W / 2.0, 190 + rects.size() * 76 + 24, 760)
	Gfx.button(ci, back_button, "Voltar", back_button.has_point(m))
