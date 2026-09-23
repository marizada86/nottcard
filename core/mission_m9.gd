class_name MissionM9
extends RefCounted

static func situations() -> Dictionary:
	var root_success := Outcome.make("As raízes respondem à marca de Bromnor e revelam uma passagem de pedra até o templo oculto.", {"xp": 24, "draw": 1})
	var root_failure := Outcome.make("A raiz fecha o caminho por um instante, mas uma corrente de ar frio ainda aponta para as ruínas do templo.", {"xp": 9, "hp_loss": [1, 2]})
	var r1 := Option.make("Seguir as raízes mais claras", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": root_success, "failure": root_failure})
	var r2 := Option.make("Abrir caminho entre as pedras", {"attribute": "forca", "dc": Option.MEDIO,
		"success": Outcome.make("A pedra se solta e deixa ver uma escadaria esquecida sob a raiz.", {"xp": 20}), "failure": root_failure})

	var temple_success := Outcome.make("O pedestal preserva uma luz antiga. O Martelo da Glória marca a direção do altar final sem revelar o que aguarda ali.", {"xp": 26})
	var temple_failure := Outcome.make("A luz vacila e o templo responde com um eco vazio. Ainda assim, o altar maior permanece acessível adiante.", {"xp": 10})
	var t1 := Option.make("Examinar o pedestal e a luz", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": temple_success, "failure": temple_failure})
	var t2 := Option.make("Proteger a passagem até o altar", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("A luz resiste enquanto o grupo avança. O altar final se abre para o confronto.", {"xp": 22}), "failure": temple_failure})

	return {
		1: Situation.make(1, ["A raiz do Plano Abissal atravessa a pedra como se procurasse a última luz presa no templo."], [r1, r2], "A trilha da raiz"),
		2: Situation.make(2, ["No templo, um pedestal vazio sustenta um brilho fraco. Mais adiante, o altar maior espera em silêncio."], [t1, t2], "A luz do templo"),
	}
