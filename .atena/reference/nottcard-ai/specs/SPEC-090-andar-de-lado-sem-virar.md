---
id: "SPEC-090"
type: "spec"
title: "Andar de lado (A e D) sem virar a visão"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
supersedes: "SPEC-064 nas teclas A/D (as demais teclas continuam)"
relations:
  - "[[PLAN-015-observacoes-v0.11.0-strafe-minimapa-dano-abas-2026-09-20]]"
  - "[[SPEC-064-teclas-da-caminhada]]"
sources:
  - "Responsável, 2026-09-20: 'ao andar com A e D manter a visão em linha reta e não virar junto'. Decisão D1 do PLAN-015 pela recomendação"
---

# Andar de lado sem virar

## Mudança
- `Walker.strafe_left()/strafe_right()` dão **um passo para a esquerda/direita de quem olha, sem alterar `facing`** (`DIRS[(facing ∓ 1) % 4]`). Parede ao lado = `Blocked`,
  sem girar. Porta, sala nova e células visitadas seguem as mesmas regras do passo à frente (`_step`).
- `WalkScreen`: o passo lateral usa a animação de movimento com `vis_angle` fixo. A batida (`bump`) agora empurra **na direção da parede que bateu** (`dir`), não sempre para a frente.
- Segurar A/D repete **o mesmo passo lateral** (na SPEC-064 repetia o avanço).
- Q/E, ←/→ (virar), W/S, X e M não mudam. O modo clássico de portas e o mapa de nós não são afetados.
- A legenda do guia do playtester e a da tela dizem "passo lateral"/"a visão não gira".

## Testes
Núcleo: o passo lateral não muda o `facing` nas 4 direções; contra a parede só bate; entra em sala e registra a célula. Tela: durante todo o passo `vis_angle` fica constante;
a batida lateral vai para o lado da parede; segurar A repete `strafe_left`; as setas continuam girando. Os testes da SPEC-064 que esperavam `Turned` em A/D foram trocados.
