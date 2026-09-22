---
id: "SPEC-068"
type: "spec"
title: "Faixa de turno no combate"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
sources:
  - "Daniel (jogador DNA), evidências da v0.9.1, nota 2"
---

# Faixa de turno no combate

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-009, D18).

## 1. Regra
Uma faixa curta no topo do combate, com texto e ícone (não só cor): "Seu turno" (com o nome do personagem ativo no grupo),
"Turno do inimigo" e o nome de quem age. Dura cerca de 1,2 s por troca, não bloqueia o input e acompanha a velocidade 1x/2x e a pausa.
Nenhuma regra muda.

## 2. Implementação
Batidas sem duração já existentes disparam a faixa: `_start_turn` (Seu turno) e o início do turno inimigo (`_after_player_action`).
A faixa é estado de tela (`banner_turn`, tempo restante) desenhado em `combat_view`; usa o relógio de animação da tela.

## 3. Testes
Ordem correta em combate de 1 inimigo, de 3 inimigos e em grupo; some sozinha; não aparece na exploração; respeita a pausa e o 2x.
