class_name Collection
extends RefCounted
## game/core/collection.py — raridade, núcleo do baralho, sorteios, coleção do jogador. `state` é um SaveState.

const COMUM := "comum"
const INCOMUM := "incomum"
const RARA := "rara"
const RARITY_ORDER := {"comum": 1, "incomum": 2, "rara": 3}
const DECK_CAP := 20
const STARTING_DECK_SIZE := 12
const MAX_DECKS := 1
const STARTING_EXTRAS := 6
const MAX_COPIES := 3
const COPY_CAP := 4
const COPY_CAP_BY_NAME := {"Poção de Cura": 1}
const DRAW_CAP_BY_NAME := {"Toque Curativo": 1, "Palavra Curativa": 1, "Golpe Perfurante": 2, "Golpe": 2}
const COLORS := ["Vermelho", "Amarelo", "Azul", "Roxo"]
const STARTING_MIN_PER_COLOR := 2
const STARTING_MIN_ATTACKS := 2
const STARTING_MIN_HEALS := 1
const CORE_DECK := ["Golpe", "Golpe", "Chama Menor", "Chama Menor", "Toque Curativo", "Palavra Curativa", "Poção de Cura", "Esquiva"]
const COMMON_NAMES := ["Golpe", "Golpe Perfurante", "Chama Menor", "Toque Curativo", "Palavra Curativa", "Aparar", "Poção de Cura", "Esquiva",
	"Estocada Mística", "Pancada de Escudo"]
const UNCOMMON_NAMES := ["Névoa Fria", "Contrafeitiço", "Golpe Contundente", "Atordoar", "Luz Reveladora", "Raio Enfraquecedor", "Surto de Ação",
	"Chama Sagrada", "Onda Psiônica", "Bola de Fogo"]
const BOSS_SOURCE := "chefe"
const BOSS_ID := "guardiao_verdadeiro"

static func core_counts() -> Dictionary:
	return Py.counter(CORE_DECK)

static func boss_pools() -> Dictionary:
	return {"guardiao_verdadeiro": Cards.c("GUARDIAO_RARAS"), "sacerdote_mente_derretida": Cards.c("SACERDOTE_RARAS")}

static func rarity_by_name(card_name: String) -> String:
	if card_name in COMMON_NAMES:
		return COMUM
	if card_name in UNCOMMON_NAMES:
		return INCOMUM
	return ""

static func rarity_of(card: Card) -> String:
	return card.rarity if card.rarity != "" else rarity_by_name(card.name)

static func is_collectible(card: Card) -> bool:
	return rarity_of(card) != ""

## Toda carta que o jogo conhece, na ordem de definição.
static func _all_source_cards() -> Array:
	var found: Array = []
	found.append_array(Cards.starting_deck())
	found.append_array(Cards.maelor_deck())
	found.append_array(Cards.sylas_deck())
	found.append_array(Cards.kayron_deck())
	for n in ["ESQUIVA", "ESTOCADA_MISTICA", "PANCADA_DE_ESCUDO", "ROMPER_ARMADURA", "REACAO_INSTINTIVA", "AMARRAR_E_SALTAR", "LOCALIZAR_CRIATURA",
			"COMUNHAO_COM_SENDRINAH", "LUZ_MAIS_PURA", "VISAO_VERDADEIRA", "RAIO_ENFRAQUECEDOR", "DOMINAR_PESSOA", "LEITURA_ABISSAL", "ASAS_NEGRAS",
			"DESCARGA_ESTELAR"]:
		found.append(Cards.c(n))
	var pools := boss_pools()
	for k in pools:
		found.append_array(pools[k])
	return found

## nome → carta das cartas da coleção (mantém a ordem de inserção como o dict do Python).
static func card_catalog() -> Dictionary:
	var catalog := {}
	for card in _all_source_cards():
		if is_collectible(card) and not catalog.has(card.name):
			catalog[card.name] = card
	return catalog

static func pool(rarity: String) -> Array:
	var catalog := card_catalog()
	var out: Array = []
	if rarity == RARA:
		for c in catalog.values():
			if rarity_of(c) == RARA:
				out.append(c)
		return out
	var names: Array = COMMON_NAMES if rarity == COMUM else UNCOMMON_NAMES
	for n in names:
		if catalog.has(n):
			out.append(catalog[n])
	return out

static func resolve(names: Array) -> Array:
	var catalog := card_catalog()
	var out: Array = []
	for n in names:
		if catalog.has(n):
			out.append(catalog[n])
	return out

static func _cap(card_name: String) -> int:
	return COPY_CAP_BY_NAME.get(card_name, COPY_CAP)

static func _draw_cap(card_name: String) -> int:
	return mini(_cap(card_name), DRAW_CAP_BY_NAME.get(card_name, COPY_CAP))

