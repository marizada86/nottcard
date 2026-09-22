---
id: "SPEC-074"
type: "spec"
title: "Motor de eventos aleatórios da exploração"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-010-ouro-carisma-e-eventos-aleatorios-2026-09-20]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
sources:
  - "Responsável, 2026-09-20: eventos aleatórios, em média 1 a cada 2 ou 3 missões"
---

# Motor de eventos aleatórios da exploração

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-010, D21, D24, D25 e D26).

## 1. Sorteio por missão
No início da missão: chance base **25%**, **+10 pontos por missão sem evento** (teto 75%), zerando quando um evento aparece; com um evento, **10%** de um segundo.
O contador (`SaveState.event_pity`) só sobe quando uma missão **termina** (vitória, derrota ou desistência). Meta medida por simulação: 1 evento a cada ~2,4 missões.
Os valores ficam num arquivo de dados ajustável pelo Higor.

## 2. Colocação e desaparecimento
Salas elegíveis: 2 a 6, ainda não limpas. Caminhada: marcador na célula livre da sala; portas: opção a mais no corredor. Depois da interação o evento **some** e
fica em `resolved`; não volta na mesma missão. O sorteio e o resultado vão ao log ("Evento: baú, sala 5, chance 0,35, proteção 1").

## 3. Dados e ferramentas
`game/core/events.py` (definições declarativas: id, grupo, peso, salas, opções, recompensas) e `event_plan.py` (sorteio com RNG injetável). Pesos por grupo: 50% de
presentes, 30% de risco e recompensa, 20% de escolhas de personagem; o mímico só depois da sala 3. Atalho de desenvolvimento **Ctrl+O+E** força um evento na sala atual;
`scripts/simulate_events.py` mede a frequência. A Sorte puxando a chance (+2 pontos por nível) fica **fora** do primeiro corte.

## 4. Testes
Frequência média entre 0,35 e 0,45 por missão em 100 mil sorteios; proteção e teto; segundo evento; sala inelegível nunca sorteada; RNG fixo reproduz; o evento some e não volta;
o contador só sobe ao fim da missão; o save antigo carrega.
