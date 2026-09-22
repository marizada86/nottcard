---
id: "SPEC-028"
type: "spec"
title: "Slime corrosivo corrói a CA, PV dos inimigos +30% e Palavra Curativa sem Constituição"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[SPEC-021-rebalanceamento-chama-nevoa-e-golpe-contundente]]"
  - "[[SPEC-025-corrente-quebra-no-erro-e-ajustes-durvall-maelor]]"
sources:
  - "Playtest do Higor e do Hiago, 2026-09-19 (pedido direto do responsável)"
---

# Balanceamento: slime, PV e cura do Maelor

Números são valores iniciais de playtest, ajustáveis sem nova spec.

## Regras

1. **Slime corrosivo corrói a CA.** Cada ataque do slime que **acerta** tem **20%** de chance de tirar
   **1 de CA** do jogador **até o fim da missão** (sobrevive aos combates seguintes; a próxima tentativa
   começa limpa). A **CAM não muda**. Acumula até `MAX_CA_PENALTY` (−4), o mesmo teto que o Romper Armadura
   tem contra os inimigos. Só o slime corrói (`Enemy.corrode_chance`); o sorteio é um d100 (≤ 20).
   A CA corroída aparece em vermelho no HUD e num aviso "CA −1" ao acontecer.
2. **PV dos inimigos +30% em média.**

| Inimigo | Antes | Agora | Aumento |
|---|---|---|---|
| Criatura corrompida | 8 | 10 | +25% |
| Slime corrosivo | 6 | 8 | +33% |
| Guardião (cópia) | 12 | 16 | +33% |
| Guardião verdadeiro (chefe) | 20 | 26 | +30% |

   Média: +30%. A sala em grupo passa de 20 para 26 PV no total.
3. **Palavra Curativa sem o bônus de Constituição.** Cura só o dado (1d4), ainda multiplicado pela Corrente
   de Classe. O Toque Curativo e a Poção de Cura seguem somando Constituição. Motivo: "Maelor está imortal"
   (Hiago, playtest).

## Critérios de aceite

- [x] O slime tira 1 de CA em 20% dos acertos, sem tocar na CAM, até o fim da missão.
- [x] Todos os inimigos com PV maior, em média +30%.
- [x] Palavra Curativa cura só o dado.
- [ ] Playtest: o Maelor ainda está imortal? Os números do slime incomodam?
