class_name UiAssets
extends RefCounted
## game/ui/assets.py — cache de texturas e o retângulo de reserva quando a arte não existe (VSN-001 "pipeline de asset").

const FALLBACK_COLORS := {
	"cards": Color8(55, 55, 70), "enemies": Color8(70, 45, 45), "rooms": Color8(45, 60, 50), "portraits": Color8(55, 50, 65),
	"hud": Color8(50, 50, 55), "items": Color8(60, 55, 45), "dice": Color8(45, 45, 55),
}

static var _cache: Dictionary = {}

static func path_of(slug: String, categoria: String, pack: String = "") -> String:
	if pack != "":
		var packed := "res://assets/%s/%s/%s.png" % [categoria, pack, slug]
		if ResourceLoader.exists(packed):
			return packed
	return "res://assets/%s/%s.png" % [categoria, slug]

static func exists(slug: String, categoria: String) -> bool:
	return ResourceLoader.exists("res://assets/%s/%s.png" % [categoria, slug])

## A textura do asset, ou null se a arte ainda não existe.
static func texture(slug: String, categoria: String, pack: String = "") -> Texture2D:
	var key := "%s|%s|%s" % [categoria, pack, slug]
	if not _cache.has(key):
		var p := path_of(slug, categoria, pack)
		_cache[key] = load(p) if ResourceLoader.exists(p) else null
	return _cache[key]
