# SPEC-002 — F1: harness de paridade e PyRandom

Status: aprovada (PLAN-001, F1). Executada.

## Problema
O core da origem usa o módulo `random` do Python (global e `Random(seed)`). O RNG do Godot é outro algoritmo, então nenhum vetor golden com semente seria reproduzível sem uma réplica do Mersenne Twister do CPython.

## Escopo
- `core/py_random.gd` (`PyRandom`): MT19937 idêntico ao CPython 3.14: seed(int), random, getrandbits, randbelow, randint, randrange, choice, choices (com pesos), shuffle, sample, uniform, gauss. Instância global `PyRandom.shared` no lugar de `random.*`.
- `tools/gen_golden.py`: gera `tests/golden/*.json` a partir do Python de origem; cada spec de porte (F2+) registra a sua seção.
- `tests/golden.gd`: carrega vetores e compara (floats com tolerância relativa 1e-12; inteiros grandes vão como string, pois o JSON do Godot lê números como float).
- Runner `tests/run_all.gd` passa a contar os testes executados.

## Decisão registrada
GUT **não** foi instalado: o runner próprio cobre a necessidade e evita dependência externa e risco de incompatibilidade com o Godot 4.7. Reavaliar se faltar recurso (mocks, parametrização).

## Critérios de aceite
1. `py_random`: 7 sementes (0, 1, 42, 12345, >2^32, >2^40, ~1e11) reproduzem todas as sequências do Python.
2. O teste falha de verdade quando o algoritmo é quebrado (sabotagem).

## Riscos conhecidos
- `sample` com `k>5` usa `ceil(log(3k,4))` em float, igual ao CPython; em potências exatas de 4 vale checar com vetor se for usado.
- `gauss` usa sin/cos/log da plataforma: tolerância de 1e-12, não exatidão de bits.
- `getrandbits` suporta até 63 bits (suficiente para o jogo).
