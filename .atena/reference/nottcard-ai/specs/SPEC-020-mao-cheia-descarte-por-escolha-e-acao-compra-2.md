---
id: "SPEC-020"
type: "spec"
title: "Mão cheia: descarte por escolha; Ação básica compra 2 cartas"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-010-reacao-cartas-escurecidas-e-ajustes-de-hud]]"
  - "[[SPEC-018-pausa-e-interacao-de-cartas]]"
sources:
  - "FB-001 A5 e B2 (Higor, 2026-09-19), aprovado com as recomendações"
---

# Descarte por escolha e Ação que compra 2

## Problema

- O excedente da mão (limite `MAX_HAND_SIZE = 5`) cai sozinho no fim do turno, sempre as últimas
  cartas compradas (`Player.discard_excess`). O jogador não escolhe.
- A Ação básica só tem "Passar"; o Bônus básico compra 1 carta. A Ação pode valer mais.

## Regras

### 1. Descarte por escolha
1. No fim do turno do jogador, se `len(hand) > MAX_HAND_SIZE`, o combate entra no **modo Descarte**
   (antes de `_enemy_turn`), com o aviso "Mão cheia: escolha N carta(s) para descartar".
2. As cartas ficam **escurecidas** (a mesma linguagem visual da Reação, SPEC-010); a **candidata
   sob o mouse** é realçada com borda vermelha e mostra o painel de detalhes (SPEC-018).
3. **Clique** na carta a descarta; as **teclas 1–5** também. Repete até chegar ao limite.
4. **Todas** as cartas podem ser escolhidas (Reação, uso único, HC), sem exceção. A carta
   descartada vai para a pilha de descarte (uma carta de uso único só sai do baralho quando é
   *jogada*, regra atual).
5. O **cronômetro do chefe** (45 s) não conta durante o descarte; ESC abre a pausa (SPEC-018).
6. O descarte só ocorre **no fim do turno**; durante o turno a mão pode passar de 5 (regra atual).

### 2. Ação básica compra 2
1. A Ação básica passa a **"Comprar 2"**: gasta a Ação e compra até 2 cartas (`Player.draw()` já
   embaralha o descarte quando o baralho acaba; se não houver carta, compra as que existirem).
2. **"Passar Ação"** continua, como botão separado, para quem não quer comprar.
3. O Bônus básico continua "comprar 1" (SPEC-005). Vale para **todos os personagens**.
4. Log/devlog e mensagens seguem o padrão: "X compra 2 cartas (Ação)".

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/state.py` | `excess_count()`, `discard_at(index)`; `discard_excess` deixa de ser usado no fluxo do jogador (fica para o descarte automático do inimigo/testes, se houver). |
| `game/app.py` | Estado `discard_pending`; entrada de clique/teclas; `_action_draw()`; botões "Comprar 2" e "Passar Ação" (layout do trilho, SPEC-016). |
| `game/ui/cards_widget.py` | Estado visual "escurecida" reutilizado; borda de candidata. |
| `game/ui/tutorial_content.py` | Páginas do turno e da compra atualizadas. |
| Testes | Excedente de 1 e de 2 cartas; escolha por clique e por tecla; sem excedente não entra no modo; "Comprar 2" gasta só a Ação; baralho vazio recompõe do descarte; compra parcial. |

## Fora do escopo

Mudar `MAX_HAND_SIZE`, descartar durante a compra, "Comunhão com Sendrinah" (SPEC-024), som.

## Critérios de aceite

- [x] Mão com 6+ cartas ao encerrar o turno abre o modo Descarte e o inimigo só age depois de escolher.
- [x] "Comprar 2" gasta a Ação e mantém o Bônus disponível.
- [x] O cronômetro do chefe não avança durante o descarte.
- [x] Testes passam.

## Ordem de execução

1. `Player.discard_at`/`excess_count` (core, com testes). 2. Modo Descarte na UI. 3. "Comprar 2". 4. Tutorial e playtest.
