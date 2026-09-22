---
id: "PLAN-018"
type: "plano"
title: "Implementação de M2: ordem, fronteiras de código e critérios de saída"
status: "draft"
created: "2026-09-20"
relations:
  - "[[PLAN-016-m2-praca-da-loucura-2026-09-20]]"
  - "[[ART-PROMPTS-022-m2-praca-da-loucura-2026-09-20]]"
  - "[[SPEC-082-inimigos-de-corpo-inteiro]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
sources:
  - "Responsável, 2026-09-20: 'vamos fazer um plano para implementar m2'"
  - "Leitura do código em 2026-09-20 (acoplamentos a M1 listados na seção 2)"
---

# Implementação de M2

> Rascunho. Detalha o **como** do `PLAN-016` (que fixa o **quê**), com o acoplamento real do código. Não autoriza codar: cada
> etapa abaixo é uma SPEC a aprovar (`execution_approval: per-spec`), e commits seguem pedindo aprovação.

> **Numeração:** as SPECs 083 a 092 já foram escritas por outras frentes (minimapa, números de dano, abas, luta por colisão, eventos, baralho,
> mercador, andar de lado, cura de aliados, testes de morte). As SPECs de M2 deste plano passam a ser **093 a 097** (numeração a reservar na hora de escrever, porque outras frentes também criam SPECs). O plano das SPECs em aguardo (086, 087, 088,
> 089, 091 e 092) está no `PLAN-019` e **vem antes** da etapa 1 daqui.

## 1. Estado de partida

- M1 é a única missão. `WorldMap` já recebe `edges` e `start`; o resto é global.
- A SPEC-082 (inimigos de corpo inteiro) e as SPECs 081, 083, 084, 085 e 090 já estão implementadas no working tree, **sem commit**. Fechar e commitar
  isso (com o OK do responsável, dado em 2026-09-20) é o passo 0 do `PLAN-019`; a suíte estava em **1677 testes verdes** em 2026-09-20.

## 2. Mapa real do acoplamento a M1

| O que é fixo em M1 | Onde | Destino |
|---|---|---|
| `ROOMS` (ids 1..7), `CONCLUSAO_XP`, `fog_for_backdrop` | `core/rooms.py` | `MissionDef.rooms`, `.completion_xp` |
| `M1_EDGES`, `M1_START` | `core/worldmap.py` | `MissionDef.edges`, `.start` (o `WorldMap` já aceita os dois) |
| `ROOM_RECTS`, `CORRIDORS`, `DOORS`, `START`, `ANCHORS`, `ENEMY_CELLS`, `PROP_CELLS`, `MARKER_ROOMS`, `event_cell`, `build()` | `core/dungeon_m1.py` | uma `DungeonDef` por missão; `walk_screen.py` deixa de importar o módulo |
| `SITUATIONS` (por id de sala) | `core/exploration.py` | `MissionDef.situations` |
| `ROOM_INTRO`, `ENEMY_FLAVOR`, `RUN_END` | `core/lore_m1.py` | `MissionDef.lore` |
| `HQ_BY_MISSION`, `CURRENT_MISSION` | `core/hq.py` | missão ativa no `App`; HQ de saída na `MissionDef` |
| `BOSS_ID` (o `offer_boss_reward` já aceita `boss_id`) | `core/collection.py` | `MissionDef.boss_id` |
| `AMBIENTE` (id → textura), `_ROOM_ASSET` | `ui/world_art.py` | vem da `MissionDef` |
| `_ROOMS`, posições dos nós | `ui/automap.py`, `ui/corridor_view.py`, `ui/map_view.py` | vêm da `MissionDef` |
| `len(ROOMS)` no texto do tutorial | `ui/tutorial_content.py` | da missão ativa |
| `ROOMS[app.room_index]` | `evidence_export.py`, `app.py` (23 pontos) | `app.mission.rooms` |
| Eventos por sala (`room > MIMIC_MIN_ROOM`, ouro por sala, textos das Docas e da "fenda de névoa") | `core/events.py`, `event_data.py` | `MissionDef.events` (ids permitidos) e índice relativo da sala |
| `start_run()` sempre cria M1 (`WorldMap()`, `dungeon_m1.build()`) | `app.py:2889` | `start_run(mission_id, party)` |
| `InterludioScreen`: "Próxima missão" abre a seleção de personagem | `app.py:1044` | tela de Missão |
| Save sem noção de missão (`hqs_seen`, sem `missions_completed`) | `core/progress.py` | campo novo com migração |
| Elenco: `CharacterSelectScreen.characters = CHARACTERS.values()`: os 5 são jogáveis desde o início (Brook desde a v0.9.1) | `app.py:829` | sistema de elenco e desbloqueio (etapa 2b) |

