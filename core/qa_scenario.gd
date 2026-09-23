class_name QaScenario
extends RefCounted

var id: String = ""
var title: String = ""
var group: String = "mission"
var kind: String = "walk"
var mission_id: String = ""
var room_id: int = 0
var hq_id: String = ""
var description: String = ""
var enemy_factory: Callable = Callable()

static func make(fields: Dictionary) -> QaScenario:
	var scenario := QaScenario.new()
	for key in fields:
		scenario.set(key, fields[key])
	return scenario
