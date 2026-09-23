class_name Dice3dView
extends Node
## Um pequeno palco 3D transparente, composto pela tela 2D como Texture2D.
## O valor já resolvido determina somente a orientação final, nunca um novo RNG.

const MeshSource = preload("res://ui/dice_mesh_3d.gd")

const VIEW_SIZE := Vector2i(420, 320)
const THROW_FRACTION := 0.58
const SETTLE_FRACTION := 0.80

var viewport: SubViewport
var stage: Node3D
var _dice: Array = [] # [{"pivot", "from", "target", "value"}]
var _duration := 0.0
var _elapsed := 0.0
var _active := false

func _ready() -> void:
	_build_stage()

func _build_stage() -> void:
	if viewport != null:
		return
	viewport = SubViewport.new()
	viewport.size = VIEW_SIZE
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.handle_input_locally = false
	add_child(viewport)
	stage = Node3D.new()
	viewport.add_child(stage)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 0, 5.4)
	camera.fov = 34.0
	stage.add_child(camera)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-38, -28, 0)
	key.light_energy = 1.45
	key.shadow_enabled = true
	stage.add_child(key)
	var rim := OmniLight3D.new()
	rim.position = Vector3(-2.0, 1.4, 2.0)
	rim.light_color = Color8(145, 255, 166)
	rim.light_energy = 2.3
	rim.omni_range = 8.0
	stage.add_child(rim)

func start(values: Array, duration: float) -> void:
	_build_stage()
	_clear_dice()
	_duration = maxf(0.1, duration)
	_elapsed = 0.0
	_active = not values.is_empty()
	for i in range(values.size()):
		var pivot := Node3D.new()
		stage.add_child(pivot)
		var instance := MeshInstance3D.new()
		instance.mesh = MeshSource.d20_mesh()
		for face_index in range(20):
			instance.set_surface_override_material(face_index, MeshSource.face_material(face_index + 1))
		pivot.add_child(instance)
		_add_face_numbers(pivot)
		var offset := (i - (values.size() - 1) / 2.0) * 1.45
		pivot.position = Vector3(-2.6 + offset, 1.25, 0.0)
		var start_rotation := Quaternion.from_euler(Vector3(1.2 + i * 0.5, -0.9 + i * 0.7, 0.4 + i * 0.3))
		pivot.quaternion = start_rotation
		var target_rotation := Quaternion(MeshSource.face_normal(int(values[i])), Vector3(0, 0, 1))
		_dice.append({"pivot": pivot, "from": start_rotation, "target": target_rotation, "offset": offset})

func _add_face_numbers(pivot: Node3D) -> void:
	for value in range(1, 21):
		var number := Label3D.new()
		number.text = str(value)
		number.font = UiTheme.card_title_font()
		number.font_size = 72
		number.outline_size = 10
		number.modulate = Color8(32, 34, 40)
		number.outline_modulate = Color8(238, 234, 220)
		number.pixel_size = 0.0042
		number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		number.position = MeshSource.face_center(value) + MeshSource.face_normal(value) * 0.025
		pivot.add_child(number)

func advance(dt: float) -> void:
	if not _active:
		return
	_elapsed = minf(_duration, _elapsed + dt)
	var p := _elapsed / _duration
	for item in _dice:
		var pivot: Node3D = item["pivot"]
		var offset: float = item["offset"]
		if p < THROW_FRACTION:
			var q := p / THROW_FRACTION
			pivot.position = Vector3(-2.6 + offset + 2.6 * (1.0 - pow(1.0 - q, 3.0)), 1.25 - 1.25 * (1.0 - pow(1.0 - q, 3.0)) + 0.5 * sin(q * PI), 0.0)
			pivot.rotate_object_local(Vector3(1.0, 0.7, 0.35).normalized(), dt * (25.0 - 17.0 * q))
		else:
			var q := clampf((p - THROW_FRACTION) / maxf(0.001, SETTLE_FRACTION - THROW_FRACTION), 0.0, 1.0)
			q = q * q * (3.0 - 2.0 * q)
			pivot.position = Vector3(offset, 0, 0)
			pivot.quaternion = pivot.quaternion.slerp(item["target"], q)
	if _elapsed >= _duration:
		_active = false

func active() -> bool:
	return _active

func texture() -> Texture2D:
	return viewport.get_texture() if viewport != null else null

func _clear_dice() -> void:
	for item in _dice:
		var pivot: Node3D = item["pivot"]
		if is_instance_valid(pivot): pivot.queue_free()
	_dice.clear()
