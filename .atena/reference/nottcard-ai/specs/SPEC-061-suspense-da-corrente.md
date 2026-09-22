---
id: "SPEC-061"
type: "spec"
title: "Suspense da Corrente: recursos só mudam na revelação"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
  - "[[SPEC-025-corrente-quebra-no-erro-e-ajustes-durvall-maelor]]"
sources:
  - "Higor, v0.9.1 (H16): a Corrente quebra antes do resultado do dado"
---

# Suspense da Corrente: recursos só mudam na revelação

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D3 do PLAN-007).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Problema
`resolve_attack` roda na hora e já quebra/avança a Corrente; o indicador lê `player.combo` ao vivo, então "Corrente perdida" aparece com o d20 ainda girando.

## 2. Regra
Separar estado real de estado mostrado (como o PV já faz com `hp_shown`).
- `ComboTracker.view()` (núcleo) devolve uma foto congelada: sequência, `broken_from`, `changes`, Poder Místico, multiplicador da próxima carta. A tela guarda a foto de antes da jogada.
- Batida sem duração `"corrente"` atualiza a foto mostrada na revelação: acerto, no início do impacto; erro, com o "Errou!"; área, depois dos d20 de todos os alvos; atordoamento que falha, no resultado do teste.
- `draw_combo_indicator` recebe a foto, não o `combo` vivo. Mesmo padrão para Poder Místico (Kayron), Cópia (Sylas), Guarda e Desonra (Brook), depois de auditar o que a UI lê ao vivo.
- Se a fila esvaziar antes (inimigo morre, combate acaba), forçar a sincronização no fim da fila e antes de `_queue_after_player`. Pausa e 2x continuam valendo.
- Não muda regra, dano, save nem o log F12 (continua imediato).

## 3. Testes
`view()` é cópia; ataque que erra mantém a foto antiga enquanto o d20 gira e iguala o real em "erro-jogador"; acerto avança só no impacto; área e atordoamento; combate que termina no golpe fecha com foto igual ao real.
