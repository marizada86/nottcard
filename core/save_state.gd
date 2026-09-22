class_name SaveState
extends RefCounted
## game/core/progress.py::SaveState — o save: progresso de todos os personagens, coleção, loja, missões concluídas.
## Conjuntos (`achievements`, `owned`, ...) são Dictionary {id: true} (ver Py.set_of).

static var last_error: String = ""

var progress: Dictionary = {}
var achievements: Dictionary = {}
var hqs_seen: Dictionary = {}
var card_layout: String = ""
var collection: Array = []
var decks: Array = []
var active_deck: int = 0
var coins: int = 0
var owned: Dictionary = {}
var pending_offer: Variant = null
var scrolls: Dictionary = {}
var upgrades: Dictionary = {}
var equipment_units: Dictionary = {}
var equipped: Dictionary = {}
var event_pity: int = 0
var missions_completed: Dictionary = {}
var unlocked_characters: Dictionary = Py.set_of(ProgressRules.ALL_CHARACTER_IDS)
var roster_rules: bool = false
var story_items: Dictionary = {}

func for_character(character_id: String) -> Progress:
	if not progress.has(character_id):
		progress[character_id] = Progress.new()
	return progress[character_id]

var has_progress: bool:
	get:
		for p in progress.values():
			if p.xp > 0 or p.level > 1:
				return true
		return false

func to_dict() -> Dictionary:
	var prog := {}
	for cid in progress:
		var p: Progress = progress[cid]
		prog[cid] = {"level": p.level, "xp": p.xp, "kills": p.kills}
	var scr := {}
	for cid in scrolls:
		if not scrolls[cid].is_empty():
			scr[cid] = scrolls[cid].duplicate()
	var up := {}
	for k in upgrades:
		if upgrades[k] != 0:
			up[k] = upgrades[k]
	var eq := {}
	for cid in equipped:
		if not equipped[cid].is_empty():
			eq[cid] = equipped[cid].duplicate()
	var units := {}
	for k in equipment_units:
		if equipment_units[k] > 0:
			units[k] = equipment_units[k]
	var deck_list: Array = []
	for d in decks:
		deck_list.append(d.duplicate())
	return {
		"version": ProgressRules.SAVE_VERSION,
		"progress": prog,
		"achievements": Py.set_sorted(achievements),
		"hqs_seen": Py.set_sorted(hqs_seen),
		"card_layout": card_layout,
		"collection": collection.duplicate(),
		"decks": deck_list,
		"active_deck": active_deck,
		"coins": coins,
		"owned": Py.set_sorted(owned),
		"pending_offer": pending_offer,
		"scrolls": scr,
		"upgrades": up,
		"equipped": eq,
		"equipment_units": units,
		"event_pity": event_pity,
		"missions_completed": Py.set_sorted(missions_completed),
		"unlocked_characters": Py.set_sorted(unlocked_characters),
		"story_items": Py.set_sorted(story_items),
	}

static func _fail(msg: String) -> SaveState:
	last_error = msg
	return null

static func _all_str(a: Variant) -> bool:
	if not (a is Array):
		return false
	for v in a:
		if not (v is String):
			return false
	return true

static func _string_set(data: Dictionary, key: String, default: Array = []) -> Variant:
	var raw: Variant = data.get(key)
	if raw == null:
		return Py.set_of(default)
	if not _all_str(raw):
		return null
	return Py.set_of(raw)

