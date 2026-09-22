class_name Gfx
extends RefCounted
## Auxiliares de desenho sobre um CanvasItem (o equivalente dos pygame.draw.*, surface.blit e dos helpers de hud.py/theme.py).
## Coordenadas em pixels lógicos 1280x720. Tudo é chamado de dentro de `_draw()`.

const W := 1280
const H := 720

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
	var words := s.split(" ")
	var lines: Array = []
	var current := ""
	for word in words:
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
	text(ci, label, r.get_center(), 22, UiTheme.TEXT_COLOR, "center")

## Barra de valor (PV, XP).
static func bar(ci: CanvasItem, r: Rect2, frac: float, fg: Color, bg: Color = UiTheme.HP_BAR_BG, radius: int = 6) -> void:
	rect(ci, r, bg, radius)
	var f := clampf(frac, 0.0, 1.0)
	if f > 0.0:
		rect(ci, Rect2(r.position, Vector2(int(r.size.x * f), r.size.y)), fg, radius)
