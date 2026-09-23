class_name MissionM3
extends RefCounted

static func situations() -> Dictionary:
	var success := Outcome.make("Entre os livros, Livrinho encontra o diário das gárgulas. Os nomes verdadeiros mostram qual corredor permanece em silêncio.", {"xp": 10, "draw": 1})
	var failure := Outcome.make("Um sussurro vira grito. As estátuas rangem, mas o grupo encontra a escada antes que todas despertem.", {"xp": 3, "hp_loss": [1, 3]})
	var o1 := Option.make("Ouvir a resposta que nunca é falada", {"attribute": "inteligencia", "dc": Option.MEDIO, "success": success, "failure": failure})
	var o2 := Option.make("Permanecer imóvel entre as estátuas", {"attribute": "constituicao", "dc": Option.MEDIO,
		"success": Outcome.make("A pedra não se move. Livrinho aponta a escada e o grupo atravessa o vestíbulo sem despertar as sentinelas.", {"xp": 8}),
		"failure": Outcome.make("A poeira denuncia um passo. Três gárgulas abrem os olhos, e a biblioteca responde com um estrondo.", {"xp": 2, "hp_loss": [1, 2]})})
	return {1: Situation.make(1, ["Livros sussurram a mesma charada: ‘Nunca fala, mas sempre responde. Quando falo, desapareço.’ Livrinho treme sobre uma mesa de pedra."], [o1, o2], "O enigma do silêncio")}