## Reconstrói o save; devolve null (e preenche last_error) se o conteúdo não for um save.
static func from_dict(data: Variant) -> SaveState:
	last_error = ""
	if not (data is Dictionary):
		return _fail("o save não é um objeto JSON")
	var version: Variant = data.get("version", 1)
	if not Py.is_int(version) or int(version) > ProgressRules.SAVE_VERSION:
		return _fail("versão de save não suportada: %s" % str(version))
	var progress_d := {}
	var raw_progress: Variant = data.get("progress", {})
	if not (raw_progress is Dictionary):
		return _fail("progress inválido")
	for cid in raw_progress:
		var raw: Variant = raw_progress[cid]
		if not (raw is Dictionary):
			return _fail("progresso de personagem inválido")
		var level: Variant = raw.get("level", 1)
		var xp: Variant = raw.get("xp", 0)
		var kills: Variant = raw.get("kills", 0)
		if not Py.is_int(level) or not Py.is_int(xp) or not Py.is_int(kills):
			return _fail("nível/XP/mortes inválidos")
		var p := Progress.new()
		p.level = maxi(1, mini(ProgressRules.MAX_LEVEL, int(level)))
		p.xp = maxi(0, mini(ProgressRules.xp_for_level(ProgressRules.MAX_LEVEL), int(xp)))
		p.kills = maxi(0, int(kills))
		progress_d[str(cid)] = p
	var achievements_a: Variant = data.get("achievements", [])
	if not _all_str(achievements_a):
		return _fail("conquistas inválidas")
	var hqs_a: Variant = data.get("hqs_seen", [])
	if not _all_str(hqs_a):
		return _fail("HQs vistas inválidas")
	var layout: Variant = data.get("card_layout", "")
	var collection_a: Variant = data.get("collection", [])
	if not _all_str(collection_a):
		return _fail("coleção inválida")
	var decks_a: Variant = data.get("decks", [])
	if not (decks_a is Array):
		return _fail("baralhos inválidos")
	for d in decks_a:
		if not _all_str(d):
			return _fail("baralhos inválidos")
	var active: Variant = data.get("active_deck", 0)
	if not Py.is_int(active):
		return _fail("baralho ativo inválido")
	var coins_v: Variant = data.get("coins", 0)
	if not Py.is_int(coins_v):
		return _fail("moedas inválidas")
	var owned_a: Variant = data.get("owned", [])
	if not _all_str(owned_a):
		return _fail("itens comprados inválidos")
	var offer: Variant = data.get("pending_offer")
	if offer != null:
		if not (offer is Dictionary) or not (offer.get("source") is String) or not _all_str(offer.get("cards")):
			return _fail("oferta pendente inválida")
		var fresh := {"source": offer["source"], "cards": offer["cards"].duplicate()}
		for k in ["for", "chosen"]:
			if offer.has(k) and offer[k] is String:
				fresh[k] = offer[k]
		offer = fresh
	var raw_scrolls: Variant = data.get("scrolls", {})
	if not (raw_scrolls is Dictionary):
		return _fail("pergaminhos inválidos")
	for k in raw_scrolls:
		if not _all_str(raw_scrolls[k]):
			return _fail("pergaminhos inválidos")
	var raw_upgrades: Variant = data.get("upgrades", {})
	if not (raw_upgrades is Dictionary):
		return _fail("upgrades inválidos")
	for k in raw_upgrades:
		if not Py.is_int(raw_upgrades[k]):
			return _fail("upgrades inválidos")
	var raw_equipped: Variant = data.get("equipped", {})
	if not (raw_equipped is Dictionary):
		return _fail("equipamento inválido")
	for k in raw_equipped:
		if not (raw_equipped[k] is Dictionary):
			return _fail("equipamento inválido")
		for a in raw_equipped[k]:
			if not (raw_equipped[k][a] is String):
				return _fail("equipamento inválido")
	var raw_units: Variant = data.get("equipment_units")
	if raw_units != null:
		if not (raw_units is Dictionary):
			return _fail("unidades de equipamento inválidas")
		for k in raw_units:
			if not Py.is_int(raw_units[k]):
				return _fail("unidades de equipamento inválidas")
	var pity: Variant = data.get("event_pity", 0)
	if not Py.is_int(pity):
		return _fail("contador de eventos inválido")
	var completed: Variant = _string_set(data, "missions_completed", ["m1"] if ("hq_001" in hqs_a) else [])
	if completed == null:
		return _fail("missions_completed inválido")
	var unlocked: Variant = _string_set(data, "unlocked_characters")
	if unlocked == null:
		return _fail("unlocked_characters inválido")
	var story: Variant = _string_set(data, "story_items")
	if story == null:
		return _fail("story_items inválido")
	var s := SaveState.new()
	s.progress = progress_d
	s.achievements = Py.set_of(achievements_a)
	s.event_pity = maxi(0, int(pity))
	s.hqs_seen = Py.set_of(hqs_a)
	s.pending_offer = offer
	s.missions_completed = completed
	s.unlocked_characters = unlocked
	s.roster_rules = true
	s.story_items = story
	for k in raw_scrolls:
		s.scrolls[k] = raw_scrolls[k].duplicate()
	s.card_layout = layout if layout is String else ""
	s.collection = collection_a.duplicate()
	for d in decks_a:
		s.decks.append(d.duplicate())
	s.active_deck = int(active) if (0 <= int(active) and int(active) < decks_a.size()) else 0
	s.coins = maxi(0, int(coins_v))
	s.owned = Py.set_of(owned_a)
	for k in raw_upgrades:
		s.upgrades[k] = maxi(0, int(raw_upgrades[k]))
	for k in raw_equipped:
		s.equipped[k] = raw_equipped[k].duplicate()
	if raw_units != null:
		for k in raw_units:
			s.equipment_units[k] = maxi(0, int(raw_units[k]))
	else:
		Equipment.migrate_units(s)
	return s
