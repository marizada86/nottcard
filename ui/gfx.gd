class_name Gfx
extends RefCounted
## Auxiliares de desenho sobre um CanvasItem (o equivalente dos pygame.draw.*, surface.blit e dos helpers de hud.py/theme.py).
## Coordenadas em pixels lógicos 1280x720. Tudo é chamado de dentro de `_draw()`.

const W := 1280
const H := 720
const CONTENT_PADDING := 10.0

static var _boxes: Dictionary = {}

## Retângulo com cantos arredondados e borda (pygame.draw.rect com border_radius e width).
static func rect(ci: CanvasItem, r: Rect2, color: Color, radius: int = 0, border: int = 0, border_color: Color = Color.BLACK) -> void:
	if color.a > 0.0:
		var key := "f|%d|%s" % [radius, color.to_html()]
		if not _boxes.has(key):
			var sb := StyleBoxFlat.new()
			sb.bg_color = color
			sb.set_corner_radius_all(radius)
			sb.anti_aliasing = radius > 0
			_boxes[key] = sb
		ci.draw_style_box(_boxes[key], r)
	if border > 0:
		outline(ci, r, border_color, border, radius)

## Só a borda (pygame.draw.rect com width>0).
static func outline(ci: CanvasItem, r: Rect2, color: Color, width: int, radius: int = 0) -> void:
	var key := "o|%d|%d|%s" % [radius, width, color.to_html()]
	if not _boxes.has(key):
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.draw_center = false
		sb.border_color = color
		sb.set_border_width_all(width)
		sb.set_corner_radius_all(radius)
		sb.anti_aliasing = radius > 0
		_boxes[key] = sb
	ci.draw_style_box(_boxes[key], r)

static func circle(ci: CanvasItem, center: Vector2, radius: float, color: Color, width: int = 0) -> void:
	if width <= 0:
		ci.draw_circle(center, radius, color)
	else:
		ci.draw_arc(center, radius, 0.0, TAU, 48, color, width, true)

static func line(ci: CanvasItem, a: Vector2, b: Vector2, color: Color, width: float = 1.0) -> void:
	ci.draw_line(a, b, color, width)

static func polygon(ci: CanvasItem, points: PackedVector2Array, color: Color) -> void:
	ci.draw_colored_polygon(points, color)

## Tamanho do texto (largura, altura) — o `font.size()` do pygame.
static func text_size(s: String, size: int, font: Font = null) -> Vector2:
	var f := font if font != null else UiTheme.font()
	size = _px(size, font)
	var sz := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	return Vector2(sz.x, f.get_height(size))

## A fonte padrão do pygame (SysFont(None, n)) tem corpo menor que o "em" da Arial: o tamanho pedido vale ~0,8x em px.
static func _px(size: int, font: Font) -> int:
	return maxi(8, int(round(size * 0.8))) if font == null else size

## Desenha texto ancorado como `surface.blit(text, text.get_rect(<anchor>=pos))`. anchor: topleft, midtop, topright, midleft, center,
## midright, bottomleft, midbottom, bottomright. Devolve o Rect2 ocupado.
static func text(ci: CanvasItem, s: String, pos: Vector2, size: int, color: Color, anchor: String = "topleft", font: Font = null) -> Rect2:
	var f := font if font != null else UiTheme.font()
	var sz := text_size(s, size, font)
	var draw_size := _px(size, font)
	var tl := pos
	match anchor:
		"midtop": tl = Vector2(pos.x - sz.x / 2.0, pos.y)
		"topright": tl = Vector2(pos.x - sz.x, pos.y)
		"midleft": tl = Vector2(pos.x, pos.y - sz.y / 2.0)
		"center": tl = Vector2(pos.x - sz.x / 2.0, pos.y - sz.y / 2.0)
		"midright": tl = Vector2(pos.x - sz.x, pos.y - sz.y / 2.0)
		"bottomleft": tl = Vector2(pos.x, pos.y - sz.y)
		"midbottom": tl = Vector2(pos.x - sz.x / 2.0, pos.y - sz.y)
		"bottomright": tl = Vector2(pos.x - sz.x, pos.y - sz.y)
	tl = tl.round()
	ci.draw_string(f, Vector2(tl.x, tl.y + f.get_ascent(draw_size)), s, HORIZONTAL_ALIGNMENT_LEFT, -1, draw_size, color)
	return Rect2(tl, sz)

