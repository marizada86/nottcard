---
id: "SPEC-073"
type: "spec"
title: "Ouro: bônus de Carisma e bolsa da missão"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-010-ouro-carisma-e-eventos-aleatorios-2026-09-20]]"
  - "[[SPEC-045-loja-de-upgrades-e-regras-do-baralho]]"
sources:
  - "Responsável, 2026-09-20: +20% de ouro por +1 de modificador de Carisma"
---

# Ouro: bônus de Carisma e bolsa da missão

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-010, D19, D20 e D23).

## 1. Bônus de Carisma
Multiplicador do ouro da missão: `1 + 0,20 x mod de Carisma + 0,10 x nível de Ganância`, com **piso 0** no modificador e **teto 2,0x**.
O Carisma que conta é o **maior modificador do grupo** no fim da missão. Arredonda para cima. A tela de resultado mostra "Carisma +2 (Kayron): +40%"
ao lado da linha da Ganância.

## 2. Bolsa da missão
Ouro achado dentro da missão vai para a **bolsa da missão** (`mission_gold`), mostrada no HUD ("Bolsa: 35", ícone `moeda_icon`) na exploração e no combate.
No fim, o que sobrou vira moedas da cidade com a regra do XP (100% na vitória e na desistência, **50% na derrota**, arredondado para baixo) e depois
recebe Carisma e Ganância. A bolsa não vai para o save; só o total convertido.

## 3. Implementação
`economy.gold_multiplier(upgrades, charisma_mod)` puro substitui `coins_with_greed` em `App.finish_run`; `RunResult` separa as linhas de Carisma e Ganância;
`RunLedger` ou o `Player` guarda `mission_gold`.

## 4. Testes
Mod 0, +1, +2, +3 e negativo; com e sem Ganância; teto; arredondamento; derrota (metade); melhor Carisma de um grupo de 3; bolsa convertida junto do XP; save intacto.
Verificação: simulador de economia (missões até a Mão Maior, antes e depois).
