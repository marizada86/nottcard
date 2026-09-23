class_name BuildConfig
extends RefCounted
## Recursos de playtest são parte da build, nunca uma preferência salva do jogador.

static func playtest_enabled() -> bool:
	return OS.is_debug_build() or OS.has_feature("playtest") or OS.has_feature("qa")

## Exports de QA são builds de depuração. Exports públicos devem usar release.
static func qa_tools_enabled() -> bool:
	return OS.has_feature("qa") or (OS.is_debug_build() and not OS.has_feature("release"))

static func production_build() -> bool:
	return not playtest_enabled()
