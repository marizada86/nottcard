class_name Cards
extends RefCounted
## game/core/cards.py — o catálogo de cartas (dados exportados) e os baralhos iniciais.

static func c(const_name: String) -> Variant:
	return GameData.module("cards")[const_name]

static func starting_deck() -> Array:
	return GameData.module("cards")["@build_starting_deck"].duplicate()

static func maelor_deck() -> Array:
	return GameData.module("cards")["@build_maelor_deck"].duplicate()

static func sylas_deck() -> Array:
	return GameData.module("cards")["@build_sylas_deck"].duplicate()

static func kayron_deck() -> Array:
	return GameData.module("cards")["@build_kayron_deck"].duplicate()

static func brook_deck() -> Array:
	return GameData.module("cards")["@build_brook_deck"].duplicate()
