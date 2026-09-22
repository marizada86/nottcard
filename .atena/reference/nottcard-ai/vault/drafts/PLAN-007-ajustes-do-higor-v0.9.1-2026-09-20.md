---
id: "PLAN-007"
type: "plano"
title: "Ajustes do Higor na v0.9.1 (guia, ícones nos botões, mão máxima, suspense da Corrente) e novo build"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[FB-003-notas-higor-guia-botoes-mao-corrente-2026-09-20]]"
  - "[[SPEC-050-modo-playtester-boas-vindas-e-bloco-de-notas]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-045-loja-de-upgrades-e-regras-do-baralho]]"
  - "[[SPEC-025-corrente-quebra-no-erro-e-ajustes-durvall-maelor]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
sources:
  - "Responsável, 2026-09-20: plano para as notas do Higor (FB-003) e análise dos assets com novo build"
---

# Ajustes do Higor na v0.9.1

Rascunho: nada aqui é regra até cada spec ser aprovada (`execution_approval: per-spec`). Onde há **[decisão]**, a recomendação vem
primeiro, para aprovar em bloco. Commit, merge e publicação seguem exigindo aprovação explícita (`add.yaml`).

## 1. Resumo e ordem

| Ordem | Spec (nova) | Nota | O que entra | Porte |
|---|---|---|---|---|
| 1 | `SPEC-059` Suspense da Corrente | H16 | O indicador da Corrente (e os outros recursos) só muda quando o resultado é revelado | M |
| 2 | `SPEC-060` Guia sempre visível e ícones nos botões | H13, H14 | Botão "Guia" global; ícones de Ação e Bônus nos botões de comprar carta | P/M |
| 3 | `SPEC-061` Upgrade "Mão Maior" liberado por conquista | H15 | Novo upgrade na loja: +1 no máximo de cartas na mão, exige uma conquista | M |
| 4 | Build `v0.9.2` | — | Auditoria dos assets, testes, build local | P |

Motivo da ordem: o H16 é o único que toca a lógica de apresentação do combate inteiro (fila de "batidas"), então entra primeiro e com
mais testes. O H13 e o H14 são só interface e não mexem em regra. O H15 é regra de loja e mexe num limite que vários pontos leem
(`MAX_HAND_SIZE`), por isso vem depois, com o simulador.

## 2. H13: guia do playtester sempre visível

**Hoje.** O botão "Guia do playtester" só existe na tela do menu (`MenuScreen.guide_button`, `game/app.py:302` e `:365`). Ele abre a
`WelcomeScreen` como uma **tela** (`open_welcome`), e ao terminar chama `return_to_menu()`. Se fosse aberto no meio de uma luta, a partida
seria destruída. Por isso hoje ele só aparece no menu.

**Proposta.**
- Um botão **"Guia"** global, no topo (pílula à esquerda do botão de velocidade 1x), desenhado em `App.draw_frame` junto de "?", tela cheia,
  pausa e velocidade. Aparece em todas as telas (menu, exploração, combate, caminhada, resultado), menos no login e na própria boas-vindas.
  Só na build de playtest (`PLAYTEST_BUILD`) e com jogador identificado, como hoje.
- O clique abre uma **sobreposição** (`GuideOverlay`), no mesmo padrão do tutorial e do bloco de notas: pausa a tela de baixo
  (`screen.pause()`, o cronômetro do chefe congela), registra no log dev ("Guia aberto (jogo pausado)") e, ao fechar (Esc, "Voltar" ou
  clicar de novo no botão), retoma. Nada da luta é perdido.
- O conteúdo é o mesmo (`guide_sections`); o desenho do painel é extraído de `playtest_guide.py` para as duas telas usarem.
- Sai o botão do menu (fica redundante). A boas-vindas da primeira vez continua igual.
- **[decisão]** atalho de teclado para o guia (proposta: `F2`; as teclas F1, F5, F6, F7, F11 e F12 já têm uso).

