extends RefCounted

func test_profile_validation() -> String:
	var g = Golden.load_json("profile")
	for row in g.names:
		var got := ProfileStore.validate_name(row[0])
		var d := Golden.diff(got, row[1], "nome '%s'" % row[0])
		if d != "": return d
	for row in g.fps:
		var d := Golden.diff(ProfileStore.clean_fps(row[0]), row[1], "fps %s" % str(row[0]))
		if d != "": return d
	return ""

func test_save_roundtrip_on_disk() -> String:
	var dir := "user://test_nottcard_%d" % Time.get_ticks_usec()
	var store := SaveStore.new(dir)
	var st := store.load_state()
	if not st.roster_rules or not st.unlocked_characters.is_empty():
		return "save novo deveria nascer sem personagem e com regras de elenco"
	st.coins = 77
	st.for_character("durvall").xp = 150
	st.unlocked_characters = Py.set_of(["durvall"])
	store.save(st)
	var again := SaveStore.new(dir).load_state()
	if again.coins != 77 or again.for_character("durvall").xp != 150 or not again.unlocked_characters.has("durvall"):
		return "o save gravado não voltou igual"
	var f := FileAccess.open(dir + "/save.json", FileAccess.WRITE)
	f.store_string("{ isto não é json")
	f.close()
	var broken := SaveStore.new(dir)
	var recovered := broken.load_state()
	if recovered.coins != 0 or broken.warning == "" or not FileAccess.file_exists(dir + "/save.json.bak"):
		return "save corrompido devia virar .bak e recomeçar"
	DirAccess.remove_absolute(dir + "/save.json.bak")
	DirAccess.remove_absolute(dir)
	return ""

func test_profile_store_roundtrip() -> String:
	var dir := "user://test_nottcard_p_%d" % Time.get_ticks_usec()
	var p := ProfileStore.new(dir)
	p.save_name("Guilherme")
	p.set_fps_cap(30)
	p.set_walk_bob(false)
	var q := ProfileStore.new(dir)
	var ok: bool = q.name == "Guilherme" and q.fps_cap == 30 and not q.walk_bob and q.torch_flicker and not q.reduce_motion
	DirAccess.remove_absolute(dir + "/perfil.json")
	DirAccess.remove_absolute(dir)
	return "" if ok else "o perfil não voltou igual"