Consequência: **`Room.id` numérico repete entre missões**. Todo lookup passa a ser pela `MissionDef` ativa; onde um id sai do `core`
(devlog, evidência, save de evento) ele leva o prefixo `m2:`.

## 3. A fronteira: `MissionDef`

Módulo novo `core/missions.py`, sem `pygame`, só dado e fábricas. Um dataclass congelado por missão:

`id`, `title`, `requires` (ids de missões concluídas), `cast` (o elenco canônico: coluna "Elenco disponível" do `VSN-003`), `unlocks_characters` (quem a conclusão libera), `rooms`, `edges`, `start`, `dungeon` (uma
`DungeonDef` com os mesmos campos de `dungeon_m1`), `situations`, `lore` (intro de sala, sabor de inimigo, fim de missão),
`events` (ids permitidos), `completion_xp`, `boss_id`, `exit_hq`, `briefing_id`.

Catálogo `MISSIONS: dict[str, MissionDef]`, com `M1` (dados de hoje, movidos sem alterar valores) e, na etapa 3, `M2`.

## 4. Ordem de implementação (cada etapa é uma SPEC e termina com a suíte verde)

### Etapa 1 — SPEC-093: catálogo de missões, M1 portada

**Objetivo:** M1 idêntica, atrás da fronteira nova.

1. Criar `core/missions.py` + `DungeonDef`; mover os dados de `rooms.py`, `dungeon_m1.py`, `worldmap.py`, `lore_m1.py`,
   `exploration.py` (situações) para o registro `M1`. Os módulos antigos viram finos ou somem, sem mudar um valor.
2. `App` passa a guardar `self.mission` (padrão `M1`). Trocar os 23 usos de `ROOMS`/`dungeon_m1` em `app.py` e nos arquivos da seção 2
   por `self.mission.*`. `start_run(mission_id=...)` valida `requires`.
3. **Teste dourado antes de mexer:** um teste que congela o que M1 é hoje (ids, arestas, `ascii_map()`, situações, fog, XP, chefe,
   `event_cell` com semente fixa) e roda **antes e depois** da migração. É a rede de segurança da etapa.
4. Simulação: `scripts/simulate.py` de M1 antes e depois, mesmos números.

**Saída:** 1639+ testes verdes, teste dourado igual, playthrough curto de M1 nos dois modos (caminhada e portas), sem conteúdo de M2.

### Etapa 2 — SPEC-094 (campanha e save) e SPEC-095 (elenco e compra)

**2a. Campanha e save**

1. `SaveState.missions_completed: set[str]`, entrando em `to_dict`/`from_dict` no padrão do arquivo (campo ausente = padrão; **sem subir
   `SAVE_VERSION`**, como as SPECs anteriores). Migração: `hq_001` em `hqs_seen` ⇒ `m1` concluída. XP sozinho não desbloqueia.
2. `finish_run(VITORIA)` registra a missão ativa (e as conquistas que ela dá) **antes** de salvar o resultado e a oferta do chefe, no mesmo
   `save_store.save`, para que fechar o jogo no meio não perca o desbloqueio; a oferta pendente continua obrigatória.
3. **Tela de Missão** (substitui o botão "Próxima missão" do `InterludioScreen`): lista as missões liberadas, mostra o briefing e leva à seleção
   de grupo. No Interlúdio A apresenta Brook. Texto na UI com fundo de fallback (`screens/missao` só entra quando a arte chegar).
4. `HQ_BY_MISSION` dá lugar à HQ de saída da `MissionDef`; `hq_002` (Interlúdio A) e `hq_003` (saída de M2) entram como dado em `core/hq.py`.

**2b. Elenco e desbloqueio** (fluxo definido pelo responsável em 2026-09-20; hoje **não existe**: os 5 personagens estão sempre livres)

1. **Começo do save:** o jogador escolhe **um** dos 4 iniciais (Kayron, Durvall, Sylas, Maelor); os outros 3 ficam bloqueados. Tela nova de
   escolha inicial, antes da seleção de sempre, com confirmação (a escolha trava os outros). `SaveState.unlocked_characters: set[str]`.
   **Vale para todos os saves, inclusive os existentes** (decisão do responsável): o save existente, ao abrir, cai nessa mesma tela (com o
   personagem mais jogado pré-selecionado). O `progress` (nível, XP, mortes), o equipamento e as cartas dos outros personagens **ficam guardados** e
   voltam quando eles forem desbloqueados; nada é apagado.