**Testes.** O botão é desenhado no combate, no menu e na caminhada; o clique no combate abre a sobreposição, pausa o cronômetro e o
`Sequencer`, bloqueia o input da mão; fechar retoma; não aparece no login, na boas-vindas nem com `PLAYTEST_BUILD = False`.

**Arte.** Nenhuma nova (botão de texto).

## 3. H14: ícones de Ação e Bônus nos botões

**Hoje.** `game/ui/combat_view.py:145-146` desenha "Comprar 1 carta (Ação)" e "Comprar 1 carta (Bônus)" como texto puro (quando o Bônus
já foi usado, "Ação Bônus usada"). O trilho da direita já mostra as gemas de Ação (losango laranja), Bônus (estrela azul) e Reação (círculo
roxo) por `draw_action_indicators`. Dois problemas: "(Bônus)" soa como carta grátis, e o jogador precisa ligar o texto à gema sozinho.

**Proposta (segue o anexo do Higor).**
- Os botões passam a dizer **"Comprar 1 carta"** + a **gema da ação** no lugar do parêntese: losango laranja no botão de Ação, estrela azul
  no de Bônus. A mesma arte e as mesmas cores do trilho, então a ligação é imediata.
- Uma função `draw_button(..., icon=)` em `hud.py`, com o ícone à direita do texto, reaproveitando `_fitted_icon` (que já recorta a margem
  transparente e ajusta o tamanho).
- **Não depende só de cor:** os ícones diferem por forma (losango x estrela) e o botão ganha uma dica ao passar o mouse
  ("Gasta a sua Ação Bônus"). O estado usado continua em texto: "Ação Bônus usada", com o ícone apagado.
- Sem a arte (regra do projeto: se o asset não existe, não bloquear), o botão cai no texto completo **"(Ação Bônus)"**, como o Higor
  sugeriu como alternativa.
- Ajustar o texto do tutorial (`tutorial_content.py:70`), que hoje diz "(Bônus)", para "Ação Bônus", e legendar as gemas. (O log do combate já diz "Ação Bônus", `app.py:1656`.)
- O rótulo "Bônus" do indicador do trilho fica (não há largura para "Ação Bônus": o trilho começa em x=1170).

**Testes.** O botão de Ação e o de Bônus têm ícone; sem o arquivo, o texto de reserva; "Ação Bônus usada" com o ícone apagado; os testes
atuais de "Comprar 1 (Ação)" (`tests/ui/test_discard_and_draw_two.py`) continuam valendo (os textos do log não mudam de Ação).

**Arte.** Nenhuma nova: `assets/hud/ind_acao.png`, `ind_bonus.png` e `ind_reacao.png` já existem (128x128, com alfa). Conferir a
legibilidade a ~28 px no build.

## 4. H15: "Mão Maior", liberada por conquista

**Hoje.** O limite da mão é a constante `MAX_HAND_SIZE = 5` (`game/core/state.py:20`), lida em `excess_count`, `discard_excess`, na mão
inicial (`min(MAX_HAND_SIZE, 3 + Mão Cheia)`), em `exploration.py:156` e no texto do tutorial ("até 5", "teclas 1 a 5"). O upgrade "Mão
Cheia" (`upgrades.py`) já existe, mas dá **cartas na mão inicial**, não aumenta o limite. A loja já liga um item a uma conquista pelo
`titulo_requerido` (título = id da conquista), hoje usado por layouts e equipamentos; os upgrades são todos livres desde o início.

**Proposta.**
- Um novo upgrade **"Mão Maior"** (`mao_maior`): **+1 no máximo de cartas na mão**, 2 níveis (5 para 6, 6 para 7). Custos iniciais
  600 e 1800 moedas (o Higor calibra com o simulador). O nome deixa claro que é diferente do "Mão Cheia".
