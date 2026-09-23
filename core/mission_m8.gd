class_name MissionM8
extends RefCounted

static func situations() -> Dictionary:
	var village_success := Outcome.make("A lanterna coberta de névoa responde ao Amuleto da Luz que alguém deixou no caminho. Uma trilha segura leva até a pousada.", {"xp": 20, "draw": 1})
	var village_failure := Outcome.make("A névoa apaga as pegadas, mas uma janela iluminada no fim da rua ainda marca o caminho da pousada.", {"xp": 7, "hp_loss": [1, 2]})
	var v1 := Option.make("Seguir a lanterna coberta de névoa", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": village_success, "failure": village_failure})
	var v2 := Option.make("Avançar pela rua alagada", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("Vocês atravessam a névoa antes que ela se feche sobre os telhados.", {"xp": 16}), "failure": village_failure})

	var inn_success := Outcome.make("As cadeiras foram derrubadas de propósito e a porta do salão está marcada por garras. A armadilha já espera por vocês.", {"xp": 22})
	var inn_failure := Outcome.make("O perfume doce da pousada confunde os sentidos por um instante. Um estalo no salão revela que não estão sozinhos.", {"xp": 8, "hp_loss": [1, 2]})
	var i1 := Option.make("Examinar as cadeiras e os canecos", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": inn_success, "failure": inn_failure})
	var i2 := Option.make("Manter a guarda junto à porta", {"attribute": "forca", "dc": Option.MEDIO,
		"success": Outcome.make("A porta abre antes do sussurro alcançar o grupo. O salão não consegue esconder a criatura.", {"xp": 18}), "failure": inn_failure})

	var church_success := Outcome.make("No relicário, os artefatos de Bromnor permanecem intactos. Erik Blackthorn sai da névoa e reconhece a marca dos Greenholders.", {"xp": 24, "draw": 1})
	var church_failure := Outcome.make("As velas se apagam, mas o relicário continua aberto. Um guia silencioso espera sob o arco quebrado para conduzir vocês de volta.", {"xp": 10})
	var c1 := Option.make("Abrir o relicário com cuidado", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": church_success, "failure": church_failure})
	var c2 := Option.make("Procurar a marca dos Greenholders", {"attribute": "carisma", "dc": Option.MEDIO,
		"success": Outcome.make("Uma voz na sombra responde à saudação. Erik aceita guiar o grupo até a saída da vila.", {"xp": 20}), "failure": church_failure})

	return {
		1: Situation.make(1, ["A Vila das Sombras está vazia, mas uma lanterna torta ainda queima no limite da névoa."], [v1, v2], "A luz na neblina"),
		2: Situation.make(2, ["A pousada parece abandonada. Canecos frios e cadeiras derrubadas contam uma história diferente."], [i1, i2], "A pousada-armadilha"),
		4: Situation.make(4, ["A Igreja das Sombras guarda um relicário aberto diante do altar. A névoa recua de alguém parado perto da saída."], [c1, c2], "Os artefatos de Bromnor"),
	}
