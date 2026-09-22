---
id: "SPEC-076"
type: "spec"
title: "Loja da exploração e cartas/itens temporários"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-010-ouro-carisma-e-eventos-aleatorios-2026-09-20]]"
  - "[[SPEC-074-motor-de-eventos-aleatorios]]"
  - "[[SPEC-036-mochila-e-itens]]"
sources:
  - "Responsável, 2026-09-20: loja do modo exploração com cartas e itens temporários"
---

# Loja da exploração e cartas/itens temporários

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-010, D20, D24 e D25).

## 1. Temporários
Carta ou item de evento entra **no `Player` da tentativa** e some com ele (o `Player` e a mochila nascem novos a cada tentativa; coleção, baralho e save não são tocados).
Só cartas **comuns e incomuns**, no máximo **2 cartas e 1 item por missão**. A carta entra no baralho de compra, embaralhada; o item na mochila (cheia: fluxo da SPEC-036).
A carta na mão ganha o selo "TEMPORÁRIA", como o de "USO ÚNICO".

## 2. Loja
Um mercador com **3 cartas e 1 item temporários**, pagos só com a **bolsa da missão** (cartas 20 a 35, item 25 a 45, poção 15); "Trocar a oferta" custa 10. O ouro gasto
não vira moeda da cidade no fim. Usa a tela "aceitar ou recusar" da SPEC-069.

## 3. Testes
Nada de temporário chega ao save nem à coleção; limites de 2 e 1; só raridades permitidas; compra desconta a bolsa; sem saldo; trocar a oferta; item com a mochila cheia; o selo na carta.
