---
id: "SPEC-098"
type: "spec"
title: "Vantagem e desvantagem no d20"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
  - "[[SPEC-099-baralho-base-esquiva-e-pocoes]]"
sources:
  - "Responsável, 2026-09-21: mecânica de vantagem/desvantagem como no D&D; 'tudo confirmado'"
---

# Vantagem e desvantagem

## Regra
- `dice.roll_d20(state)`, `state ∈ {"normal", "vantagem", "desvantagem"}`: vantagem rola 2d20 e fica o **maior**; desvantagem fica o **menor**. Vantagem e
  desvantagem ao mesmo tempo **se anulam** (rola 1d20). Função pura ao lado de `roll`; `combat._d20()` passa a recebê-lo.
- `combine(*states)` resolve várias fontes: havendo vantagem e desvantagem entre elas, o resultado é normal.
- Crítico (20) e falha crítica (1) valem só no dado **mantido**.
- Guardam `d20`, `d20_descartado` (ou `None`) e `estado`: `HitResult`, `StunCheck`, `PendingEnemyAttack` e os testes de `exploration.py`. `total`/`hit` não mudam.
- **Aplica-se a:** acerto do jogador, ataque inimigo, atordoamento, testes de exploração/situações. **Não** aos testes de morte (`death_saves.py`) nem ao agarrar do mímico.

## Fontes
- **Desvantagem** no ataque inimigo: a Esquiva (SPEC-099).
- **Vantagem** no acerto do jogador: Golpe Furtivo (quando o bônus furtivo vale) e a furtividade da SPEC-047. Localizar Criatura/Visão Verdadeira **mantêm** o +2/+3.
- **Vantagem do inimigo** contra o jogador: Ataque Imprudente **troca** "acerta sem teste" por vantagem dos inimigos até o fim do próximo turno inimigo (o campo
  `exposes` segue, o efeito muda; o crítico sem teste some). Texto da carta e do tutorial atualizados.
- Campos de carta novos: `advantage_on_hit: bool`, `forces_disadvantage: bool` (este usado pela SPEC-099).

## Interface
- `dice_widget`: com estado ≠ normal desenha **2 dados d20** lado a lado; o descartado fica apagado. Números com contraste (SPEC-102).
- Log de combate: "Vantagem: 17 e 4 → 17" / "Desvantagem: 15 e 6 → 6". Selo "VANT."/"DESV." junto ao teste.
- Tutorial e "Como jogar": um parágrafo sobre a regra.

## Testes
`tests/core/test_advantage.py`: com `random` semeado, média vantagem > normal > desvantagem; anulação; crítico só no dado mantido; cada teste guarda os dois
dados; testes de morte seguem com 1d20. `tests/ui`: o widget desenha 2 dados e o log traz a linha.
