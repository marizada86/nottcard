class_name ResourceView
extends RefCounted
## game/core/state.py::ResourceView — foto congelada dos recursos que a jogada muda cedo (leitura pela UI).
var combo
var clone_max_hp
var clone_hp
var guard_cap: int
var guard: int
var dishonored: bool

func _init(combo_ = null, clone_max_hp_ = null, clone_hp_ = null, guard_cap_: int = 0, guard_: int = 0, dishonored_: bool = false) -> void:
	combo = combo_
	clone_max_hp = clone_max_hp_
	clone_hp = clone_hp_
	guard_cap = guard_cap_
	guard = guard_
	dishonored = dishonored_
