---
id: "SPEC-067"
type: "spec"
title: "Atributo nas opções da exploração"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
sources:
  - "Daniel (jogador DNA), evidências da v0.9.1, nota 1"
---

# Atributo nas opções da exploração

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-009, D18).

## 1. Regra
Ao passar o mouse na opção de uma situação, uma dica mostra o que o teste vale para quem vai rolar:
"Carisma +2 (você) contra CD 12", os bônus com a origem ("+2 armadura leve", "+1 gancho") e a chance ("precisa de 10 ou mais no d20").
Opção de combate (sem teste) não mostra dica de atributo.

## 2. Implementação
`exploration.check_preview(player, option)` puro devolve o atributo, o modificador, os bônus com origem, a CD e o valor mínimo do d20
(20 sempre passa, 1 sempre falha; desvantagem da armadura de placa avisada). A `SituacaoScreen` só desenha a dica. Sem arte.

## 3. Testes
Cada atributo; bônus de gancho, de acessório e de armadura furtiva; desvantagem; o mínimo do d20 nos extremos; opção de combate sem dica.
