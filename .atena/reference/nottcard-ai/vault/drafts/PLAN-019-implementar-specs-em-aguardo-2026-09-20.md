---
id: "PLAN-019"
type: "plano"
title: "Implementar as SPECs aprovadas em aguardo: 086, 087, 088, 089, 091 e 092"
status: "draft"
created: "2026-09-20"
relations:
  - "[[SPEC-086-luta-por-colisao-portas-travadas-e-confronto-por-falha]]"
  - "[[SPEC-087-frequencia-de-eventos-garantida-e-conquista-o-infeliz]]"
  - "[[SPEC-088-sugerir-baralho-para-todos-resultado-enxuto-x2-e-ajustes-de-tela]]"
  - "[[SPEC-089-loja-do-mercador-com-as-moedas-do-perfil]]"
  - "[[SPEC-091-curar-aliados-com-cartas-de-cura]]"
  - "[[SPEC-092-testes-de-morte-do-personagem-caido]]"
  - "[[PLAN-018-implementacao-de-m2-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'Faça um plano para implementar todas as specs em aguardo' e 'fechar e commitar a SPEC-082 antes': sim"
  - "Varredura de .atena/specs em 2026-09-20: SPECs 086, 087, 088, 089 e 091 sem nenhuma referência em game/ ou tests/ (as demais, 081 a 085 e 090, já têm código)"
---

# Implementar as SPECs em aguardo

> **Atualização:** a **SPEC-092** (testes de morte do caído) surgiu depois da primeira versão deste plano e entra entre a 088 e a 091.

> Rascunho. Cada SPEC abaixo já está **aprovada** (`execution_approval: per-spec`), então pode ser implementada sem nova aprovação de
> conteúdo. Commits seguem exigindo o OK do responsável (`add.yaml`), pedido por gate.

## 1. Quais são

Todas as 91 SPECs estão com `status: approved`, então o critério foi "sem código": procurei o id de cada SPEC em `game/` e `tests/`.

| SPEC | Assunto | Código hoje | Tamanho |
|---|---|---|---|
| **087** | Frequência de eventos (30%, garantia na 3ª missão) e a conquista "O infeliz" | nenhum | pequeno |
| **089** | Mercador aceita as moedas do perfil | nenhum | pequeno |
| **086** | Luta por colisão, portas travadas, falha inicia luta, alvo 100% aleatório | nenhum | médio |
| **088** | Sugerir baralho p/ qualquer personagem, resultado enxuto, x2 em situações, Esc em exploração, 3 acertos de layout | nenhum | médio (várias telas) |
| **092** | Testes de morte do personagem caído (d20 por rodada, 3 sucessos revivem, 3 falhas matam) | nenhum | médio (`core` novo + UI do retrato) |
| **091** | Cartas de cura em aliados, inclusive levantar quem caiu | nenhum | grande (regra de combate + UI) |

Já implementadas (com código, ainda **sem commit**): 081, 082, 083, 084, 085 e 090. As de M2 (093 a 097, no `PLAN-018`) ainda **não foram
escritas** e entram depois deste plano.

## 2. Passo 0: fechar o que está pendente (OK dado em 2026-09-20)

O working tree tem 50+ arquivos alterados de várias frentes, entre elas as SPECs 081 a 085 e 090 e os arquivos da 082 (com a arte nova
`assets/enemies/*_v01_fit.png` ainda sem versão final). Antes de começar as novas:
1. Rodar a suíte completa (estava em **1677 verdes**) e conferir no jogo o combate com 1 e com 3 inimigos (SPEC-082).
2. Separar em commits **por SPEC** com `git add` seletivo (arquivos compartilhados como `app.py` e `hud.py` misturam várias SPECs: onde não
   der para separar por arquivo, agrupar num commit só e dizer quais SPECs entraram).
3. Não entram no commit: `assets/_raw/`, o PDF `MODIFICACOES-apos-v0.11.0` (a confirmar) e as `*_v01_fit.png` até você aprovar a arte.
4. Perguntar o texto da mensagem e a versão (`game/version.py` está em 0.11.0) só no momento do commit.

## 3. Ordem de implementação e por quê

**087 → 089 → 086 → 088 → 092 → 091**

