---
id: "SPEC-004"
type: "spec"
title: "Cadência do combate: turnos em batidas visuais e números que demoram na tela"
status: "approved"
created: "2026-09-18"
reviewed: "2026-09-18"
relations:
  - "[[SPEC-002-animacao-dado-d20-procedural-3d]]"
  - "[[SPEC-003-dano-flutuante-e-eliminacao]]"
sources:
  - "Pedido do responsável em 2026-09-18: cadência, dano visível, bloqueado/reduzido por 1–2 s"
  - "game/app.py (CombateScreen: roll_queue + pending_effect)"
  - "game/core/combat.py (apply_enemy_action desconta o PV na hora da chamada)"
---

# Cadência do combate

## Problema

Hoje um turno inteiro acontece quase de uma vez: o jogador joga a carta, o
dado rola, o dano é aplicado, e o ataque do inimigo já é resolvido e o dado
dele enfileirado sem pausa. Os números flutuantes duram ~1 s e se
sobrepõem à rolagem seguinte. Pior: `apply_enemy_action` (core) desconta o
PV do Durvall **antes** da rolagem do dado do inimigo, então a barra de PV
cai antes de o jogador ver o dado — o oposto de "revelar".

## Declaração proposta

Transformar o turno em uma **sequência de batidas** (uma coisa por vez,
cada uma com duração própria) e fazer o **PV mostrado na tela** só mudar
na batida do impacto. **Nenhuma regra ou número muda; `game/core/` fica
intocado** — o core continua resolvendo tudo de uma vez, a UI é quem
distribui o que aparece no tempo.

## 1. Sequência de um turno (durações iniciais, ajustáveis)

**Turno do jogador (ataque):**
1. **Anúncio** (0,4 s) — "Durvall usa Golpe" sobre a carta jogada.
2. **Rolagem** (2,1 s) — dado 3D (SPEC-002), como hoje.
3. **Pausa** (0,25 s) — dado assentado e legível.
4. **Impacto** (~1,6 s de exibição) — inimigo treme + partículas; **a barra de PV do inimigo drena animada**; o número da carta sobe (batida 1); o bônus de classe sai ~0,4 s depois (batida 2).
5. **Legenda de modificadores** (1,5 s, sob o número) — explica o que mudou o dano: "Corrente 2x", "Cor incompatível ×0,5" (ver §3).
6. **Respiro** (0,5 s).
7. Se o inimigo zerou: **morte** (sprite escurece/some) → aviso "X foi eliminado" (SPEC-003) → fim do combate. Senão, segue.

**Turno do inimigo:**
8. **Telégrafo** (0,6 s) — "Criatura usa ataque básico" (ou o nome do golpe especial); o inimigo dá um avanço curto (lunge) em direção ao jogador.
9. **Rolagem** (2,1 s) — dado do inimigo.
10. **Pausa** (0,25 s).
11. **Impacto no Durvall** (~1,6 s) — barra de PV do Durvall drena animada; tremor + partículas; número de dano.
12. **Mitigação** (1,5 s) — ver §2.
13. **Respiro** (0,5 s) → volta pro turno do jogador (compra de cartas em escalonamento curto, ~0,1 s por carta).

Tempo total estimado por rodada completa: ~9–10 s. É deliberadamente mais
lento (o pedido é cadência e "satisfação" dos números). §5 propõe
um atalho pra quem já conhece o ritmo.

## 2. Números, bloqueios e reduções (1–2 s na tela)

Todos os campos abaixo **já existem** no core (`EnemyActionResult.raw_damage/damage/reduced_by`, `AttackResult.*`):

| Situação | O que aparece |
|---|---|
| Dano normal | Número na cor da origem (SPEC-003), fica ~1,5 s (sobe menos e desvanece mais tarde que hoje: 1,0 → 1,6 s de vida). |
| Ataque reduzido (Névoa Fria) | Número **cru riscado em cinza** ("6") e, logo depois (~0,3 s), o **final** ("4") mais forte, com legenda "−2 Névoa Fria". |
| Ataque totalmente bloqueado | "**Bloqueado**" em cinza-azulado + o número cru riscado; sem tremor e sem partículas. |
| Bônus de efeito de classe | Segundo número "+N" (Roxo claro, contorno dourado) atrasado ~0,4 s. |
| Cura | "+N" verde; barra de PV do Durvall **enche animada**. |
| Golpe especial do inimigo | Número maior + nome do golpe na legenda. |

Legendas ficam ~1,5 s e não sobrepõem o número (posição fixa abaixo dele).

## 3. Módulos

| Módulo | Mudança |
|---|---|
| `game/ui/sequence.py` (novo) | `Sequencer`: fila de `Beat(duration, on_start, on_end)`; `update(dt)`, `busy`. Sem pygame — testável. |
| `game/ui/damage_fx.py` | `FloatingNumber` ganha `strike` (riscado) e `caption`; vida configurável; `AnimatedBar` (valor mostrado que persegue o valor real). |
| `game/ui/hud.py` | `draw_hp_bar` recebe o **valor mostrado** (animado), não o real. |
| `game/app.py` | `CombateScreen` troca `roll_queue` + `pending_effect` por `Sequencer`. O core é chamado no começo da batida certa; o **PV mostrado** só é atualizado no impacto. |

Única mudança em `game/core/` (**aprovada em 2026-09-18**): campo aditivo
`compat: float` em `AttackResult` (1.0 ou 0.5, o fator que `resolve_attack`
já calcula), pra a UI poder mostrar a legenda "Cor incompatível ×0,5". Nenhum
cálculo muda.

## 4. Fora do escopo

Som, animação de carta voando pra mesa, câmera/zoom, tela de resumo do
turno, log rolável.

## 5. Sem atalho para pular

Decidido em 2026-09-18: nenhum atalho de pular nesta spec. Um modo de
acelerar pode vir depois, em spec própria.

## 6. Critérios de aceite

- [x] Nunca acontecem duas batidas ao mesmo tempo: o jogador vê uma coisa por vez.
- [x] A barra de PV de quem leva dano só muda **depois** do dado e no impacto, e drena animada.
- [x] O dano do inimigo aparece só depois do telégrafo e da rolagem dele.
- [x] Redução, bloqueio e bônus ficam visíveis por 1–2 s, cada um separado.
- [x] Input bloqueado durante toda a sequência; sem duplo `_finish`.
- [ ] `game/core/` só ganha o campo `compat` em `AttackResult`; nenhum cálculo muda.
- [x] Testes: `Sequencer` (ordem, durações), `AnimatedBar`, e um turno completo simulado por sem-tela (kill, bloqueio, redução).

## 7. Ordem de execução (após aprovação)

1. `Sequencer` + testes.
2. Refatorar `CombateScreen` para batidas, sem mudar nenhum visual (mesma ordem de hoje, só orquestrada).
3. `AnimatedBar` e PV mostrado só no impacto (conserta a barra caindo antes do dado).
4. Telégrafo do inimigo, respiros e novos tempos.
5. Números riscados, legendas, bloqueio.
6. Playtest e evidência em `.atena/evidence/`.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Aberto: o critério do `core` (só o campo `compat`) não vale mais como está, pois o `core` mudou em specs posteriores.
