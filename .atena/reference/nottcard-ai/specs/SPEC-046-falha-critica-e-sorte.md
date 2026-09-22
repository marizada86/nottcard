---
id: "SPEC-046"
type: "spec"
title: "Falha crítica nos eventos e a Sorte (rerrolar um d20 ruim)"
status: "approved"
created: "2026-09-20"
reviewed: "2026-09-20"
relations:
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-045-loja-de-upgrades-e-regras-do-baralho]]"
sources:
  - "Higor, 2026-09-19: H6 (punição mais pesada no 1 natural em eventos) e H7 (habilidade Sorte: rerrolar um d20 ruim, 1 por missão)"
  - "Responsável, 2026-09-20: aprovado nas recomendações do PLAN-001"
---

# Falha crítica e Sorte

> **Aprovada pelo responsável em 2026-09-20.** Números são o ponto de partida; o Higor ajusta por sala depois do playtest.

## 1. Falha crítica (H6)

- **Quando:** o d20 de um teste de exploração é **1 natural** (hoje só falha). Vale para todas as opções com teste.
- **Custo padrão** (igual em todas as salas; `Option.critical` opcional permite um desfecho próprio por opção, sem uso ainda):
  1. **PV:** perde o **dobro do máximo** do desfecho de falha da opção (mínimo **3**); se a falha não tem perda de PV, perde **3**. **Nunca** deixa o
     jogador abaixo de **1 PV** fora do combate.
  2. **Carta:** uma carta aleatória do **baralho da tentativa** (compra, mão ou descarte) **sai da tentativa** (vai para `exhausted`).
  3. **Item:** um item aleatório da **mochila** é perdido (se tiver).
  O XP do desfecho de falha continua valendo (o jogador aprende mesmo assim).
- **Tela:** o resultado mostra **"FALHA CRÍTICA"** em vermelho e o custo (PV, carta, item) linha a linha.
- **Dados:** `CheckResult.critical` (natural 1); `Applied.critical`, `Applied.lost_card`, `Applied.lost_item`; `apply_critical(player, option)`.

## 2. Sorte (H7)

- **Recurso da missão, por personagem** (quem testa gasta a dele; `Player.luck`): **1** na tentativa, **+1 no nível 3**, **+1 no nível 5** e **+N** do upgrade
  "Sorte" (`SPEC-045`). Zera a cada tentativa.
- **Uso:** depois de um d20 de exploração **malsucedido** (inclusive a falha crítica), o resultado mostra **"Usar Sorte (N)"** e **"Aceitar"**. Usar Sorte
  gasta 1, **rola o d20 de novo e vale o segundo resultado** (mesmo se pior; o natural 1 do segundo rolamento também é falha crítica). **Não** rerrola
  sucesso. **Não vale no combate** (v1). O desfecho só é aplicado depois de aceitar ou de gastar a Sorte.
- **Contador:** "Sorte: N" no canto da tela de exploração (do personagem que testa).
- **Futuro:** cartas e habilidades que dão Sorte extra ficam para depois; `Player.luck` já aceita `+N`.
- **Dados:** `Player.luck`, `game/core/exploration.py` (`resolve_check` com `roll`; `spend_luck`).

## 3. Arquivos

`game/core/exploration.py` (falha crítica, Sorte), `game/core/state.py` (`luck`), `game/app.py` (SituacaoScreen em duas fases: rolar → Sorte/Aceitar →
aplicar; contador), `tests/`.

## 4. Testes

- Natural 1: custo padrão (dobro do PV com mínimo 3, nunca abaixo de 1 PV; uma carta da tentativa sai; um item da mochila some, se houver; sem item, sem erro); falha
  comum e sucesso não mudam; `Option.critical` próprio vale.
- Sorte: valores por nível (1, nível 3 = 2, nível 5 = 3) mais o upgrade; só depois de falha; rerrola e vale o segundo; não em sucesso; sem Sorte, sem botão;
  o segundo rolamento pode ser crítico; gasta do personagem que testa; zera na nova tentativa.
- Interface: "FALHA CRÍTICA" em vermelho com o custo; botões "Usar Sorte" e "Aceitar"; contador.

## 5. Critérios de aceite

- [x] O 1 natural em evento aplica o custo padrão e a tela mostra "FALHA CRÍTICA" com o custo.
- [x] A Sorte rerrola uma falha (e só ela), vale o segundo resultado, e o contador mostra quantas restam.
- [x] `core` sem pygame; todos os testes passam.
- [ ] Custos calibrados por sala após o playtest.

## Registro da implementação (2026-09-20)

- Feito conforme a spec. A tela de exploração ganhou duas fases: rola o d20, e, numa falha com Sorte à mão, espera "Usar Sorte (N)" ou "Aceitar"
  antes de aplicar o desfecho. Quem falha sem Sorte (ou passa) segue como antes. A Sorte é do personagem que testa.
- Usar Sorte é uma vez por teste (o segundo resultado vale e o desfecho é aplicado); o consumível de bônus já gasto no primeiro d20 vale de novo no segundo.
- Testes: `test_crit_luck.py` (core) e `test_crit_luck_flow.py` (tela).

## Review record

- Proposed by: Claude, a partir de H6/H7 do PLAN-001.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20 (padrão único de falha crítica; Sorte por personagem).
