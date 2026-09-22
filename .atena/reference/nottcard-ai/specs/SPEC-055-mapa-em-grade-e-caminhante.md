---
id: "SPEC-055"
type: "spec"
title: "Caminhada em primeira pessoa, W1: mapa em grade e caminhante (núcleo)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-005-caminhada-em-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
sources:
  - "Responsável, 2026-09-20: todas as decisões do PLAN-005 aprovadas conforme as recomendações; \"vamos seguir\""
---

# Mapa em grade e caminhante (W1)

> **Aprovada em 2026-09-20** (`execution_approval: per-spec`), junto do PLAN-005. Só `core`, **sem pygame**. Não muda o `WorldMap`.

## 1. Objetivo
Um mundo em grade que o jogador percorre andando, recuando e virando, com regras testáveis sem janela.

## 2. Especificação
- `game/core/gridmap.py`: `GridMap` (linhas de texto: `#` parede, `.` chão, `D` porta), regiões retangulares por sala
  (`room_at(x, y)`), `passable`, direções `N, L, S, O` (`DIRS`), leitura por texto (`from_rows`).
- `game/core/walker.py`: `Walker(grid, x, y, facing)` com `forward()`, `backward()`, `turn_left()`, `turn_right()` e `about_face()`.
  Cada comando devolve **eventos**: `Moved`, `Turned`, `Blocked` (parede), `DoorOpened` e `EnteredRoom(sala)`. Recuar mantém a
  frente. Uma porta fechada abre quando o jogador entra nela e fica aberta. `visited` guarda as células vistas (automapa).
- `game/core/dungeon_m1.py`: o desenho do M1 (dados: retângulos das salas, corredores, portas, âncoras de encontro e a partida).
  O caminho físico segue **exatamente** as arestas de `M1_EDGES`: 1-2, 2-3, 2-4, 4-5, 5-6, 6-7.
- **Âncora** de cada sala: a célula onde o encontro ou a situação acontece (centro da sala, ou o fundo do corredor da sala 6).

## 3. Aceite
1. Paredes bloqueiam; virar 4 vezes volta à direção original; recuar mantém a frente.
2. Andar de 1 até 7 passa pelas salas 2, 4, 5, 6 e 7, nesta ordem, e nenhuma sala é alcançável sem passar pelas vizinhas do grafo.
3. `EnteredRoom` sai uma vez por entrada em uma região; portas abrem uma vez.
4. Uma âncora está a no máximo 2 células (Chebyshev) de qualquer trajeto que atravesse a sala.
