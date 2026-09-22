---
id: "SPEC-100"
type: "spec"
title: "Cartas universais para Kayron e Brook, Olhar Fixo roxo e regra de variedade"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[SPEC-099-baralho-base-esquiva-e-pocoes]]"
  - "[[SPEC-097-m2-inimigos-sacerdote-e-reforcos]]"
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
sources:
  - "Responsável, 2026-09-21: 'aceito recomendações e propostas'; nota 13 do Higor: Olhar Fixo de amarelo para roxo"
---

# Cartas universais e variedade

**Regra de variedade (vale daqui em diante):** carta nova ou reajustada muda **pelo menos um eixo** em relação às existentes — alvo, timing, recurso gasto, estado
aplicado ou condição de uso. A tabela abaixo é conferida por teste.

## Cartas (comuns, em `COMMON_NAMES`, fora do núcleo)
| Carta | Cor | Efeito | Eixo novo |
|---|---|---|---|
| **Estocada Mística** | Roxo | ataque 1d6; `spends_mystic=3` (+1 de dano por Poder gasto) | recurso: usa o Poder que sobra no Kayron; para os demais é um ataque Roxo simples |
| **Pancada de Escudo** | Vermelho | ataque 1d6 (era 1d4; a simulação de 2026-09-21 mostrou ganho pequeno no Brook); o próximo ataque do alvo cai −2 (reaproveita o efeito de Névoa Fria/Cegueira) | dano + controle numa carta só, para o Brook |

## Olhar Fixo
`OLHAR_FIXO.color = "Roxo"` (era Amarelo). Vira a 2ª fonte Roxa de controle (o alvo perde 1 ataque). Layouts, pool de raras e testes de cor atualizados.

## Simulação (critério de aceite)
`scripts/simulate.py` roda a **linha de base** (antes da SPEC-099) e o resultado **depois de 098–100** para Durvall, Maelor, Sylas, Kayron e Brook (vitória e PV
perdidos, 500 combates da M1 cada). Aceite: os 5 dentro de ±15% entre si; se Kayron ou Brook ficar fora, ajustar dados/Poder de Estocada Mística e Pancada de
Escudo (números iniciais) e repetir. Os resultados vão para `.atena/evidence/`.

## Testes
`test_cards.py` (cores, `spends_mystic`, penalidade aplicada), `test_variety.py` (nenhum par de cartas comuns com o mesmo conjunto de eixos), `test_simulate.py`
(a simulação roda com as cartas novas).