- **Exige o título de uma conquista** (`titulo_requerido`): sem ela, o item aparece na loja bloqueado com "Requer: <conquista>"
  (o padrão que a loja já usa); ao ganhar a conquista, libera.
- **Núcleo:** `MAX_HAND_SIZE` vira `BASE_MAX_HAND = 5`; `upgrades.hand_limit(upgrades)` devolve 5 + nível; o `Player` guarda o
  limite da tentativa (como já faz com o Mão Cheia) e `excess_count`, `discard_excess`, a compra inicial e a exploração passam a usar
  esse valor. O teto do "Mão Cheia" acompanha o limite. O texto do tutorial e as teclas de descarte (1 a N) ficam dinâmicos.
- A interface da mão já aperta as cartas quando a mão cresce (`layout_hand`); confirmar visualmente com 6 e 7 cartas.
- **Save antigo:** sem o campo, o nível é 0 (`level()` já limita ao teto): não precisa de migração. "Novo jogo" zera, como os outros.
- O catálogo de conquistas mostra "libera: ..." com um item só (`item_for_title` devolve o primeiro): passa a listar todos.
- **Trava contra quebrar o jogo (regra do Higor):** teto de +2 (mão de 7); não muda Corrente, dano nem cura; rodar `scripts/simulate.py`
  antes e depois para ver se a taxa de vitória sobe demais.
- **[decisão]** qual conquista libera. Hoje: *Fechadura Aberta* (concluir a missão), *Dois Veteranos* (todos os personagens no nível 5;
  com 5 personagens isso ficou muito difícil) e *Sorte de Sendrinah* (3 críticos numa tentativa). **Recomendação:** *Fechadura Aberta*,
  porque é a primeira que o jogador ganha e mostra a loja pagando. Alternativa: nível 1 pela *Fechadura* e nível 2 pelos *Veteranos*
  (exige requisito por nível, mais código).

**Testes.** Núcleo: limite 5/6/7 conforme o nível; descarte de excesso e mão inicial respeitam o limite; o Mão Cheia não passa dele;
`shop.availability` bloqueia sem a conquista e libera com ela; compra sobe o nível e cobra; save antigo carrega; catálogo lista os
itens de cada título. Interface: mão de 7 cartas sem sobrepor o orbe.

**Arte.** Nenhuma nova (a loja desenha upgrades sem ícone).

## 5. H16: o suspense da Corrente

**Hoje (causa).** Em `CombateScreen`, ao jogar uma carta, o `resolve_attack` roda **na hora** e já chama `combo.break_chain()` ou
`combo.advance()` (`game/core/combat.py:265-292`). Só depois a fila de batidas (`Sequencer`) toca: anúncio, d20 do acerto, dados de
dano, impacto ou "erro". O `draw_combat` desenha o indicador a partir de `player.combo` **ao vivo** e reinicia a animação quando
`combo.changes` muda (`combat_view.py:125`). Resultado: o aviso "Corrente xN perdida" e o tremor aparecem enquanto o d20 ainda gira.
O PV já evita isso (`hp_shown`); a Corrente não.

**Proposta.** Separar o **estado real** do **estado mostrado**, como o PV já faz.
- `ComboTracker.view()` (núcleo, sem pygame) devolve uma foto congelada: sequência, `broken_from`, `changes`, Poder Místico, multiplicador
  da próxima carta. A tela guarda a foto de **antes** da jogada.
- Uma batida sem duração, `"corrente"`, atualiza a foto mostrada **no instante da revelação**: no acerto, no início do impacto; no erro,
  junto do "Errou!" (início de `erro-jogador`); no ataque em área, depois dos d20 de todos os alvos; no teste de atordoamento que falha
  (Golpe Contundente), no resultado do teste. `draw_combo_indicator` passa a receber a foto, não o `combo` vivo.
- **Mesmo padrão nos outros recursos** que a jogada muda cedo: Poder Místico do Kayron, Cópia do Sylas, Guarda e Desonra do Brook
  (`draw_player_resources`). A spec inclui uma auditoria do que a UI lê ao vivo antes da batida.
