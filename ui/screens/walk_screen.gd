class_name WalkScreen
extends UiScreen
## game/ui/walk_screen.py — a exploração por caminhada em primeira pessoa (WorldView) e o HUD. As regras vivem no core (Walker, WorldMap).

const STEP_TIME := 0.28
const TURN_TIME := 0.22
const BUMP_TIME := 0.09
const BUMP_DISTANCE := 0.07
const DIRECTION_LABELS := {"N": "Norte", "L": "Leste", "S": "Sul", "O": "Oeste"}
const KEYS := {KEY_W: "forward", KEY_UP: "forward", KEY_S: "backward", KEY_DOWN: "backward", KEY_Q: "turn_left", KEY_LEFT: "turn_left",
	KEY_E: "turn_right", KEY_RIGHT: "turn_right", KEY_A: "strafe_left", KEY_D: "strafe_right", KEY_X: "about_face"}
const COMMANDS := ["turn_left", "strafe_left", "forward", "backward", "strafe_right", "turn_right"]
const LABELS := {"turn_left": "Virar (Q)", "strafe_left": "Esquerda (A)", "forward": "Avançar (W)", "backward": "Recuar (S)", "strafe_right": "Direita (D)", "turn_right": "Virar (E)"}

var walker: Walker
var view: WorldView
var hud: Control
var vis_pos: Vector2
var vis_angle: float = 0.0
var anim: Variant = null
var queue: Array = []
var pending: Array = []
var chained: Array = []
var collide: bool = false
var buttons: Dictionary = {}
var backpack_button := Rect2(20, 56, 170, 40)
var map_button := Rect2(20, 104, 170, 40)
var _dt: float = 0.016
var _sprite_cache: Dictionary = {}

func enter() -> void:
	walker = app.run.walker
	view = WorldView.new()
	view.walker = walker
	view.mission = app.run.mission
	view.flicker = app.torch_flicker
	app.add_child(view)
	hud = Control.new()
	hud.size = Vector2(Gfx.W, Gfx.H)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(func(): _draw_hud(hud))
	app.add_child(hud)
	vis_pos = Vector2(walker.x + 0.5, walker.y + 0.5)
	vis_angle = WorldArt.facing_angle(walker.facing)
	var y := Gfx.H - 74
	var w := 150
	var h := 50
	var gap := 10
	var left := (Gfx.W - (6 * w + 5 * gap)) / 2
	for i in range(COMMANDS.size()):
		buttons[COMMANDS[i]] = Rect2(left + i * (w + gap), y, w, h)
	view.set_frame(vis_pos, vis_angle, _sprites(), 0.0)

func exit() -> void:
	if view != null:
		view.queue_free()
	if hud != null:
		hud.queue_free()

func _enemy_slugs(room: int) -> Array:
	var mission := app.run.mission
	var key := "%s|%d" % [mission.id, room]
	if not _sprite_cache.has(key):
		var r: Variant = mission.room(room)
		var out: Array = []
		if r != null and r.kind == Rooms.COMBATE:
			for e in r.make_enemies():
				out.append(e.slug)
		_sprite_cache[key] = out
	return _sprite_cache[key]

func _sprites() -> Array:
	var out: Array = []
	var run := app.run
	for c in run.event_marker_cells():
		out.append({"x": c.x + 0.5, "y": c.y + 0.5, "kind": "marker", "slug": ""})
	var dg := run.mission.dungeon
	for room in dg.prop_cells:
		for p in dg.prop_cells[room]:
			out.append({"x": p[0].x + 0.5, "y": p[0].y + 0.5, "kind": "prop", "slug": p[1]})
	for room in dg.enemy_cells:
		if run.world.is_cleared(room):
			continue
		var slugs := _enemy_slugs(room)
		var cells: Array = dg.enemy_cells[room]
		for i in range(mini(cells.size(), slugs.size())):
			out.append({"x": cells[i].x + 0.5, "y": cells[i].y + 0.5, "kind": "enemy", "slug": slugs[i]})
	for room in dg.marker_rooms:
		if not run.world.is_cleared(room) and room != 1:
			var a: Vector2i = dg.anchors[room]
			out.append({"x": a.x + 0.5, "y": a.y + 0.5, "kind": "marker", "slug": ""})
	return out