2. **Tamanho do grupo por conquista** (regra do responsável, 2026-09-20; `PARTY_MAX = 3` em `party.py:18` vira `party_limit(save)`, usado em
   `app.py:863`, `:942` e `:2894`):
   - **1** personagem por padrão;
   - **2** com a conquista **"Dupla"**: ter **pelo menos 1 personagem no nível 3** (350 XP acumulados; uma vitória de M1 vale ~100);
   - **3** com a conquista **"Trio"**: **todos os personagens no nível 3, incluindo Brook** (leitura: os 5 do elenco, o que exige tê-los comprado).
   As conquistas são avaliadas em `finish_run` e **também ao abrir o save** (um save antigo com personagem no nível 3 já nasce com "Dupla").
   O mesmo padrão de `_veterans` (todos os `CHARACTERS` no nível N), com N = 3.
3. **Mais personagens: conquista libera, compra efetiva** (regra do responsável): uma conquista de liberação **não dá o personagem**, ela **libera a
   compra** dele na loja. Cabe no que a SPEC-035 já tem: `ShopItem` ganha o tipo `PERSONAGEM`, com `titulo_requerido` = id da conquista (o mecanismo de
   títulos que já liberam equipamentos e upgrades) e `preco` em moedas; `shop.buy` adiciona o id a `SaveState.unlocked_characters`. Sem a conquista
   o item nem aparece; com ela e sem moedas aparece com "Faltam N". **Brook segue a mesma regra**, mas só pode ser cobrado **depois de concluída a
   missão em que é introduzido** (M2, onde o `VSN-003` lista "+Brook"): a conquista dele é "Conclua M2". O Interlúdio A o **apresenta** na história,
   mas ele só fica jogável depois da compra. Preço inicial a balancear no playtest (proposta: ~300 moedas, cerca de 3 vitórias de M1).
   **Vagas de compra (aprovado):** em vez de ligar cada conquista a um personagem, cada conquista de liberação abre **1 vaga** e o jogador
   escolhe quem comprar entre os iniciais ainda bloqueados. São 3 vagas: **"Dupla"** (1º), **"Conclua M2"** (2º) e **"Conclua M2 com o grupo de
   dois"** (3º). Compra permitida = `personagens_comprados < vagas_abertas`. **Brook** tem item próprio, liberado por **"Conclua M2"** (a mesma
   conquista abre a 2ª vaga e a compra dele). **Preço:** 300 moedas para todos (a ajustar no playtest).
4. **Regra de acesso à missão** (função pura `can_play(mission, party, save)`): o grupo respeita `party_limit(save)` e cada personagem precisa
   estar desbloqueado **e** (a missão já foi
   concluída **ou** ele está no `cast` da missão). A **primeira vez** só vale com quem estava na missão (M1: Kayron, Durvall, Sylas, Maelor; M2: os
   quatro + Brook; M3 a M6: os 5); **depois de concluída**, qualquer personagem desbloqueado pode rejogá-la. Vale para cada membro do grupo.
5. **Seleção de personagem** mostra os bloqueados como silhueta com a condição ("Conquista: ...", "Conclua M1") e esmaece quem ainda não pode entrar
   na missão escolhida (fora do `cast`). O botão de grupo mostra "Conquista: Dupla" ou "Conquista: Trio" enquanto o limite não abre; com 1 personagem o modo grupo não aparece.
6. **Baralho:** já é único e serve a todos (`start_run` monta `deck_names` do save para cada `Player`); nada muda.
7. **Ajustes que o modelo novo obriga:** a conquista "Dois Veteranos" (`_veterans`) exige **todos** os `CHARACTERS` no nível 5, o que com
   personagens bloqueados fica impossível: passa a valer só para os **que o jogador possui**, com o texto ajustado. Os marcos de layout de classe por
   mortes (`layout_unlocks`) só andam para quem o jogador tem: aceito, mas sinalizado no texto.
8. **Migração:** save **sem** `unlocked_characters` (todo save existente) **passa pela escolha inicial** (item 1). Se já tem `hq_001` visto, Brook
   entra desbloqueado (M1 concluída). O aviso na tela explica que os outros personagens voltam por conquista, sem perda de progresso.

