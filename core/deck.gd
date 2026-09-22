class_name Deck
extends RefCounted
## game/core/collection.py::Deck — nomes de cartas da coleção, até DECK_CAP; o núcleo fica travado.
## `names` é a MESMA lista do save (o Python também compartilha a referência).

var names: Array = []

func _init(names_: Array = []) -> void:
	names = names_

func size() -> int:
	return names.size()

var full: bool:
	get:
		return names.size() >= Collection.DECK_CAP

func locked(card_name: String) -> bool:
	return names.count(card_name) <= Collection.core_counts().get(card_name, 0)

func add(card_name: String, collection: Array) -> bool:
	if full or names.count(card_name) >= Py.counter(collection).get(card_name, 0):
		return false
	names.append(card_name)
	return true

func remove(card_name: String) -> bool:
	if not (card_name in names) or locked(card_name):
		return false
	names.remove_at(names.find(card_name))
	return true

func swap(out_name: String, in_name: String, collection: Array) -> bool:
	if not (out_name in names) or locked(out_name):
		return false
	var index := names.find(out_name)
	names.remove_at(index)
	if add(in_name, collection):
		return true
	names.insert(index, out_name)
	return false
