extends SceneTree
## Runner mínimo: godot --headless -s tests/run_all.gd [-- filtro]  (o filtro casa com "arquivo.teste")

func _initialize() -> void:
	var filt := ""
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		filt = args[0]
	var failures := 0
	var ran := 0
	var root_dir := "res://tests/cases"
	var dir := DirAccess.open(root_dir)
	if dir != null:
		var files := Array(dir.get_files())
		files.sort()
		for f in files:
			if f.begins_with("test_") and f.ends_with(".gd"):
				var t = load("%s/%s" % [root_dir, f]).new()
				for m in t.get_method_list():
					if String(m.name).begins_with("test_"):
						var label := "%s.%s" % [f, m.name]
						if filt != "" and not label.contains(filt):
							continue
						ran += 1
						var t0 := Time.get_ticks_msec()
						var raw: Variant = t.call(m.name)
						var err: String = ""
						if typeof(raw) != TYPE_STRING:
							err = "erro em tempo de execução (o teste não devolveu texto)"
						else:
							err = raw
						var dt := Time.get_ticks_msec() - t0
						if filt != "" or dt > 2000:
							print("  %s: %d ms" % [label, dt])
						if err != "":
							failures += 1
							printerr("FAIL %s: %s" % [label, err])
	print("testes executados: %d, falhas: %d" % [ran, failures])
	quit(1 if failures > 0 else 0)
