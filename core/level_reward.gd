class_name LevelReward
extends RefCounted
## game/core/characters.py::LevelReward — o que um nível libera (SPEC-024).

var cards: Array = []
var passive: String = ""
var passive_text: String = ""
var attr_bonus: Dictionary = {}
var hooks: Array = []
