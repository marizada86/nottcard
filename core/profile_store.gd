class_name ProfileStore
extends RefCounted
## game/core/profile.py (FileProfileStore) — nome do jogador e opções (câmera, FPS, tremulação, movimento suave, playtester) em perfil.json.

const PROFILE_NAME := "perfil.json"
const MIN_NAME := 2
const MAX_NAME := 24
const FPS_CHOICES := [30, 60]
const FPS_DEFAULT := 60

var directory: String = ""
var warning: String = ""
var persisted: bool = true
var welcomed: Array = []
var reduce_motion: bool = false
var playtester: bool = false
var fps_cap: int = FPS_DEFAULT
var torch_flicker: bool = true
var walk_bob: bool = true
var name: String = ""

func _init(directory_: String = "") -> void:
	directory = directory_
	if directory != "":
		name = _read()

static func clean_fps(value: Variant) -> int:
	return int(value) if (Py.is_int(value) and int(value) in FPS_CHOICES) else FPS_DEFAULT

## [nome aparado, motivo do erro]; erro vazio = válido.
static func validate_name(text: String) -> Array:
	var ws := RegEx.new()
	ws.compile("\\s+")
	var cleaned := ws.sub(text.strip_edges(), " ", true)
	if cleaned.length() < MIN_NAME:
		return [cleaned, "Digite pelo menos %d caracteres." % MIN_NAME]
	if cleaned.length() > MAX_NAME:
		return [cleaned, "No máximo %d caracteres (agora são %d)." % [MAX_NAME, cleaned.length()]]
	var rx := RegEx.new()
	rx.compile("[^\\p{L}\\p{N}_ .\\-]")
	var bad := {}
	for m in rx.search_all(cleaned):
		bad[m.get_string()] = true
	if not bad.is_empty():
		var keys := bad.keys()
		keys.sort()
		return [cleaned, "Só letras, números, espaço, ponto, hífen e sublinhado (não vale: %s)." % " ".join(keys)]
	return [cleaned, ""]

var path: String:
	get:
		return "%s/%s" % [directory, PROFILE_NAME]

func _read() -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var data: Variant = JSON.parse_string(f.get_as_text())
	if not (data is Dictionary):
		return ""
	var seen: Variant = data.get("boas_vindas", [])
	welcomed = []
	if seen is Array:
		for n in seen:
			welcomed.append(str(n))
	reduce_motion = data.get("reduzir_movimento") == true
	playtester = data.get("playtester") == true
	fps_cap = clean_fps(data.get("fps"))
	torch_flicker = data.get("tremulacao") != false
	walk_bob = data.get("movimento_suave") != false
	if not data.has("nome"):
		return ""
	var v := validate_name(str(data["nome"]))
	return "" if v[1] != "" else v[0]

func save_name(new_name: String) -> bool:
	name = new_name
	return _write("o nome")

var welcome_seen: bool:
	get:
		return name in welcomed

func mark_welcome_seen() -> void:
	if name != "" and not (name in welcomed):
		welcomed.append(name)
		_write("o aviso de boas-vindas")

func set_reduce_motion(value: bool) -> void:
	reduce_motion = value
	if name != "": _write("a opção de movimento")

func set_fps_cap(value: int) -> void:
	fps_cap = clean_fps(value)
	if name != "": _write("os quadros por segundo")

func set_walk_bob(value: bool) -> void:
	walk_bob = value
	if name != "": _write("o movimento suave")

func set_torch_flicker(value: bool) -> void:
	torch_flicker = value
	if name != "": _write("a tremulação da luz")

func set_playtester(value: bool) -> void:
	playtester = value
	if name != "": _write("o modo playtester")

func _write(what: String) -> bool:
	if directory == "":
		return true
	DirAccess.make_dir_recursive_absolute(directory)
	var data := {"nome": name, "boas_vindas": welcomed}
	if reduce_motion: data["reduzir_movimento"] = true
	if playtester: data["playtester"] = true
	if fps_cap != FPS_DEFAULT: data["fps"] = fps_cap
	if not torch_flicker: data["tremulacao"] = false
	if not walk_bob: data["movimento_suave"] = false
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		persisted = false
		warning = "Não foi possível guardar %s; vale só nesta sessão." % what
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	DirAccess.rename_absolute(tmp, path)
	persisted = true
	return true
