class_name MissionM4
extends RefCounted

static func situations() -> Dictionary:
	var success := Outcome.make("O grupo encontra uma passagem de serviço e reduz a distância até as carroças. Os rastros levam direto à ponte.", {"xp": 12, "draw": 1})
	var failure := Outcome.make("A chuva esconde a bifurcação. Vocês recuperam o rastro, mas chegam sob uma saraivada de flechas.", {"xp": 4, "hp_loss": [1, 3]})
	var o1 := Option.make("Ler os rastros na lama", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": success, "failure": failure})
	var o2 := Option.make("Forçar os cavalos pelo atalho", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("A cavalaria improvisada vence a chuva. A ponte surge antes que os rebeldes possam fechar a passagem.", {"xp": 10}),
		"failure": Outcome.make("O atalho cobra fôlego e lama, mas a luz das lanternas rebeldes ainda é visível à frente.", {"xp": 3, "hp_loss": [1, 2]})})
	return {1: Situation.make(1, ["Marcas de rodas cortam a lama. À frente, as carroças que levaram Kein descem para Rodhe's Bridge sob a chuva."], [o1, o2], "A perseguição")}