- Sem mudar regra, dano, save nem o registro do log dev (F12 pode continuar imediato).
- **Cuidados:** se a fila esvaziar antes (o inimigo morre no golpe, o combate acaba), forçar a sincronização no fim da fila e antes de
  `_queue_after_player`; a pausa e o 2x já param ou aceleram o `Sequencer`, então a foto acompanha.

**Testes.** No núcleo: `view()` é uma cópia (não muda quando o tracker muda). Na tela, com o `Sequencer` avançado à mão: ataque que erra
mantém a foto antiga (mesma sequência e `changes`) enquanto a batida do d20 está ativa, e iguala o real quando "erro-jogador" começa;
ataque que acerta avança a Corrente só no impacto; área e atordoamento; combate que acaba no golpe termina com a foto igual ao real.

**Arte.** Nenhuma.

## 6. Análise dos assets (feita em 2026-09-20, somente leitura)

Rodei uma auditoria: o que o conteúdo do jogo pede (cartas, inimigos, personagens, itens, salas, dados) e o que o código carrega por
nome (`load_image` e `asset_exists`), contra o que existe em `assets/`.

| Resultado | Detalhe |
|---|---|
| **Faltando** | **Nenhum.** Toda arte que o jogo pede existe (nenhum cai no retângulo com o nome) |
| **Criados desde o último build** (0.9.1, 14:13) | **59 arquivos novos ou refeitos** (o pacote do 0.9.1 tinha 18 texturas de dado e 3 do mundo; agora há 48 e 29). **Ainda fora do git: 68 arquivos** (39 faces de dado e o `assets/world/` inteiro). **(1) Mundo, 29 arquivos:** parede, piso e teto das 7 salas (21) e 8 adereços (tocha, barril, caixote, livros, braseiro, rede, vela, ossos). O `world_art.py` já carrega o chão, a parede, o teto e os adereços (SPEC-058), mas essa parte do código é justamente o **trabalho em andamento não commitado**. **(2) Faces dos dados, 30 arquivos** (d4, d6, d8, d10 e d20; 48 no total em `dice/textures/`): **nenhum código as carrega** (o dado é malha procedural, `dice_mesh.py`), então entram no pacote e só ocupam ~1,7 MB. Precisam de uma spec de integração para aparecer no jogo |
| Pasta `assets/` | 586 MB no disco; o `build_local.py` deixa de fora `_raw/` (saída bruta) e `concepts/` (54 MB de conceito que o jogo nunca carrega); o pacote do executável fica com **45 MB** |
| Contagem (processada) | cartas 79, dados 54 (48 texturas de face), HUD 42, mundo 29, salas 21, telas 9, portas 5, inimigos 4, itens 4, retratos 5, HQ 4, arquivos de fonte 5 |
| Formato | cartas, inimigos, itens e retratos em RGB; HUD, dados e portas em RGBA; salas e HQ misturam paleta (P) e RGBA. 3 fundos de sala passam de 700 KB (o maior, 905 KB): sem problema |
| Sobra (sem referência no código) | `verso_carta`, `d20_edge_glow`, `deck_icon`, `discard_icon`, `baralho_2_icon` e `pacote_figurinhas_icon` (recursos que saíram na SPEC-045), `moeda_icon`, `raridade_comum/incomum/rara_icon`, `carga_icon`, `copia_icon`, `guarda_icon` (as barras de recurso hoje não usam ícone) e as telas `diario` e `interludio`. São poucos KB; recomendo **manter** (documentados como reservados). Os falsos alertas (faces dos dados, `attr_*`, `passiva_*`) são carregados por nome montado e já estão de fora da lista |
| Ícones do H14 | `ind_acao`, `ind_bonus`, `ind_reacao`: 128x128, RGBA, existem. Nenhuma arte nova é necessária |

