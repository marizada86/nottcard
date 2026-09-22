---
id: "SPEC-064"
type: "spec"
title: "Teclas da caminhada: Q/E viram, A/D andam de lado"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-008-retorno-dos-playtesters-v0.9.1-2026-09-20]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
sources:
  - "Daniel, v0.9.1 (H18)"
---

# Teclas da caminhada: Q/E viram, A/D andam de lado

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D12 do PLAN-008).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Teclas
W/↑ avançar · S/↓ recuar · **Q**/← virar à esquerda · **E**/→ virar à direita · **A** andar para a esquerda · **D** andar para a direita · X meia-volta · M mapa.
- A/D: `Walker.strafe_left()`/`strafe_right()` (gira e anda; eventos `Turned` e `Moved`/`Blocked`); a tela enfileira giro e depois passo.
- Parede ao lado: a tela vira e "bate".
- Segurar A/D: o primeiro toque gira e anda, segurar repete só o passo à frente.
- Seis botões: Virar (Q), Esquerda (A), Avançar (W), Recuar (S), Direita (D), Virar (E), mais legenda de teclas.
- Página nova "Explorar" no tutorial "?", que abre nela na caminhada; o guia do playtester ganha a linha das teclas.

## 2. Testes
Núcleo: strafe nas 4 direções, contra parede. Tela: cada tecla, segurar A repete só o passo, setas continuam, modo clássico de portas intacto.
