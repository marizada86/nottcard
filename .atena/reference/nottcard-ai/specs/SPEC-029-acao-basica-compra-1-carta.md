---
id: "SPEC-029"
type: "spec"
title: "A Ação básica compra 1 carta (não 2)"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-020-mao-cheia-descarte-por-escolha-e-acao-compra-2]]"
sources:
  - "Playtest, 2026-09-19 (pedido direto do responsável)"
---

# Ação básica: comprar 1 carta

## Regra

O botão da Ação passa de "Comprar 2 cartas (Ação)" a **"Comprar 1 carta (Ação)"**: gasta a Ação e compra
**1** carta (antes: até 2). Vale a regra de sempre do baralho: se ele acabar, o descarte é embaralhado de
volta. Sem carta em lugar nenhum, a Ação se gasta e não compra nada. A Ação Bônus continua comprando 1.
Isto altera o "Comprar 2" da SPEC-020; o descarte por escolha e o limite de mão dela seguem valendo.

O botão é `action_draw_button` no código (era `draw_two_button`); o tutorial foi atualizado.

## Critérios de aceite

- [x] O botão e o texto do tutorial dizem "Comprar 1 carta (Ação)".
- [x] A Ação compra 1 carta e gasta só a Ação.
- [ ] Playtest.