**Saída:** save novo só oferece M1 e o personagem escolhido; vitória persistida de M1 libera M2 e a de M2 libera a compra de Brook; save antigo migra sem perder coleção, equipamento,
nível nem personagem (os outros ficam guardados até serem comprados); fechar e reabrir com oferta do chefe pendente não permite contorná-la; um personagem fora do `cast` não entra na primeira vez
de uma missão, mas entra depois de ela ser concluída.

### Etapa 3 — SPEC-096: M2, mapa, exploração e narrativa

1. As 6 salas lineares (Entrada de Dagruve → Praça externa → Beco das sentinelas → Porta da igreja → Nave profanada → Altar), o
   grafo `1-2-3-4-5-6`, a `DungeonDef` em grade (retângulos, corredores, portas, âncoras, células de inimigo e adereços) e o modo de portas.
2. Situações: entrada (Arlindo, escolha social que dá vantagem pequena, nunca bloqueio) e porta da igreja (pistas do ritual, item
   temporário ou ouro). Lore de sala, sabor dos inimigos e fim de missão.
3. **Eventos:** `MissionDef.events` filtra o sorteio. O evento da "fenda de névoa" e o texto das Docas são de M1; em M2 valem os
   demais. `MIMIC_MIN_ROOM` e o ouro por sala passam a usar o índice **relativo** da sala na missão.
4. **Recompensas narrativas** (mapa de Dagruve; a ocarina foi retirada por decisão do responsável): guardadas em um conjunto novo `SaveState.story_items` (mesmo padrão de
   campo opcional), não como carta nem equipamento. O mapa marca `m3` como desbloqueada. Poção de força de gigante do gelo e
   gema elemental entram na bolsa, conforme o que `items.py` já suporta (a decidir na SPEC).
5. Com `Room.fog` opcional: M2 nasce **sem névoa**, como nos prompts.

**Saída:** M2 completa em ambos os modos com fallback (retângulos), sem chefe especial ainda (o altar usa um cultista comum como
placeholder).

### Etapa 4 — SPEC-097: inimigos, sacerdote e reforços

1. Inimigos de dado declarativo em `enemies.py`: cultista de adaga, cultista de cajado, cultista arqueiro, sacerdote, zumbi. O
   arqueiro é inimigo normal (sem cobertura); a diferença é o dado de ataque e o texto.
2. **`EncounterScript`** no `core` (a única mecânica nova, ver seção 5).
3. Recompensa do chefe: `boss_offer("sacerdote_mente_derretida")` precisa de um pool próprio de raras. Decidir na SPEC: reaproveitar
   parte do pool de M1 ou criar poucas cartas novas. Também `BOSS_ID` deixa de ser constante.
4. Números **iniciais**, âncoras relativas a M1 (guardião cópia 16 PV/CA 12; verdadeiro 26 PV/CA 13/CAM 12): cultista ~10-12 PV/CA 11;
   arqueiro ~8 PV, ataque à distância mais forte e CA baixa; sacerdote ~34 PV, CAM 14; zumbi ~14 PV, lento (ataca a cada 2 turnos),
   CA 9. XP e ouro na escala de M1 ×1,5. Todos ficam marcados como "a ajustar no playtest".

**Saída:** M2 jogável de ponta a ponta, com o sacerdote invocando 4 zumbis; suíte verde.

### Etapa 5 — Arte e ligação (paralela a partir do fim da etapa 3)

1. Gerar com `ART-PROMPTS-022` na ordem sugerida lá: inimigos e cenas primeiro.
2. `process_art.py`: novas categorias de nomes (`portraits` já existe; `items`, `hq`, `screens`, `world` e `enemies` já processam);
   conferir que `enemies` (SPEC-082) sai em 320x480 com alfa.
3. Ligar por convenção de nome: cena `rooms/<sala>/bg|fg`, `world/<ambiente>/wall|floor|ceiling`, `doors/porta_igreja`. O cabeçalho
   `AMBIENTE` de `world_art.py` passa a vir da `MissionDef`.
4. Sem o arquivo, continua o fallback. Testar a build empacotada (PyInstaller `--add-data assets/`) com e sem arte de M2.

### Etapa 6 — Validação e playtest

Simulação por composição de grupo (`scripts/simulate.py`) para M2; regressão completa de M1; campanha M1→Interlúdio A→M2 nos dois modos;
saves migrados; playtest humano (tarefas novas em `.atena/tasks/`) medindo duração, dificuldade e clareza da invocação. Ajustar números
só depois, numa evidência (`EVID-xxx`).

