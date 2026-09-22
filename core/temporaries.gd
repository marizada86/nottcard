class_name Temporaries
extends RefCounted
## game/core/temporaries.py — cartas e itens temporários de evento (só desta tentativa).

const MAX_TEMP_CARDS := 2
const MAX_TEMP_ITEMS := 1

static func temp_items() -> Array:
	var items: Dictionary = GameData.module("items")
	return [items["LUPA"], items["FAIXA"]]

static func card_pool() -> Array:
	return Collection.pool(Collection.COMUM) + Collection.pool(Collection.INCOMUM)

static func pick_card(rng: PyRandom, exclude: Array = []) -> Card:
	var pool: Array = []
	for c in card_pool():
		if not (c.name in exclude):
			pool.append(c)
	return rng.choice(pool)

static func find_card(card_name: String) -> Variant:
	return Collection.card_catalog().get(card_name)

## Põe uma carta temporária no baralho de compra, embaralhada; null se o limite da missão acabou.
static func grant_card(player: Player, budget: TempBudget, rng: PyRandom, card_name: String = "") -> Variant:
	if not budget.can_card:
		return null
	var base: Variant = find_card(card_name) if (card_name != "" and card_name != "random") else pick_card(rng)
	if base == null:
		return null
	var card: Card = base.replace({"temporary": true})
	player.draw_pile.append(card)
	rng.shuffle(player.draw_pile)
	budget.cards += 1
	return card

## [item|null, coube]. [null, true] se o limite da missão acabou.
static func grant_item(player: Player, budget: TempBudget, rng: PyRandom, item_id: String = "") -> Array:
	if not budget.can_item:
		return [null, true]
	var items: Dictionary = GameData.module("items")["ITEMS"]
	var item: Variant = items.get(item_id) if (item_id != "" and item_id != "random") else rng.choice(temp_items())
	if item == null:
		return [null, true]
	budget.items += 1
	return [item, player.backpack.add(item)]
