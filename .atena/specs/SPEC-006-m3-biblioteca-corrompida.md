---
id: "SPEC-006"
title: "M3 — Biblioteca Corrompida"
status: "executed"
created: "2026-09-22"
plan: "M3-001"
evidence: "EVID-006-m3-biblioteca-corrompida-2026-09-22"
---

# M3 — Biblioteca Corrompida

## Escopo

Adicionar a primeira fatia jogável de M3: três salas, dois confrontos de
gárgulas, o enigma do silêncio, ambientes e props P0. A missão fica liberada
ao concluir M2.

## Não objetivos

Não revelar a origem de Aila, criar cartas de pesadelo, alterar regras globais
ou implementar todas as dez gárgulas como encontros obrigatórios.

## Aceite

- M3 aparece bloqueada antes de M2 e liberada depois dela.
- As três salas, o ambiente, as gárgulas e os props carregam sem fallback.
- O enigma usa apenas o sistema de situações já existente.
- M1/M2 continuam passando em regressão.

## Impactos

- Catálogo de missões, mapa de dungeon, encontros, lore, salvamento de
  recompensa e smoke test de interface.
- Oito assets P0: três fundos, três camadas de primeiro plano (uma moldura
  reutilizada) e dois props novos, além dos assets importados previamente.

## Plano de voo executado

1. Promover o fluxo aprovado a cânone e criar o contrato de M3.
2. Produzir e importar salas/props P0; usar o sistema de imagens do Godot.
3. Integrar missão, grupos de gárgulas, enigma, lore e recompensa persistida.
4. Validar contrato M3, UI real, compilação, regressão e auditoria; registrar
   a evidência.

## Reconciliação

Os grupos de combate foram fechados em três gárgulas cada para respeitar a
regra narrativa. As quatro estátuas restantes pertencem à ambientação e não
forçam um combate adicional. A Ampulheta é salva como item narrativo
`ampulheta_silencio_eterno`; ela não recebe mecânica de equipamento nesta fatia.
