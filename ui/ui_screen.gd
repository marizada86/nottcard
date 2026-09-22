class_name UiScreen
extends RefCounted
## Base das telas (game/app.py::Screen). O App chama handle_input / update / draw; `enter` e `exit` abrem e fecham nós filhos (o mundo 3D da caminhada).

var app: GameApp

func enter() -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_dt: float) -> void:
	pass

func draw(_ci: CanvasItem) -> void:
	pass

func pause() -> void:
	pass

func resume() -> void:
	pass

## Posição do mouse em pixels lógicos.
func mouse() -> Vector2:
	return app.get_local_mouse_position()

## Clique esquerdo?
static func is_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT

static func is_key(event: InputEvent, keycode: int) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == keycode
