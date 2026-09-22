---
id: "SPEC-096"
type: "spec"
title: "M2 — A Praça da Loucura: mapa, exploração e narrativa"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-093-catalogo-de-missoes-e-m1-portada]]"
  - "[[PLAN-016-m2-praca-da-loucura-2026-09-20]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[ART-PROMPTS-022-m2-praca-da-loucura-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'tudo aprovado' (PLAN-016/018, etapa 3); a ocarina sai de M2"
---

# M2 — mapa, exploração e narrativa

- **Seis espaços em linha** (sem bifurcação): Entrada de Dagruve → Praça externa → Beco das sentinelas → Porta da igreja → Nave profanada → Altar da
  Mente Derretida. Grafo `1-2-3-4-5-6`; masmorra em grade `dungeon_m2` (portas, âncoras, células de inimigo e adereços); modo de portas e caminhada, com a
  colisão e a porta travada da SPEC-086 valendo igual.
- **Situações:** entrada (Arlindo Orlando: "Ouvir o que Arlindo sabe" por Carisma ou "Perguntar aos vizinhos" por Inteligência; vantagem pequena, nunca bloqueio) e
  porta da igreja (pistas do ritual: Inteligência, Força ou Constituição; item ou XP). Lore de sala, sabor de inimigo e fim de missão em `lore_m2` (sem entidade
  nem spoiler: o garoto não é identificado como receptáculo; nada do segredo do Durvall).
- **Eventos:** `MissionDef.event_ids` = baú, mercador, altar e viajante (a "fenda de névoa" é de M1), nas salas 2 a 5.
- **Itens narrativos:** vencer a M2 guarda o **mapa de Dagruve** em `SaveState.story_items` (abre a M3, ainda não jogável). A **ocarina foi retirada** por
  decisão do responsável; poção de força de gigante do gelo e gema elemental ficam como próximas recompensas de itens (fora deste corte).
- **Mundo:** ambientes `dagruve_entrada`, `praca`, `beco`, `igreja_porta`, `nave`, `altar` (texturas em `assets/world/<ambiente>`, com o fallback de sempre);
  portas por sala (`porta_madeira`, `porta_pedra`, `porta_igreja` nova, `porta_ritual`); M2 **sem névoa** (`Room.fog` nulo).
- **Arte processada** (ART-PROMPTS-021/022): inimigos de corpo inteiro, cenas das salas 1 a 4, parede de Dagruve, `porta_igreja`. O que falta (salas 5 e 6,
  texturas, adereços, retratos, itens, HQs) cai no fallback e não bloqueia.

## Testes
`tests/core/test_missions.py` (estrutura, conectividade da grade, 10 a 14 cultistas, eventos) e `tests/ui/test_m2_flow.py` (M2 nos dois modos, texturas e portas).
