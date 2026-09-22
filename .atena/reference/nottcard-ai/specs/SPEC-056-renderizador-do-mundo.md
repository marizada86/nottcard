---
id: "SPEC-056"
type: "spec"
title: "Caminhada em primeira pessoa, W2: renderizador do mundo (raycast texturizado)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-005-caminhada-em-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-055-mapa-em-grade-e-caminhante]]"
sources:
  - "Responsável, 2026-09-20: todas as decisões do PLAN-005 aprovadas conforme as recomendações; \"vamos seguir\""
---

# Renderizador do mundo (W2)

> **Aprovada em 2026-09-20**. Só desenho (`game/ui/`). Sem dependência nova (nada de numpy).

## 1. Especificação
- `game/ui/raycast.py` (sem desenho): DDA por coluna (`cast_ray`), vetores da câmera, projeção de sprites; função pura e testada.
- `game/ui/world_view.py`: o quadro é desenhado em resolução interna de 640x360 e ampliado 2x (pixel art). Paredes em fatias de textura
  pré-cortadas e escurecidas em 4 níveis de distância (névoa); piso e teto por projeção em resolução menor; sprites (inimigos e
  marcadores) como cartazes, com oclusão pelas paredes por coluna; portas abertas somem.
- `game/ui/world_art.py`: qual textura de parede, piso, teto e porta cada sala usa (dados). Enquanto as texturas ladrilháveis da
  SPEC-058 não existirem, saem de recortes do cenário pintado da sala (`rooms/<sala>/bg.png`).
- Animação de passo (0,28 s) e giro (0,22 s) com aceleração suave; com "reduzir movimento" os comandos cortam sem animar.

## 2. Aceite
1. 60 fps em 1280x720 numa máquina de teste (meta: quadro do mundo abaixo de 12 ms).
2. Nada vaza pelas frestas nem aparece borda; o giro de 360° fecha sem salto.
3. Um sprite atrás de uma parede não aparece; um sprite à frente cresce ao se aproximar.
4. Sem nenhuma textura da sala, o mundo desenha cores lisas (fallback).
