---
id: "SPEC-066"
type: "spec"
title: "Log de combate detalhado (Ctrl+F12)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-008-retorno-dos-playtesters-v0.9.1-2026-09-20]]"
  - "[[SPEC-007-log-dev-f12]]"
  - "[[SPEC-061-suspense-da-corrente]]"
sources:
  - "Higor/Daniel, v0.9.1 (H19): log no estilo do Baldur's Gate 3"
---

# Log de combate detalhado (Ctrl+F12)

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D13 do PLAN-008).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Regra
- **Ctrl+F12** abre o painel "Log de combate" (maior, com rolagem); o F12 fica como está.
- Uma linha por acontecimento, colorida por quem age, com cada modificador e sua origem, tipo de dano, quem rolou cada dado, composição da CA/CAM do alvo, PV antes/depois, efeitos, Reações e testes de d20 da exploração.
- **Sem spoiler:** as linhas entram na batida da revelação (mesma sincronização da SPEC-061).
- Núcleo: registros `CombatEvent` e `Player.defense_breakdown()` (e o do inimigo), puros; F12 e painel consomem os mesmos números. Tipo de dano: `Card.elements` (físico/mágico pela cor).
- Evidência: o pacote da F7 ganha `log-de-combate.txt` (mesmo filtro de dados pessoais). Botão de copiar para o bloco de notas (F5). Sem filtros no 1º corte.

## 2. Testes
Cada `narrate_*` devolve as linhas esperadas; Ctrl+F12 abre o painel e F12 não; linhas só na batida certa; o `.zip` contém o arquivo.
