class_name Golden
extends RefCounted
## Carrega vetores de paridade gerados por tools/gen_golden.py e compara valores.

static func load_json(name: String) -> Variant:
	var f := FileAccess.open("res://tests/golden/%s.json" % name, FileAccess.READ)
	if f == null:
		return null
	return JSON.parse_string(f.get_as_text())

## "" se igual; senão a descrição da diferença. Floats com tolerância relativa (o JSON do Godot não garante ida e volta exata).
static func diff(actual: Variant, expected: Variant, path: String = "", eps: float = 1e-12) -> String:
	if expected is Array:
		if not (actual is Array) or actual.size() != expected.size():
			return "%s: tamanho/tipo diferente (%s vs %s)" % [path, str(actual), str(expected)]
		for i in range(expected.size()):
			var d := diff(actual[i], expected[i], "%s[%d]" % [path, i], eps)
			if d != "":
				return d
		return ""
	if expected is Dictionary:
		for k in expected:
			if not (actual is Dictionary) or not actual.has(k):
				return "%s.%s ausente" % [path, k]
			var d := diff(actual[k], expected[k], "%s.%s" % [path, k], eps)
			if d != "":
				return d
		return ""
	if expected is float or actual is float:
		var a := float(actual)
		var e := float(expected)
		return "" if absf(a - e) <= eps * maxf(1.0, absf(e)) else "%s: %s != %s" % [path, a, e]
	return "" if str(actual) == str(expected) else "%s: %s != %s" % [path, str(actual), str(expected)]

## Converte um objeto do core (RefCounted com script) em Dictionary/Array/valores simples, para comparar com o `plain()` do Python.
## Cartas viram o nome; propriedades computadas (total, crit, hit, ...) entram porque o GDScript as lista como variáveis de script.
static func plain(x: Variant) -> Variant:
	if x == null:
		return null
	if x is Card:
		return x.name
	if x is ItemDef:
		return x.id
	if x is Array:
		var a: Array = []
		for v in x:
			a.append(plain(v))
		return a
	if x is Dictionary:
		var d := {}
		for k in x:
			d[str(k)] = plain(x[k])
		return d
	if x is Object:
		var out := {}
		for p in x.get_property_list():
			if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not String(p.name).begins_with("_"):
				var v: Variant = x.get(p.name)
				if v is Callable:
					continue
				out[p.name] = plain(v)
		return out
	return x
