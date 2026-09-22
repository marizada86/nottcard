class_name RunResult
extends RefCounted
## game/core/progress.py::RunResult

var outcome: String = ""
var character_id: String = ""
var lines: Array = []
var raw_xp: int = 0
var adjustment: int = 0
var gained: int = 0
var level_before: int = 1
var level_after: int = 1
var xp_before: int = 0
var xp_after: int = 0
var level_ups: Array = []
var stats: RunStats = null
var achievements: Array = []
var coins: int = 0
var scrolls_lost: Array = []
var bag_coins: int = 0
var charisma_pct: int = 0
var charisma_who: String = ""
var greed_pct: int = 0

var leveled_up: bool:
	get:
		return not level_ups.is_empty()
