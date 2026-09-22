---
id: "SPEC-065"
type: "spec"
title: "Mão Maior: upgrade de loja liberado pela Fechadura Aberta"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
  - "[[SPEC-045-loja-de-upgrades-e-regras-do-baralho]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
sources:
  - "Higor, v0.9.1 (H15) e resposta de 2026-09-20"
---

# Mão Maior: upgrade de loja liberado pela Fechadura Aberta

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D4, D5 do PLAN-007).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Regra
- Upgrade `mao_maior`: +1 no máximo de cartas na mão, 2 níveis (5→6→7), custos iniciais 600 e 1800 (a calibrar).
- `titulo_requerido` = conquista **Fechadura Aberta** (concluir a primeira missão): a conquista **libera a compra** na loja; antes, aparece bloqueado com "Requer: Fechadura Aberta".
- Teto +2 (mão de 7). Não muda Corrente, dano nem cura.

## 2. Núcleo
`MAX_HAND_SIZE` vira `BASE_MAX_HAND = 5`; `upgrades.hand_limit(upgrades)` = 5 + nível; `Player` guarda o limite; `excess_count`, `discard_excess`, mão inicial e exploração usam-no. O teto do "Mão Cheia" acompanha. Tutorial e teclas de descarte (1 a N) dinâmicos. Save antigo: nível 0, sem migração. Catálogo de conquistas lista todos os itens liberados por um título.

## 3. Verificação
Simulador: `scripts/simulate.py` nunca descarta o excesso da mão (compra 1 por turno sem limite), então já se comporta como mão ilimitada e não mede este upgrade; o efeito é só reter 1 ou 2 cartas a mais no fim do turno (não muda Corrente, dano nem cura). Conferir no playtest. Testes: limite 5/6/7, descarte e mão inicial, bloqueio sem a conquista e liberação com ela, compra cobra, save antigo, mão de 7 sem sobrepor o orbe.
