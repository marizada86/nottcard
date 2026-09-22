---
id: "SPEC-047"
type: "spec"
title: "Equipamento: 3 armaduras, 3 armas com carta própria, menu de equipar e furtividade"
status: "approved"
created: "2026-09-20"
reviewed: "2026-09-20"
relations:
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[SPEC-036-mochila-e-itens]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-045-loja-de-upgrades-e-regras-do-baralho]]"
  - "[[SPEC-046-falha-critica-e-sorte]]"
sources:
  - "Higor, 2026-09-19: H8 (armas e armaduras baseadas em D&D, menu de equipar por personagem, conquistas liberam melhores)"
  - "Responsável, 2026-09-20: aprovado nas recomendações do PLAN-001 (armas com carta própria; números da tabela como ponto de partida)"
---

# Equipamento

> **Aprovada pelo responsável em 2026-09-20.** Preços e deltas são o ponto de partida; o Higor calibra no playtest.

## 1. Modelo

`EquipmentDef(id, nome, slot, preco, ca, cam, furtividade, carta, titulo_requerido)`. Cada personagem tem **1 arma + 1 armadura** equipadas, que valem
**entre tentativas** (ficam no save). O **acessório da mochila** (`SPEC-036`) continua sendo item de tentativa. A "Arma de assinatura" do Durvall continua
sendo a arma exibida quando nada está equipado. Comprar na loja dá o item ao jogador (vale para todos os personagens; equipa-se por personagem).

## 2. Armaduras (deltas sobre a CA e a CAM do personagem)

| Armadura | CA | CAM | Furtividade | Preço |
|---|---|---|---|---|
| Couro | +1 | 0 | normal | 100 |
| Cota de malha | +3 | −1 | −2 no teste | 300 |
| Placa completa | +5 | −3 | desvantagem | 600 |

- **Furtividade** é uma etiqueta de **opção de evento** (`Option.stealth`; "Contornar o slime" é a primeira). Na opção furtiva: cota de malha soma **−2** ao teste;
  placa completa dá **desvantagem** (rola dois d20 e vale o menor). Armadura leve/nenhuma: normal.

## 3. Armas (cada uma com a própria carta)

A carta da arma é de **assinatura** (fora do teto do baralho, 1 cópia, só entra com a arma equipada; não está na coleção). Não altera as cartas vermelhas existentes.

| Arma | Carta | Efeito | Preço |
|---|---|---|---|
| Adaga | Golpe Rápido | Vermelho, **Ação Bônus**, 1d4 | 100 |
| Espada longa | Golpe Versátil | Vermelho, Ação, 1d6 (**1d10** com a Corrente em x2 ou mais) | 300 |
| Maça de guerra | Golpe Esmagador | Vermelho, Ação, 1d8, testa atordoar como o Golpe Contundente | 300 |

## 4. Loja, conquistas e menu

- **Loja:** as 6 peças aparecem na loja (`SPEC-045`), pelo preço da tabela. **Conquistas** liberam, por título (como no `SPEC-035`), equipamentos avançados: o
  campo `titulo_requerido` existe; o conteúdo avançado é uma spec de conteúdo à parte (nada avançado nesta spec).
- **Menu "Equipamento"** (menu principal): por personagem (abas), lista o que o jogador tem por slot e o equipado; clicar equipa/desequipa; mostra a
  CA/CAM resultante e a carta da arma. (O botão por cartão na seleção de personagem fica para depois.)
- **Dados (core, sem pygame):** `game/core/equipment.py`; `SaveState.equipped: dict[personagem, {"arma": id, "armadura": id}]` e os ids comprados em `owned`;
  `Player.for_character(..., equipment=...)` aplica CA/CAM e acrescenta a carta da arma ao baralho da tentativa.

## 5. Testes

- Catálogo: os 6 itens, preços, deltas e a carta de cada arma (Golpe Rápido é Bônus 1d4; Versátil 1d10 com Corrente ≥ x2; Esmagador testa atordoar).
- Efeito: armadura muda CA/CAM do `Player`; sem armadura, igual a hoje; a carta da arma entra no baralho da tentativa e não conta no teto nem está na coleção.
- Furtividade: cota −2; placa desvantagem (dois d20, vale o menor); só em opção `stealth`.
- Loja e menu: comprar e equipar por personagem; equipar sem possuir é recusado; o save guarda o equipado; "Novo jogo" limpa equipamento e compras.

## 6. Critérios de aceite

- [x] As 3 armaduras e as 3 armas existem, à venda, e se equipam por personagem no menu "Equipamento".
- [x] A armadura muda a CA/CAM; a arma traz a carta própria à tentativa.
- [x] Furtividade (cota −2, placa desvantagem) vale nas opções furtivas.
- [x] `core` sem pygame; todos os testes passam.
- [ ] Preços e deltas calibrados após o playtest.

## Registro da implementação (2026-09-20)

- Feito conforme a spec, exceto o botão de equipamento por cartão na seleção de personagem (a spec já o deixava para depois): o menu
  "Equipamento" é o único ponto de entrada. `titulo_requerido` existe, mas nenhum equipamento avançado foi criado (spec de conteúdo à parte).
- A "Arma de assinatura" do Durvall segue como arma exibida na mochila; a arma equipada acrescenta a carta dela à tentativa.
- Testes: `test_equipment.py` e `test_equipment_flow.py`.

## Review record

- Proposed by: Claude, a partir de H8 do PLAN-001.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20 (armas com carta própria; números da tabela como ponto de partida).
