class_name DiceMesh
extends RefCounted
## Geometria de apresentação. O dado em 2.5D reaproveita as faces ilustradas
## importadas do original; a rotação é deliberadamente apenas visual.

static func texture_for(sides: int, value: int) -> Texture2D:
	var path := "res://assets/dice/textures/d%d_face_%s.png" % [sides, str(value).pad_zeros(2)]
	return load(path) if ResourceLoader.exists(path) else null

static func die_texture(sides: int) -> Texture2D:
	return UiAssets.texture("d%d" % sides, "dice")
