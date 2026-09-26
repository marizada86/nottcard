---
id: "SPEC-017"
titulo: "Correção do bloco de notas F5 e cheat de QA"
status: "aprovada — aguardando validação no runtime Godot"
criado: "2026-09-26"
aprovacao: "Plano aprovado pelo Guilherme em 2026-09-26"
relacoes:
  - "SPEC-013-ferramentas-de-playtest-e-navegador-qa"
---

# SPEC-017 — Correção do bloco de notas F5 e cheat de QA

## Intenção

Restaurar o bloco de notas de playtest e reservar `Ctrl+O+P` para liberar
progresso de playtest em builds QA. O Navegador QA continua disponível pelo
menu **Ferramentas de teste**.

## Escopo

- F5 abre o bloco de notas sem acessar propriedades inexistentes de `TextEdit`.
- A nota é limitada a 1.000 caracteres e o contador continua fiel ao conteúdo.
- Em build QA, `Ctrl+O+P` define todos os personagens no nível 5 com XP no
  teto, libera conquistas, layouts, itens e personagens, e atualiza a coleção.
- O cheat persiste no save, informa a aplicação na tela e registra-a no log.
- A tentativa em andamento não é modificada; os efeitos valem ao iniciar a
  próxima.

## Fora de escopo

- Alterar o conteúdo, regras ou progressão de uma tentativa em andamento.
- Expor o cheat em builds de produção ou no tutorial de jogadores.
- Remover o Navegador QA ou seu acesso pelo menu de ferramentas.

## Critérios de aceite

- [ ] F5 abre sem erro e a nota não aceita mais de 1.000 caracteres.
- [ ] O contador mostra o tamanho efetivamente guardado.
- [ ] Em QA, `Ctrl+O+P` libera o progresso descrito e persiste-o.
- [ ] O atalho não cria nem altera uma tentativa em curso.
- [ ] O Navegador QA segue acessível pelo menu e o cheat não roda fora de QA.

## Plano de voo

1. Substituir o limite inválido de `TextEdit` por limitação no evento de texto.
2. Reatribuir o atalho ao cheat e aplicar somente mudanças no estado persistido.
3. Cobrir o truncamento e a liberação por testes automatizados.
4. Executar a suíte, validar os critérios e reconciliar esta spec e a SPEC-013.

## Evidência e reconciliação

- Testes de playtest passam para limite de texto e estado liberado.
- A SPEC-013 conserva o Navegador QA pelo menu; esta spec substitui somente o
  uso de `Ctrl+O+P` como atalho para ele.
