extends RefCounted
## Todo script de core/ e ui/ precisa compilar (um erro de parse num arquivo ainda não usado não passa em silêncio).

func test_all_scripts_compile() -> String:
	var bad: Array = []
	for dir in ["res://core", "res://ui"]:
		var d := DirAccess.open(dir)
		if d == null:
			continue
		for f in d.get_files():
			if f.ends_with(".gd"):
				var s = ResourceLoader.load("%s/%s" % [dir, f], "", ResourceLoader.CACHE_MODE_IGNORE)
				if s == null or not (s is GDScript) or not s.can_instantiate() and not s.is_abstract():
					bad.append("%s/%s" % [dir, f])
	return "" if bad.is_empty() else "não compilam: " + ", ".join(bad)
