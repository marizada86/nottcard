class_name CharacterDefs
extends RefCounted
## Catálogo de personagens jogáveis (characters.CHARACTERS): id → CharacterDef, na ordem da origem.

static func all() -> Dictionary:
	return GameData.module("characters")["CHARACTERS"]

static func get_def(character_id: String) -> CharacterDef:
	return all()[character_id]

static func durvall() -> CharacterDef:
	return all()["durvall"]

static func attribute_names() -> Dictionary:
	return GameData.module("characters")["ATTRIBUTE_NAMES"]
