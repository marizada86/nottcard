class_name CharacterSelectScreen
extends UiScreen
## game/app.py::CharacterSelectScreen — a escolha do personagem (ou do inicial), em dois passos: o clique seleciona, "Começar"/Enter/novo clique confirma.

const CARD_SIZE := Vector2(340, 400)
const CARD_GAP := 50
const CARD_TOP := 112
const SELECT_LIFT := 14
const XP_BAR_HEIGHT := 22
const ATTRIBUTE_LABELS := [["forca", "FOR"], ["inteligencia", "INT"], ["constituicao", "CON"], ["carisma", "CAR"]]

var mission: MissionDef
var starter: bool = false
var characters: Array = []
var rects: Array = []
var passive_rect := Rect2(190, 524, Gfx.W - 380, 122)
var back_button := Rect2(40, Gfx.H - 64, 180, 46)
var start_button := Rect2(Gfx.W - 260, Gfx.H - 64, 220, 46)
var selected: int = -1
var select_age: float = 99.0
var group: Array = []
var chip_rects: Array = []

func _init(mission_: MissionDef = null, starter_: bool = false) -> void:
	mission = mission_ if mission_ != null else Missions.current()
	starter = starter_
	if starter:
		for i in Missions.STARTERS:
			characters.append(CharacterDefs.get_def(i))
	else:
		characters = CharacterDefs.all().values()
	var count := characters.size()
	var gap: int = CARD_GAP if count <= 3 else 24
	var width: int = mini(int(CARD_SIZE.x), (Gfx.W - 80 - (count - 1) * gap) / count)
	var total := count * width + (count - 1) * gap
	var start := (Gfx.W - total) / 2
	for i in range(count):
		rects.append(Rect2(start + i * (width + gap), CARD_TOP, width, CARD_SIZE.y))
	for r in rects:
		chip_rects.append(Rect2(r.position.x + 16, r.end.y - 40, r.size.x - 32, 28))

func blocked_reason(index: int) -> String:
	if starter:
		return ""
	return Roster.why_not(mission, app.save_state, characters[index].id)

func select(index: int) -> void:
	selected = index
	select_age = 0.0

func toggle_group(index: int) -> void:
	if starter or blocked_reason(index) != "":
		return
	if index in group:
		group.erase(index)
	elif group.size() < Roster.party_limit(app.save_state):
		group.append(index)
	else:
		var hint := Roster.group_hint(app.save_state)
		app.show_toast(hint if hint != "" else "Grupo cheio", 3.0)

func roster_chosen() -> Array:
	var out: Array = []
	if not group.is_empty():
		for i in group:
			out.append(characters[i])
	elif selected >= 0:
		out.append(characters[selected])
	return out

func confirm() -> void:
	var chosen := roster_chosen()
	var state := app.save_state
	if starter:
		if selected >= 0:
			app.choose_starter(characters[selected].id)
		return
	if not chosen.is_empty():
		var ids: Array = []
		for c in chosen: ids.append(c.id)
		var ok := Roster.can_field(mission, state, ids)
		if not ok[0]:
			app.show_toast(ok[1], 4.0)
			return
		if not state.decks.is_empty():
			var problems := Collection.deck_problems(state.decks[mini(state.active_deck, state.decks.size() - 1)])
			if not problems.is_empty():
				app.show_toast("Baralho inválido: " + "; ".join(problems) + ". Ajuste em Baralho.", 6.0)
				return
		app.start_run(chosen, mission.id)

func handle_input(event: InputEvent) -> void:
	if is_click(event):
		var p: Vector2 = event.position
		if not starter:
			for i in range(chip_rects.size()):
				if chip_rects[i].has_point(p):
					toggle_group(i)
					return
		for i in range(rects.size()):
			if rects[i].has_point(p):
				if i == selected:
					confirm()
				else:
					select(i)
				return
		if start_button.has_point(p) and not roster_chosen().is_empty():
			confirm()
		elif back_button.has_point(p):
			app.return_to_menu()
	elif is_key(event, KEY_ENTER) or is_key(event, KEY_KP_ENTER):
		confirm()
	elif is_key(event, KEY_ESCAPE):
		app.return_to_menu()

func update(dt: float) -> void:
	select_age += dt

