class_name Events
extends RefCounted
## game/core/events.py — os eventos aleatórios da exploração (baú, mercador, altar, viajante, fenda, frasco).
## `app` (opcional) é qualquer objeto/Dictionary com temp_budget, ledger e save_state (para o mercador).

const CHEST_LOCKED_CHANCE := 0.25
const CHEST_REWARD_CHANCE := 0.40
const MIMIC_CHANCE := 0.25
const CHEST_EXAMINE_DC := 12
const LOCK_DC := 12
const LOCK_DAMAGE := [1, 4]
const SHOP_CARD_PRICE := [20, 35]
const SHOP_ITEM_PRICE := [25, 45]
const POTION_NAME := "Poção de Cura"
const POTION_PRICE := 15
const SHOP_REROLL_COST := 10
const ALTAR_HEAL_COST := 15
const ALTAR_BLESS_COST := 20
const ALTAR_CLEANSE_COST := 20
const ALTAR_HEAL_PCT := 50
const TRAVELER_ASSAULT_GOLD := [20, 30]
const TRAVELER_DC := 12
const RIFT_DC := 12
const RIFT_XP := 12
const RIFT_DAMAGE := [2, 5]

static func all() -> Array:
	return GameData.module("events")["EVENTS"]

static func by_id(event_id: String) -> Variant:
	for e in all():
		if e.id == event_id:
			return e
	return null

static func _c(name: String) -> Variant:
	return GameData.module("events")[name]

static func chest_gold(room: int, rng: PyRandom) -> int:
	var low: int = int(_c("CHEST_GOLD_LOW")) + int(_c("CHEST_GOLD_PER_ROOM")) * maxi(0, room - 2)
	return rng.randint(low, low + int(_c("CHEST_GOLD_SPAN")))

static func shop_offer(rng: PyRandom) -> Array:
	var picked: Array = [Temporaries.pick_card(rng, [POTION_NAME]).name]
	picked.append(Temporaries.pick_card(rng, [POTION_NAME, picked[0]]).name)
	var offer: Array = []
	for n in picked:
		offer.append({"kind": "card", "name": n, "price": rng.randint(SHOP_CARD_PRICE[0], SHOP_CARD_PRICE[1])})
	offer.append({"kind": "card", "name": POTION_NAME, "price": POTION_PRICE})
	var item_id: String = rng.choice(Temporaries.temp_items()).id
	offer.append({"kind": "item", "id": item_id, "price": rng.randint(SHOP_ITEM_PRICE[0], SHOP_ITEM_PRICE[1])})
	return offer

static func roll_state(instance: EventInstance, rng: PyRandom) -> Dictionary:
	var kind := instance.event_id
	var room := instance.room
	if kind == "bau":
		var mimic: bool = room > int(GameData.module("event_data")["MIMIC_MIN_ROOM"]) and rng.random() < MIMIC_CHANCE
		var locked: bool = not mimic and rng.random() < CHEST_LOCKED_CHANCE
		var reward: String = rng.choice(["card", "item"]) if rng.random() < CHEST_REWARD_CHANCE else ""
		return {"mimic": mimic, "locked": locked, "gold": chest_gold(room, rng), "reward": reward, "revealed": false, "examined": false}
	if kind == "mercador":
		return {"offer": shop_offer(rng), "sold": [], "rerolls": 0}
	if kind == "viajante":
		return {"gold": rng.randint(TRAVELER_ASSAULT_GOLD[0], TRAVELER_ASSAULT_GOLD[1])}
	return {}

static func make_mimic(instance: EventInstance) -> Enemy:
	var rooms: Array = Missions.current().rooms
	var enemies: Array = []
	for r in rooms:
		if r.kind == Rooms.COMBATE and not r.is_boss:
			enemies.append_array(r.make_enemies())
	var room: Variant = null
	for r in rooms:
		if r.id == instance.room:
			room = r
			break
	var room_hp: int
	if room != null and room.kind == Rooms.COMBATE:
		room_hp = 0
		for e in room.make_enemies():
			room_hp += e.hp
	else:
		var hp_sum := 0
		for e in enemies:
			hp_sum += e.hp
		room_hp = Py.round_half_even(float(hp_sum) / enemies.size())
	var ca_sum := 0
	var cam_sum := 0
	for e in enemies:
		ca_sum += e.ca
		cam_sum += e.cam
	return Enemies.mimico(room_hp, Py.round_half_even(float(ca_sum) / enemies.size()), Py.round_half_even(float(cam_sum) / enemies.size()))

static func mimic_gold(instance: EventInstance) -> int:
	return 2 * int(instance.state.get("gold", 0))