static func _take(candidates: Array, commons: Array, counts: Dictionary, picked: Array, rng: PyRandom) -> void:
	var options: Array = []
	for c in candidates:
		if counts.get(c.name, 0) < _draw_cap(c.name):
			options.append(c)
	var card: Card = rng.choice(options if not options.is_empty() else commons)
	counts[card.name] = counts.get(card.name, 0) + 1
	picked.append(card)

static func starting_deck(rng: PyRandom = null, size: int = STARTING_DECK_SIZE) -> Array:
	var r := rng if rng != null else PyRandom.new()
	var commons := pool(COMUM)
	var counts := {}
	var picked: Array = []
	for color in COLORS:
		for _i in range(STARTING_MIN_PER_COLOR):
			var cand: Array = []
			for c in commons:
				if c.color == color: cand.append(c)
			_take(cand, commons, counts, picked, r)
	while _count_kind(picked, "ataque") < STARTING_MIN_ATTACKS:
		var cand: Array = []
		for c in commons:
			if c.kind == "ataque": cand.append(c)
		_take(cand, commons, counts, picked, r)
	while _count_kind(picked, "cura") < STARTING_MIN_HEALS:
		var cand: Array = []
		for c in commons:
			if c.kind == "cura": cand.append(c)
		_take(cand, commons, counts, picked, r)
	while picked.size() < size:
		_take(commons, commons, counts, picked, r)
	r.shuffle(picked)
	return picked

static func _count_kind(cards: Array, kind: String) -> int:
	var n := 0
	for c in cards:
		if c.kind == kind: n += 1
	return n

static func starting_extras(rng: PyRandom = null, size: int = STARTING_EXTRAS) -> Array:
	var r := rng if rng != null else PyRandom.new()
	var commons := pool(COMUM)
	var counts := core_counts()
	var picked: Array = []
	while picked.size() < size:
		var options: Array = []
		for c in commons:
			if counts.get(c.name, 0) < mini(_draw_cap(c.name), MAX_COPIES):
				options.append(c)
		var card: Card = r.choice(options if not options.is_empty() else commons)
		counts[card.name] = counts.get(card.name, 0) + 1
		picked.append(card)
	return picked

static func boss_offer(boss_id: String, rng: PyRandom = null, count: int = 3) -> Array:
	var r := rng if rng != null else PyRandom.new()
	var boss_pool: Array = boss_pools().get(boss_id, [])
	return r.sample(boss_pool, mini(count, boss_pool.size()))

## Cartas de assinatura + cartas de nível liberadas até `level`.
static func signature_cards(character: CharacterDef, level: int = 1) -> Array:
	var cards: Array = []
	for c in character.build_deck():
		if not is_collectible(c):
			cards.append(c)
	var lvls := character.level_rewards.keys()
	lvls.sort()
	for lvl in lvls:
		if 2 <= lvl and lvl <= level:
			cards.append_array(character.level_rewards[lvl].cards)
	return cards

static func run_deck(character: CharacterDef, deck_names: Array, level: int = 1) -> Array:
	var out := resolve(deck_names)
	out.append_array(signature_cards(character, level))
	return out

static func deck_problems(names: Array) -> Array:
	var catalog := card_catalog()
	var cards_in: Array = []
	for n in names:
		if catalog.has(n):
			cards_in.append(catalog[n])
	var problems: Array = []
	for color in COLORS:
		var have := 0
		for c in cards_in:
			if c.color == color: have += 1
		var missing := STARTING_MIN_PER_COLOR - have
		if missing > 0:
			problems.append("faltam %d carta(s) %s" % [missing, color])
	var heals := STARTING_MIN_HEALS - _count_kind(cards_in, "cura")
	if heals > 0:
		problems.append("faltam %d de cura" % heals)
	var attacks := STARTING_MIN_ATTACKS - _count_kind(cards_in, "ataque")
	if attacks > 0:
		problems.append("faltam %d de ataque" % attacks)
	var counts := {}
	for c in cards_in:
		counts[c.name] = counts.get(c.name, 0) + 1
	for n in counts:
		var cap := 1 if rarity_of(catalog[n]) == RARA else mini(MAX_COPIES, _cap(n))
		if counts[n] > cap:
			problems.append("%s passa de %d cópia(s)" % [n, cap])
	return problems

static func _rarity_key(catalog: Dictionary, order: Array) -> Callable:
	return func(n):
		return [RARITY_ORDER[rarity_of(catalog[n])], order.find(n) if n in order else order.size()]

static func _sorted_by_rarity(names: Array) -> Array:
	var catalog := card_catalog()
	var order: Array = COMMON_NAMES + UNCOMMON_NAMES
	var known: Array = []
	for n in names:
		if catalog.has(n):
			known.append(n)
	return Py.sorted_by(known, _rarity_key(catalog, order))

static func sorted_by_rarity(names: Array) -> Array:
	return _sorted_by_rarity(names)

## Elementos de um Counter, na ordem de inserção das chaves (Counter.elements()).
static func _elements(counter: Dictionary) -> Array:
	var out: Array = []
	for k in counter:
		for _i in range(maxi(0, counter[k])):
			out.append(k)
	return out

