---
id: "SPEC-060"
type: "spec"
title: "Defesa base e PV por nível de cada personagem"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-008-retorno-dos-playtesters-v0.9.1-2026-09-20]]"
  - "[[SIS-001]]"
sources:
  - "Higor/Daniel/Hiago, v0.9.1: inimigos acertam demais; responsável: equilibrar todos, PV no padrão D&D 2024"
---

# Defesa base e PV por nível de cada personagem

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D10, D14 do PLAN-008).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Regra
- **PV por nível (D&D 5.5, 2024):** nível 1 = `K` + dado de vida máximo + mod. de Constituição; cada nível seguinte = (dado/2 + 1) + mod. de Constituição vigente. `K = 10` (constante de escala do jogo, mantém a média do grupo perto de 20 PV no nível 1).
- **Defesa base:** `defense_bonus_ca` e `defense_bonus_cam` por personagem, somados à CA e à CAM em `Player.ca`/`cam`. A fórmula `10 + modificador` não muda. Regra de calibragem: quanto menos cura, mais defesa.
- Bônus de conquista (Fechadura +2 PV) e a Vitalidade somam por cima.

## 2. Dados (calibrados no simulador, 2026-09-20; evidência em `EVID-SPEC-060`)
`HP_LEVEL_SCALE = 0.5` multiplica o ganho por nível (a regra literal deixava o nível 5 quase garantido: Durvall 99%, Sylas 100%). O nível 1 segue a regra sem escala.
| Personagem | Dado | PV níveis 1 a 5 | Bônus CA / CAM |
|---|---|---|---|
| Durvall | d10 | 21, 25, 29, 33, 38 | 0 / 0 |
| Maelor | d8 | 21, 25, 29, 33, 37 | 0 / 0 |
| Sylas | d8 | 20, 24, 28, 32, 37 | 0 / 0 |
| Kayron | d6 | 17, 20, 23, 26, 29 | +2 / +2 |
| Brook | d10 | 23, 28, 33, 38, 43 | 0 / 0 |
Durvall e Sylas ficaram sem bônus porque o simulador os mostra fortes; o Brook parece fraco no simulador, que não joga a Guarda (a confirmar no playtest). Valores finais: Higor.

## 3. Implementação
`CharacterDef` ganha `hit_die`, `defense_bonus_ca`, `defense_bonus_cam` (dado declarativo; `max_hp` fixo sai). `hp_at(character, level)` puro no núcleo. `Player.for_character` usa `hp_at`. Textos fixos que citam CA/CAM ou 20 PV são ajustados.

## 4. Calibragem
Rodar `scripts/simulate.py` (300 combates por nível, todos os personagens, salas e chefe) antes e depois; guardar a tabela na evidência. O ganho por nível usa `HP_LEVEL_SCALE` (0.5) sem mudar a regra "média + 1 + Con". Valores finais: Higor.

## 5. Testes
`hp_at` bate com a tabela nos níveis 1 a 5 de cada personagem; usa a Constituição do nível; Vitalidade e Fechadura somam; CA/CAM somam só o bônus do personagem certo; teste de acerto do inimigo usa o novo valor; Kayron 13/13.
