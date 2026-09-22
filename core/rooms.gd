class_name Rooms
extends RefCounted
## game/core/rooms.py e mission_m2.py — as salas de cada missão (com fábricas de inimigos).

const EXPLORACAO := "exploracao"
const EVENTO := "evento"
const COMBATE := "combate"
const CONCLUSAO_XP := 20
const FOG_GREEN := [96, 120, 108]
const FOG_PURPLE := [96, 70, 128]

static func slime_da_entrada() -> Enemy:
	return Enemies.slime_corrosivo(10)

static func grupo_do_corredor() -> Array:
	return [Enemies.criatura_corrompida(), Enemies.slime_corrosivo(), Enemies.slime_corrosivo()]

static func rooms_m1() -> Array:
	return [
		Room.make({"id": 1, "name": "As Docas", "kind": EXPLORACAO, "asset_id": "sala_1_docas"}),
		Room.make({"id": 2, "name": "O cais atacado", "kind": COMBATE, "asset_id": "sala_2_cais", "enemy_factory": Enemies.criatura_corrompida, "reward_tier": 1, "fog": FOG_GREEN}),
		Room.make({"id": 3, "name": "A rachadura na Tarn", "kind": EVENTO, "asset_id": "sala_3_rachadura", "xp": 10}),
		Room.make({"id": 4, "name": "O porão — entrada", "kind": EXPLORACAO, "asset_id": "sala_4_porao_entrada", "enemy_factory": slime_da_entrada, "optional": true, "reward_tier": 1, "fog": FOG_GREEN}),
		Room.make({"id": 5, "name": "O porão — sala de livros", "kind": COMBATE, "asset_id": "sala_5_porao_livros", "enemy_factory": Enemies.guardiao_copia, "reward_tier": 2}),
		Room.make({"id": 6, "name": "O porão — o corredor", "kind": COMBATE, "asset_id": "sala_5b_porao_corredor", "group_factory": grupo_do_corredor, "reward_tier": 3, "fog": FOG_GREEN}),
		Room.make({"id": 7, "name": "O ritual", "kind": COMBATE, "asset_id": "sala_6_ritual", "enemy_factory": Enemies.guardiao_verdadeiro, "is_boss": true, "reward_tier": 3, "fog": FOG_PURPLE}),
	]

static func _grp_praca() -> Array:
	return [Enemies.cultista_adaga(), Enemies.cultista_cajado(), Enemies.cultista_adaga()]

static func _grp_beco() -> Array:
	return [Enemies.cultista_arqueiro(), Enemies.cultista_adaga(), Enemies.cultista_arqueiro()]

static func _grp_nave() -> Array:
	return [Enemies.cultista_adaga(), Enemies.cultista_arqueiro(), Enemies.cultista_cajado(), Enemies.cultista_adaga()]

static func rooms_m2() -> Array:
	return [
		Room.make({"id": 1, "name": "Entrada de Dagruve", "kind": EXPLORACAO, "asset_id": "m2_sala_1_entrada"}),
		Room.make({"id": 2, "name": "A praça externa", "kind": COMBATE, "asset_id": "m2_sala_2_praca", "group_factory": _grp_praca, "reward_tier": 1}),
		Room.make({"id": 3, "name": "O beco das sentinelas", "kind": COMBATE, "asset_id": "m2_sala_3_beco", "group_factory": _grp_beco, "reward_tier": 2}),
		Room.make({"id": 4, "name": "A porta da igreja", "kind": EXPLORACAO, "asset_id": "m2_sala_4_porta_igreja", "xp": 10}),
		Room.make({"id": 5, "name": "A nave profanada", "kind": COMBATE, "asset_id": "m2_sala_5_nave", "group_factory": _grp_nave, "reward_tier": 2}),
		Room.make({"id": 6, "name": "O altar da Mente Derretida", "kind": COMBATE, "asset_id": "m2_sala_6_altar", "enemy_factory": Enemies.sacerdote_mente_derretida, "is_boss": true, "reward_tier": 3}),
	]
