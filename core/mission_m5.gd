class_name MissionM5
extends RefCounted

static func situations() -> Dictionary:
	var success := Outcome.make("O grupo encontra marcas de uma luta antiga e segue a névoa até a passagem entre as lápides.", {"xp": 15, "draw": 1})
	var failure := Outcome.make("A fratura devolve imagens de um massacre que não pertence ao cemitério. O grupo se recompõe antes de descer.", {"xp": 5, "hp_loss": [1, 3]})
	var o1 := Option.make("Ler as marcas deixadas entre as lápides", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": success, "failure": failure})
	var o2 := Option.make("Atravessar a névoa sem recuar", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("A névoa se abre. Um corredor de pedra leva à dimensão de bolso antes que a fratura se feche.", {"xp": 12}),
		"failure": Outcome.make("O ar corta os pulmões, mas a luz verde revela a escadaria para baixo.", {"xp": 4, "hp_loss": [1, 2]})})
	return {1: Situation.make(1, ["Entre lápides partidas, a névoa verte de uma fratura maior que todas as vistas em Dagruve. Nenhum rastro de Bromnor volta do outro lado."], [o1, o2], "A fratura do cemitério")}
