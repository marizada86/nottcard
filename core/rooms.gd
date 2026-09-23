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

static func _grp_gargulas_acervo() -> Array:
	return [Enemies.gargula_corrompida(), Enemies.gargula_corrompida(), Enemies.gargula_corrompida()]

static func _grp_gargulas_arquivo() -> Array:
	return [Enemies.gargula_corrompida(), Enemies.gargula_corrompida(), Enemies.gargula_corrompida()]

static func rooms_m3() -> Array:
	return [
		Room.make({"id": 1, "name": "Vestíbulo selado", "kind": EVENTO, "asset_id": "m3_sala_1_entrada", "xp": 10}),
		Room.make({"id": 2, "name": "Acervo do silêncio", "kind": COMBATE, "asset_id": "m3_sala_2_acervo", "group_factory": _grp_gargulas_acervo, "reward_tier": 2, "fog": FOG_PURPLE}),
		Room.make({"id": 3, "name": "Arquivo da estrela", "kind": COMBATE, "asset_id": "m3_sala_3_arquivo", "group_factory": _grp_gargulas_arquivo, "is_boss": true, "reward_tier": 3, "fog": FOG_PURPLE}),
	]

static func _grp_rebeldes_ponte() -> Array:
	return [Enemies.rebelde_ponte(), Enemies.rebelde_ponte()]

static func _grp_rebeldes_carroca() -> Array:
	return [Enemies.rebelde_ponte(), Enemies.rebelde_ponte(), Enemies.rebelde_ponte()]

static func rooms_m4() -> Array:
	return [
		Room.make({"id": 1, "name": "Estrada sob chuva", "kind": EVENTO, "asset_id": "m4_sala_1_estrada", "xp": 12}),
		Room.make({"id": 2, "name": "A ponte em perseguição", "kind": COMBATE, "asset_id": "m4_sala_2_ponte", "group_factory": _grp_rebeldes_ponte, "reward_tier": 2, "fog": FOG_GREEN}),
		Room.make({"id": 3, "name": "A carroça-prisão", "kind": COMBATE, "asset_id": "m4_sala_3_carroca", "group_factory": _grp_rebeldes_carroca, "is_boss": true, "reward_tier": 3, "fog": FOG_GREEN}),
	]

static func _grp_notivagos() -> Array:
	return [Enemies.notivago(), Enemies.notivago()]

static func rooms_m5() -> Array:
	return [
		Room.make({"id": 1, "name": "Cemitério partido", "kind": EVENTO, "asset_id": "m5_sala_1_cemiterio", "xp": 15}),
		Room.make({"id": 2, "name": "Limiar da dimensão", "kind": COMBATE, "asset_id": "m5_sala_2_limiar", "group_factory": _grp_notivagos, "reward_tier": 2, "fog": FOG_GREEN}),
		Room.make({"id": 3, "name": "Santuário de Astherion", "kind": COMBATE, "asset_id": "m5_sala_3_santuario", "enemy_factory": Enemies.astherion_fase_1, "is_boss": true, "reward_tier": 3, "fog": FOG_PURPLE}),
	]

static func _grp_willie_amalgame() -> Array:
	var group: Array = [Enemies.willie_amalgame()]
	for _i in range(Enemies.WILLIE_TENTACLES):
		group.append(Enemies.tentaculo_willie())
	return group

static func rooms_m6() -> Array:
	return [
		Room.make({"id": 1, "name": "Docas sem voz", "kind": EVENTO, "asset_id": "m6_sala_1_docas", "xp": 18}),
		Room.make({"id": 2, "name": "Armazém inundado", "kind": EXPLORACAO, "asset_id": "m6_sala_2_armazem"}),
		Room.make({"id": 3, "name": "Píer do Amálgama", "kind": COMBATE, "asset_id": "m6_sala_3_pier", "group_factory": _grp_willie_amalgame, "is_boss": true, "reward_tier": 3, "fog": FOG_GREEN}),
	]

static func rooms_m7() -> Array:
	return [
		Room.make({"id": 1, "name": "Pátio do Espeto", "kind": EVENTO, "asset_id": "m7_sala_1_patio", "xp": 18}),
		Room.make({"id": 2, "name": "Fornalhas apagadas", "kind": EVENTO, "asset_id": "m7_sala_2_fornalhas", "xp": 20}),
		Room.make({"id": 3, "name": "Porão dos portais gêmeos", "kind": EVENTO, "asset_id": "m7_sala_3_portais", "xp": 20}),
		Room.make({"id": 4, "name": "Oficina do mímico", "kind": COMBATE, "asset_id": "m7_sala_4_oficina", "enemy_factory": Enemies.mimico_espeto, "is_boss": true, "reward_tier": 3, "fog": FOG_PURPLE}),
	]

static func rooms_m8() -> Array:
	return [
		Room.make({"id": 1, "name": "Entrada da Vila", "kind": EVENTO, "asset_id": "m8_sala_1_vila", "xp": 20}),
		Room.make({"id": 2, "name": "Pousada vazia", "kind": EVENTO, "asset_id": "m8_sala_2_pousada", "xp": 22}),
		Room.make({"id": 3, "name": "Salão da armadilha", "kind": COMBATE, "asset_id": "m8_sala_3_salao", "enemy_factory": Enemies.demonio_sedutor_vila, "is_boss": true, "reward_tier": 3, "fog": FOG_PURPLE}),
		Room.make({"id": 4, "name": "Igreja das Sombras", "kind": EVENTO, "asset_id": "m8_sala_4_igreja", "xp": 24}),
	]

static func rooms_m9() -> Array:
	return [
		Room.make({"id": 1, "name": "Raiz do Plano Abissal", "kind": EVENTO, "asset_id": "m9_sala_1_raiz", "xp": 24}),
		Room.make({"id": 2, "name": "Templo da Tarn", "kind": EVENTO, "asset_id": "m9_sala_2_templo", "xp": 26}),
		Room.make({"id": 3, "name": "Altar do Véu", "kind": COMBATE, "asset_id": "m9_sala_3_altar", "enemy_factory": Enemies.kein_altar, "is_boss": true, "reward_tier": 3, "fog": FOG_PURPLE}),
	]
