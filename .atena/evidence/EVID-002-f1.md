# EVID-002 — F1
- `python tools/gen_golden.py` → `tests/golden/py_random.json`.
- `Godot_v4.7.2-stable_win64_console.exe --headless --path . -s tests/run_all.gd` → "testes executados: 3, falhas: 0".
- Sabotagem (constante do MT trocada de 1664525 para 1664526): "FAIL test_py_random.gd.test_golden: seed=0 random[0]: 0.166 != 0.844", 1 falha. Revertido, volta a 0 falhas.
