# SPEC-001 — F0: bootstrap do projeto Godot

Status: aprovada (plano `PLAN-001`, aprovado em 2026-09-21). Executada.

## Escopo
- `project.godot` (Godot 4.7.2, GL Compatibility, viewport lógico 1280x720 como `WINDOW_SIZE` da origem, filtro nearest, stretch canvas_items).
- Estrutura `core/ ui/ data/ tests/ tools/ assets/`.
- `assets/` copiado da origem, sem `_raw` (731 MB, bruto) e `concepts` (não referenciado pelo código). 61 MB.
- Referência somente leitura da origem em `.atena/reference/nottcard-ai/` (specs + vault).
- Runner de teste mínimo `tests/run_all.gd` (troca por GUT na F1).

## Critérios de aceite
1. `--import` headless conclui sem erro.
2. `-s tests/run_all.gd` roda com 0 falhas.
3. Cena principal abre e imprime a versão de paridade (0.18.0).

## Evidência
Os três critérios passaram em 2026-09-21 com `Godot_v4.7.2-stable_win64_console.exe` (ver `evidence/EVID-001-f0.md`).