| Ordem | SPEC | Por que aqui |
|---|---|---|
| 1 | 087 | Isolada em `core` (`event_data`, `event_plan`, `achievements`, `progress`). Mexe no **catálogo de conquistas**, que o `PLAN-018` (desbloqueio de personagem) também vai estender. Melhor entrar antes. |
| 2 | 089 | Isolada: `events._shop` + uma função `spend_gold` em `core`. Baixo risco, ganho imediato para o playtest. |
| 3 | 086 | Mexe em `walk_screen`, `exploration` e `party.choose_target`. **Precisa vir antes da 091** (as duas mexem em `Party`) e **antes da 088** (a 088 reposiciona botões da mesma `WalkScreen`). |
| 4 | 088 | Lote de interface em várias telas (`deck_screen`, `combat_narration`, `SituacaoScreen`, `_can_pause`, três layouts). Vem antes da 091 para que a narração da cura já nasça no formato enxuto (§2 da 088). |
| 5 | 092 | Cria `Player.death_saves`, `is_downed`/`dead` e `core/death_saves.py`, que a 091 usa ("cura levanta e zera o contador"). Mexe no início do turno do jogador e no retrato do caído. |
| 6 | 091 | A maior: nova regra de combate em grupo (`Card.self_only`, `heal_ally`, levantar aliado caído) mais seleção de alvo na `CombateScreen`. Por último, sobre `Party` e narração já estáveis. |

**Método por SPEC** (o mesmo para todas): (1) reler a SPEC e o código citado; (2) escrever primeiro os testes de `core` da seção "Testes" dela;
(3) implementar; (4) suíte completa verde; (5) **conferir no jogo** o que é interface (skill `run`, captura de tela) e mudar o `README`/tutorial/guia
onde a SPEC pede; (6) registrar evidência em `.atena/evidence/` quando a SPEC pedir; (7) pedir OK para commit e seguir para a próxima.

## 4. SPEC-087: eventos e "O infeliz"

- **`event_data.py`:** `BASE_CHANCE` 0,25 → **0,30**; novo `PITY_GUARANTEE = 2`; `PITY_STEP` e `CHANCE_CAP` ficam.
- **`event_plan.py`:** `chance(pity)` devolve **1,0** com `pity >= 2`; `next_pity` passa a zerar só se um evento **foi aberto** (não basta ter sido
  sorteado). O `App` precisa informar "algum evento foi aberto" (hoje `finish_run` usa `bool(self.event_plan)`, `app.py:3186`): usar
  `events_resolved` mais o evento aberto e interrompido por derrota (`_event_instance`).
- **`achievements.py`:** `EXTRA_LUCK`, conquista `infeliz` ("O infeliz"), condição `stats.natural_ones >= 3`. **`progress.RunStats.natural_ones`** novo,
  somado em `resolve_check` e `reroll_with_luck` (só o d20 mantido, só exploração e eventos). **`Player.for_character`** soma +1 Sorte com o benefício.
  `unlock_all` (cheat) e o guia do playtester incluem a nova conquista.
- **`scripts/simulate_events.py`:** parâmetro `--reach` (padrão 0,8) e o intervalo médio entre eventos **vistos**.
- **Devlog:** "chance 1,00 (garantia)".
- **Testes:** os da seção 5 da SPEC (chance 0,30/0,40/1,00; frequência média 0,44 a 0,52 em 100 mil missões; `next_pity` por evento visto; "O infeliz" com
  3 naturais 1 em exploração, 2 não, combate não conta, +1 Sorte em todos, save antigo carrega).
- **Atenção:** `Player.luck`/`LUCK_BASE` também são lidos pelos níveis e pelo upgrade Sorte; conferir a soma para não contar duas vezes.

## 5. SPEC-089: mercador com as moedas do perfil

- **`core/economy.py`** (ou onde `settle_coins` mora): `spend_gold(ledger, save, price) -> bool` debita o **ouro da missão primeiro** e o resto de
  `SaveState.coins`; nunca deixa negativo; recusa se `missão + perfil < price`.
- **`events._shop`:** saldo somado no texto ("Ouro da missão: 12 · Moedas: 118"); "Faltam N" pelo saldo somado; troca de oferta (`SHOP_REROLL_COST`)
  pela mesma função.
- **Persistência:** o débito chama `save_store.save` na hora (a compra não desfaz se a missão terminar mal). O `settle_coins` de fim de missão não muda.
- **Não mudam:** os outros eventos com `cost_gold` (baú trancado etc.).
- **Testes:** os da seção 4 da SPEC. Conferir também a UI do mercador no jogo (duas bolsas visíveis, botão desabilitado com o texto certo).

## 6. SPEC-086: colisão, portas travadas, falha inicia a luta, alvo aleatório

1. **Colisão (§1):** em `walk_screen.py`, `near_anchor` (`:65`) deixa de abrir o combate nas salas de **combate** (âncora com `ENEMY_CELLS`: 2, 5, 6, 7).
   O inimigo vivo passa a ocupar a célula (`Blocked` contra ela) e o passo à frente dela abre o combate. Girar, andar de lado e recuar nunca abrem.
   Salas de **situação** (1, 3, 4) mantêm a proximidade; eventos (marcador) não mudam.
