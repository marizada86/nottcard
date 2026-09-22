class_name CardView
extends RefCounted
## Desenho de uma carta (o essencial de game/ui/cards_widget.py + card_layouts.py): moldura na cor, arte, nome, tipo e dado, texto.

const KIND_LABELS := {"ataque": "Ataque", "cura": "Cura", "controle": "Controle", "atordoamento": "Atordoamento", "surto": "Surto", "reacao": "Reação",
	"equipavel": "Equipável", "canalizar": "Canalizar", "localizar": "Localizar", "enfraquecer": "Enfraquecer", "comunhao": "Comunhão", "protecao": "Proteção", "magia": "Magia"}

static func kind_line(card: Card) -> String:
	var parts: PackedStringArray = [KIND_LABELS.get(card.kind, card.kind)]
	if card.dice != "":
		parts.append(card.dice)
	if card.area:
		parts.append("área")
	var act: String = {"acao": "Ação", "bonus": "Bônus", "reacao": "Reação"}.get(card.action_type, "")
	if act != "":
		parts.append(act)
	return " · ".join(parts)

## Desenha a carta em `r`. `playable=false` escurece (carta que não dá para usar agora).
static func draw_card(ci: CanvasItem, card: Card, r: Rect2, hovered: bool = false, playable: bool = true, selected: bool = false) -> void:
	var color := UiTheme.card_color(card.color)
	Gfx.rect(ci, r, color, 10)
	var border := UiTheme.SELECTED_BORDER if (selected or hovered) else UiTheme.CARD_BORDER
	var art := Rect2(r.position.x + 8, r.position.y + 34, r.size.x - 16, r.size.y * 0.42)
	Gfx.image(ci, card.slug, "cards", art)
	var title_size := int(clampf(r.size.x * 0.115, 13, 24))
	var lines := Gfx.wrap_lines(card.name, title_size, r.size.x - 14, UiTheme.card_title_font())
	if lines.size() > 1:
		title_size = maxi(11, int(title_size * 0.78))
		lines = Gfx.wrap_lines(card.name, title_size, r.size.x - 14, UiTheme.card_title_font())
	var ty := r.position.y + (8.0 if lines.size() == 1 else 3.0)
	for ln in lines.slice(0, 2):
		Gfx.text(ci, ln, Vector2(r.get_center().x, ty), title_size, UiTheme.TEXT_COLOR, "midtop", UiTheme.card_title_font())
		ty += title_size + 1
	var y := art.end.y + 6
	Gfx.text(ci, kind_line(card), Vector2(r.get_center().x, y), int(clampf(r.size.x * 0.085, 12, 18)), Color8(240, 235, 215), "midtop", UiTheme.card_text_font(true))
	y += int(clampf(r.size.x * 0.085, 12, 18)) + 6
	if card.note != "":
		Gfx.wrapped_center(ci, card.note, int(clampf(r.size.x * 0.078, 11, 16)), Color8(235, 235, 235), r.get_center().x, y, r.size.x - 16, 1, UiTheme.card_text_font())
	Gfx.outline(ci, r, border, 4 if selected else (3 if hovered else 2), 10)
	if card.class_ability:
		Gfx.text(ci, "HC", Vector2(r.end.x - 8, r.position.y + 6), 14, UiTheme.SELECTED_BORDER, "topright", UiTheme.card_text_font(true))
	if card.scroll:
		Gfx.text(ci, "Pergaminho", Vector2(r.position.x + 8, r.end.y - 6), 13, UiTheme.TEXT_MUTED, "bottomleft", UiTheme.card_text_font(true))
	if not playable:
		Gfx.rect(ci, r, Color8(8, 8, 12, 150), 10)
