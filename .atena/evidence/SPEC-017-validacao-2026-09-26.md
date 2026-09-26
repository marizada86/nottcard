# SPEC-017 — Registro de validação

Data: 2026-09-26

## Verificações concluídas

- A busca no código não encontrou mais atribuição a `TextEdit.max_length`.
- A revisão estática confirma que `Ctrl+O+P` chama `_apply_qa_cheat()` somente
  sob `BuildConfig.qa_tools_enabled()`.
- O menu **Ferramentas de teste** continua chamando `open_qa_navigator()`.
- `git diff --check` terminou sem erros de whitespace.

## Validação pendente

A suíte `godot --headless --path . -s tests/run_all.gd -- test_playtest_tools`
não pôde ser iniciada porque o executável `godot` não está disponível no PATH
e não há runtime portátil dentro deste checkout. Portanto os critérios que
dependem de execução do Godot (F5 real, atalho real e testes) aguardam um
runtime Godot 4.x disponível.
