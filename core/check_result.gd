class_name CheckResult
extends RefCounted
## game/core/exploration.py::CheckResult

var roll: int = 0
var modifier: int = 0
var bonus: int = 0
var total: int = 0
var dc: int = 0
var success: bool = false
var natural: String = ""
var rolls: Array = []
var disadvantage: bool = false

var critical: bool:
	get:
		return natural == "1"
