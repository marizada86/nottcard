---
id: "SPEC-057"
type: "spec"
title: "Caminhada em primeira pessoa, W3: exploração por caminhada (WalkScreen)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-005-caminhada-em-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-055-mapa-em-grade-e-caminhante]]"
  - "[[SPEC-056-renderizador-do-mundo]]"
  - "[[SPEC-053-corredor-portas-e-recompensas-primeira-pessoa-fp2-fp3]]"
sources:
  - "Responsável, 2026-09-20: todas as decisões do PLAN-005 aprovadas conforme as recomendações; \"vamos seguir\""
---

# Exploração por caminhada (W3)

> **Aprovada em 2026-09-20**. Liga o núcleo (SPEC-055) e o renderizador (SPEC-056) ao jogo. O `WorldMap` e as telas de combate,
> situação e recompensa **não mudam**.

## 1. Especificação
- **`WalkScreen`** substitui o `MapaScreen` como tela de exploração. Controles: **W** ou seta para cima avança; **S** ou seta para baixo
  recua (mantendo a frente); **A** e **D** ou setas laterais viram 90°; **X** meia-volta; **M** automapa; botões na tela para quem
  joga só com o mouse; a `Camera` do mouse dá um balanço leve ao mundo (some com "reduzir movimento"). Um comando fica na fila
  enquanto o passo anterior termina; segurar a tecla repete.
- **Salas:** cruzar a soleira de uma sala vizinha chama `world.move_to`. **Encontro:** cada sala não resolvida tem uma âncora. Chegar a
  2 células dela (combate) ou a 1 célula (situação) abre a tela de hoje (`_enter_room`). Os inimigos da sala aparecem como sprites
  (`assets/enemies/*.png`, o grupo da sala 6 alinhado) e os pontos de situação como um marcador. Salas limpas só se atravessam.
- **Volta:** depois do combate ou da situação o jogador reaparece **na mesma célula e direção**; a posição não vai para o save.
- **Automapa** (`game/ui/automap.py`, tecla M): células visitadas reveladas, sala atual e seta do jogador; um botão leva ao mapa de
  salas atual (`NodeMapScreen`).
- **Modo clássico:** `MapaScreen` (portas, SPEC-053) fica como opção. `perfil.json` guarda `"exploracao": "caminhada" | "classica"`;
  padrão **caminhada**; sem perfil (o `App()` dos testes) o padrão é **clássica**. Alternável no menu principal.
- **Reduzir movimento:** passos e giros viram cortes instantâneos.

## 2. Aceite
1. A missão M1 completa andando, da sala 1 ao chefe, incluindo o beco da Rachadura e voltar por salas limpas.
2. Combate e situação abrem ao chegar perto e o jogador volta à mesma célula e direção.
3. Nenhum trajeto atravessa uma sala não resolvida sem disparar o encontro dela.
4. O modo clássico continua funcionando, com os testes existentes.
