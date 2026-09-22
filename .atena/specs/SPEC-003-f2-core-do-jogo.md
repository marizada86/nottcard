# SPEC-003 — F2/F3: o core do jogo em GDScript, com paridade

Status: aprovada (PLAN-001). Executada em 2026-09-21.

## Baseline
A origem continua evoluindo (SPEC-110/111 em andamento, sem commit). O porte segue o **commit c118d16 (v0.18.0)**, extraído por `git archive`
para `.baseline/v0.18.0/` (ignorado pelo git; recriar com `git -C <nottcard-ai> archive c118d16 game | tar -x -C .baseline/v0.18.0`).
`tools/export_data.py`, `tools/gen_golden.py` e `tools/gen_dataclasses.py` usam esse snapshot por padrão.
Mudanças da origem depois do baseline entram por specs de sincronização (ex.: SPEC-110: Dupla pela HQ, 2º baralho, personagens a 100 moedas).

## O que foi portado (core/)
Aleatoriedade (`PyRandom`), dados, atributos, cartas, personagens, inimigos, turno, testes de morte, combate (Corrente, acerto, dano, reações,
Cópia Sombria, Guarda, Poder Místico, pergaminhos), Player, grupo, coleção e baralho, upgrades, economia, progresso e save (`SaveState`), equipamento,
pergaminhos, mochila, exploração (testes de d20, Sorte, recompensas), eventos e plano de eventos, mapa de nós, grade, caminhada, portão de passagem,
missões M1/M2, loja, conquistas, layouts, elenco.
Conteúdo declarativo vem de `data/core/*.json`, exportado do Python (`tools/export_data.py`); fábricas de inimigos e salas são código (`Enemies`, `Rooms`).

## Como a paridade é provada
`tools/gen_golden.py` roda o Python e grava `tests/golden/*.json`; `tests/cases/*.gd` repetem os mesmos cenários em GDScript e comparam:
- 69 lutas completas (12 combinações de personagem/nível/inimigos x sementes, mais pergaminhos e upgrades), passo a passo: rolagens, dano, Corrente, PV, mão e pilhas;
- 180 testes de exploração, planos e situações de eventos, 5 caminhadas de 140 passos, todos os ramos de coleção/loja/conquistas/elenco/grupo.
- `test_compile.gd` garante que todo script compila.

## Fora desta spec
Bundle/evidência (pacote de playtest), textbuffer, combat_narration e o `profile`/`save_file` em disco (F5, com a UI). A camada `app.py` (4k linhas) e toda a UI são as fases F4–F7.
