class_name DiceRollView
extends RefCounted
## Dado de apresentação: o valor é recebido pronto do core e apenas revelado.

const THROW_TIME := 1.2
const SETTLE_TIME := 0.4
const HOLD_TIME := 0.5

var sides: int
var target_value: int
var label: String
var duration: float
var elapsed := 0.0
var index: int

func _init(sides_: int, target_: int, label_: String = "", duration_: float = 2.1, index_: int = 0) -> void:
	sides = sides_; target_value = target_; label = label_; duration = maxf(0.1, duration_); index = index_

var finished: bool:
	get: return elapsed >= duration

func update(dt: float) -> void:
	elapsed = minf(duration, elapsed + dt)

func draw(ci: CanvasItem, center: Vector2) -> void:
	var p := elapsed / duration
	var throw_end := THROW_TIME / (THROW_TIME + SETTLE_TIME + HOLD_TIME)
	var settle_end := (THROW_TIME + SETTLE_TIME) / (THROW_TIME + SETTLE_TIME + HOLD_TIME)
	var entering := clampf(p / throw_end, 0.0, 1.0)
	var settle := clampf((p - throw_end) / maxf(0.001, settle_end - throw_end), 0.0, 1.0)
	var offset := Vector2(-260.0, -150.0).rotated(index * 0.55) * pow(1.0 - entering, 3.0)
	offset.y -= 52.0 * sin(entering * PI)
	var spin := (1.0 - entering) * (22.0 + index * 1.7)
	var scale := 1.0 + 0.14 * sin(entering * PI * 3.0) * (1.0 - entering)
	var size := 122.0 * scale
	# Dados que ainda não receberam malha 3D usam o mesmo vocabulário visual de
	# mesa: desenho neutro e numeral do resultado, nunca sprite ilustrado.
	var tex: Texture2D = null
	# Fantasmas simples de movimento, do mais antigo ao mais recente.
	for ghost in range(4, 0, -1):
		if p >= throw_end or tex == null: break
		var gp := maxf(0.0, p - ghost * 0.045)
		var goff := Vector2(-260.0, -150.0).rotated(index * 0.55) * pow(1.0 - gp / throw_end, 3.0)
		var gc := Color(0.93, 0.91, 0.84, 0.05 * (5 - ghost))
		ci.draw_set_transform(center + goff, spin - ghost * 0.65, Vector2.ONE)
		Gfx.circle(ci, Vector2.ZERO, size / 2.0, gc)
	ci.draw_set_transform(center + offset, spin * (1.0 - settle), Vector2.ONE)
	if tex != null:
		ci.draw_texture_rect(tex, Rect2(-size / 2.0, -size / 2.0, size, size), false, Color.WHITE)
	else:
		Gfx.circle(ci, Vector2.ZERO, size / 2.0, Color8(232, 228, 214))
		Gfx.circle(ci, Vector2.ZERO, size / 2.0, Color8(42, 44, 50), 2)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if p >= throw_end:
		Gfx.text_outlined(ci, str(target_value), center + offset, 42, Color8(32, 34, 40), Color8(238, 234, 220), "center", UiTheme.card_title_font(), 2)
	if label != "":
		Gfx.text(ci, label, center + Vector2(0, 92), 17, UiTheme.TEXT_MUTED, "midtop", UiTheme.card_text_font())
