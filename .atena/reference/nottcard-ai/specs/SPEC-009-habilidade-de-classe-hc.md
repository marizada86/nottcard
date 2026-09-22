---
id: "SPEC-009"
type: "spec"
title: "Habilidade de Classe (HC): Segundo Fôlego e Surto de Ação, 1 uso por combate"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-008-ajustes-pos-playtest-evid-003]]"
sources:
  - "Decisão do responsável em 2026-09-19: só 1 Segundo Fôlego e 1 Surto de Ação por combate; nunca mais de 1 de cada no baralho até o fim do combate; dar um nome a esse tipo de carta (Habilidade de Classe, HC, por enquanto)"
---

# Habilidade de Classe (HC)

## Declaração

Novo tipo de carta, **Habilidade de Classe (HC)** (nome provisório): recurso de
classe de uso limitado, como no D&D (Segundo Fôlego e Surto de Ação do Guerreiro).

Regras:
1. Cada HC tem **1 cópia** no baralho. O **Segundo Fôlego passa de 2 para 1 cópia**;
   o baralho inicial vai de **14 para 13 cartas**.
2. Usada, a HC **sai do baralho até o fim do combate**: não vai pro descarte,
   não volta ao embaralhar. Ela **volta ao baralho (embaralhada) ao começar o próximo combate**.
3. Diferença pra "uso único" (Poção): a Poção só volta numa nova tentativa; a HC volta a cada combate.
4. Cartas HC mostram a etiqueta **"· HC"** na carta.
5. HC atuais: **Segundo Fôlego** e **Surto de Ação**. Nenhuma outra carta muda.

Isso **substitui** o item "máx. 1 Segundo Fôlego na mão" da SPEC-008 (regra de
compra removida: com 1 cópia, ficou sem função).

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | `Card.class_ability`; Segundo Fôlego 1 cópia; baralho de 13. Remove `one_per_hand`. **Mudança de core.** |
| `game/core/state.py` | `Player.spent_class` e `restore_class_abilities()`; remove regra de compra da SPEC-008. |
| `game/app.py` | Jogar HC manda a carta pra `spent_class`; novo combate restaura. |
| `game/ui/cards_widget.py` | Etiqueta "· HC". |
| Testes | Baralho de 13; HC = Segundo Fôlego + Surto de Ação, 1 cópia; HC usada não volta no combate mas volta no próximo; restauração sem duplicar. |

## Pendente / fora do escopo

Nome definitivo do tipo; arte/cor própria pras HC; HC de outros personagens; se
HC podem ser recompensa de sala.
