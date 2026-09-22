class_name Achievement
extends RefCounted
## game/core/achievements.py::Achievement — a condição (`earned`) é Achievements.earned(id, ...), não um campo.

var id: String = ""
var name: String = ""
var description: String = ""
var benefit: String = ""
var benefit_key: String = ""
var grants: Array = []
