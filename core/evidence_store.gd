class_name EvidenceStore
extends RefCounted
## Rascunho persistente e exportação do pacote de evidências. Não conhece UI.

const DRAFT_DIR := "user://nottcard/evidence_drafts"
const EXPORT_FALLBACK_DIR := "user://nottcard/evidencias"
const MAX_IMAGES := 20
const MAX_IMAGE_BYTES := 8 * 1024 * 1024

var items: Array = []
var warning: String = ""

func _init() -> void:
	_load()

func image_count() -> int:
	return items.size()

func notes_count() -> int:
	var n := 0
	for item in items:
		if item.get("kind", "") == "note":
			n += 1
	return n

func prints_count() -> int:
	return image_count() - notes_count()

func image_bytes() -> int:
	var total := 0
	for item in items:
		total += int(item.get("bytes", 0))
	return total

func summary() -> String:
	return "%d nota%s · %d print%s" % [notes_count(), "s" if notes_count() != 1 else "", prints_count(), "s" if prints_count() != 1 else ""]

func near_limit() -> bool:
	return image_count() >= int(MAX_IMAGES * 0.8) or image_bytes() >= int(MAX_IMAGE_BYTES * 0.8)

func add_print(png: PackedByteArray, context: Dictionary) -> Dictionary:
	return _add("print", png, "", context)

func add_note(png: PackedByteArray, note: String, context: Dictionary) -> Dictionary:
	return _add("note", png, note, context)

func _add(kind: String, png: PackedByteArray, note: String, context: Dictionary) -> Dictionary:
	if png.is_empty():
		return {"ok": false, "error": "Não foi possível capturar a tela."}
	if image_count() >= MAX_IMAGES or image_bytes() + png.size() > MAX_IMAGE_BYTES:
		return {"ok": false, "error": "Pacote cheio: aperte F7 para gerar o ZIP."}
	var make_err := DirAccess.make_dir_recursive_absolute(DRAFT_DIR)
	if make_err != OK:
		return {"ok": false, "error": "Não foi possível guardar a evidência no disco."}
	var index := items.size() + 1
	var name := "%02d-%s.png" % [index, "nota" if kind == "note" else "print"]
	var path := DRAFT_DIR.path_join(name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "Não foi possível gravar o print."}
	file.store_buffer(png)
	file.close()
	var item := {
		"kind": kind,
		"file": name,
		"bytes": png.size(),
		"created_at": Time.get_datetime_string_from_system(false, true),
		"context": context.duplicate(true),
		"note": scrub(note),
	}
	items.append(item)
	if not _write_manifest():
		items.pop_back()
		DirAccess.remove_absolute(path)
		return {"ok": false, "error": "Não foi possível atualizar o rascunho de evidências."}
	return {"ok": true, "item": item, "near_limit": near_limit()}

func clear() -> bool:
	var dir := DirAccess.open(DRAFT_DIR)
	if dir != null:
		for file_name in dir.get_files():
			var err := dir.remove(file_name)
			if err != OK:
				warning = "Não foi possível limpar o rascunho de evidências."
				return false
	items = []
	warning = ""
	return true

func export_bundle(tester_name: String, version: String, state: Dictionary, log_text: String) -> Dictionary:
	if items.is_empty():
		return {"ok": false, "empty": true, "error": "Não há evidência a ser enviada."}
	var filename := "EV-%s-%s.zip" % [_safe_name(tester_name), Time.get_datetime_string_from_system(false, true).replace("-", "").replace(":", "").replace("T", "-")]
	var target := _preferred_export_dir()
	var result := _write_zip(target.path_join(filename), tester_name, version, state, log_text)
	if not result.ok:
		target = EXPORT_FALLBACK_DIR
		result = _write_zip(target.path_join(filename), tester_name, version, state, log_text)
	if not result.ok:
		return result
	var exported_notes := notes_count()
	var exported_prints := prints_count()
	if not clear():
		return {"ok": false, "error": "O ZIP foi criado, mas o rascunho não pôde ser limpo: %s" % result.path}
	return {"ok": true, "path": result.path, "filename": filename, "notes": exported_notes, "prints": exported_prints}

