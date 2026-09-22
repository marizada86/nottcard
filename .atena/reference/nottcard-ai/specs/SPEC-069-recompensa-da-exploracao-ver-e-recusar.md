---
id: "SPEC-069"
type: "spec"
title: "Recompensa da exploração: ver e recusar"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
  - "[[SPEC-036-mochila-e-itens]]"
sources:
  - "Daniel (jogador DNA), evidências da v0.9.1, nota 3"
---

# Recompensa da exploração: ver e recusar

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-009, D17 e D18).

## 1. Regra
- O desfecho de sucesso de uma opção (XP, cartas, item) é mostrado **antes** de aplicar: nome e efeito do item, a carta comprada, o XP.
  Na opção aparece de antemão o **tipo** de recompensa, sem revelar qual carta sai.
- Botões **Aceitar** e **Recusar** para o que é opcional (item e cartas); o XP entra sempre.
- **Recusar não troca por outra coisa** e não devolve o d20 nem a Sorte. Uma carta recusada não é comprada; o item recusado não vai para a mochila.
- A falha crítica não tem recompensa para recusar.

## 2. Implementação
`apply_result` passa a devolver uma **oferta** (`Applied` com `pending_reward`) com `accept()` e `decline()`; a `SituacaoScreen` mostra a
oferta e só então aplica. Mochila cheia segue o fluxo da SPEC-036. A mesma tela "aceitar ou recusar" serve depois à loja e aos eventos.

## 3. Testes
Aceitar entrega; recusar não entrega nem cobra; o XP entra nos dois casos; mochila cheia; falha crítica sem oferta; a Sorte não devolve a recusa.
