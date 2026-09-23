---
id: "SPEC-007"
title: "M4 — O Resgate em Rodhe's Bridge"
status: "executed"
created: "2026-09-23"
plan: "M4-001"
evidence: "EVID-007-m4-rodhes-bridge-2026-09-23"
---

# M4 — O Resgate em Rodhe's Bridge

## Escopo

Entregar uma M4 jogável de três salas: situação de perseguição, confronto na
ponte e combate final na carroça-prisão. Integrar rebelde, lore, assets P0 e
persistência dos cadernos mágicos.

## Não objetivos

Não criar mecanismo de perseguição, montar novos ambientes first-person,
reputação, variações de rebelde ou conteúdo posterior de Greenholders/Ailalore.

## Aceite

- M4 desbloqueia somente após M3.
- Os três pares `bg`/`fg`, os assets reutilizados e a grade da carroça carregam.
- A situação e os dois grupos de combate funcionam nas telas reais.
- Vitória registra `cadernos_magicos` e M1–M3 preservam regressão.

## Impactos

Catálogo, dungeon, salas, inimigos, salvamento, smoke test, dados de lore e
assets de cena. A visualização first-person reutiliza o ambiente `cais`, já
importado, para não criar fallback nem uma família ambiental fora deste recorte.

## Plano de voo

1. Promover a intenção aprovada e fixar o contrato.
2. Criar/importar arte P0 e reaproveitar a cena de ponte existente.
3. Integrar dados e missão, depois testar o fluxo real e a persistência.
4. Registrar evidência e reconciliar limites narrativos.

## Reconciliação

Os ambientes first-person reutilizam `cais`, uma textura externa já importada,
enquanto os combates e situações usam os três cenários próprios da ponte. Isso
preserva leitura visual sem ampliar a produção para uma nova família de
texturas. Os cadernos são salvos como `cadernos_magicos`, sem efeito de carta
ou equipamento.
