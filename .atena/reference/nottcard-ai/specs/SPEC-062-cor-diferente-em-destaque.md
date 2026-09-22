---
id: "SPEC-062"
type: "spec"
title: "Cor diferente da classe em destaque (×0,5)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-008-retorno-dos-playtesters-v0.9.1-2026-09-20]]"
sources:
  - "Daniel, v0.9.1 (H17)"
---

# Cor diferente da classe em destaque (×0,5)

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D11 do PLAN-008).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Regra (não muda)
Ataque e controle de cor diferente da classe valem ×0,5 (`combat.py`); pergaminhos, cura e cor da classe não sofrem.

## 2. Destaque
- **Selo "×0,5"** no canto da carta da mão de ataque/controle de outra cor (padrão do selo "USO ÚNICO").
- **Detalhe ao passar o mouse:** linha "Cor diferente da classe: dano ×0,5" em `detail_lines`.
- **No dano:** legenda "Cor diferente da classe ×0,5" junto do número (a legenda de Cor já existia como "Cor incompatível") e a mensagem do combate diz uma vez por jogada.
- **Tutorial:** a página de cores mostra o selo e um exemplo numérico.
- Texto e forma, não só tom. Nenhuma arte nova.

## 3. Testes
Selo, detalhe e legenda só nos casos com penalidade; o número de dano não muda.
