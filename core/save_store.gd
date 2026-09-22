class_name SaveStore
extends RefCounted
## game/core/save_file.py (FileSaveStore) e progress.MemorySaveStore — o save em disco (user://nottcard/save.json), gravado de forma atômica.
## `directory` vazio = só memória (testes). Arquivo ilegível vira save.json.bak e o jogo segue com um save novo.

const SAVE_NAME := "save.json"
const BACKUP_NAME := "save.json.bak"
const DEFAULT_DIR := "user://nottcard"

var directory: String = ""
var warning: String = ""
var _state: SaveState = null

func _init(directory_: String = "") -> void:
	directory = directory_

static func fresh() -> SaveState:
	var s := SaveState.new()
	s.unlocked_characters = {}
	s.roster_rules = true
	return s

var path: String:
	get:
		return "%s/%s" % [directory, SAVE_NAME]

func load_state() -> SaveState:
	if _state == null:
		_state = _read() if directory != "" else SaveState.new()
	return _state

func save(state: SaveState) -> void:
	_state = state
	if directory != "":
		_write(state)

func clear() -> void:
	_state = fresh() if directory != "" else SaveState.new()
	if directory != "" and FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		if err != OK:
			warning = "Não foi possível apagar o save."

func _read() -> SaveState:
	if not FileAccess.file_exists(path):
		return fresh()
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		warning = "Não foi possível ler o save."
		return fresh()
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	var state: SaveState = null
	if parsed != null:
		state = SaveState.from_dict(GameData.hydrate(parsed))
	if state == null:
		_keep_backup()
		warning = "Save ilegível: guardado como save.json.bak. Começando um save novo."
		return fresh()
	return state

func _keep_backup() -> void:
	DirAccess.rename_absolute(path, "%s/%s" % [directory, BACKUP_NAME])

func _write(state: SaveState) -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		warning = "Não foi possível gravar o save."
		return
	f.store_string(JSON.stringify(state.to_dict(), "  ", false))
	f.close()
	DirAccess.rename_absolute(tmp, path)
