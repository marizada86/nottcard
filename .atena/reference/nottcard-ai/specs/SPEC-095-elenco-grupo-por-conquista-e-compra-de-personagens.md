---
id: "SPEC-095"
type: "spec"
title: "Elenco: inicial, grupo por conquista e compra de personagens"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-093-catalogo-de-missoes-e-m1-portada]]"
  - "[[SPEC-094-campanha-save-e-interludio-a]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-037-grupo-mais-de-um-personagem-em-cena]]"
  - "[[PLAN-018-implementacao-de-m2-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: fluxo de elenco (1 inicial entre 4; mais personagens por conquista; baralho único; primeira vez só com o elenco da missão)"
  - "Responsável, 2026-09-20: grupo de 2 = 1 personagem no nível 3; grupo de 3 = todos no nível 3 (incluindo o Brook); conquista libera, é preciso comprar; Brook só após a missão em que entra"
  - "Responsável, 2026-09-20: 'tudo aprovado com suas recomendações' (300 moedas; 3 vagas de compra; regra aplicada a todos os saves)"
---

# Elenco, grupo por conquista e compra

`core/roster.py` (puro). As regras só valem em **saves reais** (`SaveState.roster_rules`, ligado por `from_dict`, pelos `SaveStore` de disco e por "Novo jogo");
um `SaveState()` de teste segue com os 5 liberados e grupo de 3.

1. **Início:** o save começa sem personagem (`unlocked_characters` vazio). Tela de escolha dos 4 iniciais (Kayron, Durvall, Sylas, Maelor); escolher trava os
   outros 3. **Vale para todos os saves, inclusive os existentes:** o progresso (nível, XP, mortes), o equipamento e as cartas dos bloqueados ficam guardados.
2. **Tamanho do grupo por conquista:** 1 por padrão; **"Dupla"** (1 personagem que o jogador tem no nível 3) libera 2; **"Trio"** (os 5 personagens, com o
   Brook, no nível 3, o que exige tê-los comprado) libera 3. Avaliadas no fim da missão e ao abrir a seleção (um save que já cumpre nasce com "Dupla").
3. **Compra:** a conquista **libera** a compra, ela não dá o personagem. Cada uma abre 1 **vaga** entre os iniciais bloqueados: "Dupla", "A Praça em silêncio"
   (concluir a M2) e "Dupla na Praça" (concluir a M2 com 2 ou 3 personagens). O jogador escolhe quem comprar. O **Brook** tem compra própria, liberada ao
   concluir a M2 (a missão em que entra). Na Loja, aba "Personagens", **300 moedas** cada (a ajustar no playtest); o cheat entrega todos.
4. **Acesso à missão** (`can_play`/`can_field`): o personagem precisa ser do jogador e (a missão já foi concluída **ou** ele está no elenco canônico). A 1ª vez
   só com o elenco (M1: os 4 iniciais; M2: os 4 + Brook); **depois de concluída, qualquer personagem que o jogador tem** pode rejogá-la.
5. **Seleção:** cartões bloqueados ou fora do elenco escurecem com o motivo ("Bloqueado", "Fora do elenco (conclua a missão antes)"); o chip de grupo mostra
   "Conquista: Dupla/Trio" no limite. O baralho é único e serve a todos (sem mudança).
6. **Ajustes:** "Dois Veteranos" passa a valer só para quem o jogador tem; "Sugerir baralho" lista só os personagens que o jogador tem.

## Testes
`tests/core/test_roster.py` (regras, vagas, preço, migração), `tests/ui/test_m2_flow.py` (escolha do inicial, bloqueios, grupo, Brook em M1 e M2), `test_shop*`.