func _write_zip(path: String, tester_name: String, version: String, state: Dictionary, log_text: String) -> Dictionary:
	var folder := path.get_base_dir()
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return {"ok": false, "error": "A pasta de evidências não aceita gravação."}
	var zip := ZIPPacker.new()
	if zip.open(path) != OK:
		return {"ok": false, "error": "Não foi possível criar o ZIP de evidências."}
	var public_items: Array = []
	for i in range(items.size()):
		var item: Dictionary = items[i]
		public_items.append({"number": i + 1, "kind": item.kind, "created_at": item.created_at, "file": "prints/%s" % item.file, "context": item.context})
	var info := {"tester": scrub(tester_name), "version": version, "exported_at": Time.get_datetime_string_from_system(false, true), "items": public_items, "notes": notes_count(), "prints": prints_count()}
	if not _zip_text(zip, "info.json", JSON.stringify(info, "  ")) or not _zip_text(zip, "estado.json", JSON.stringify(state, "  ")) or not _zip_text(zip, "log.txt", scrub(log_text)):
		zip.close()
		return {"ok": false, "error": "Não foi possível gravar os dados do ZIP."}
	var notes := _notes_markdown()
	if notes != "" and not _zip_text(zip, "notas.md", notes):
		zip.close()
		return {"ok": false, "error": "Não foi possível gravar as notas no ZIP."}
	for item in items:
		var file := FileAccess.open(DRAFT_DIR.path_join(item.file), FileAccess.READ)
		if file == null:
			zip.close()
			return {"ok": false, "error": "Um print do rascunho não foi encontrado."}
		var bytes := file.get_buffer(file.get_length())
		file.close()
		if zip.start_file("prints/%s" % item.file) != OK or zip.write_file(bytes) != OK or zip.close_file() != OK:
			zip.close()
			return {"ok": false, "error": "Não foi possível gravar um print no ZIP."}
	if zip.close() != OK:
		return {"ok": false, "error": "Não foi possível finalizar o ZIP."}
	return {"ok": true, "path": path}

func _zip_text(zip: ZIPPacker, path: String, text: String) -> bool:
	return zip.start_file(path) == OK and zip.write_file(text.to_utf8_buffer()) == OK and zip.close_file() == OK

func _notes_markdown() -> String:
	var out: Array = []
	var number := 0
	for item in items:
		if item.kind != "note":
			continue
		number += 1
		out.append("## Nota %d — %s" % [number, item.created_at])
		out.append("Contexto: %s" % JSON.stringify(item.context))
		out.append("")
		out.append(item.note)
		out.append("")
	return "\n".join(out)

func _load() -> void:
	items = []
	var file := FileAccess.open(DRAFT_DIR.path_join("manifest.json"), FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or not (parsed.get("items", []) is Array):
		warning = "O rascunho de evidências não pôde ser lido."
		return
	for raw in parsed.items:
		if raw is Dictionary and raw.get("file", "") is String and FileAccess.file_exists(DRAFT_DIR.path_join(raw.file)):
			items.append(raw)

func _write_manifest() -> bool:
	var tmp := DRAFT_DIR.path_join("manifest.json.tmp")
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"items": items}, "  "))
	file.close()
	if FileAccess.file_exists(DRAFT_DIR.path_join("manifest.json")):
		DirAccess.remove_absolute(DRAFT_DIR.path_join("manifest.json"))
	return DirAccess.rename_absolute(tmp, DRAFT_DIR.path_join("manifest.json")) == OK

func _preferred_export_dir() -> String:
	if OS.has_feature("editor"):
		return EXPORT_FALLBACK_DIR
	return OS.get_executable_path().get_base_dir().path_join("evidencias")

static func scrub(text: String) -> String:
	var out := text
	var home := OS.get_user_data_dir()
	if home != "":
		out = out.replace(home, "<dados-do-jogo>")
	var users := RegEx.new()
	users.compile("(?i)[A-Z]:\\\\Users\\\\[^\\\\/\\s]+")
	return users.sub(out, "<usuário>", true)

static func _safe_name(value: String) -> String:
	var clean := value.strip_edges().to_lower()
	var rx := RegEx.new()
	rx.compile("[^a-z0-9_-]+")
	clean = rx.sub(clean, "-", true).strip_edges()
	return clean if clean != "" else "tester"
