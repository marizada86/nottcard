extends SceneTree
## Auditoria reproduzível dos assets declarados nos JSONs do Godot.
## Uso: godot --headless --path . -s res://tools/audit_assets.gd

const JSON_DIR := "res://data/core"
const DIRECT_CATEGORIES := ["cards", "enemies", "items", "portraits", "screens", "hud", "hq", "doors"]

var asset_ids: Dictionary = {}
var hq_images: Dictionary = {}

func _initialize() -> void:
	var dir := DirAccess.open(JSON_DIR)
	if dir == null:
		printerr("Não foi possível abrir " + JSON_DIR)
		quit(2)
		return
	for filename in dir.get_files():
		if filename.ends_with(".json"):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(JSON_DIR.path_join(filename)))
			if parsed == null:
				printerr("JSON inválido: " + filename)
				quit(2)
				return
			_collect(parsed)
	var missing: Array[String] = []
	for asset_id_variant in asset_ids.keys():
		var asset_id: String = asset_id_variant
		if not _exists_asset(asset_id):
			missing.append("asset_id: " + asset_id)
	for image_variant in hq_images.keys():
		var image: String = image_variant
		var path: String = "res://assets/hq/%s.png" % image
		if not ResourceLoader.exists(path):
			missing.append("hq: " + path)
	missing.sort()
	print("# Auditoria de assets do Godot")
	print("")
	print("- asset_id declarados: %d" % asset_ids.size())
	print("- imagens de HQ declaradas: %d" % hq_images.size())
	print("- faltantes: %d" % missing.size())
	for entry in missing:
		print("- " + entry)
	quit(1 if not missing.is_empty() else 0)

func _collect(value: Variant) -> void:
	if value is Dictionary:
		for key in value:
			var child: Variant = value[key]
			if key == "asset_id" and child is String and child != "":
				asset_ids[child] = true
			elif key == "image" and child is String and child != "":
				hq_images[child] = true
			_collect(child)
	elif value is Array:
		for child in value:
			_collect(child)

func _exists_asset(asset_id: String) -> bool:
	var room_dir := "res://assets/rooms/" + asset_id
	if ResourceLoader.exists(room_dir.path_join("bg.png")) and ResourceLoader.exists(room_dir.path_join("fg.png")):
		return true
	for category in DIRECT_CATEGORIES:
		if ResourceLoader.exists("res://assets/%s/%s.png" % [category, asset_id]):
			return true
	return false
