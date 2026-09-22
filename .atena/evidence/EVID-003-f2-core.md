# EVID-003 — core em GDScript
`Godot_v4.7.2-stable_win64_console.exe --headless --path . -s tests/run_all.gd` → "testes executados: 29, falhas: 0" (2026-09-21).
Sabotagens conferidas (cada uma derrubou o teste certo e foi revertida): HP_LEVEL_SCALE, AREA_CONTROL_FACTOR, fator de cor fora da classe, CRITICAL_MIN_HP_LOSS.
Regenerar os vetores: `python tools/gen_golden.py`; dados: `python tools/export_data.py`.