static func default_deck(collection: Array) -> Array:
	var remaining := Py.counter(collection)
	var deck: Array = []
	for n in CORE_DECK:
		if remaining.get(n, 0) > 0:
			remaining[n] -= 1
			deck.append(n)
	var rest := _sorted_by_rarity(_elements(remaining))
	var all: Array = deck + rest
	return all.slice(0, DECK_CAP)

static func suggest_deck(collection: Array, deck_names: Array, class_color: String) -> Array:
	var catalog := card_catalog()
	var known: Array = []
	for n in collection:
		if catalog.has(n):
			known.append(n)
	var owned := Py.counter(known)
	var deck: Array = deck_names.duplicate()
	var counts := Py.counter(deck)
	var order: Array = COMMON_NAMES + UNCOMMON_NAMES
	var pref := func(n):
		var card: Card = catalog[n]
		return [1 if card.color != class_color else 0, -RARITY_ORDER[rarity_of(card)], order.find(n) if n in order else order.size()]
	for n in Py.sorted_by(owned.keys(), pref):
		var cap := 1 if rarity_of(catalog[n]) == RARA else mini(MAX_COPIES, _cap(n))
		while deck.size() < DECK_CAP and counts.get(n, 0) < mini(owned[n], cap):
			deck.append(n)
			counts[n] = counts.get(n, 0) + 1
	return deck

static func migrated_collection() -> Array:
	var best := {}
	for deck in [Cards.starting_deck(), Cards.maelor_deck(), Cards.sylas_deck(), Cards.kayron_deck()]:
		var names: Array = []
		for c in deck:
			if is_collectible(c): names.append(c.name)
		var cnt := Py.counter(names)
		for k in cnt:   # Counter |= : máximo por chave
			best[k] = maxi(best.get(k, 0), cnt[k])
	return _elements(best)

static func _topup_collection(state: SaveState) -> bool:
	var changed := false
	var have := Py.counter(state.collection)
	var cc := core_counts()
	for n in cc:
		for _i in range(cc[n] - have.get(n, 0)):
			state.collection.append(n)
			changed = true
	return changed

static func ensure_core(state: SaveState) -> bool:
	var changed := _topup_collection(state)
	var cc := core_counts()
	for deck in state.decks:
		for n in COPY_CAP_BY_NAME:
			while deck.count(n) > COPY_CAP_BY_NAME[n]:
				deck.remove_at(deck.find(n))
				changed = true
		for n in cc:
			for _i in range(cc[n] - deck.count(n)):
				if deck.size() >= DECK_CAP:
					var victim := -1
					for i in range(deck.size() - 1, -1, -1):
						if deck.count(deck[i]) > cc.get(deck[i], 0):
							victim = i
							break
					if victim < 0:
						break
					deck.remove_at(victim)
				deck.append(n)
				changed = true
	return changed

static func ensure_collection(state: SaveState, rng: PyRandom = null) -> bool:
	var changed := false
	if state.collection.is_empty():
		if state.has_progress:
			state.collection = migrated_collection()
		else:
			var extras: Array = []
			for c in starting_extras(rng):
				extras.append(c.name)
			state.collection = CORE_DECK.duplicate() + extras
		state.decks = []
		state.active_deck = 0
		changed = true
	if state.decks.is_empty():
		_topup_collection(state)
		state.decks = [default_deck(state.collection)]
		changed = true
	if ensure_core(state):
		changed = true
	return changed

static func grant_cards(state: SaveState, cards: Array) -> void:
	ensure_collection(state)
	for card in cards:
		state.collection.append(card.name)
		var deck := Deck.new(state.decks[state.active_deck])
		deck.add(card.name, state.collection)

static func set_offer(state: SaveState, source: String, cards: Array) -> void:
	var names: Array = []
	for c in cards:
		names.append(c.name)
	state.pending_offer = {"source": source, "cards": names}

static func offered_cards(state: SaveState) -> Array:
	return resolve(state.pending_offer["cards"]) if state.pending_offer != null and not state.pending_offer.is_empty() else []

static func pick_offer(state: SaveState, card_name: String) -> Variant:
	var offer: Variant = state.pending_offer
	if offer == null or offer.is_empty() or not (card_name in offer["cards"]):
		return null
	var card: Variant = null
	for c in offered_cards(state):
		if c.name == card_name:
			card = c
			break
	if card == null:
		return null
	grant_cards(state, [card])
	state.pending_offer = null
	return card

static func offer_boss_reward(state: SaveState, rng: PyRandom = null, boss_id: String = BOSS_ID) -> bool:
	if state.pending_offer != null and not state.pending_offer.is_empty():
		return false
	var cards := boss_offer(boss_id, rng)
	if cards.is_empty():
		return false
	set_offer(state, BOSS_SOURCE, cards)
	return true
