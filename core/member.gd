class_name Member
extends RefCounted
## game/core/party.py::Member — um personagem do grupo e a economia de turno dele.

var player: Player
var turn: TurnState = TurnState.new()

func _init(player_: Player = null) -> void:
	player = player_

var alive: bool:
	get:
		return player.is_alive()

var character: CharacterDef:
	get:
		return player.character

var downed: bool:
	get:
		return player.is_downed

var dead: bool:
	get:
		return player.dead
