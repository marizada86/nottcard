---
id: "SPEC-075"
type: "spec"
title: "Evento Baú e Mímico"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-010-ouro-carisma-e-eventos-aleatorios-2026-09-20]]"
  - "[[SPEC-074-motor-de-eventos-aleatorios]]"
sources:
  - "Responsável, 2026-09-20: baú com ouro e cartas/itens temporários, e mímico disfarçado de baú"
---

# Evento Baú e Mímico

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-010, D22).

## 1. Baú
Duas escolhas: **Abrir** (sem teste) ou **Examinar** (Inteligência CD 12). Dentro: **15 a 35** de ouro na bolsa (sobe com a sala) e, em 40% dos baús, uma carta ou item
temporário. Em 25% dos baús vem **trancado**: Arrombar (Inteligência) ou Forçar (Força); falhar causa 1d4 de dano e o baú continua.

## 2. Mímico
Em **25% dos "baús"** o que se abre é um inimigo. Combate contra um só (PV da sala x 1,3, CA e CAM médias, mordida que prende: o alvo perde a próxima Ação se falhar um teste de Força).
Recompensa maior que a do baú: o dobro do ouro, sempre um item temporário e XP. Contramedidas: o exame o revela; a carta **Localizar Criatura** o entrega sem teste;
passar o mouse mostra "Baú (?)".

## 3. Implementação
Definições em `events.py`, `mimico()` em `enemies.py` (reaproveita todo o combate), tela de opções como a `SituacaoScreen`, ouro na bolsa (SPEC-073). Arte a gerar depois:
baú fechado e aberto, mímico (baú e boca aberta); sem a arte, o retângulo com o nome.

## 4. Testes
Faixa de ouro por sala; a proporção baú/mímico; exame revela; Localizar revela; falhar no arrombamento; o mímico dá a recompensa maior; o evento some depois.
