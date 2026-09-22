extends RefCounted

func test_viewport_size() -> String:
	var w: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var h: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	return "" if w == 1280 and h == 720 else "viewport %dx%d != 1280x720" % [w, h]

func test_assets_present() -> String:
	for p in ["res://assets/fonts/CinzelDecorative-Bold.ttf", "res://assets/cards", "res://assets/screens"]:
		if not (FileAccess.file_exists(p) or DirAccess.dir_exists_absolute(p)):
			return "faltando " + p
	return ""
