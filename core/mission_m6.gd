class_name MissionM6
extends RefCounted

static func situations() -> Dictionary:
	var success := Outcome.make("Entre as redes rasgadas, o grupo encontra óleo bastante para acender uma trilha e uma poção que guarda uma chama sem fumaça.", {"xp": 18, "draw": 1})
	var failure := Outcome.make("A maré apaga as pegadas e encharca as botas. A névoa responde com um gosto metálico, mas o caminho para o armazém continua aberto.", {"xp": 6, "hp_loss": [1, 3]})
	var o1 := Option.make("Examinar os barcos vazios e as redes", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": success, "failure": failure})
	var o2 := Option.make("Avançar pela água escura antes da maré", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("Vocês cruzam as tábuas podres antes que elas cedam. A trilha de névoa leva ao armazém inundado.", {"xp": 14}),
		"failure": Outcome.make("Uma onda gela as pernas do grupo, mas algo enorme se move sob o píer e indica o rumo certo.", {"xp": 5, "hp_loss": [1, 2]})})
	var warehouse_success := Outcome.make("Uma corrente sob as tábuas leva a névoa até o píer distante. O grupo cruza o armazém sem chamar atenção da coisa no mar.", {"xp": 12})
	var warehouse_failure := Outcome.make("Uma viga cede na água e o ruído acorda algo sob o píer. Ainda assim, o caminho até a arena permanece aberto.", {"xp": 4, "hp_loss": [1, 2]})
	var w1 := Option.make("Seguir as marcas de sucção entre as caixas", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": warehouse_success, "failure": warehouse_failure})
	var w2 := Option.make("Cruzar a água rasa em silêncio", {"attribute": "destreza", "dc": Option.MEDIO,
		"success": Outcome.make("A água mal se move. Vocês chegam ao píer antes que os tentáculos possam alcançá-los.", {"xp": 10}),
		"failure": Outcome.make("A maré puxa uma bota, mas a porta quebrada do píer continua ao alcance.", {"xp": 3, "hp_loss": [1, 2]})})
	return {
		1: Situation.make(1, ["As Docas estão vazias demais. Barcos batem sem tripulação, e uma névoa verde escorre entre as redes apodrecidas."], [o1, o2], "Docas sem voz"),
		2: Situation.make(2, ["O armazém está tomado por água negra. Marcas de sucção somem entre caixas quebradas e apontam para o píer."], [w1, w2], "Armazém inundado"),
	}
