class_name RunStats
extends RefCounted
## game/core/progress.py::RunStats

var damage_dealt: int = 0
var damage_taken: int = 0
var healing: int = 0
var enemies_defeated: int = 0
var cards_played: int = 0
var max_multiplier: int = 1
var turns: int = 0
var hits: int = 0
var misses: int = 0
var mission_id: String = ""
var party_size: int = 1
var crits: int = 0
var max_hit: int = 0
var natural_ones: int = 0
var seconds: float = 0.0

func record_damage(amount: int) -> void:
	max_hit = maxi(max_hit, amount)

## `hit` = HitResult (ou qualquer objeto com .hit e .crit).
func record_hit(hit) -> void:
	if hit == null:
		return
	if hit.crit:
		crits += 1
	if hit.hit:
		hits += 1
	else:
		misses += 1

func note_multiplier(multiplier: int) -> void:
	max_multiplier = maxi(max_multiplier, multiplier)
