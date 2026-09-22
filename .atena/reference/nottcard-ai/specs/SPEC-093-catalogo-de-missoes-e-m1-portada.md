---
id: "SPEC-093"
type: "spec"
title: "Catálogo de missões (MissionDef) e M1 portada"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-016-m2-praca-da-loucura-2026-09-20]]"
  - "[[PLAN-018-implementacao-de-m2-2026-09-20]]"
  - "[[PLAN-020-roteiro-geral-de-implementacao-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'tudo aprovado' (PLAN-018, etapa 1); implementação na mesma leva"
---

# Catálogo de missões e M1 portada

## O que muda
- Novo `core/missions.py` (sem pygame): `MissionDef` congelado com `id`, `title`, `briefing`, `cast` (elenco canônico, coluna "Elenco disponível" do
  VSN-003), `requires`, `rooms`, `edges`, `start`, `dungeon` (módulo da masmorra em grade), `situations`, `lore`, `completion_xp`, `boss_id`,
  `event_ids`/`event_rooms`, `ambientes` (texturas do mundo), `exit_hq` e `briefing_hq`. Catálogo `MISSIONS = {"m1", "m2"}`, missão ativa
  `current()`/`set_current()`, `fog_for_backdrop` e `is_unlocked`.
- **M1 é o mesmo dado de sempre** (`rooms`, `dungeon_m1`, `exploration.SITUATIONS`, `lore_m1`), apenas dentro da fronteira nova.
- O `App` ganha `mission` e `start_run(..., mission_id=)`; salas, mundo (`WorldMap`), masmorra, portas travadas, situações, lore, XP de conclusão, eventos
  e recompensa do chefe leem a missão ativa. As telas (`walk_screen`, `world_art`, `automap`, `corridor_view`, `map_view`, `scenes_data`, `combat_view`,
  `result_panel`, `tutorial_content`, `evidence_export`) trocaram os globais de M1 por consultas à missão ativa.
- `dungeon_m1` ganha `build_grid` e `pick_event_cell` genéricos, que a masmorra de M2 também usa.

## Teste dourado
`tests/core/test_missions.py` congela M1 (salas, arestas, XP, chefe, hash do mapa em texto, célula de evento com semente fixa). A suíte de M1 inteira
(1.700+ testes) segue verde sem mudar um valor.

## Fora
Nenhum conteúdo novo de jogo nesta SPEC (M2 entra na SPEC-096/097).
