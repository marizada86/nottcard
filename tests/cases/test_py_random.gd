extends RefCounted
## Paridade do PyRandom com o random.Random do CPython (SPEC-002).

func test_golden() -> String:
	var g = Golden.load_json("py_random")
	if g == null:
		return "tests/golden/py_random.json ausente (rode tools/gen_golden.py)"
	for c in g.cases:
		var r := PyRandom.new(int(c.seed))
		var seed_tag := "seed=%d" % int(c.seed)
		var out := {}
		out.random = [r.random(), r.random(), r.random(), r.random(), r.random()]
		out.getrandbits = []
		for k in [1, 8, 16, 32, 33, 48, 63]:
			out.getrandbits.append(str(r.getrandbits(k)))
		out.randint_1_20 = _rep(12, func(): return r.randint(1, 20))
		out.randint_big = _rep(4, func(): return r.randint(-1000, 100000))
		out.randrange_7 = _rep(6, func(): return r.randrange(7))
		out.randrange_step = _rep(6, func(): return r.randrange(0, 50, 5))
		out.choice = _rep(6, func(): return r.choice(["a", "b", "c", "d", "e", "f", "g"]))
		out.uniform = _rep(4, func(): return r.uniform(-2.5, 9.75))
		var pool: Array = range(10)
		r.shuffle(pool)
		out.shuffle_10 = pool
		out.sample_small = r.sample(range(10), 3)
		out.sample_k6 = r.sample(range(20), 8)
		out.sample_large_pop = r.sample(range(200), 5)
		out.choices_plain = r.choices(["w", "x", "y", "z"], [], 8)
		out.choices_weighted = r.choices(["a", "b", "c"], [1, 3, 6], 10)
		out.gauss = _rep(5, func(): return r.gauss(10, 2))
		for key in out:
			var d := Golden.diff(out[key], c[key], key)
			if d != "":
				return "%s %s" % [seed_tag, d]
	return ""

func _rep(n: int, f: Callable) -> Array:
	var a: Array = []
	for _i in range(n):
		a.append(f.call())
	return a