## 5. `EncounterScript`: o desenho da única mecânica nova

- **Dado, no `core`:** `EncounterScript(trigger_hp_pct, summons: Callable[[], list[Enemy]], once=True)`, anexado ao `Enemy` do sacerdote.
  Estado próprio `fired: bool` **na instância do inimigo**, então recarregar a UI, trocar de alvo ou reabrir o combate não dispara de novo.
- **Gatilho:** depois de cada dano ao portador que o deixa **vivo**, `script.check(enemy)` devolve os reforços quando
  `hp <= trigger_hp_pct * max_hp` e ainda não disparou. **Valor decidido: 50% dos PV.**
- **Morre sem invocar (decidido):** se um golpe leva o sacerdote de acima do gatilho direto a 0 PV, ele cai, o script não dispara e o combate
  acaba, sem limite de dano nem exceção. Consequência: quem tem dano alto pode pular a invocação; o gatilho e os PV do sacerdote controlam a
  frequência dela, e isso vai para o playtest.
- **UI (`CombateScreen`):** um método `add_enemies(list[Enemy])` acrescenta `EnemySlot`s ao fim da fileira, recalcula posições e rótulos
  (`enemy_positions` suporta 5: 5x160 + 4x30 = 920 px, cabe em 1280; o layout de combate precisa ser conferido em captura), toca um
  aviso ("Os mortos se levantam") e os reforços **só agem a partir do próximo turno inimigo**. A tela também precisa incluí-los
  em alvo de área, na fila de ataque e na contagem de "último inimigo" (o combate só acaba quando não sobra nenhum vivo).
- **Fora:** IA geral, fases arbitrárias, cinemática. Reaproveitável em M5 (Astherion tem 2 fases) só depois de provar valor.

## 6. Testes e critérios de aceite transversais

- **Puros (`tests/core`):** catálogo e `requires`; migração de save (com `hq_001`, sem, campo ausente, campo inválido); `WorldMap` por
  missão; grade de M2 (Euler não se aplica: conferir conectividade, portas e âncoras dentro das salas); `EncounterScript` (uma vez,
  morrer sem disparar, disparar uma vez, recarga); pool do chefe.
- **De fluxo (`tests/ui`):** M1→Interlúdio A→M2 nos dois modos; oferta pendente ao fechar/reabrir; elenco (escolha inicial, `can_play`, replay com outro personagem, migração); sacerdote com
  4 reforços no layout; build sem arte.
- **Dourado de M1** (etapa 1) roda em toda etapa seguinte como guarda.

## 7. Decisões (todas aprovadas em 2026-09-20 com as recomendações)

- **Elenco:** 1 inicial entre 4; os outros por conquista + compra (300 moedas); 3 vagas de compra ("Dupla", "Conclua M2", "Conclua M2 com o grupo de
  dois"); Brook comprável só depois de concluir M2 (conquista "Conclua M2"); regra aplicada a todos os saves, com o progresso dos bloqueados guardado.
- **Grupo:** 2 com "Dupla" (1 personagem no nível 3); 3 com "Trio" (os 5 personagens no nível 3, o que exige tê-los comprado).
- **Missões:** primeira vez só com o elenco canônico (coluna "Elenco disponível" do `VSN-003`); depois de concluída, qualquer personagem que o jogador tenha.
- **Chefe de M2:** morre sem invocar; gatilho em 50% dos PV; 4 zumbis.
- **Itens:** ocarina fora; mapa de Dagruve em `story_items` no save (sem virar carta nem equipamento).
- **Fila:** SPEC-082 fechada antes de tudo; as SPECs em aguardo (`PLAN-019`) antes da etapa 1.

## 8. Estimativa de tamanho e risco

| Etapa | Tamanho | Risco principal | Contenção |
|---|---|---|---|
| 1 | maior (mexe em ~18 arquivos) | regressão de M1 | teste dourado antes; sem conteúdo novo |
| 2 | médio | perder desbloqueio ou oferta no save | gravar conclusão e oferta no mesmo `save()`; testar fechar/reabrir |
| 3 | médio | duplicar dado de M1 por engano | `MissionDef` é a única fonte; M1 e M2 no mesmo teste de estrutura |
| 4 | médio | layout com 5 inimigos e fluxo de morte | captura do combate; teste do "último inimigo" com reforços |
| 5 | pequeno (código) / grande (geração) | arte fora do contrato | triagem do `ART-PROMPTS-022`; fallback intacto |
| 6 | pequeno | dificuldade errada | evidência antes de rebalancear |