func draw(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, Gfx.W, Gfx.H), UiTheme.BACKGROUND_COLOR)
	Gfx.text(ci, "Escolha o personagem inicial" if starter else "Escolha o personagem", Vector2(Gfx.W / 2.0, 62), 40, UiTheme.TEXT_COLOR, "center")
	var m := mouse()
	for i in range(characters.size()):
		var c: CharacterDef = characters[i]
		var rect: Rect2 = rects[i]
		var chosen := i == selected
		var shown := Rect2(rect.position + Vector2(0, -SELECT_LIFT), rect.size) if chosen else rect
		_draw_card(ci, c, shown, rect.has_point(m), chosen, select_age, app.save_state.for_character(c.id))
		if selected >= 0 and not chosen:
			Gfx.rect(ci, rect, Color8(8, 8, 12, 130), 12)
		var reason := blocked_reason(i)
		if reason != "":
			Gfx.rect(ci, rect, Color8(6, 6, 10, 190), 12)
			var hint := reason
			if reason == "Bloqueado":
				var bh := Roster.buy_hint(app.save_state, c.id)
				hint = bh if bh != "" else reason
			var lines: Array = ["Bloqueado" if reason == "Bloqueado" else "Fora do elenco"] + Gfx.wrap_lines(hint, 19, rect.size.x - 24, UiTheme.card_text_font(true))
			var k := 0
			for line in lines:
				Gfx.text(ci, line, Vector2(rect.get_center().x, rect.position.y + 120 + k * 24), 21 if k == 0 else 17,
					UiTheme.BLOCKED_COLOR if k == 0 else UiTheme.TEXT_MUTED, "midtop", UiTheme.card_text_font(true))
				k += 1
	if selected >= 0:
		_draw_passive_panel(ci, characters[selected], passive_rect)
	else:
		Gfx.text(ci, "Escolha um personagem para ver a passiva de classe", passive_rect.get_center(), 24, UiTheme.TEXT_MUTED, "center", UiTheme.card_text_font())
	Gfx.button(ci, back_button, "Voltar", back_button.has_point(m))
	if not starter:
		for i in range(chip_rects.size()):
			var chip: Rect2 = chip_rects[i]
			var in_group := i in group
			var locked := blocked_reason(i) != ""
			var limit := Roster.party_limit(app.save_state)
			var full := locked or (not in_group and group.size() >= limit)
			Gfx.rect(ci, chip, Color8(52, 90, 60) if in_group else UiTheme.BUTTON_COLOR, 6, 2, UiTheme.SELECTED_BORDER if in_group else UiTheme.CARD_BORDER)
			var label: String
			if in_group:
				label = "No grupo (%dº)" % (group.find(i) + 1)
			elif locked:
				label = "Bloqueado"
			elif not full:
				label = "+ Grupo"
			else:
				var gh := Roster.group_hint(app.save_state)
				label = gh if gh != "" else "Grupo cheio"
			Gfx.text(ci, label, chip.get_center(), 19, UiTheme.TEXT_MUTED if full else UiTheme.TEXT_COLOR, "center", UiTheme.card_text_font(true))
	if not group.is_empty():
		var names: PackedStringArray = []
		for i in group: names.append(characters[i].name)
		Gfx.text(ci, "Grupo: " + ", ".join(names), Vector2(Gfx.W / 2.0, 88), 22, UiTheme.SELECTED_BORDER, "midtop", UiTheme.card_text_font(true))
	if not roster_chosen().is_empty():
		Gfx.button(ci, start_button, "Começar (Enter)", start_button.has_point(m))

func _draw_card(ci: CanvasItem, c: CharacterDef, rect: Rect2, hovered: bool, chosen: bool, age: float, progress: Progress) -> void:
	var color := UiTheme.card_color(c.class_color)
	if chosen:
		var glow := maxf(0.0, 1.0 - age / 0.6)
		var halo := Rect2(rect.position - Vector2(12, 12), rect.size + Vector2(24, 24))
		Gfx.rect(ci, halo, Color(color.r, color.g, color.b, (28.0 + 80.0 * glow) / 255.0), 18)
	Gfx.rect(ci, rect, color, 12)
	Gfx.outline(ci, rect, UiTheme.SELECTED_BORDER if (hovered or chosen) else UiTheme.CARD_BORDER, 5 if chosen else (4 if hovered else 3), 12)
	var areas := select_card_areas(rect)
	var bar: Rect2 = areas[0]
	var portrait: Rect2 = areas[1]
	Gfx.image(ci, c.id, "portraits", portrait)
	Gfx.rect(ci, bar, UiTheme.HP_BAR_BG, 6)
	Gfx.rect(ci, Rect2(bar.position, Vector2(int(bar.size.x * progress.fraction_to_next()), bar.size.y)), Color8(110, 90, 40), 6)
	Gfx.outline(ci, bar, UiTheme.SELECTED_BORDER, 2, 6)
	var caption := ("XP máx · Nível %d" % progress.level) if progress.at_cap else ("XP %d/%d · Nível %d" % [progress.xp, progress.next_threshold(), progress.level])
	Gfx.text(ci, caption, bar.get_center(), 17, UiTheme.TEXT_COLOR, "center", UiTheme.card_text_font(true))
	Gfx.text(ci, String(c.name).split(" ")[0], Vector2(rect.get_center().x, rect.position.y + 224), 32, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
	Gfx.text(ci, "%s · PV %d" % [c.class_label, c.max_hp], Vector2(rect.get_center().x, rect.position.y + 266), 22, UiTheme.TEXT_COLOR, "midtop")
	var attrs: PackedStringArray = []
	for kv in ATTRIBUTE_LABELS:
		attrs.append("%s %d" % [kv[1], c.attributes[kv[0]]])
	Gfx.text(ci, "  ".join(attrs), Vector2(rect.get_center().x, rect.position.y + 298), 20, UiTheme.TEXT_COLOR, "midtop")
	Gfx.text(ci, c.passive_name, Vector2(rect.get_center().x, rect.position.y + 332), 22, UiTheme.card_text_color(c.class_color), "midtop", UiTheme.card_text_font(true))

static func select_card_areas(rect: Rect2) -> Array:
	var bar := Rect2(rect.position.x + 20, rect.position.y + 8, rect.size.x - 40, XP_BAR_HEIGHT)
	var width := rect.size.x - 40
	var portrait := Rect2(rect.position.x + 20, bar.end.y + 6, width, minf(180.0, round(width * 2.0 / 3.0)))
	return [bar, portrait]

func _draw_passive_panel(ci: CanvasItem, c: CharacterDef, rect: Rect2) -> void:
	Gfx.rect(ci, rect, UiTheme.PANEL_COLOR, 14, 3, UiTheme.card_color(c.class_color))
	Gfx.text(ci, c.passive_name, Vector2(rect.position.x + 24, rect.position.y + 14), 30, UiTheme.card_text_color(c.class_color), "topleft", UiTheme.card_title_font())
	Gfx.wrapped_left(ci, c.passive_text, 22, UiTheme.TEXT_COLOR, rect.position.x + 24, rect.position.y + 56, rect.size.x - 48, 2, UiTheme.card_text_font())
