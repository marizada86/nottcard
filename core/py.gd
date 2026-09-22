class_name Py
extends RefCounted
## Auxiliares que reproduzem a semântica numérica/de texto do Python (a origem depende delas).

## a // b (piso, também para negativos).
static func fdiv(a: int, b: int) -> int:
	return floori(float(a) / float(b)) if (a % b != 0 and ((a < 0) != (b < 0))) else a / b

## a % b com o sinal do divisor (Python).
static func fmod(a: int, b: int) -> int:
	return a - fdiv(a, b) * b

## round() do Python 3: arredonda para o par em empates (0.5 → 0, 1.5 → 2, 2.5 → 2).
static func round_half_even(x: float) -> int:
	var f := floorf(x)
	var diff := x - f
	if diff < 0.5:
		return int(f)
	if diff > 0.5:
		return int(f) + 1
	return int(f) if int(f) % 2 == 0 else int(f) + 1

## f"{x:g}" simplificado para os casos do jogo (sem notação científica).
static func fmt_g(x: float) -> String:
	if x == floorf(x) and absf(x) < 1e15:
		return str(int(x))
	return String.num(snappedf(x, 0.000001))

static func sum(a: Array) -> float:
	var t := 0.0
	for v in a:
		t += v
	return t

static func sum_int(a: Array) -> int:
	var t := 0
	for v in a:
		t += int(v)
	return t

## Conjuntos do Python como Dictionary {valor: true}.
static func set_of(a: Array = []) -> Dictionary:
	var d := {}
	for v in a:
		d[v] = true
	return d

## sorted(set): lista ordenada das chaves.
static func set_sorted(s: Dictionary) -> Array:
	var keys := s.keys()
	keys.sort()
	return keys

static func is_int(v: Variant) -> bool:
	return (v is int) or (v is float and v == floorf(v))

## round(x, n) do Python (n casas), aproximado por round-half-even sobre x * 10^n.
static func round_n(x: float, n: int) -> float:
	var f := pow(10.0, n)
	return float(round_half_even(x * f)) / f

## math.ceil(round(x, 6)), o idioma usado nas fórmulas de dano para evitar ruído de ponto flutuante.
static func ceil6(x: float) -> int:
	return int(ceil(round_n(x, 6)))

## Conta ocorrências (collections.Counter): {valor: quantidade}.
static func counter(a: Array) -> Dictionary:
	var d := {}
	for v in a:
		d[v] = d.get(v, 0) + 1
	return d

## Compara dois valores/arrays como tuplas do Python (lexicográfico).
static func key_less(a: Variant, b: Variant) -> bool:
	if a is Array and b is Array:
		for i in range(mini(a.size(), b.size())):
			if a[i] != b[i]:
				return key_less(a[i], b[i])
		return a.size() < b.size()
	return a < b

## sorted(items, key=keyfn) estável. keyfn(item) -> valor ou Array (tupla).
static func sorted_by(items: Array, keyfn: Callable) -> Array:
	var deco: Array = []
	for i in range(items.size()):
		deco.append([keyfn.call(items[i]), i, items[i]])
	deco.sort_custom(func(x, y):
		if key_less(x[0], y[0]):
			return true
		if key_less(y[0], x[0]):
			return false
		return x[1] < y[1])
	var out: Array = []
	for d in deco:
		out.append(d[2])
	return out

## Ordena uma cópia (estável, como sorted do Python).
static func sorted_copy(a: Array) -> Array:
	var c := a.duplicate()
	c.sort()
	return c

## dataclasses.replace: cópia rasa de um objeto do core (RefCounted sem argumentos no _init) com campos trocados.
static func dc_replace(obj: Object, changes: Dictionary = {}) -> Object:
	var c: Object = obj.get_script().new()
	for p in obj.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var v = obj.get(p.name)
			if not (v is Callable):
				c.set(p.name, v)
	for k in changes:
		c.set(k, changes[k])
	return c