**Atenção ao estado do código antes do build.** A árvore de trabalho tem **7 arquivos alterados e não commitados**
(`dungeon_m1.py`, `walk_screen.py`, `world_art.py`, `world_view.py`, `process_art.py`, `test_process_art.py`, `test_walk_flow.py`), que
parecem ser o trabalho em andamento das texturas do mundo (SPEC-058). Na linha de base a suíte tem **1309 testes passando e 1 falhando**:
`tests/ui/test_walk_flow.py::test_a_full_turn_closes_without_a_jump` (mudou 83.425 px; o limite é 2%, 55.296 px). Não mexi em nada.
- **[decisão]** o que fazer com esse trabalho em andamento no build: **(a)** recomendado: terminar/ajustar o teste e incluí-lo;
  **(b)** deixá-lo de fora do build (guardar as alterações à parte e buildar só os ajustes do Higor); **(c)** esperar você decidir. Não vou
  descartar nem sobrescrever nada disso sem a sua palavra.

## 7. Build v0.9.2

> Este build também inclui as notas H17 a H20 do relatório do Daniel e do Hiago (`PLAN-008`, specs 062 a 065).

1. Você aprova as specs (059 a 061) e as decisões abaixo.
2. Implemento por spec, com os testes primeiro; a suíte inteira precisa passar (incluindo o teste da caminhada, conforme a decisão acima).
3. Rodo a auditoria de assets de novo (esperado: nenhum faltando).
4. `game/version.py` sobe para `0.9.2` (regra do arquivo: mudar a cada build enviada para playtest) e a data.
5. `python scripts/build_local.py` gera `dist/nottcard-ai-0.9.2.exe` (a partir de um pacote de assets novo em `build/assets_bundle`, sem `_raw/` e
   `concepts/`), como o CI, e conferimos o tamanho (hoje 62 MB) e que o executável abre.
6. Evidência (`EVID`) com testes, auditoria e a checagem visual de cada nota. **Sem commit e sem publicar** até você aprovar: o CI
   publica o `.exe` na release `latest` a cada push em `main`.

## 8. Decisões, para aprovar em bloco

| # | Decisão | Recomendação |
|---|---|---|
| D1 | Guia sempre visível: sobreposição com botão "Guia" no topo, sai do menu; atalho `F2` | **Aprovado** |
| D2 | Botões: gema no lugar do parêntese, dica ao passar o mouse, texto de reserva "(Ação Bônus)" | **Aprovado** |
| D3 | Suspense: foto congelada da Corrente e dos outros recursos, sincronizada por uma batida no momento da revelação | **Aprovado** |
| D4 | Mão Maior: 2 níveis (6 e 7 cartas), custo 600 e 1800, liberada por 1 conquista | **Aprovado** |
| D5 | Qual conquista libera a Mão Maior | **Resolvida pelo Higor em 2026-09-20: *Fechadura Aberta*** (concluir a primeira missão). Leitura registrada: a conquista **libera a compra** da Mão Maior na loja (como no H15). Se ele quis dizer que dá o +1 **automaticamente**, sem comprar, me avise: a `SPEC-061` vira um benefício de conquista (como o "+2 PV" da própria Fechadura) e a loja perde esse item |
| D6 | Trabalho em andamento das texturas do mundo no build | **Aprovado**: (a) incluir, ajustando o teste |
| D7 | Assets sem uso ficam no pacote | **Aprovado**: Manter |
| D8 | Versão do build | **Aprovado**: `0.9.2` |
| D9 | Faces dos dados (48 arquivos): entram no pacote, mas sem integração neste build (a spec de integração fica para depois) | **Aprovado**: Sim, sem integrar agora |


> **2026-09-20:** o responsável aprovou todas as decisões D1 a D9 (D5: a conquista *Fechadura Aberta* libera a compra da Mão Maior na loja). As specs 059 a 061 ainda precisam de aprovação própria.
