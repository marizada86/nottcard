---
id: "SPEC-058"
type: "spec"
title: "Caminhada em primeira pessoa, W4: texturas e adereços do mundo (arte)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-005-caminhada-em-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-056-renderizador-do-mundo]]"
sources:
  - "Responsável, 2026-09-20: todas as decisões do PLAN-005 aprovadas conforme as recomendações; \"vamos seguir\""
---

# Texturas e adereços do mundo (W4)

> **Aprovada em 2026-09-20**. **Nunca bloqueia código:** sem a textura, o mundo usa o recorte do cenário pintado e, sem ele, cor lisa.

## 1. Convenção
- `assets/world/<ambiente>/wall.png`, `floor.png`, `ceiling.png`: **ladrilháveis** (128x128, emenda invisível em 3x3), pixel art
  sombria de `SIS-004`. Ambientes: `docas`, `cais`, `rachadura`, `porao`, `biblioteca`, `corredor`, `ritual`.
- `assets/world/props/<nome>.png`: adereços em cartaz com alfa (tocha, barril, caixote, livros, braseiro, rede): ~8.
- Portas: as `assets/doors/porta_*.png` (já existem) viram a textura da porta no mundo.
- Prompts em `.atena/generated/ART-PROMPTS-016-mundo-*.md`, gerados depois da aprovação do W0/W2 e conferidos por uma amostra 3x3.
- `scripts/process_art.py` ganha a categoria `world` (redução suave para 128x128, sem chroma, com alfa só nos adereços).

## 2. Aceite
1. As 7 salas com paredes, piso e teto próprios; costuras sem emenda visível.
2. Fallback: sem arquivo, recorte do cenário pintado; sem ele, cor lisa.
