---
id: "FB-003"
type: "feedback"
title: "Notas do Higor sobre a v0.9.1: guia sempre visível, ícones nos botões, mão máxima e suspense da Corrente"
status: "draft"
created: "2026-09-20"
relations:
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
sources:
  - "Higor (game designer), notas repassadas pelo responsável em 2026-09-20, com um print do combate anexo (FB-003-anexo-icones-nos-botoes.png)"
---

# Notas do Higor sobre a v0.9.1 (2026-09-20)

Regra do responsável: as notas do Higor têm prioridade. Cada nota tem um id (`H13`..) para o plano e as specs apontarem.
O que o código faz hoje e a proposta estão no `PLAN-007`.

## 1. Índice

| Id | Tipo | Resumo |
|---|---|---|
| H13 | interface | A opção "Guia do playtester" deve ficar sempre visível, inclusive nas lutas |
| H14 | interface / clareza | "Comprar 1 carta (Bônus)" confunde: parece carta bônus grátis. Trocar o texto pelo ícone da ação |
| H15 | regra (loja) | Ao desbloquear uma conquista, liberar na loja "Aumentar o número máximo de cartas na mão" |
| H16 | bug de apresentação | Ao atacar, a Corrente quebra antes de o resultado do dado aparecer, estragando o suspense da rolagem |

Pedido do responsável junto das notas: **analisar todos os assets criados e refazer o build.**

## 2. As notas, como enviadas

1. (H13) A opção "Guia do playtester" deve ficar a todo momento aparente, incluindo as lutas. No momento aparece somente quando abre o
   jogo e no menu inicial.
2. (H14) Na batalha, "Comprar 1 carta (Bônus)" deve conter "Comprar 1 carta (Ação Bônus)": somente "Bônus" pode confundir o
   usuário a achar que é uma carta bônus, ou seja, uma carta grátis. Uma solução pode ser a opção "Comprar 1 carta (Ação)" substituir
   "(Ação)" pelo ícone que o representa e fazer o mesmo com "Comprar 1 carta (Bônus)": substituir o texto entre parênteses por ícone,
   como no anexo. (O anexo mostra os ícones de Ação e de Bônus do trilho da direita ligados por setas aos dois botões.)
3. (H15) Ao desbloquear uma conquista, liberar na loja "Aumentar o número máx. de cartas na mão".
4. (H16) Ao atacar, a Corrente quebra antes que o resultado do dado seja mostrado, quebrando o suspense da rolagem de dados.
