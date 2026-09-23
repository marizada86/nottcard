class_name MissionM7
extends RefCounted

static func situations() -> Dictionary:
	var courtyard_success := Outcome.make("Sob a bigorna caída, o grupo encontra a marca de Bromnor e a passagem para as fornalhas internas.", {"xp": 18, "draw": 1})
	var courtyard_failure := Outcome.make("A chuva apaga a maior parte das marcas. O cheiro de ferro queimado ainda conduz vocês pela entrada lateral.", {"xp": 6, "hp_loss": [1, 2]})
	var c1 := Option.make("Examinar a bigorna e as ferramentas", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": courtyard_success, "failure": courtyard_failure})
	var c2 := Option.make("Forçar o portão enferrujado", {"attribute": "forca", "dc": Option.MEDIO,
		"success": Outcome.make("O portão cede com um gemido. As fornalhas apagadas esperam logo adiante.", {"xp": 14}),
		"failure": Outcome.make("O ferro corta uma mão, mas a corrente arrebenta e revela a entrada.", {"xp": 5, "hp_loss": [1, 2]})})

	var forge_success := Outcome.make("As três fornalhas formam a mesma sequência de calor, sombra e faísca vista nos aros do porão. A pista aponta para o portal azul.", {"xp": 20})
	var forge_failure := Outcome.make("A cinza sobe como fumaça e cobre a leitura das fornalhas. Vocês precisam observar a sequência outra vez.", {"xp": 4, "hp_loss": [1, 2], "remain": true})
	var f1 := Option.make("Comparar as cinzas e os aros das fornalhas", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": forge_success, "failure": forge_failure, "critical": forge_failure})
	var f2 := Option.make("Escutar o fole e seguir o ritmo dos pistões", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("O ritmo morto do fole revela a ordem das fornalhas: frio, cinza, centelha. O portal azul responde à sequência.", {"xp": 16}),
		"failure": forge_failure, "critical": forge_failure})

	var blue := Outcome.make("O portal azul se abre para uma galeria estreita. Do outro lado, uma voz assustada pede que não fechem a passagem.", {"xp": 20})
	var amber := Outcome.make("O portal âmbar devolve vocês à mesma sala e queima o ar ao redor. A pista das fornalhas insistia no azul.", {"xp": 3, "hp_loss": [1, 2], "remain": true})
	var p1 := Option.make("Atravessar o portal azul", {"auto": true, "success": blue})
	var p2 := Option.make("Atravessar o portal âmbar", {"auto": true, "success": amber})

	return {
		1: Situation.make(1, ["A ferraria Espeto de Pau está fechada há anos. Chuva, ferro e uma bigorna caída guardam a única entrada sem correntes."], [c1, c2], "Pátio da ferraria"),
		2: Situation.make(2, ["Três fornalhas apagadas dividem a nave. Seus aros carregam marcas que se repetem no porão abaixo."], [f1, f2], "A sequência das fornalhas"),
		3: Situation.make(3, ["Dois portais iguais vibram sob a ferraria. A pista do fogo frio aponta para um deles."], [p1, p2], "Portais gêmeos"),
	}
