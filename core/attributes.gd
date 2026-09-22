class_name Attributes
extends RefCounted
## game/core/attributes.py — modificador = piso((valor - 10) / 2).

static func modifier(value: int) -> int:
	return Py.fdiv(value - 10, 2)

static func armor_class(attrs: Dictionary) -> int:
	return 10 + modifier(attrs["forca"])

static func magic_armor_class(attrs: Dictionary) -> int:
	return 10 + modifier(attrs["inteligencia"])

static func durvall() -> Dictionary: return GameData.module("attributes")["DURVALL_ATTRIBUTES"].duplicate()
static func maelor() -> Dictionary: return GameData.module("attributes")["MAELOR_ATTRIBUTES"].duplicate()
static func sylas() -> Dictionary: return GameData.module("attributes")["SYLAS_ATTRIBUTES"].duplicate()
static func kayron() -> Dictionary: return GameData.module("attributes")["KAYRON_ATTRIBUTES"].duplicate()
static func brook() -> Dictionary: return GameData.module("attributes")["BROOK_ATTRIBUTES"].duplicate()

static func color_attribute(color: String) -> String:
	return GameData.module("attributes")["COLOR_ATTRIBUTE"][color]
