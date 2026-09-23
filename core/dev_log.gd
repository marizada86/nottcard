class_name DevLog
extends RefCounted
## Buffer de diagnóstico exportável. Não executa comandos nem altera regras.

const MAX_LINES := 300

var lines: Array = []
var visible: bool = false
var commands_tab: bool = false

func add(text: String) -> void:
	var stamp := Time.get_time_string_from_system()
	lines.append("[%s] %s" % [stamp, text])
	if lines.size() > MAX_LINES:
		lines = lines.slice(lines.size() - MAX_LINES)

func recent(limit: int = 200) -> Array:
	return lines.slice(maxi(0, lines.size() - limit))

func export_text() -> String:
	return "\n".join(recent())
