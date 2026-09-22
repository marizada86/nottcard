---
id: "SPEC-109"
type: "spec"
title: "Andar quadrado por quadrado: segurar a tecla não repete o passo"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[SPEC-090]]"
  - "[[SPEC-103]]"
sources:
  - "Responsável, 2026-09-21: ao clicar D não anda um quadrado e sim até a próxima parede; o Andar deve ser quadrado por quadrado"
---

# Um toque, um quadrado

- Causa: `WalkScreen.update` repetia o comando enquanto a tecla continuava apertada (`_held`), sem pausa; um toque acima de 0,28 s (`STEP_TIME`)
  virava vários passos e segurar corria até a parede. Substitui a regra "segurar A/D repete o passo lateral" da SPEC-090.
- Cada aperto de tecla (W/S/A/D/Q/E e setas) ou clique de botão faz exatamente um quadrado ou um giro. Segurar não repete.
- A fila de 1 comando continua (um toque rápido durante o passo não se perde); pausa e perda de foco continuam esvaziando a fila.
- `_held` e `_wait_release` (SPEC-103 G6) saem: sem repetição não há tecla "presa" para proteger. O texto do tutorial é atualizado.

## Testes
`tests/ui/test_walk_flow.py`: tecla mantida por 6 s anda 1 quadrado; apertar de novo anda mais 1; a fila guarda só 1 comando; pausa e foco esvaziam a fila.
