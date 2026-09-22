class_name Scrolls
extends RefCounted
## game/core/scrolls.py — pergaminhos: cartas temporárias de uso único. `state` é um SaveState.

const SCROLL_CAP := 3
const OFFER_SIZE := 3
const SCROLL_SOURCE := "pergaminho"
const TIERS := [1, 2, 3]

static func all() -> Array:
	return GameData.module("scrolls")["SCROLLS"]

static func by_id(sid: String) -> Variant:
	return GameData.module("scrolls")["BY_ID"].get(sid)

static func by_card_name(card_name: String) -> Variant:
	return GameData.module("scrolls")["BY_CARD_NAME"].get(card_name)

static func scrolls_of_tier(tier: int) -> Array:
	var out: Array = []
	for s in all():
		if s.tier == tier:
			out.append(s)
	return out

static func offer(tier: int, rng: PyRandom = null) -> Array:
	var r := rng if rng != null else PyRandom.new()
	var pool := scrolls_of_tier(tier)
	if pool.is_empty():
		pool = scrolls_of_tier(TIERS[0])
	return r.sample(pool, mini(OFFER_SIZE, pool.size()))

## A carta de um pergaminho pelo id ou pelo nome da carta; null se desconhecido.
static func card_of(name_or_id: String) -> Variant:
	var s = by_id(name_or_id)
	if s == null:
		s = by_card_name(name_or_id)
	return s.card if s != null else null

static func stock_of(state: SaveState, character_id: String) -> Array:
	if not state.scrolls.has(character_id):
		state.scrolls[character_id] = []
	return state.scrolls[character_id]

static func stock_cards(state: SaveState, character_id: String) -> Array:
	var out: Array = []
	for i in stock_of(state, character_id):
		var c = card_of(i)
		if c != null:
			out.append(c)
	return out

static func is_full(state: SaveState, character_id: String) -> bool:
	return stock_of(state, character_id).size() >= SCROLL_CAP

static func add(state: SaveState, character_id: String, scroll_id: String) -> bool:
	if by_id(scroll_id) == null or is_full(state, character_id):
		return false
	stock_of(state, character_id).append(scroll_id)
	return true

static func consume(state: SaveState, character_id: String, card: Card) -> bool:
	var s = by_card_name(card.name)
	var stock := stock_of(state, character_id)
	if s == null or not (s.id in stock):
		return false
	stock.remove_at(stock.find(s.id))
	return true

static func replace_scroll(state: SaveState, character_id: String, drop_id: String, new_id: String) -> bool:
	var stock := stock_of(state, character_id)
	if not (drop_id in stock) or by_id(new_id) == null:
		return false
	stock.remove_at(stock.find(drop_id))
	stock.append(new_id)
	return true

## Derrota ou desistência: o estoque de todos se perde. Devolve os nomes perdidos.
static func clear_all(state: SaveState) -> Array:
	var lost: Array = []
	for cid in state.scrolls:
		for i in state.scrolls[cid]:
			var s = by_id(i)
			if s != null:
				lost.append(s.name)
	state.scrolls = {}
	return lost

static func total_stock(state: SaveState) -> int:
	var t := 0
	for cid in state.scrolls:
		t += state.scrolls[cid].size()
	return t

## Quem tem menos guardados (o 1º, no empate).
static func recipient(state: SaveState, character_ids: Array) -> String:
	var best := ""
	var best_count := -1
	for cid in character_ids:
		var n := stock_of(state, cid).size()
		if best_count < 0 or n < best_count:
			best = cid
			best_count = n
	return best

static func set_offer(state: SaveState, character_id: String, scrolls: Array) -> void:
	var names: Array = []
	for s in scrolls:
		names.append(s.card.name)
	state.pending_offer = {"source": SCROLL_SOURCE, "cards": names, "for": character_id}

static func offered_cards(state: SaveState) -> Array:
	var data: Variant = state.pending_offer
	if data == null or data.get("source") != SCROLL_SOURCE:
		return []
	var out: Array = []
	for n in data["cards"]:
		var c = card_of(n)
		if c != null:
			out.append(c)
	return out

## "added" | "full" | "" (nada mudou)
static func pick(state: SaveState, card_name: String) -> String:
	var data: Variant = state.pending_offer
	if data == null or data.get("source") != SCROLL_SOURCE or not (card_name in data["cards"]):
		return ""
	var s = by_card_name(card_name)
	if s == null:
		return ""
	if add(state, data["for"], s.id):
		state.pending_offer = null
		return "added"
	data["chosen"] = s.id
	return "full"

static func swap_pending(state: SaveState, drop_id: String) -> bool:
	var data: Variant = state.pending_offer
	if data == null or not data.has("chosen"):
		return false
	if not replace_scroll(state, data["for"], drop_id, data["chosen"]):
		return false
	state.pending_offer = null
	return true

static func decline_pending(state: SaveState) -> bool:
	if state.pending_offer == null or state.pending_offer.get("source") != SCROLL_SOURCE:
		return false
	state.pending_offer = null
	return true
