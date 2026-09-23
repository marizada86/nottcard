---
id: "SPEC-008"
title: "M5 — O Santuário de Astherion"
status: "executed"
created: "2026-09-23"
plan: "M5-001"
evidence: "EVID-008-m5-santuario-astherion-2026-09-23"
---

# M5 — O Santuário de Astherion

## Escopo

Criar M5 com situação no cemitério, dois Notívagos, arena de Astherion e
transição única de fase. Integrar cenários/props P0 e persistir Colar e selo
da Tarn de Dagruve.

## Não objetivos

Não criar fases arbitrárias, cinemáticas, sistema de sangue/paralisia, conteúdo
de Interlúdio C ou explicação sobre Durvall e Astherion.

## Aceite

- M5 exige M4.
- A transição ocorre uma vez, no mesmo slot, com arte e ataques de fase 2.
- Salas e props P0 carregam nas telas reais sem fallback.
- Vitória registra `colar_visao_verdadeira` e `tarn_dagruve_selada`.
- M1–M4 preservam regressão.

## Impactos

Missões, salas, dungeon, inimigos, salvamento, UI de combate existente,
EncounterScript, smoke tests e assets. A caminhada reutiliza `rachadura` e
`ritual`, sem nova família de texturas first-person.

## Plano de voo

1. Promover a intenção e fixar a transição de fase estreita.
2. Criar/importar cenários e props P0.
3. Integrar M5 e validar a troca de fase no core e UI real.
4. Rodar regressões, auditar assets e registrar a evidência.

## Reconciliação

A fase 2 substitui Astherion no slot visual existente, em vez de criar um
reforço ou registrar uma morte intermediária. Isso mantém o combate como um
único chefe em duas fases e deixa a invocação única do sacerdote de M2 sem
alteração. A caminhada reutiliza `rachadura` e `ritual`; as telas de situação
e combate usam os três cenários próprios da M5.
