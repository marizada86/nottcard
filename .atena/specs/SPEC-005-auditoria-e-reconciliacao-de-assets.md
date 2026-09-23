---
id: "SPEC-005"
title: "Auditoria e reconciliação de assets importados"
status: "executed"
created: "2026-09-22"
plan: "PLAN-002"
---

# Auditoria e reconciliação de assets importados

## Escopo

Reimportar os arquivos finais presentes em `assets/`, auditar referências
declaradas em `data/core/*.json` e validar que o projeto continua compilando
e que o smoke test de interface executa.

## Não objetivos

Não criar, substituir, renomear ou apagar arte; não mudar conteúdo narrativo
nem ampliar M3–M9.

## Plano de voo

1. Rodar o importador headless do Godot.
2. Executar uma auditoria que reconhece `asset_id`, `image` de HQ e salas
   compostas por `bg.png` e `fg.png`.
3. Rodar os testes de compilação e smoke de UI.
4. Registrar a saída em `evidence/` e reconciliar o status.

## Aceite

- Todas as referências visuais declaradas têm arquivo final importável.
- Salas M1/M2 em camadas não são classificadas como ausentes.
- Compilação e smoke de UI passam.

## Evidência e reconciliação

- `EVID-005-auditoria-de-assets-2026-09-22.md` registra a reimportação e os
  resultados dos testes.
- A auditoria inicialmente encontrou `assets/hq/hq_002_q4.png`; após a
  aprovação narrativa/visual, a arte foi criada, importada e a auditoria
  passou sem faltas.