## Aplica o efeito de um desfecho ao estado do evento. true se as opções precisam ser refeitas.
static func apply_effect(instance: EventInstance, effect: String, rng: PyRandom = null) -> bool:
	if effect == "":
		return false
	var state := instance.state
	if effect == "reveal":
		state["revealed"] = true
		state["examined"] = true
	elif effect == "examined":
		state["examined"] = true
	elif effect == "reroll":
		state["rerolls"] = state.get("rerolls", 0) + 1
		state["offer"] = shop_offer(rng if rng != null else PyRandom.new())
		state["sold"] = []
	elif effect.begins_with("sold:"):
		if not state.has("sold"):
			state["sold"] = []
		state["sold"].append(int(effect.split(":", true, 1)[1]))
	return true

static func apply_party_effects(applied: Applied, players: Array) -> void:
	for player in players:
		if applied.bless != 0:
			player.bless = maxi(player.bless, applied.bless + (1 if player.character.id == "maelor" else 0))
		if player.character.id == "brook":
			if applied.dishonor:
				player.dishonored = true
			if applied.clear_dishonor:
				player.dishonored = false

static func _has_locator(players: Array) -> bool:
	for p in players:
		for pile in [p.hand, p.draw_pile, p.discard]:
			for c in pile:
				if c.name == "Localizar Criatura":
					return true
	return false

static func _app_get(app: Variant, key: String) -> Variant:
	if app == null:
		return null
	if app is Dictionary:
		return app.get(key)
	return app.get(key)

static func build_situation(instance: EventInstance, players: Array, app: Variant = null) -> Situation:
	match instance.event_id:
		"bau": return _chest(instance, players)
		"mercador": return _shop(instance, app)
		"altar": return _altar(instance, players)
		"viajante": return _traveler(instance)
		"fenda": return _rift(instance, players)
		_: return _flask(instance)

static func _leave(label: String = "Deixar para lá", text: String = "Você segue caminho.") -> Option:
	return Option.make(label, {"auto": true, "success": Outcome.make(text)})

static func _chest(instance: EventInstance, players: Array) -> Situation:
	var state := instance.state
	if state["mimic"] and not state["revealed"] and _has_locator(players):
		state["revealed"] = true
		state["examined"] = true
	if state["mimic"] and state["revealed"]:
		return Situation.make(instance.room, ["O baú respira. É um mímico!", "Ele ainda não te notou."], [
			Option.make("Enfrentar o mímico", {"auto": true, "success": Outcome.make("O mímico ataca!", {"fight": "mimico", "gold": 0})}),
			_leave("Deixar em paz", "Você recua sem fazer barulho."),
		], "Evento: Mímico")
	var loot := Outcome.make("Dentro há ouro" + (" e mais alguma coisa." if state["reward"] != "" else "."), {"gold": state["gold"],
		"temp_card": "random" if state["reward"] == "card" else "", "temp_item": "random" if state["reward"] == "item" else ""})
	if state["mimic"]:
		loot = Outcome.make("Não era um baú! Dentes e tábuas: é um mímico!", {"fight": "mimico"})
	var options: Array = []
	if state["locked"]:
		var fail := Outcome.make("A tranca resiste e você se fere.", {"hp_loss": LOCK_DAMAGE, "remain": true})
		options.append(Option.make("Arrombar a tranca", {"attribute": "inteligencia", "dc": LOCK_DC, "success": loot, "failure": fail, "critical": fail}))
		options.append(Option.make("Forçar a tranca", {"attribute": "forca", "dc": LOCK_DC, "success": loot, "failure": fail, "critical": fail}))
	else:
		options.append(Option.make("Abrir", {"auto": true, "success": loot}))
	if not state["examined"]:
		var found: Outcome
		if state["mimic"]:
			found = Outcome.make("Algo no baú respira. É um mímico!", {"effect": "reveal", "remain": true})
		else:
			found = Outcome.make("Nada de estranho: é um baú de verdade.", {"effect": "examined", "remain": true})
		var miss := Outcome.make("Não dá para ter certeza.", {"effect": "examined", "remain": true})
		options.append(Option.make("Examinar", {"attribute": "inteligencia", "dc": CHEST_EXAMINE_DC, "success": found, "failure": miss, "critical": miss}))
	options.append(_leave("Deixar o baú", "Você deixa o baú onde está."))
	var lines := ["Um baú velho, fechado com uma tranca."] if state["locked"] else ["Um baú velho, sem tranca."]
	return Situation.make(instance.room, lines, options, "Evento: Baú (?)")

static func _flask(instance: EventInstance) -> Situation:
	var take := Outcome.make("O líquido ainda é vermelho e quente: uma Poção de Cura entra na sua bolsa.", {"temp_card": POTION_NAME})
	return Situation.make(instance.room, ["Entre os escombros, um frasco de vidro grosso, intacto."],
		[Option.make("Pegar o frasco", {"auto": true, "success": take}), _leave("Deixar o frasco", "Você segue sem tocar nele.")],
		"Evento: Frasco esquecido")

