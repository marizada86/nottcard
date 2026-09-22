class_name EventPlan
extends RefCounted
## game/core/event_plan.py — o sorteio dos eventos de uma missão (RNG injetável).

static func _data() -> Dictionary:
	return GameData.module("event_data")

static func chance(pity: int) -> float:
	var d := _data()
	if pity >= d["PITY_GUARANTEE"]:
		return 1.0
	return minf(d["CHANCE_CAP"], d["BASE_CHANCE"] + d["PITY_STEP"] * maxi(0, pity))

## Sorteia o grupo pelos pesos e, dentro dele, o evento pelo peso. null se não há elegível.
static func pick_event(events: Array, room: int, rng: PyRandom, taken: Array = []) -> Variant:
	var d := _data()
	var eligible: Array = []
	for e in events:
		if room in e.rooms and not (e.id in taken) and d["GROUP_WEIGHTS"].get(e.group, 0) > 0:
			eligible.append(e)
	var group_set := {}
	for e in eligible:
		group_set[e.group] = true
	var groups := group_set.keys()
	groups.sort()
	if groups.is_empty():
		return null
	var gw: Array = []
	for g in groups:
		gw.append(d["GROUP_WEIGHTS"][g])
	var group: String = rng.choices(groups, gw)[0]
	var pool: Array = []
	for e in eligible:
		if e.group == group:
			pool.append(e)
	var pw: Array = []
	for e in pool:
		pw.append(e.weight)
	return rng.choices(pool, pw)[0]

static func roll_plan(pity: int, events: Array, rng: PyRandom, rooms: Variant = null, always: bool = false) -> Array:
	var d := _data()
	var room_list: Array = d["ELIGIBLE_ROOMS"] if rooms == null else rooms
	var plan: Array = []
	if not always and rng.random() >= chance(pity):
		return plan
	for attempt in range(2):
		if attempt == 1 and rng.random() >= d["SECOND_EVENT_CHANCE"]:
			break
		var free_rooms: Array = []
		for r in room_list:
			var used := false
			for p in plan:
				if p.room == r:
					used = true
			if not used:
				free_rooms.append(r)
		if free_rooms.is_empty():
			break
		var room: int = rng.choice(free_rooms)
		var taken: Array = []
		for p in plan:
			taken.append(p.event_id)
		var event: Variant = pick_event(events, room, rng, taken)
		if event == null:
			break
		plan.append(EventInstance.new(event.id, room))
	return plan

static func next_pity(pity: int, had_event: bool) -> int:
	return 0 if had_event else pity + 1
