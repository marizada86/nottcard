---
id: "SPEC-071"
type: "spec"
title: "Barra de XP acima do retrato na seleção"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
sources:
  - "Daniel (jogador DNA), evidências da v0.9.1, nota 8 do zip 161744"
---

# Barra de XP acima do retrato na seleção

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-009, D18).

## 1. Regra
A barra de XP sai de cima da foto e vai para uma faixa própria **acima do retrato**, com "XP 40/100 · Nível 2". Nada cobre a foto.

## 2. Implementação
Ajuste de layout da tela de seleção (retângulo da barra fora do retângulo do retrato).

## 3. Testes
A barra não intersecta o retrato nos 5 personagens, na janela, em tela cheia e redimensionada.
