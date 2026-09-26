class_name SaveStore
extends RefCounted
## game/core/save_file.py (FileSaveStore) e progress.MemorySaveStore — o save em disco (user://nottcard/save.json), gravado de forma atômica.
## `directory` vazio = só memória (testes). Arquivo ilegível vira save.json.bak e o jogo segue com um save novo.

const SAVE_NAME := "save.json"
const BACKUP_NAME := "save.json.bak"
const REPLACE_BACKUP_NAME := "save.json.replace.bak"
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

func save(state: SaveState) -> bool:
	_state = state
	if directory != "":
		return _write(state)
	return true

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

func _write(state: SaveState) -> bool:
	warning = ""
	var mkdir_err := DirAccess.make_dir_recursive_absolute(directory)
	if mkdir_err != OK:
		warning = "Não foi possível preparar a pasta do save."
		return false
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		warning = "Não foi possível gravar o save."
		return false
	f.store_string(JSON.stringify(state.to_dict(), "  ", false))
	f.close()
	var replace_backup := "%s/%s" % [directory, REPLACE_BACKUP_NAME]
	DirAccess.remove_absolute(replace_backup)
	var had_previous := FileAccess.file_exists(path)
	if had_previous:
		var preserve_err := DirAccess.rename_absolute(path, replace_backup)
		if preserve_err != OK:
			DirAccess.remove_absolute(tmp)
			warning = "Não foi possível substituir o save existente; o anterior foi preservado."
			return false
	var replace_err := DirAccess.rename_absolute(tmp, path)
	if replace_err != OK:
		if had_previous:
			DirAccess.rename_absolute(replace_backup, path)
		DirAccess.remove_absolute(tmp)
		warning = "Não foi possível finalizar a gravação do save; o estado anterior foi restaurado."
		return false
	if had_previous:
		DirAccess.remove_absolute(replace_backup)
	return true
