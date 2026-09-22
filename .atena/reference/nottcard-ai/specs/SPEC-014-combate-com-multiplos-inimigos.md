---
id: "SPEC-014"
type: "spec"
title: "Combate com múltiplos inimigos e nova sala da M1"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-003-dano-flutuante-e-eliminacao]]"
  - "[[SPEC-004-cadencia-do-combate]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SIS-003-fileira-de-inimigos-exploracao-com-cartas-hud]]"
sources:
  - "Decisões do responsável em 2026-09-19: combate com 2–3 inimigos; Criatura + 2 Slimes; sala nova entre a 5 e a 6; todos os inimigos atacam, da esquerda para a direita"
---

# Combate com múltiplos inimigos

## Declaração

Hoje um combate tem exatamente 1 inimigo. Esta spec permite um grupo de 2–3 inimigos
e adiciona à M1 um combate de grupo. É pré-requisito da Bola de Fogo do Maelor
(SPEC-012). Não muda o combate dos demais salões nem o comportamento do Durvall.

## Regras

1. **Sala nova** entre "O porão — sala de livros" (5) e "O ritual" (6, chefe): combate
   contra **Criatura corrompida + 2 Slimes corrosivos** (8 + 6 + 6 = 20 PV). O chefe passa
   a ser a sala 7; `asset_id` das salas existentes não muda. A sala nova usa um
   `asset_id` novo (sem arte, cai no fallback).
2. **Alvo:** cartas de alvo único (`ataque`, `controle`) usam a linha de mira já existente
   e vão no inimigo escolhido. Cartas de área (`Card.area`) não pedem alvo e atingem todos
   os inimigos vivos.
3. **Turno inimigo:** **todos os inimigos vivos atacam**, da esquerda para a direita,
   cada um com o próprio teste de acerto (SPEC-006) contra a CA/CAM do jogador.
4. **Redução da Névoa Fria** é por inimigo (`Enemy.next_attack_reduction` já é por
   instância): reduz só o próximo ataque do alvo escolhido.
5. **Eliminação individual** (SPEC-003): cada inimigo cai quando o PV chega a 0, os
   sobreviventes seguem atacando. O combate termina quando **todos** caem.
6. O temporizador do chefe (`boss_timeout_expired`) só vale para combate de chefe; o
   combate de grupo não tem.
7. **Ações do turno do jogador** (SPEC-005) e a **Corrente** não mudam: uma carta de área
   é **uma** carta jogada.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/rooms.py` | `Room.enemy_factory` passa a devolver `list[Enemy]` (ou nova `enemy_factories`); sala nova; chefe vira sala 7. **Mudança de core.** |
| `game/core/combat.py` | `apply_enemy_action` já é por inimigo — só um laço sobre os vivos; helper `resolve_area_attack`. |
| `game/app.py` | Estado de combate com lista de inimigos; alvo selecionado; fim quando todos caem. |
| `game/ui/` | Fileira de inimigos lado a lado (SIS-003), barra de PV e alvo destacado por inimigo; números flutuantes por alvo. |
| Testes | Sala com 3 inimigos; todos atacam em ordem; eliminação individual; fim só com todos mortos; Névoa Fria só no alvo; salas antigas iguais a antes. |

## Pendente / fora do escopo

Balanceamento fino do grupo (playtest, `EVID-004`); arte da sala nova; inimigos que
morrem trocando de posição na fileira; comportamento com a Reação da SPEC-010 (ainda
rascunho) quando vários inimigos atacam no mesmo turno.
