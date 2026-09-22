---
id: "SPEC-036"
type: "spec"
title: "Mochila e itens"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-001-vertical-slice-m1-solo]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
sources:
  - "SPEC-001 §5 (canon): 1 arma + 1 acessório, mochila de 3 slots, temporária por tentativa; trocar em combate custa a Ação"
  - "Responsável, 2026-09-19: sem efeito de dano e sem item de cura na v1; 2 ou 3 itens no M1"
---

# Mochila e itens


## Regras (do canon, `SPEC-001` §5)

- **1 arma + 1 acessório** equipados; o Durvall já começa com a arma de assinatura (não é carta).
- **Mochila de 3 slots**, temporária: esvazia ao fim da tentativa (baralho e itens são "por tentativa").
- Trocar de equipamento **entre salas é grátis**; **em combate custa a Ação** do turno.

## 1. Itens como dado

`ItemDef(id, nome, tipo, efeito, descricao, asset_id)`. Tipos:

- **acessório:** ocupa o slot de acessório, efeito passivo enquanto equipado.
- **consumível:** uso único, some depois de usado.
- **pista:** sem efeito mecânico; guarda lore (a "Carta sobre o Messias" do Durvall entra assim).

## 2. Efeitos permitidos na v1

- **Bônus fixo num atributo** enquanto equipado (reaproveita `player.attributes`/`hooks`).
- **Bônus em teste de d20** de exploração (ex.: +2 em Inteligência): entra no `bonus` do `CheckResult`.
- **Uso único que dá bônus na próxima situação** (ex.: vantagem numérica de +3 no próximo teste).
- **Proibido na v1:** qualquer efeito que mude a fórmula de dano, e **item de cura** (a Poção de Cura já é
  uma carta; não se duplica a mecânica).

## 3. De onde vêm

- `Outcome` da `SPEC-031` ganha o campo `item`: o sucesso de um teste pode entregar um item.
- Mochila cheia: a UI pede para descartar um item (ou recusar o novo), como o descarte de mão (SPEC-020).
- O item nunca vem de recompensa garantida que trave a missão; é um bônus por explorar.

## 4. Conteúdo do M1 (2 ou 3 itens, para provar o fluxo)

Depois do balanceamento da SPEC-031, o Porão tem uma opção de **Inteligência** (além de Carisma), então a Lupa
rende no M1. A Faixa (Força) só rende quando houver situação de Força depois da Rachadura (M2 em diante).

| Item | Tipo | Efeito | Origem |
|---|---|---|---|
| Lupa de latão | acessório | +2 nos testes de Inteligência | sucesso na Rachadura (Inteligência) |
| Carta chamuscada | pista | nenhum (lore) | sucesso nas Docas |
| Faixa de couro | acessório | +2 nos testes de Força | sucesso na Rachadura (Força) |

Valores iniciais, a ajustar no playtest. A pista não tem efeito mecânico, só aparece na mochila.

## 5. UI

- Mochila como **sobreposição** aberta no mapa (botão) e no Interlúdio; 3 slots + slot de arma + slot de
  acessório, com o texto do efeito ao passar o mouse.
- Em combate: botão "Usar item" que gasta a **Ação** (consumível) ou "Trocar acessório" (Ação). Sem item,
  o botão não aparece.
- Arte ausente cai no retângulo com o nome.

## Arquitetura

`game/core/items.py` (dados, `Backpack` com equipar/usar/descartar, sem pygame); `Player.backpack`; ganchos
de bônus lidos por `resolve_check`; `game/ui/backpack.py` (sobreposição); campo `item` no `Outcome`.

## Fora de escopo

Loja de itens, itens com efeito de combate ofensivo, itens de cura, o companheiro Livrinho (é um caso de
`SPEC-037`), crafting, peso e durabilidade.

## Critérios de aceite

- [x] Mochila de 3 slots, 1 arma e 1 acessório; esvazia ao fim da tentativa.
- [x] Acessório equipado altera o teste de d20 e o valor aparece no resultado.
- [x] Trocar equipamento é grátis fora de combate e custa a Ação em combate.
- [x] Mochila cheia pede escolha; nada é perdido em silêncio.
- [x] Nenhum item muda dano nem cura.
- [x] `core` sem pygame; testes de slots, efeitos, uso e descarte (`tests/core/test_items.py`, `tests/ui/test_backpack_flow.py`).
- [ ] Playtest.

Notas de implementação:
- **Onde abre:** o botão "Mochila" do mapa e, em combate, o botão "Mochila" (só aparece com um acessório para equipar ou um consumível para usar). O Interlúdio não tem o botão: a mochila esvazia ao fim da tentativa, então lá só haveria a arma.
- **Grupo (SPEC-037):** cada personagem tem a própria mochila; no mapa, os botões < > alternam entre eles; em combate abre a do personagem ativo. O item ganho num teste vai para quem fez o teste.
- **Custo em combate:** equipar, guardar o acessório ou usar um consumível gasta a Ação do personagem ativo (o descarte é de graça). Se era a última ação, o turno segue quando a mochila fecha. O cronômetro do chefe fica parado com a mochila aberta.
- **Mochila cheia:** a tela abre sozinha depois do d20 com o item novo; só se sai descartando um guardado ("Descartar e pegar o novo") ou recusando o novo.
- **Conteúdo do M1:** Carta chamuscada (pista) nas duas opções de sucesso das Docas, Lupa de latão (+2 Inteligência) no sucesso de "Decifrar" e Faixa de couro (+2 Força) no sucesso de "Forçar" na Rachadura. O consumível existe no código (`next_check_bonus`), mas nenhum item do M1 o usa.
- O Durvall começa com a Arma de assinatura no slot de arma (sem efeito mecânico).