## Texto com contorno (o `render_outlined` dos números flutuantes).
static func text_outlined(ci: CanvasItem, s: String, pos: Vector2, size: int, color: Color, outline_color: Color = UiTheme.TEXT_OUTLINE,
		anchor: String = "topleft", font: Font = null, thickness: int = 2) -> Rect2:
	for dx in range(-thickness, thickness + 1):
		for dy in range(-thickness, thickness + 1):
			if dx != 0 or dy != 0:
				text(ci, s, pos + Vector2(dx, dy), size, outline_color, anchor, font)
	return text(ci, s, pos, size, color, anchor, font)

## Quebra gulosa de linha (theme.wrap_text).
static func wrap_lines(s: String, size: int, max_width: float, font: Font = null) -> Array:
	var lines: Array = []
	for paragraph in s.split("\n", true):
		if paragraph.is_empty():
			lines.append("")
			continue
		var current := ""
		for word in paragraph.split(" ", false):
			var candidate := ("%s %s" % [current, word]).strip_edges()
			if text_size(candidate, size, font).x <= max_width or current == "":
				current = candidate
			else:
				lines.append(current)
				current = word
		if current != "":
			lines.append(current)
	return lines

## Texto centralizado com quebra; devolve a altura usada.
static func wrapped_center(ci: CanvasItem, s: String, size: int, color: Color, center_x: float, top_y: float, max_width: float, spacing: int = 2, font: Font = null) -> float:
	var y := top_y
	for ln in wrap_lines(s, size, max_width, font):
		var r := text(ci, ln, Vector2(center_x, y), size, color, "midtop", font)
		y += r.size.y + spacing
	return y - top_y

static func wrapped_left(ci: CanvasItem, s: String, size: int, color: Color, x: float, top_y: float, max_width: float, spacing: int = 2, font: Font = null) -> float:
	var y := top_y
	for ln in wrap_lines(s, size, max_width, font):
		var r := text(ci, ln, Vector2(x, y), size, color, "topleft", font)
		y += r.size.y + spacing
	return y - top_y

## Retângulo interno de uma moldura. Mantém o texto afastado da borda e torna
## explícito qual área pode ser ocupada pelo conteúdo.
static func content_rect(r: Rect2, padding: float = CONTENT_PADDING) -> Rect2:
	var size := Vector2(maxf(0.0, r.size.x - padding * 2.0), maxf(0.0, r.size.y - padding * 2.0))
	return Rect2(r.position + Vector2(padding, padding), size)

## Escolhe o maior corpo que cabe em uma linha. É próprio para rótulos e HUD;
## narrativas devem usar `wrapped_*` ou uma área paginada, nunca esta função.
static func fitting_size(s: String, preferred_size: int, max_width: float, min_size: int = 12, font: Font = null) -> int:
	var candidate := preferred_size
	while candidate > min_size and text_size(s, candidate, font).x > max_width:
		candidate -= 1
	return candidate

## Texto de uma linha que respeita um retângulo. Se o menor corpo ainda não
## couber, a string recebe reticências de forma explícita, preservando o início.
static func text_fit(ci: CanvasItem, s: String, r: Rect2, preferred_size: int, color: Color,
		anchor: String = "center", font: Font = null, min_size: int = 12, padding: float = CONTENT_PADDING) -> Rect2:
	var inner := content_rect(r, padding)
	var body := fitting_size(s, preferred_size, inner.size.x, min_size, font)
	var shown := s
	if text_size(shown, body, font).x > inner.size.x:
		var suffix := "…"
		while shown.length() > 1 and text_size(shown + suffix, body, font).x > inner.size.x:
			shown = shown.left(shown.length() - 1)
		shown += suffix
	var pos := inner.get_center()
	match anchor:
		"topleft": pos = inner.position
		"midtop": pos = Vector2(inner.get_center().x, inner.position.y)
		"topright": pos = Vector2(inner.end.x, inner.position.y)
		"bottomleft": pos = Vector2(inner.position.x, inner.end.y)
		"midbottom": pos = Vector2(inner.get_center().x, inner.end.y)
		"bottomright": pos = inner.end
		"midleft": pos = Vector2(inner.position.x, inner.get_center().y)
		"midright": pos = Vector2(inner.end.x, inner.get_center().y)
	return text(ci, shown, pos, body, color, anchor, font)

