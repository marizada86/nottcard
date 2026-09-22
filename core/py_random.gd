class_name PyRandom
extends RefCounted
## Réplica bit a bit do `random.Random` do CPython 3.14 (Mersenne Twister MT19937).
## Com a mesma semente, produz a mesma sequência do Python — base dos testes de paridade (SPEC-002).
## Espelha: seed(int), random, getrandbits, randbelow, randint, randrange, choice, choices, shuffle, sample, uniform, gauss.

const N := 624
const M := 397
const MASK32 := 0xFFFFFFFF

## Instância global, equivalente às funções do módulo `random` (o core da origem as usa sem semente).
static var shared: PyRandom = PyRandom.new()

var _mt: PackedInt64Array = PackedInt64Array()
var _index: int = N + 1
var _gauss_next: Variant = null

func _init(seed_value: Variant = null) -> void:
	_mt.resize(N)
	if seed_value == null:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		seed_int(rng.randi())
	else:
		seed_int(int(seed_value))

func seed_int(seed_value: int) -> void:
	var key: Array[int] = []
	var a: int = absi(seed_value)
	if a == 0:
		key.append(0)
	while a > 0:
		key.append(a & MASK32)
		a >>= 32
	_init_by_array(key)
	_gauss_next = null

func _init_genrand(s: int) -> void:
	_mt[0] = s & MASK32
	for i in range(1, N):
		var prev: int = _mt[i - 1]
		_mt[i] = (1812433253 * (prev ^ (prev >> 30)) + i) & MASK32
	_index = N

func _init_by_array(key: Array[int]) -> void:
	_init_genrand(19650218)
	var i := 1
	var j := 0
	var klen := key.size()
	for _k in range(maxi(N, klen)):
		var prev: int = _mt[i - 1]
		_mt[i] = ((_mt[i] ^ ((prev ^ (prev >> 30)) * 1664525)) + key[j] + j) & MASK32
		i += 1
		j += 1
		if i >= N:
			_mt[0] = _mt[N - 1]
			i = 1
		if j >= klen:
			j = 0
	for _k in range(N - 1):
		var prev2: int = _mt[i - 1]
		_mt[i] = ((_mt[i] ^ ((prev2 ^ (prev2 >> 30)) * 1566083941)) - i) & MASK32
		i += 1
		if i >= N:
			_mt[0] = _mt[N - 1]
			i = 1
	_mt[0] = 0x80000000
	_index = N

func _genrand_uint32() -> int:
	if _index >= N:
		for kk in range(N):
			var y: int = (_mt[kk] & 0x80000000) | (_mt[(kk + 1) % N] & 0x7FFFFFFF)
			var v: int = _mt[(kk + M) % N] ^ (y >> 1)
			if y & 1:
				v ^= 0x9908B0DF
			_mt[kk] = v
		_index = 0
	var x: int = _mt[_index]
	_index += 1
	x ^= x >> 11
	x ^= (x << 7) & 0x9D2C5680
	x ^= (x << 15) & 0xEFC60000
	x ^= x >> 18
	return x & MASK32

func random() -> float:
	var a: int = _genrand_uint32() >> 5
	var b: int = _genrand_uint32() >> 6
	return (a * 67108864.0 + b) * (1.0 / 9007199254740992.0)

func getrandbits(k: int) -> int:
	if k <= 32:
		return _genrand_uint32() >> (32 - k)
	# k > 32 (até 63 bits): palavras little-endian, a última é encurtada
	var words := (k - 1) / 32 + 1
	var result := 0
	var remaining := k
	for w in range(words):
		var r: int = _genrand_uint32()
		if remaining < 32:
			r >>= 32 - remaining
		result |= r << (32 * w)
		remaining -= 32
	return result

func randbelow(n: int) -> int:
	assert(n > 0)
	var k := 64 - _clz64(n)   # n.bit_length()
	var r := getrandbits(k)
	while r >= n:
		r = getrandbits(k)
	return r

static func _clz64(n: int) -> int:
	var c := 0
	var bit := 63
	while bit >= 0 and ((n >> bit) & 1) == 0:
		c += 1
		bit -= 1
	return c

func randint(a: int, b: int) -> int:
	return a + randbelow(b - a + 1)

func randrange(start: int, stop: int = -0x7FFFFFFFFFFFFFFF, step: int = 1) -> int:
	if stop == -0x7FFFFFFFFFFFFFFF:
		return randbelow(start)
	var width := stop - start
	if step == 1:
		return start + randbelow(width)
	var n: int
	if step > 0:
		n = (width + step - 1) / step
	else:
		n = floori(float(width + step + 1) / float(step))
	return start + step * randbelow(n)

func choice(seq: Array) -> Variant:
	return seq[randbelow(seq.size())]

func shuffle(x: Array) -> void:
	for i in range(x.size() - 1, 0, -1):
		var j := randbelow(i + 1)
		var tmp = x[i]
		x[i] = x[j]
		x[j] = tmp

func sample(population: Array, k: int) -> Array:
	var n := population.size()
	var result: Array = []
	result.resize(k)
	var setsize := 21
	if k > 5:
		setsize += int(pow(4, ceili(log(k * 3) / log(4))))
	if n <= setsize:
		var pool: Array = population.duplicate()
		for i in range(k):
			var j := randbelow(n - i)
			result[i] = pool[j]
			pool[j] = pool[n - i - 1]
	else:
		var selected := {}
		for i in range(k):
			var j := randbelow(n)
			while selected.has(j):
				j = randbelow(n)
			selected[j] = true
			result[i] = population[j]
	return result

func choices(population: Array, weights: Array = [], k: int = 1) -> Array:
	var out: Array = []
	var n := population.size()
	if weights.is_empty():
		for _i in range(k):
			out.append(population[int(floor(random() * n))])
		return out
	var cum: Array = []
	var acc := 0.0
	for w in weights:
		acc += float(w)
		cum.append(acc)
	var total: float = cum[n - 1]
	var hi := n - 1
	for _i in range(k):
		var x := random() * total
		var lo := 0
		var h := hi
		while lo < h:   # bisect_right
			var mid := (lo + h) / 2
			if x < cum[mid]:
				h = mid
			else:
				lo = mid + 1
		out.append(population[lo])
	return out

func uniform(a: float, b: float) -> float:
	return a + (b - a) * random()

func gauss(mu: float = 0.0, sigma: float = 1.0) -> float:
	var z: Variant = _gauss_next
	_gauss_next = null
	if z == null:
		var x2pi := random() * TAU
		var g2rad := sqrt(-2.0 * log(1.0 - random()))
		z = cos(x2pi) * g2rad
		_gauss_next = sin(x2pi) * g2rad
	return mu + float(z) * sigma
