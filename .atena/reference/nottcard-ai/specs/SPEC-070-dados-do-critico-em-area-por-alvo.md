---
id: "SPEC-070"
type: "spec"
title: "Dados do crítico em área, por alvo"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
  - "[[SPEC-012-ataque-em-area]]"
sources:
  - "Daniel (jogador DNA), evidências da v0.9.1, notas 6 e 7"
---

# Dados do crítico em área, por alvo

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-009, D18).

## 1. Regra
Em ataque de área, cada alvo tem o **seu grupo de dados** desenhado acima do próprio inimigo (o lugar do resultado do d20), com o
rótulo "crítico: 4d4" no alvo que dobrou. A rolagem é simultânea e a soma sobe no impacto. Com um único alvo, os dados ficam no centro como hoje.
O cálculo do núcleo não muda (o log já confirma 4d4 no alvo do crítico e 2d4 nos outros).

## 2. Implementação
`_play_area_attack` monta uma `Beat` de dados com um grupo por alvo, com o deslocamento derivado do `slot.rect`; a legenda "crítico" usa
`AttackResult.hit.crit`. Muitos dados por alvo se apertam como já se apertam no centro.

## 3. Testes
Número de dados por alvo; posição junto do inimigo certo; crítico em um de três alvos; alvo único inalterado.