static func _shop(instance: EventInstance, app: Variant) -> Situation:
	var state := instance.state
	var budget: Variant = _app_get(app, "temp_budget")
	if budget == null:
		budget = TempBudget.new()
	var options: Array = []
	var index := 0
	for entry in state["offer"]:
		if index in state["sold"]:
			index += 1
			continue
		var price: int = entry["price"]
		var outcome: Outcome
		var label: String
		if entry["kind"] == "card":
			if not budget.can_card:
				index += 1
				continue
			outcome = Outcome.make("Você leva %s." % entry["name"], {"temp_card": entry["name"], "gold": -price, "remain": true, "effect": "sold:%d" % index})
			label = "%s — %d de ouro" % [entry["name"], price]
		else:
			if not budget.can_item:
				index += 1
				continue
			var item: ItemDef = GameData.module("items")["ITEMS"][entry["id"]]
			outcome = Outcome.make("Você leva %s." % item.nome, {"temp_item": entry["id"], "gold": -price, "remain": true, "effect": "sold:%d" % index})
			label = "%s — %d de ouro" % [item.nome, price]
		options.append(Option.make(label, {"auto": true, "cost_gold": price, "success": outcome}))
		index += 1
	options.append(Option.make("Trocar a oferta", {"auto": true, "cost_gold": SHOP_REROLL_COST,
		"success": Outcome.make("O mercador vasculha o estoque.", {"gold": -SHOP_REROLL_COST, "remain": true, "effect": "reroll"})}))
	options.append(_leave("Sair da loja", "Você se despede do mercador."))
	var ledger: Variant = _app_get(app, "ledger")
	var save: Variant = _app_get(app, "save_state")
	var purse: String
	if ledger != null and save != null:
		purse = "Ouro da missão: %d · Moedas: %d" % [ledger.mission_gold, save.coins]
	else:
		purse = "Ele aceita o ouro da bolsa e as moedas do perfil."
	return Situation.make(instance.room, ["Um mercador ambulante abre a carroça.", purse], options, "Evento: Mercador")

static func _altar(instance: EventInstance, players: Array) -> Situation:
	var options: Array = [
		Option.make("Oferecer ouro: cura", {"auto": true, "cost_gold": ALTAR_HEAL_COST,
			"success": Outcome.make("O altar aquece e as feridas fecham.", {"heal_pct": ALTAR_HEAL_PCT, "gold": -ALTAR_HEAL_COST})}),
		Option.make("Oferecer ouro: bênção", {"auto": true, "cost_gold": ALTAR_BLESS_COST,
			"success": Outcome.make("Uma bênção pousa sobre o grupo: +1 no acerto no próximo combate (+2 para o Maelor).", {"bless": 1, "gold": -ALTAR_BLESS_COST})}),
	]
	var brook_dishonored := false
	for p in players:
		if p.character.id == "brook" and p.dishonored:
			brook_dishonored = true
	if brook_dishonored:
		options.append(Option.make("Oferecer ouro: limpar a Desonra", {"auto": true, "cost_gold": ALTAR_CLEANSE_COST,
			"success": Outcome.make("A vergonha se dissolve.", {"clear_dishonor": true, "gold": -ALTAR_CLEANSE_COST})}))
	options.append(_leave("Deixar o altar", "Você faz uma reverência e segue."))
	return Situation.make(instance.room, ["Um altar simples, com velas acesas e uma tigela de oferendas."], options, "Evento: Altar")

static func _traveler(instance: EventInstance) -> Situation:
	var help := Option.make("Ajudar", {"attribute": "carisma", "dc": TRAVELER_DC,
		"success": Outcome.make("Ele agradece e te entrega algo. \"Fique atento ao que vem pela frente.\"", {"temp_item": "random"}),
		"failure": Outcome.make("Ele desconfia e não diz nada.")})
	var assault := Option.make("Assaltar", {"auto": true, "success": Outcome.make("Você toma o que ele tem. A culpa pesa.",
		{"gold": int(instance.state.get("gold", 25)), "dishonor": true})})
	return Situation.make(instance.room, ["Um sobrevivente ferido pede ajuda, encostado na parede."],
		[help, _leave("Ignorar", "Você passa sem olhar para trás."), assault], "Evento: Viajante ferido")

static func _rift(instance: EventInstance, players: Array) -> Situation:
	var ok := Outcome.make("Você atravessa a fenda e sai do outro lado.", {"xp": RIFT_XP})
	var mist := false
	for p in players:
		if p.hooks.has("mist_immune"):
			mist = true
	var cross: Option
	if mist:
		cross = Option.make("Atravessar (a névoa te reconhece)", {"auto": true, "success": ok})
	else:
		cross = Option.make("Atravessar a fenda", {"attribute": "constituicao", "dc": RIFT_DC, "success": ok,
			"failure": Outcome.make("A névoa te castiga na travessia.", {"hp_loss": RIFT_DAMAGE})})
	return Situation.make(instance.room, ["Uma fenda de névoa corta o caminho."], [cross, _leave("Contornar", "Você contorna a fenda.")], "Evento: Fenda de névoa")