2. **Porta travada (§2):** com a sala de combate obrigatória sem resolver, o passo contra a porta da sala seguinte vira `Blocked` com o toast
   "Elimine o inimigo primeiro." (um por tentativa); a de volta abre; sala `optional` não trava. `walk_cross`/`_enter_room` ficam como garantia.
3. **Falha inicia a luta (§3):** `EXPLORATION_FIGHTS` (dado declarativo) lista as opções de evitar confronto; na falha e na falha crítica ganham
   `fight=<inimigo da sala>` **além** da penalidade, reaproveitando o caminho do mímico (`open_event` → `_start_combat`). Levantar as `Situation` das
   salas 1, 3 e 4 (`exploration.py:356`, `:380` etc.) e confirmar quais têm "evitar". Tela: "…e o slime ataca!" antes de abrir o combate.
4. **Alvo aleatório (§4):** `Party.choose_target` (`party.py:103`) sorteia com peso igual entre os vivos; RNG injetável; área continua em todos.
   **Atualizar** a SPEC-037 §3 e o texto do tutorial/guia que cita "menor CA".
5. **Testes:** os da seção 5 (colisão só de frente; porta travada e destravada; falha e falha crítica do slime abrem a luta, sucesso não; 10 mil golpes
   ~1/3 cada; reescrever os testes de "menor CA" da SPEC-037).
- **Contato com M2:** os dados de colisão e porta ficam em `dungeon_m1` (`ENEMY_CELLS`, `DOORS`); ao migrar para `MissionDef` (`PLAN-018`, etapa 1) esse
  comportamento **já faz parte do teste dourado de M1**. Por isso a 086 vem antes.

## 7. SPEC-088: lote de interface

Entrega em **subpassos independentes**, cada um com seu teste, na ordem abaixo (do mais local ao mais transversal):

| Subpasso | O que | Onde |
|---|---|---|
| 88.1 | "Sugerir baralho" abre a lista de personagens liberados; com 1 aplica direto; Esc/clique fora fecha | `deck_screen.py:93` e `:178`; `collection.suggest_deck` não muda |
| 88.2 | Resultados enxutos: uma linha por golpe no combate e "d20 + mod = total contra DC" nas situações; detalhe só no log e no F12 | `combat_narration.py`, resultado da `SituacaoScreen` |
| 88.3 | x2 também na `SituacaoScreen` (mesmo estado do combate; cronômetro do chefe em tempo real) | `speed.py`, `app.py` (~3518) |
| 88.4 | Esc abre o menu na caminhada, no modo de portas e nas situações (a sobreposição mais interna fecha primeiro); "Desistir" mantém o XP | `App._can_pause()` (`app.py:3451`), `PauseMenu`, `walk_screen.pause/resume` |
| 88.5 | Notas do Leoric 1, 8 e 10: texto sobreposto na escolha de carta, bolsa sobre o botão de equipamento, sinal do teste sobre o bônus do 3º personagem | `ChooseCardScreen`, `WalkScreen`, coluna de testes |
| 88.6 | Nota 7 ("cartas extras em todos os baralhos"): **investigar primeiro** com um teste que reproduz a recompensa, depois corrigir ou explicar na tela | recompensa/carta temporária |
| fora do corte | Notas 4 e 6 (livros e ossos são cenário) | decisão pendente da SPEC |

- **Risco:** `_can_pause` afeta o Esc de todas as telas; o teste "Esc fecha primeiro a sobreposição mais interna" tem de existir **antes** de mexer.
- **Testes:** os da seção 6 da SPEC, incluindo geometria dos rects nas 3 notas de layout com 1, 2 e 3 personagens.

## 7b. SPEC-092: testes de morte do caído

1. **`core/death_saves.py`** (puro, RNG injetável): `DeathSaves` (sucessos e falhas), `roll_save(saves, rng) -> Outcome`, `DC = 10`, `STABLE_AT = 3`, `DEAD_AT = 3`.
   d20 puro, sem modificador nem Sorte; **20 natural** revive na hora; **1 natural** vale 2 falhas.
2. **`Player`:** `death_saves`, `dead`, `is_downed` (`hp <= 0` e não morto); `is_alive()` **não muda** (`hp > 0`). **`Party`:** `downed_members()` e
   `dead_members()`; `all_down` não muda (todos a 0 PV = derrota, sem testes).
3. **`App`:** no início do turno do jogador, 1 teste por caído (só em grupo; solo: cair = derrota); quem revive **não age naquele turno**; no fim do combate
   **vencido**, caídos e mortos voltam com **1 PV** e o contador zera; morto não é alvo, não age e não recebe cura na batalha. `SaveState` sem mudança.
