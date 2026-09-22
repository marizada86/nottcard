---
id: "SPEC-092"
type: "spec"
title: "Testes de morte do personagem caído"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-037-grupo-mais-de-um-personagem-em-cena]]"
  - "[[SPEC-091-curar-aliados-com-cartas-de-cura]]"
  - "[[SPEC-046-falha-critica-e-sorte]]"
sources:
  - "Responsável, 2026-09-20: caído joga 1 death saving throw por rodada (d20). 10 ou mais 3x = revive com 1 de vida. 9 ou menos 3x = morre."
---

# Testes de morte do personagem caído

> Aprovada pelo responsável em 2026-09-20 (`execution_approval: per-spec`), com as decisões: teste de morte por rodada, morte e derrota (§3), "se todos caírem, a missão falhou" e solo "caiu, morreu".

## 1. Regra base (do responsável)
- Um personagem a **0 PV** está **caído** (inconsciente): não age, não compra carta e não é alvo dos inimigos (SPEC-037).
- **Uma vez por rodada**, no início do turno do jogador, cada personagem caído faz **1 teste de morte: 1d20 puro** (sem modificador, sem Sorte, sem bônus), **DC 10**.
  - **10 ou mais** = sucesso. **9 ou menos** = falha.
  - **3 sucessos**: revive com **1 PV**.
  - **3 falhas**: **morre**.
- Sucessos e falhas **acumulam** (não precisam ser seguidos) e valem só dentro da mesma queda: o contador zera quando o personagem revive, morre ou é curado (SPEC-091).
- **Cura de aliado** (SPEC-091 §2.1) continua levantando na hora, com os PV curados (mínimo 1), e **zera o contador**. O teste de morte é o caminho de quem **não** recebe cura.

## 2. Extensões recomendadas (D&D 2024)
- **20 natural** no teste de morte: revive na hora com 1 PV (a regra do D&D 2024). **1 natural** conta como **2 falhas**.
- **Quem revive** pelo teste (3 sucessos ou 20 natural) **não age no turno em que revive**, como o levantado por cura (SPEC-091 §2.1), e volta a agir no seguinte.
- **Dano em caído: fora.** Como o caído não é alvo dos inimigos (SPEC-037 §3, SPEC-086 §4), o "dano em inconsciente conta falha" do D&D não entra. O risco do caído vem só do d20; se todos caem, a missão falha (§3). **[decisão]** alternativa: o caído continua sendo alvo possível e cada golpe que o atinge conta 1 falha (2 se crítico). Não recomendo agora: com alvo 100% aleatório, mataria o caído rápido demais e o grupo perderia o turno tentando protegê-lo.

## 3. Morte, derrota e o fim do combate (decisão do responsável, 2026-09-20)
- **Morto** = fora **até o fim do combate**: não age, não é alvo e não recebe cura durante a batalha.
- **Derrota: se todos os personagens caírem (todos a 0 PV, caídos ou mortos), a missão falhou**, na hora, sem testes de morte para ninguém. É a regra de sempre da SPEC-037 (`Party.all_down`); os testes de morte só existem enquanto **ainda há alguém de pé** que possa carregar a luta. Um morto ou caído com outro personagem de pé **não** encerra a missão.
- **Solo: caiu, morreu.** O único personagem a 0 PV = derrota imediata, como hoje. Os testes de morte só valem em grupo (2 ou 3 personagens).
- **No fim do combate vencido, todos os que estavam caídos ou mortos voltam com 1 PV** (o contador de testes zera). A morte, portanto, vale só dentro da batalha; **não há perda permanente** nem baixa que dure pela missão. O XP da tentativa continua indo para todos que estiveram em cena (SPEC-037 §1), inclusive quem morreu. Isto responde à pergunta em aberto da SPEC-091 §2.1.
- Como o último de pé cair encerra a missão, **cura de aliado** (SPEC-091) e os testes de morte são a forma de trazer alguém de volta **antes** disso.

## 4. Interface (`CombateScreen`)
- No retrato do caído: 3 marcas de **sucesso** (verdes) e 3 de **falha** (vermelhas) que acendem conforme os testes; ícone/rótulo "Caído"; "Morto" (retrato apagado com cruz) após 3 falhas.
- No início do turno, para cada caído: o dado d20 rola (mesmo widget dos testes, respeitando o **x2** e "reduzir movimento") e o resultado vai ao **log** e ao F12 ("Sylas: teste de morte 14, sucesso (2/3)").
- Um aviso curto ao reviver ("Sylas se levanta com 1 PV") ou morrer ("Sylas morreu").
- O retrato do caído acende como alvo de cura com o rótulo "Levantar" (SPEC-091).

## 5. Arquitetura
- `game/core/death_saves.py` (puro, RNG injetável): `DeathSaves` (sucessos, falhas), `roll_save(saves, rng) -> Outcome`, `STABLE_AT = 3`, `DEAD_AT = 3`, `DC = 10`.
- `Player`: `death_saves`, `dead: bool`, `is_downed` (hp <= 0 e não morto). `is_alive()` continua sendo `hp > 0` (quem está em cena). `Party.alive_members()` não muda; ganham `downed_members()` e `dead_members()`, e `all_down` não muda (todos a 0 PV = derrota).
- `App`: no início do turno do jogador chama os testes; no fim do combate vencido, todo caído ou morto volta com 1 PV (mortos e caídos são estados só do combate; os PV seguem persistindo entre salas em `Player.hp`).
- `SaveState`: **sem mudança** (nada é perdido de forma permanente).

## 6. Testes
- **Base:** com RNG fixo, 3 sucessos revivem com 1 PV; 3 falhas matam; sucessos e falhas acumulam em qualquer ordem; 9 falha e 10 passa (a fronteira); o contador zera ao reviver, morrer ou ser curado.
- **Extensões (aprovadas):** 20 natural revive na hora; 1 natural vale 2 falhas; quem revive não age no turno.
- **Morte:** morto não age, não é alvo, não recebe cura durante a batalha; o XP é mantido.
- **Fim do combate vencido:** caído e morto voltam com 1 PV; contador zerado.
- **Derrota:** um caído ou morto com outro de pé não falha a missão; todos a 0 PV falha na hora (sem testes de morte). Solo: cair = derrota imediata.
- **UI:** as marcas acendem na ordem; o log e o F12 trazem o d20 e o placar; o x2 acelera o d20.
- **Regressão:** os testes de combate solo e de grupo seguem passando (o solo não tem teste de morte: cair = derrota, como hoje).

## Fora do escopo
Estabilizar por cura de "Estabilizar" ou teste de Medicina (não existe); ressuscitação de morto durante a batalha; morte permanente; dano em caído (§2); rodadas de morte sem ninguém de pé (todos caindo é derrota, §3).
