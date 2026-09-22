class_name XpLine
extends RefCounted
var source: String = ""
var amount: int = 0
func _init(source_: String = "", amount_: int = 0) -> void:
	source = source_
	amount = amount_