## Parágrafo que reduz apenas o necessário para caber na área designada. Para
## conteúdo que ainda não caiba no corpo mínimo, o chamador deve paginar ou
## disponibilizar rolagem; esta rotina não descarta linhas.
static func wrapped_fit(ci: CanvasItem, s: String, r: Rect2, preferred_size: int, color: Color,
		centered: bool = false, spacing: int = 2, font: Font = null, min_size: int = 14, padding: float = CONTENT_PADDING) -> float:
	var inner := content_rect(r, padding)
	var body := preferred_size
	var lines := wrap_lines(s, body, inner.size.x, font)
	while body > min_size and lines.size() * (text_size("A", body, font).y + spacing) - spacing > inner.size.y:
		body -= 1
		lines = wrap_lines(s, body, inner.size.x, font)
	var y := inner.position.y
	for line in lines:
		if centered:
			text(ci, line, Vector2(inner.get_center().x, y), body, color, "midtop", font)
		else:
			text(ci, line, Vector2(inner.position.x, y), body, color, "topleft", font)
		y += text_size("A", body, font).y + spacing
	return y - inner.position.y - spacing

## Desenha a arte `slug` de `categoria` esticada em `r` (ou o retângulo de reserva com o nome).
static func image(ci: CanvasItem, slug: String, categoria: String, r: Rect2, modulate: Color = Color.WHITE, pack: String = "") -> void:
	var tex := UiAssets.texture(slug, categoria, pack)
	if tex != null:
		ci.draw_texture_rect(tex, r, false, modulate)
		return
	rect(ci, r, UiAssets.FALLBACK_COLORS.get(categoria, Color8(80, 80, 80)))
	outline(ci, r, Color8(15, 15, 18), 2)
	var label := slug.replace("_", " ")
	var lines := wrap_lines(label, 16, r.size.x - 12)
	var total: float = lines.size() * (text_size("A", 16).y + 2)
	var y: float = r.position.y + r.size.y / 2.0 - total / 2.0
	for ln in lines:
		var rr := text(ci, ln, Vector2(r.position.x + r.size.x / 2.0, y), 16, UiTheme.TEXT_COLOR, "midtop")
		y += rr.size.y + 2

## Arte fundo da tela cheia (Menu/Vitória/Game Over).
static func screen_background(ci: CanvasItem, slug: String) -> void:
	image(ci, slug, "screens", Rect2(0, 0, W, H))

## Painel escuro semitransparente (hud.draw_scrim).
static func scrim(ci: CanvasItem, r: Rect2, alpha: int = 150) -> void:
	ci.draw_rect(r, Color8(8, 8, 12, alpha))

## O botão de sempre (hud.draw_button), sem ícone.
static func button(ci: CanvasItem, r: Rect2, label: String, hovered: bool) -> void:
	rect(ci, r, UiTheme.BUTTON_HOVER if hovered else UiTheme.BUTTON_COLOR, 8, 2, UiTheme.CARD_BORDER)
	text_fit(ci, label, r, 22, UiTheme.TEXT_COLOR, "center", null, 14, 8)

## Barra de valor (PV, XP).
static func bar(ci: CanvasItem, r: Rect2, frac: float, fg: Color, bg: Color = UiTheme.HP_BAR_BG, radius: int = 6) -> void:
	rect(ci, r, bg, radius)
	var f := clampf(frac, 0.0, 1.0)
	if f > 0.0:
		rect(ci, Rect2(r.position, Vector2(int(r.size.x * f), r.size.y)), fg, radius)