func near_anchor(room: int) -> bool:
	var dg := app.run.mission.dungeon
	var a: Vector2i = dg.anchors[room]
	return maxi(absi(walker.x - a.x), absi(walker.y - a.y)) <= dg.encounter_range

func command(name: String) -> void:
	if anim != null:
		queue.append(name)
		if queue.size() > 1:
			queue = queue.slice(queue.size() - 1)
		return
	_start(walker.call(name))

func _start(events: Array) -> void:
	var turns: Array = []
	for e in events:
		if e["type"] == "Turned":
			turns.append(e)
	if not turns.is_empty() and turns.size() < events.size():
		chained = events.filter(func(e): return e["type"] != "Turned")
		events = turns
	pending = events.duplicate()
	collide = walker.block_reason == WalkRules.ENEMY
	var target := Vector2(walker.x + 0.5, walker.y + 0.5)
	for e in events:
		match e["type"]:
			"Moved":
				anim = {"kind": "move", "t": 0.0, "dur": STEP_TIME, "p0": vis_pos, "p1": target}
			"Turned":
				anim = {"kind": "turn", "t": 0.0, "dur": TURN_TIME if absi(e["delta"]) == 1 else TURN_TIME * 1.6, "a0": vis_angle, "a1": vis_angle + e["delta"] * PI / 2.0}
			"Blocked":
				if walker.block_reason == WalkRules.LOCKED:
					if app.toast != WalkRules.LOCKED_TEXT or app.toast_left <= 0.0:
						app.show_toast(WalkRules.LOCKED_TEXT, 3.0)
				var toward := Vector2(e["x"] + 0.5, e["y"] + 0.5) - vis_pos
				anim = {"kind": "bump", "t": 0.0, "dur": BUMP_TIME, "p0": vis_pos, "p1": vis_pos, "dir": toward.normalized() if toward.length() > 0 else Vector2.ZERO}
	if app.reduce_motion and anim != null:
		_finish()
	elif anim == null:
		_finish()

func _finish() -> void:
	vis_pos = Vector2(walker.x + 0.5, walker.y + 0.5)
	vis_angle = WorldArt.facing_angle(walker.facing)
	anim = null
	var events := pending
	pending = []
	for e in events:
		if e["type"] == "EnteredRoom":
			if app.run.walk_cross(e["room"]):
				_open_room_encounter()
				return
	if not chained.is_empty():
		var rest := chained
		chained = []
		_start(rest)
		return
	_check_encounter()

func _check_encounter() -> void:
	var run := app.run
	var room := walker.room
	var event: Variant = run.event_near(walker)
	if event != null:
		_open_event(event)
		return
	if collide and room != 0 and room == run.world.current and not run.world.is_cleared(room):
		collide = false
		_open_room_encounter()
		return
	collide = false
	if room != 0 and room == run.world.current and not run.world.is_cleared(room) and not run.mission.dungeon.enemy_cells.has(room) and near_anchor(room):
		_open_room_encounter()

## Abre o combate ou a situação da sala atual.
func _open_room_encounter() -> void:
	var run := app.run
	var room := run.current_room()
	if room.kind == Rooms.COMBATE:
		app.start_combat(room.make_enemies(), room.is_boss, room.asset_id)
	else:
		var sit: Situation = run.mission.situations[room.id]
		app.set_screen(SituationScreen.new(sit, Callable(), "", func(applied): _situation_finished(applied)))

func _situation_finished(applied: Applied) -> void:
	var run := app.run
	if applied.fight == "sala":
		var room := run.current_room()
		app.start_combat(room.make_enemies(), false, room.asset_id)
	else:
		app.advance_room(false)

func _open_event(instance: EventInstance) -> void:
	var run := app.run
	var situation := run.open_event(instance)
	var done := func(applied: Applied):
		if applied.fight == "mimico":
			var enemy := Events.make_mimic(instance)
			run.event_win = func():
				app.show_toast(run.mimic_won(instance), 6.0)
				run.finish_event()
				app.open_walk()
			app.start_combat([enemy], false, run.current_room().asset_id, run.event_win)
		else:
			run.finish_event()
			app.open_walk()
	app.set_screen(SituationScreen.new(situation, Callable(), situation.title, done, func(): return run.rebuild_event()))

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if KEYS.has(event.keycode):
			command(KEYS[event.keycode])
		elif event.keycode == KEY_ESCAPE:
			app.return_to_menu()
	elif is_click(event):
		var p: Vector2 = event.position
		for name in buttons:
			if buttons[name].has_point(p):
				command(name)
				return

