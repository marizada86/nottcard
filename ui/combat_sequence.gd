class_name CombatSequence
extends RefCounted
## Fila de batidas visuais. Não conhece combate nem CanvasItem, para poder ser
## testada isoladamente e para que só uma apresentação aconteça por vez.

class Beat:
	var name: String
	var duration: float
	var on_start: Callable
	var on_update: Callable
	var on_end: Callable
	var elapsed := 0.0
	var started := false

	func _init(name_: String, duration_: float, start: Callable = Callable(), update: Callable = Callable(), end: Callable = Callable()) -> void:
		name = name_
		duration = maxf(0.0, duration_)
		on_start = start
		on_update = update
		on_end = end

var _queue: Array[Beat] = []
var current: Beat = null

var busy: bool:
	get: return current != null or not _queue.is_empty()

var progress: float:
	get: return 1.0 if current == null or current.duration <= 0.0 else clampf(current.elapsed / current.duration, 0.0, 1.0)

func add(name: String, duration: float, start: Callable = Callable(), update: Callable = Callable(), end: Callable = Callable()) -> void:
	_queue.append(Beat.new(name, duration, start, update, end))

func clear() -> void:
	_queue.clear()
	current = null

func update(dt: float) -> void:
	var left := maxf(0.0, dt)
	var safety := 0
	while safety < 128:
		safety += 1
		if current == null:
			if _queue.is_empty():
				return
			current = _queue.pop_front()
			current.started = true
			if current.on_start.is_valid():
				current.on_start.call()
		if current.duration <= 0.0:
			_finish_current()
			continue
		var used := minf(left, current.duration - current.elapsed)
		current.elapsed += used
		if current.on_update.is_valid() and used > 0.0:
			current.on_update.call(used)
		left -= used
		if current.elapsed + 0.0001 >= current.duration:
			_finish_current()
			continue
		return

func _finish_current() -> void:
	var done := current
	current = null
	if done.on_end.is_valid():
		done.on_end.call()
