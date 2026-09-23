class_name CombatFx
extends RefCounted
## Estado visual do combate. Valores reais podem mudar no core antes, mas este
## objeto só recebe o novo alvo no beat de impacto.

class ShownValue:
	var value: float
	var _from: float
	var _target: float
	var _duration := 0.0
	var _elapsed := 0.0

	func _init(initial: float) -> void:
		value = initial
		_from = initial
		_target = initial

	func animate_to(target: float, duration: float = 0.6) -> void:
		_from = value
		_target = target
		_duration = maxf(0.001, duration)
		_elapsed = 0.0

	func update(dt: float) -> void:
		if _elapsed >= _duration:
			return
		_elapsed = minf(_duration, _elapsed + dt)
		var p := _elapsed / _duration
		p = 1.0 - pow(1.0 - p, 3.0)
		value = lerpf(_from, _target, p)

class Floater:
	var text: String
	var origin: Vector2
	var color: Color
	var size: int
	var delay: float
	var lifetime: float
	var rise: float
	var outline: Color
	var age := 0.0

	func _init(text_: String, origin_: Vector2, color_: Color, size_: int = 38, delay_: float = 0.0, lifetime_: float = 1.5, rise_: float = 54.0, outline_: Color = UiTheme.TEXT_OUTLINE) -> void:
		text = text_; origin = origin_; color = color_; size = size_
		delay = delay_; lifetime = lifetime_; rise = rise_; outline = outline_

	func alive() -> bool:
		return age < delay + lifetime

	func position() -> Vector2:
		var p := clampf((age - delay) / lifetime, 0.0, 1.0)
		return origin + Vector2(0, -rise * (1.0 - pow(1.0 - p, 2.0)))

	func alpha() -> float:
		if age < delay: return 0.0
		var p := (age - delay) / lifetime
		return 1.0 - maxf(0.0, (p - 0.65) / 0.35)

class Banner:
	var text: String
	var age := 0.0
	const FADE := 0.18
	const HOLD := 1.2
	func _init(text_: String) -> void: text = text_
	func finished() -> bool: return age >= FADE + HOLD
	func alpha() -> float: return clampf(age / FADE, 0.0, 1.0) if age < FADE else 1.0

var floaters: Array[Floater] = []
var banner: Banner = null

func spawn(text: String, origin: Vector2, color: Color, size: int = 38, delay: float = 0.0, lifetime: float = 1.5, rise: float = 54.0, outline: Color = UiTheme.TEXT_OUTLINE) -> void:
	floaters.append(Floater.new(text, origin, color, size, delay, lifetime, rise, outline))

func update(dt: float) -> void:
	for f in floaters: f.age += dt
	floaters = floaters.filter(func(f: Floater): return f.alive())
	if banner != null:
		banner.age += dt
		if banner.finished(): banner = null

func draw(ci: CanvasItem) -> void:
	for f in floaters:
		var col := f.color
		col.a *= f.alpha()
		if col.a > 0.0:
			Gfx.text_outlined(ci, f.text, f.position(), f.size, col, f.outline, "center", UiTheme.card_title_font())
	if banner != null:
		var c := UiTheme.SELECTED_BORDER
		c.a = banner.alpha()
		Gfx.scrim(ci, Rect2(260, 310, 760, 90), 190)
		Gfx.text_outlined(ci, banner.text, Vector2(Gfx.W / 2.0, 355), 36, c, UiTheme.TEXT_OUTLINE, "center", UiTheme.card_title_font(), 2)