func update(dt: float) -> void:
	_dt = dt
	view.flicker = app.torch_flicker
	if anim != null:
		anim["t"] += dt
		var raw: float = anim["t"] / anim["dur"]
		var p := _ease(raw)
		if anim["kind"] == "move":
			vis_pos = anim["p0"].lerp(anim["p1"], p)
		elif anim["kind"] == "turn":
			vis_angle = lerpf(anim["a0"], anim["a1"], p)
		if anim["t"] >= anim["dur"]:
			_finish()
	if anim == null and not queue.is_empty():
		command(queue.pop_front())
	if view != null:
		var pos := vis_pos
		if anim != null and anim["kind"] == "bump":
			pos += anim["dir"] * BUMP_DISTANCE * sin(PI * minf(1.0, anim["t"] / anim["dur"]))
		view.set_frame(pos, vis_angle, _sprites(), dt)
	if hud != null:
		hud.queue_redraw()

func _ease(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	if app.walk_bob:
		t = pow(t, 1.3)
	return t * t * (3.0 - 2.0 * t)

func draw(_ci: CanvasItem) -> void:
	pass

func _draw_hud(ci: CanvasItem) -> void:
	var m := mouse()
	var w := Gfx.W
	var run := app.run
	var room := WorldArt.room_for_cell(walker.grid, walker.x, walker.y)
	var in_room := walker.grid.room_at(walker.x, walker.y)
	var name: String = run.mission.room(room).name if in_room != 0 else "Corredor"
	Gfx.scrim(ci, Rect2(w / 2.0 - 260, 14, 520, 66), 150)
	Gfx.text(ci, name, Vector2(w / 2.0, 18), 28, UiTheme.TEXT_COLOR, "midtop")
	Gfx.text(ci, "Virado para o %s" % DIRECTION_LABELS[NavGrid.DIR_NAMES[walker.facing]], Vector2(w / 2.0, 52), 18, UiTheme.TEXT_MUTED, "midtop")
	var held := 0
	for mb in run.party.members:
		held += mb.player.backpack.bag.size() + (1 if mb.player.backpack.accessory != null else 0)
	Gfx.button(ci, backpack_button, "Mochila (%d)" % held if held > 0 else "Mochila", backpack_button.has_point(m))
	Gfx.button(ci, map_button, "Mapa (M)", map_button.has_point(m))
	for n in buttons:
		Gfx.button(ci, buttons[n], LABELS[n], buttons[n].has_point(m))
	Gfx.text(ci, "Bolsa: %d de ouro" % run.ledger.mission_gold, Vector2(20, 14), 22, UiTheme.SELECTED_BORDER, "topleft")
	Gfx.text(ci, "W/S avançar e recuar · Q/E ou setas virar · A/D passo lateral · X meia-volta", Vector2(w / 2.0, Gfx.H - 78), 18, UiTheme.TEXT_MUTED, "midbottom")
	_draw_minimap(ci)

func _draw_minimap(ci: CanvasItem) -> void:
	var g := walker.grid
	var cell := 6
	var w := g.width * cell
	var h := g.height * cell
	var scale := minf(1.0, minf(230.0 / w, 150.0 / h))
	var cs := maxf(2.0, floor(cell * scale))
	var origin := Vector2(Gfx.W - 20 - g.width * cs, 20)
	Gfx.scrim(ci, Rect2(origin - Vector2(6, 6), Vector2(g.width * cs + 12, g.height * cs + 12)), 150)
	for v in walker.visited:
		var seen := [v]
		for n in g.neighbors(v.x, v.y):
			seen.append(n)
		for c in seen:
			var col := Color8(58, 58, 70) if not g.is_door(c.x, c.y) else Color8(150, 110, 60)
			if g.is_wall(c.x, c.y):
				continue
			ci.draw_rect(Rect2(origin + Vector2(c.x, c.y) * cs, Vector2(cs, cs)), col)
	var pp := origin + vis_pos * cs
	ci.draw_circle(pp, maxf(2.0, cs * 0.6), UiTheme.SELECTED_BORDER)
	var d := Vector2(sin(vis_angle), -cos(vis_angle))
	ci.draw_line(pp, pp + d * cs * 1.6, UiTheme.SELECTED_BORDER, 2.0)
