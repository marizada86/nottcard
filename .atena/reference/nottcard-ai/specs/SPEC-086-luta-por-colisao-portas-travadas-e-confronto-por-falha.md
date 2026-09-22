---
id: "SPEC-086"
type: "spec"
title: "Luta por colisão, portas travadas e confronto que começa na falha do teste"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-037-grupo-de-ate-3]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
  - "[[SPEC-031-modo-exploracao]]"
sources:
  - "Higor, playtest da v0.11.0 (Hiago), 2026-09-20: itens 1, 2 e 7"
  - "Leoric, EV-Leoric-20260920-212314, nota 2: 'Falha no teste de luta do slime e a luta não começou'"
  - "Responsável, 2026-09-20: item 7 = 100% aleatório"
---

# Luta por colisão, portas travadas e confronto por falha

> Aprovada pelo responsável em 2026-09-20 (`execution_approval: per-spec`). Nada aqui é regra até ser aprovada.

## 1. A luta só começa ao colidir com o inimigo (item 1)
**Hoje:** o encontro abre quando o caminhante chega a `ENCOUNTER_RANGE` (2 células, Chebyshev) da âncora da sala (`near_anchor`, `walk_screen.py`), mesmo de costas ou recuando.
**Passa a ser:** nas salas de **combate** (âncora com `ENEMY_CELLS`: salas 2, 5, 6 e 7) o encontro abre **só** quando o jogador **anda para a frente e a célula à frente é a de um inimigo vivo** (a colisão). O inimigo passa a ocupar a célula: o passo vira `Blocked` contra ela e a tela abre o combate no lugar do "bump". Girar, andar de lado (A/D) e recuar nunca abrem luta.
- Salas de **situação** (marcador na âncora: 1, 3, 4) seguem abrindo por proximidade, porque ali o jogador **escolhe** como agir (ex.: contornar o slime).
- Evento aleatório (SPEC-074) segue por marcador; não muda.

## 2. Luta obrigatória trava as portas (item 1)
Enquanto a sala de combate obrigatória não está resolvida, a porta que leva **à sala seguinte** não abre: o passo contra ela vira `Blocked` e aparece o aviso **"Elimine o inimigo primeiro."** (toast de 3 s, sem repetir a cada tecla: um por tentativa). A porta de volta continua livre. Sala **opcional** (`Room.optional`) não trava nada.
- O `walk_cross`/`_enter_room` de hoje (que abre o encontro quando se deixa a sala sem resolver) fica só como garantia.

## 3. Falhar num teste de confronto inicia a luta (item 2)
**Hoje:** só o mímico (SPEC-075) tem `Outcome.fight`. O teste do slime da sala 4 (`exploration.py:380`) falha, cobra a penalidade e **não** abre a luta (nota 2 do Leoric).
**Passa a ser:** toda opção cujo objetivo é **evitar** uma luta (contornar, passar sorrateiro, convencer) tem, na falha (e na falha crítica), `fight=<id do inimigo da sala>` **além** da penalidade que já existe. Reaproveita o caminho de `open_event` → `_start_combat` (o mesmo do mímico); ao vencer, a sala fica resolvida e o XP entra pelo abate como hoje.
- Levantar todas as `Situation` com opção de evitar confronto (sala 4 hoje; conferir 1 e 3) e listar em `EXPLORATION_FIGHTS` (dado declarativo).
- A tela de resultado da falha mostra "…e o slime ataca!" antes de abrir o combate.

## 4. Inimigos atacam um alvo aleatório (item 7)
**Hoje:** `Party.choose_target` (`party.py`, regra da SPEC-037 §3) escolhe o de **menor CA** (ou CAM, se o golpe é mágico); com 3 personagens quase sempre cai no do meio.
**Passa a ser:** `choose_target` sorteia **entre todos os vivos, com peso igual** (decisão do responsável: 100% aleatório). O golpe em área continua atingindo todos os vivos. O RNG segue injetável.
- A SPEC-037 §3 é **atualizada** (a regra da menor CA sai) e o texto do tutorial/guia que a cita é ajustado.

## 5. Testes
- Andar de costas/de lado/girar perto do inimigo **não** abre luta; andar de frente para a célula dele abre.
- Porta da sala seguinte bloqueada com a sala obrigatória viva ("Elimine o inimigo primeiro"), livre depois de vencer; sala opcional não bloqueia.
- Falha e falha crítica no teste do slime abrem a luta; sucesso não. Um teste por opção de evitar confronto.
- `choose_target`: com RNG fixo, em 10 mil golpes cada um dos 3 vivos leva ~1/3 (tolerância); morto nunca é alvo; solo é o único; golpe em área atinge todos.
- Os testes da SPEC-037 §3 que esperavam "menor CA" são reescritos.

## Fora do escopo
Mudar o desenho das salas ou o número de inimigos. Arte nova do inimigo bloqueando a passagem.