4. **Interface:** no retrato do caído, 3 marcas de sucesso e 3 de falha, "Caído"/"Morto"; o d20 usa o widget dos testes e respeita x2 e "reduzir movimento";
   log/F12 ("Sylas: teste de morte 14, sucesso (2/3)"); aviso ao reviver e ao morrer. O rótulo "Levantar" do retrato fica para a 091.
5. **Testes:** os da seção 6 da SPEC (fronteira 9/10, acumular fora de ordem, zerar ao reviver/morrer/curar, 20 e 1 naturais, quem revive não age, fim do combate,
   derrota só com todos a 0 PV, solo, marcas na ordem, x2). Regressão: o solo não muda.
6. **Contato com 086:** o alvo aleatório (086 §4) só sorteia **vivos**; caído e morto nunca são alvo, então a 086 já tem que respeitar `is_alive()`.

## 8. SPEC-091: cura de aliados (depois da 092)

1. **`core`:** `Card.self_only: bool` (Segundo Fôlego, Imagem Espelhada `heals_clone`, Redenção Divina `redeems`); `heal_ally(caster, target, card)`
   com o dado e o modificador **do lançador**, Corrente e Desonra **do lançador**, PV para o **alvo**, respeitando o máximo; `single_use` consumido do
   baralho do lançador; alvo com PV cheio recusa.
2. **Levantar (§2.1):** cura em aliado a 0 PV o levanta com `PV = cura efetiva` (mínimo 1), **sem agir no turno em que levantou**, Corrente zerada, mão
   e pilha preservadas; a Poção também levanta; todos caídos segue sendo derrota; ao fim do combate volta com 1 PV (conferir o que a SPEC-037 já faz).
   Atualizar a SPEC-037 §1 ("fica fora até o fim do combate").
3. **Cartas afetadas:** as de `kind == "cura"` e os pergaminhos `scrolls.py` (Curar Ferimentos, Curar Ferimentos Maior, Palavra Curativa).
4. **Interface (`CombateScreen`):** com grupo > 1, ao selecionar uma carta de cura não-`self_only` os retratos do grupo acendem os alvos válidos
   (o caído com o rótulo "Levantar"; os inválidos apagados com o motivo); clicar no retrato confirma; clicar de novo na carta ou no lançador cura a si;
   o número de cura e o `player_hp_shown` animam no retrato do alvo; o texto da carta mostra "Só em si" ou "Alvo: aliado".
5. **Narração:** "Durvall usa Poção de Cura em Sylas: +4 (PV 3 → 7)", no formato enxuto da 088.
- **Decisão a fechar na implementação:** Redenção Divina (recomendação da SPEC: **só em si**); e se a Poção da mochila (SPEC-036) já permite aliado,
  senão abre spec própria (fora do escopo).
- **Regressão:** os testes de combate solo não podem mudar (com 1 personagem, sem seleção de alvo).

## 9. Testes, versão e evidência

- **Meta de contagem:** hoje 1677; cada SPEC acrescenta os testes da sua seção e nenhum antigo pode ser removido, **exceto** os de "menor CA" da SPEC-037
  (reescritos na 086) e os que dependem do texto de narração antigo (reescritos na 088).
- **Versão:** `game/version.py` sobe uma vez por lote. Proposta: **0.11.1** depois de 087, 089, 086 e 088; **0.12.0** com a 091 (regra nova de combate). O
  texto e a data pedem seu OK no commit.
- **Evidência:** ao fim de cada SPEC, um resumo curto em `.atena/evidence/` (o que foi conferido no jogo e o número de testes), como o `EVID-005`.
- **Playtest:** as tarefas em `.atena/tasks/` ganham itens para colisão, porta travada, mercador com moedas, x2, Esc na exploração e cura de aliado.

## 10. Depois deste plano

Segue o `PLAN-018` (M2): SPECs 092 a 095 a escrever e aprovar, começando pelo catálogo de missões com o teste dourado de M1. Os pontos abertos dele
estão na seção 7 do `PLAN-018` (a "primeira fase de dupla", que personagem a conquista libera, o mapa de Dagruve).

## 11. Riscos

| Risco | Contenção |
|---|---|
| Working tree misturado (várias frentes editando os mesmos arquivos) | Passo 0: commits por SPEC com `git add` seletivo; suíte verde antes de cada um |
| `app.py` (3.500+ linhas) concentra 086, 088 e 091 | Uma SPEC de cada vez, suíte completa entre elas; sem refatorar `app.py` no meio |
| 088 mexe no Esc de todas as telas | Testes de "sobreposição mais interna primeiro" antes da mudança |
| 091 muda regra de combate em grupo | Os testes do solo como rede; `self_only` e levantar com teste puro antes da UI |
| Números ajustados sem playtest (087) | Só os da SPEC; qualquer outra mudança vai para evidência |
