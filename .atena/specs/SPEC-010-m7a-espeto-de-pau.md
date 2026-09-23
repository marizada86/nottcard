---
id: "SPEC-010"
titulo: "M7-A — O Espeto de Pau"
status: "executado"
intencao: "M7-001"
evidencia: "EVID-010-m7a-espeto-de-pau-2026-09-23.md"
---

# SPEC-010 — M7-A: O Espeto de Pau

## Escopo

Implementar a Missão 7 após M6: quatro salas lineares, duas situações de
investigação, a escolha de portais gêmeos, o combate contra o Mímico do Espeto,
os recursos visuais da ferraria e os registros narrativos do diário, Korrak e
Leoric.

## Fora de escopo

- Tornar Korrak ou Leoric personagens selecionáveis (M7-B).
- Criar um sistema de teleporte reutilizável.
- Alterar as regras de combate fora do inimigo da missão.

## Critérios de aceitação

- M7 exige M6, possui quatro salas e chega ao combate do mímico sem bloqueio.
- A rota errada dos portais aplica a consequência e repete somente a situação.
- A vitória registra `diario_bromnor`, `korrak_recrutado` e `leoric_recrutado`.
- Salas, adereços e item carregam recursos locais válidos; a caminhada reutiliza
  o kit visual existente de corredor.
- Contratos, bot de fluxo, fumaça de UI e auditoria de assets passam.

## Impactos

- `core/missions.gd`, `core/rooms.gd`, `core/enemies.gd`, `core/run_session.gd`
  e o fluxo de situações recebem o conteúdo M7.
- `data/core/` recebe dungeon e lore próprios; `assets/` recebe quatro salas e
  adereços da ferraria.
- Testes cobrem contrato, portais, persistência e viagem automática da M7.

## Plano de voo executado

1. Modelar missão, salas, dungeon, lore, situações e inimigo.
2. Integrar a reabertura local de situações para tentativas de portal.
3. Importar e ligar artes de sala, props e item.
4. Registrar o progresso narrativo na vitória.
5. Validar contratos, fluxo, UI, auditoria e regressão completa.

## Reconciliação

M7-A está concluída. M7-B permanece uma decisão de produto posterior, sem
promessa de disponibilidade imediata no elenco.

