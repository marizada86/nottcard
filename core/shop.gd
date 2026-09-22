class_name Shop
extends RefCounted
## game/core/shop.py — loja e títulos: valida título, saldo, teto e duplicidade; debita e entrega.

const CLASSIC_LAYOUT := "classico"
const LAYOUT := "layout"
const UPGRADE := "upgrade"
const EQUIPAMENTO := "equipamento"
const PERSONAGEM := "personagem"
const LEGACY_LAYOUT_PRICES := {"pergaminho": 100, "obsidiana": 100, "recorte": 100, "bosque": 100, "gelo": 100, "neon": 200, "vitral": 200, "ferro": 200, "brasa": 200}
const REFUND_SECOND_DECK := 500
const REFUND_PACK := 100
const LEGACY_SECOND_DECK_ID := "baralho_2"

## Upgrades, depois equipamento, personagens e layouts (a ordem da origem).
static func items() -> Array:
	return GameData.module("shop")["SHOP_ITEMS"]

static func by_id(item_id: String) -> Variant:
	for i in items():
		if i.id == item_id:
			return i
	return null

static func titles_of(state: SaveState) -> Dictionary:
	return state.achievements.duplicate()

static func items_for_title(title_id: String) -> Array:
	var out: Array = []
	for i in items():
		if i.titulo_requerido == title_id:
			out.append(i)
	return out

static func item_for_title(title_id: String) -> Variant:
	var l := items_for_title(title_id)
	return l[0] if not l.is_empty() else null

static func owns(state: SaveState, item_id: String) -> bool:
	var item = by_id(item_id)
	if item != null and item.tipo == PERSONAGEM:
		return Roster.has_character(state, item_id)
	return state.owned.has(item_id)

static func owned_layouts(state: SaveState) -> Array:
	return LayoutUnlocks.owned_layouts(state)

static func level_of(state: SaveState, item: ShopItem) -> int:
	return Upgrades.level(state.upgrades, item.id) if item.tipo == UPGRADE else 0

## O preço de agora; -1 no teto do upgrade (a origem devolve None).
static func price(state: SaveState, item: ShopItem) -> int:
	return Upgrades.cost_of_next(state.upgrades, item.id) if item.tipo == UPGRADE else item.preco

static func can_afford(state: SaveState, item: ShopItem) -> bool:
	var cost := price(state, item)
	return cost >= 0 and state.coins >= cost

static func missing_coins(state: SaveState, item: ShopItem) -> int:
	var cost := price(state, item)
	return 0 if cost < 0 else maxi(0, cost - state.coins)

## "ok" | "possuido" | "maximo" | "titulo" | "saldo"
static func availability(state: SaveState, item: ShopItem) -> String:
	if item.tipo == UPGRADE:
		if Upgrades.is_maxed(state.upgrades, item.id):
			return "maximo"
	elif item.tipo != EQUIPAMENTO and owns(state, item.id):
		return "possuido"
	if item.tipo == PERSONAGEM:
		if not Roster.can_buy(state, item.id):
			return "titulo"
	if item.titulo_requerido != null and item.titulo_requerido != "" and not titles_of(state).has(item.titulo_requerido):
		return "titulo"
	if not can_afford(state, item):
		return "saldo"
	return "ok"

static func _purchase(ok: bool, reason: String = "", item: Variant = null, level: int = 0) -> Purchase:
	var p := Purchase.new()
	p.ok = ok
	p.reason = reason
	p.item = item
	p.level = level
	return p

static func buy(state: SaveState, item_id: String) -> Purchase:
	var item = by_id(item_id)
	if item == null:
		return _purchase(false, "desconhecido")
	var status := availability(state, item)
	if status != "ok":
		return _purchase(false, status, item)
	state.coins -= price(state, item)
	if item.tipo == UPGRADE:
		state.upgrades[item.id] = Upgrades.level(state.upgrades, item.id) + 1
		return _purchase(true, "", item, state.upgrades[item.id])
	if item.tipo == PERSONAGEM:
		Roster.unlock(state, item.id)
		return _purchase(true, "", item)
	if item.tipo == EQUIPAMENTO:
		Equipment.add_unit(state, item.id)
		return _purchase(true, "", item)
	state.owned[item.id] = true
	return _purchase(true, "", item)

static func migrate_removed_items(state: SaveState) -> bool:
	var changed := false
	for layout_id in LEGACY_LAYOUT_PRICES:
		if state.owned.has(layout_id):
			state.owned.erase(layout_id)
			state.coins += LEGACY_LAYOUT_PRICES[layout_id]
			changed = true
	if state.owned.has(LEGACY_SECOND_DECK_ID):
		state.owned.erase(LEGACY_SECOND_DECK_ID)
		state.coins += REFUND_SECOND_DECK
		changed = true
	if state.decks.size() > 1:
		state.decks = state.decks.slice(0, 1)
		state.active_deck = 0
		changed = true
	if state.pending_offer != null and not state.pending_offer.is_empty() and state.pending_offer.get("source") == "pacote":
		state.pending_offer = null
		state.coins += REFUND_PACK
		changed = true
	return changed

static func grant_everything(state: SaveState) -> void:
	for item in items():
		if item.tipo == PERSONAGEM:
			Roster.unlock(state, item.id)
		elif item.tipo == EQUIPAMENTO:
			Equipment.add_unit(state, item.id, maxi(0, 5 - Equipment.units(state, item.id)))
		elif item.unique:
			state.owned[item.id] = true
	LayoutUnlocks.unlock_all(state)
