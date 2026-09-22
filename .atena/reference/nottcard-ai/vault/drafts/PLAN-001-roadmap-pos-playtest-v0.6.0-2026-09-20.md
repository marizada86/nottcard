---
id: "PLAN-001"
type: "plano"
title: "Roadmap pós-playtest v0.6.0: ajustes do Higor, Brook, Tasks e primeira pessoa"
status: "draft"
created: "2026-09-20"
relations:
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[SPEC-042-brook-franca-paladino-juramento-de-lliira]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-041-colecao-de-cartas-baralho-aleatorio-chefes-e-pacotes]]"
  - "[[SPEC-036-mochila-e-itens]]"
sources:
  - "Responsável, 2026-09-20: notas do Higor têm prioridade; criar Brook; sistema de Tasks para playtesters (Discord do Marizverso); referências de primeira pessoa com a câmera acompanhando o mouse"
---

# Roadmap pós-playtest v0.6.0

> Escrito para: Guilherme (responsável) e Higor (game designer). Rascunho: nada aqui é regra até a aprovação de
> cada spec (`execution_approval: per-spec`). Cada item marca **[decisão]** onde preciso de uma resposta; a
> recomendação vem primeiro, para aprovar em bloco.

## 1. Ordem de execução

Regra do responsável: **o que o Higor pediu para mudar vem primeiro**. Depois vêm as frentes novas.

| Fase | Spec (nova) | O que entra | Porte |
|---|---|---|---|
| **F0** | `SPEC-044` Ajustes do playtest v0.6.0 | H1 linha do "?", H2 fórmula do atributo, H9 psiônico fixo, H3 pilhas clicáveis, H10 balanço do Sylas, ferramenta de simulação | P/M |
| **F1** | `SPEC-045` Loja de upgrades + regras do baralho | H4 (sai o pacote, entram os upgrades) e H5 (núcleo obrigatório) | M |
| **F2** | `SPEC-046` Falha crítica e Sorte | H6 e H7 | P/M |
| **F3** | `SPEC-047` Equipamento | H8 (3 armaduras, 3 armas, menu de equipar, desbloqueio por conquista) | G |
| **F4** | `SPEC-048` Tasks e evidências | Tasks, Discord, exportar evidência pelo jogo | M |
| **F5** | `SPEC-049` Primeira pessoa | Câmera com o mouse, cena em camadas, layout novo do combate e das portas | G |
| **F6** | `SPEC-042` Brook | Personagem novo (já tem os prompts de arte) | M |

Motivo da ordem: a F0 é pequena e corrige o que o Higor viu (o dano do Durvall e do Sylas contamina qualquer
outro teste). A **F4 pode andar em paralelo** com a F1 a F3: é quase toda script, documento e um atalho no jogo, e
destrava o próximo playtest (2 e 3 personagens, H12) com tasks em vez de textão. A F5 mexe na cara do jogo inteiro,
então vem depois de a loja, o baralho e os equipamentos terem telas definitivas. O Brook vai por último porque
reaproveita tudo (Guarda, Desonra, equipamento, tasks).

Publicar (push) e commitar seguem exigindo a sua aprovação por fase.

## 2. Notas do Higor (prioridade)

O que o código faz hoje foi conferido em `game/`, não de memória.

### H1. A linha sob o "?" cobre CA e CAM (bug) → F0
- **Hoje:** `draw_player_panel` (`game/ui/hud.py`) desenha a dica "?" e a linha de sublinhado em cima do texto
  "CA x · CAM y", que fica só 12 px abaixo do nome.
- **Proposta:** descer "CA · CAM" e "Nível" para abaixo da dica e desenhar o "?" ao lado do nome, sem sublinhado.
  Só desenho; sem spec própria, entra na `SPEC-044`. Teste: renderizar o painel e checar que os retângulos do
  nome, da dica e da defesa não se cruzam.

### H2. Fórmula de dano: o atributo entra como percentual → F0
- **Hoje** (`combat._attack_outcome`): `ceil(dado × Corrente × compat × (1 + 0,2 × modificador)) + dado psiônico`.
  Não há soma flat do modificador no dano; o "+60%" (Força +3) **é** a contribuição do atributo, e o `ceil` arredonda
  9,6 para 10. O exemplo do Higor (6 x 1 = 6, +3 de Força = 9, +1d4 = 10) só bate se o atributo for **flat**.
- **Proposta (recomendo):** `dano = ceil(dado × Corrente × compat) + modificador do atributo da cor` (flat, **não**
  multiplicado pela Corrente, nunca abaixo de 0), depois o dado psiônico do Durvall. O `+modificador` também vale
  para o controle (Névoa Fria etc.), para não sobrar dois modelos. A cura já usa modificador flat.
- **[decisão]** O modificador flat entra uma vez por carta (recomendo) ou uma vez por dado da carta? E vale nas
  cartas fora da cor (compat 0,5), ou só o dado é reduzido? Recomendo: o flat entra **inteiro** mesmo fora da cor
  (a penalidade da cor incompatível já corta o dado).
- **Efeito nos números:** o percentual escalava com a Corrente e o flat não. Para um `Golpe` (1d8, média 4,5) com
  Força +3: Corrente x1 dá ~7,2 hoje e 7,5 depois; Corrente x4 dá ~28,8 hoje e 21 depois. Ou seja, o corte
  cai no topo da Corrente, que é onde o Higor sentiu o problema.
- O log dev (F12) passa a mostrar a conta nova: `dado × Corrente × cor + atributo`.
- **Canon:** muda `SIS-001` (que diz "+20% por ponto"). Registrar a mudança na spec e no canon local, com a
  data e o nome do Higor.

### H9. Durvall: a Corrente não multiplica o 1d4 psiônico → F0
- **Hoje:** `PSIONIC_DICE_BY_MULT = {1: 1d4, 2: 2d4, 3: 3d4, 4: 4d4}`: o dado psiônico cresce com a Corrente.
- **Proposta (do Higor):** o psiônico fica **1d4 fixo**; só o dado da carta é multiplicado. Vale nos 4 níveis.
- Com H2 + H9 juntos, um Golpe a x4 cai de ~39 (28,8 + 4d4) para ~23,5 (18 + 3 + 1d4). **Antes de qualquer outro
  nerf**, medir de novo (a simulação da `SPEC-044`).
- **[decisão]** Manter o texto da passiva "1x = 1d4 | 2x = 2d4..." como está no cartão? Recomendo trocar por
  "+1d4 psiônico em ataques da Corrente".

### H3. Pilhas de compra e descarte clicáveis → F0
- **Hoje:** `draw_pile_counter` só desenha o ícone e o número.
- **Proposta:** clicar no baralho abre um painel com **as cartas que ainda podem ser compradas** (agrupadas por
  nome, com a quantidade, em ordem alfabética: nunca a ordem de compra) e clicar nos descartes abre o das descartadas.
  Também mostra as cartas de uso único gastas e as HC usadas (em seções separadas). Mesma sobreposição do catálogo
  (pausa o combate, `Esc` fecha). Serve depois de encaixe na primeira pessoa: os livros dos cantos das referências
  **são** exatamente isso.

### H10. Sylas muito forte (combo infinito, cópia imortal) → F0
Causas que achei no código (`characters.SYLAS`, `state.Player`):
1. `chain_elements=("sombra",)` + cor Amarelo: **quase todas** as cartas dele contam na Corrente (Raio, Lâmina, Toque,
   Farpa por cor; Escuridão, Cegueira, Imagem, Passo pelo elemento). Só a Poção quebra. A Corrente praticamente não
   quebra e ele vive em x4.
2. Cada carta que avança a Corrente a partir de x2 cura a Cópia em +2, +3 ou +4 PV (`_on_chain_advance`), então uma
   Cópia com 10 PV se recupera sozinha, mais a Imagem Espelhada (recria) e a Sombra Persistente (nível 5).
- **Proposta (recomendo, na ordem):**
  a. A tag `sombra` só nas cartas de **dano** (Raio, Lâmina, Toque). Controle, cura e reação não mantêm a Corrente
     (elas ainda valem pelos efeitos). Mantém a alegria de "encadear sombra" sem o combo infinito.
  b. A cura da Cópia pela Corrente vale **uma vez por turno** (a maior), e só em x3 e x4. A Cópia continua sendo
     recuperável, mas não imortal.
  c. Se ainda passar do ponto na simulação: teto de x3 para o Sylas.
- **[decisão]** Higor prefere reduzir a Corrente (a) ou o teto de cura da Cópia (b) primeiro? Recomendo (a)+(b) e
  medir; (c) só se precisar.

### H11. Kayron → sem mudança
Nenhuma. Entra como task de reteste (grupo de slimes e chefe) na F4.

### Ferramenta de simulação (nova, parte da F0)
Para balancear com número e não por palpite: `scripts/simulate.py` joga N combates por personagem (política simples:
melhor carta que mantém a Corrente) contra os inimigos do M1 e imprime dano por turno, turnos para vencer, PV
perdidos e (Sylas) tempo com a Cópia viva. Roda em segundos, sem janela. Serve antes e depois de cada ajuste da
F0 e vira critério de aceite ("Sylas vence o chefe em X a Y turnos").

### H4. Loja de upgrades, sem pacote → F1
- **Hoje:** `game/core/shop.py` vende layouts, o pacote (escolha 1 de 3) e o 2º baralho.
- **Proposta:** o **pacote sai** (com `PackSource`, o item da loja, o texto e os testes). A loja passa a vender
  **upgrades permanentes por nível**, com custo crescente (estilo Vampire Survivors): compra, sobe o nível, o
  preço do próximo sobe. Os upgrades valem para o jogador (não por personagem) e "Novo jogo" os zera.
- Catálogo inicial (números para o Higor ajustar):

| Upgrade | Efeito por nível | Níveis | Custo (moedas) |
|---|---|---|---|
| Força Bruta | +4% no dano base dos dados de ataque | 5 | 100, 200, 400, 800, 1600 |
| Vitalidade | +2 PV máximo | 5 | 80, 160, 320, 640, 1280 |
| Mão Cheia | +1 carta na mão inicial | 2 | 500, 1500 |
| Rerrolagem | +1 rerrolagem de recompensa por missão | 3 | 150, 450, 1350 |
| Sorte | +1 uso de Sorte por missão (H7) | 3 | 300, 900, 2700 |
| Bolso Fundo | +1 slot na mochila | 1 | 600 |
| Ganância | +10% de moedas por tentativa | 3 | 200, 600, 1800 |

  A "rerrolagem" é um botão na tela "Escolha 1 de 3" (chefe e pergaminho) que sorteia a oferta de novo.
- **Trava contra quebrar o jogo (o pedido do Higor):** cada upgrade tem teto; "% de dano base" fica em no máximo
  +20% no total; nada de upgrade cura ou multiplica a Corrente.
- **Layouts de carta** continuam à venda (só cosmético). O **2º baralho** sai da loja (ver H5).
- **[decisão]** Upgrade global (recomendo) ou por personagem? Global é mais simples e evita re-comprar 4 vezes.
  Os números da tabela são um ponto de partida; Higor calibra com o simulador e o playtest.

### H5. Menos liberdade no baralho → F1
- **Hoje:** o baralho é livre até 20 cartas (`DECK_CAP`), com o sorteio inicial de 12 só dando o começo.
- **Proposta (recomendo A + B):**
  - **A. Núcleo obrigatório:** as 12 cartas do sorteio inicial ficam **travadas** (não saem do baralho); o jogador
    só edita as vagas até o teto de 20. Sem isso ele tira tudo e joga só as 6 melhores.
  - **B. Regras de validade:** o baralho só é aceito para iniciar a tentativa se tiver pelo menos 2 cartas de cada
    cor, 1 de cura e 2 de ataque (as mesmas garantias do sorteio), e no máximo 3 cópias de cada carta (1 para as
    raras). A tela "Baralho" mostra o que falta ("faltam 1 cura").
  - O **2º baralho** (SPEC-035/041) sai: com o núcleo travado ele perde o sentido. Quem já comprou recebe as moedas
    de volta na migração do save.
- **[decisão]** Higor quer que o núcleo seja o sorteio inicial (recomendo) ou uma lista fixa escolhida por ele
  (por exemplo, sempre 2 Golpes e 1 cura)? A fixa é mais previsível para balancear; o sorteio dá variedade por jogo.

### H6. Falha crítica pesa mais nos eventos → F2
- **Hoje:** 1 natural só falha (`resolve_check`); o custo é o mesmo de qualquer falha (0 a 3 PV, ou descartar uma carta).
- **Proposta:** cada opção de evento ganha um desfecho de **falha crítica** (`Option.critical`), mais duro que a
  falha comum. Padrão (para ajuste por sala do Higor): perde o **dobro do PV** (mínimo 3), **descarta uma carta**
  aleatória do baralho da tentativa e **perde um item da mochila** (se tiver). Nunca leva o jogador abaixo de 1 PV
  fora do combate. A tela mostra "FALHA CRÍTICA" com o custo, em vermelho.
- **[decisão]** Os custos do padrão acima estão bons, ou Higor prefere um específico por sala (Docas, Rachadura,
  Porão)? Recomendo começar com o padrão e ajustar depois do playtest.

### H7. Sorte (rerrolar um d20 ruim) → F2
- **Proposta:** recurso de missão `Sorte`: **1 por missão**, +1 no nível 3 e +1 no 5 (acumulável com o upgrade da
  loja). Depois de um d20 de exploração **malsucedido** (inclusive falha crítica), o jogador pode gastar 1 Sorte
  para **rolar de novo e ficar com o segundo resultado**. Não rerrola sucesso. Não vale no combate (v1).
- **Fluxo:** o resultado mostra o botão "Usar Sorte (1)"; o contador fica no canto da tela de exploração.
- **Futuro (o que o Higor citou):** cartas e habilidades que dão Sorte extra ficam para depois; o contador já
  aceita `+N`.
- **[decisão]** Sorte por personagem (recomendo: quem testa gasta a dele) ou do grupo?

### H8. Equipamento (armas e armaduras) → F3
- **Modelo:** `EquipmentDef(id, nome, slot, preco, ca, cam, furtividade, carta, titulo_requerido)`. Cada personagem
  tem **1 arma + 1 armadura** equipadas, que valem entre tentativas. O **acessório da mochila** (SPEC-036) continua
  como item de tentativa. A "Arma de assinatura" do Durvall vira a arma inicial dele.
- **Regra de design:** armadura pesada = CA alta, CAM baixa e desvantagem em furtividade; a leve é o contrário.
  Furtividade é uma etiqueta de opção de evento (por exemplo, "Contornar o slime"); com desvantagem o d20 rola duas
  vezes e vale o menor.
- **3 armaduras básicas** (deltas sobre a CA/CAM do personagem; o Higor calibra):

| Armadura | CA | CAM | Furtividade | Preço |
|---|---|---|---|---|
| Couro | +1 | 0 | normal | 100 |
| Cota de malha | +3 | −1 | −2 no teste | 300 |
| Placa completa (full plate) | +5 | −3 | desvantagem | 600 |

- **3 armas básicas**, **cada uma com a própria carta** (recomendo em vez de alterar as vermelhas: não mexe no
  equilíbrio das cartas existentes e é fácil de ler). A carta da arma é de assinatura (fora do teto do baralho,
  1 cópia):

| Arma | Carta | Efeito | Preço |
|---|---|---|---|
| Adaga | Golpe Rápido | Vermelho, **Ação Bônus**, 1d4 | 100 |
| Espada longa | Golpe Versátil | Vermelho, Ação, 1d6 (1d10 com a Corrente em x2 ou mais) | 300 |
| Maça de guerra | Golpe Esmagador | Vermelho, Ação, 1d8, testa atordoar como o Golpe Contundente | 300 |

- **Melhores equipamentos:** cada conquista libera (título, como no `SPEC-035`) um equipamento avançado na loja.
  Conteúdo avançado é uma spec de conteúdo à parte.
- **Menu "Equipamento":** na seleção de personagem (botão por cartão) e no menu principal. Lista arma, armadura,
  o que o jogador tem e o efeito na CA/CAM.
- **[decisão]** Armas com carta própria (recomendo) ou alterando as vermelhas? E os preços e números acima.

### H12. Próximo playtest com 2 e depois 3 personagens → F4
Vira duas tasks (seção 4) com roteiro curto: formação, alvo pela menor CA, queda de personagem, exploração com quem
testa, pergaminho por personagem.

## 3. As frentes novas

### 3.1 Brook França (`SPEC-042`) → F6
- **Arte:** a auditoria de assets já está pronta em `.atena/generated/ART-PROMPTS-012-brook-franca-e-auditoria-2026-09-19.md`.
  Conferi de forma independente: **não falta nenhuma imagem do jogo atual**; para o Brook faltam **13 imagens**
  (retrato, emblema da passiva, ícone de Guarda e 10 cartas) e o prompt de cada uma está no 012.
- **Decidido (2026-09-20): o retrato segue o concept, o anão mais velho.** Havia a divergência: a ficha diz "jovem guerreiro de Fateridge", mas o concept
  (`brook_franca_fullbody_v2.png`) é um **anão idoso**. O 012 seguiu o concept. Higor, qual vale?
- **Spec:** a `SPEC-042` está em rascunho. Pendências dela (Desonra, teto da Guarda 6, nível 5) continuam com as
  recomendações do próprio rascunho. Depois do H2, a fórmula e os números do Brook usam o modificador flat.
- **Depende da F3** (equipamento) só para o teste; o desenvolvimento pode começar antes.

### 3.2 Tasks e evidências → F4

**O problema hoje (o que vi):**
- As evidências (`EVID-002..004`) têm de 125 a 222 linhas, com tabelas de dezenas de linhas. O playtester não sabe o
  que é "a evidência" nem como produzi-la; cada um escreve do seu jeito (as notas do Higor misturam bug, regra
  nova, balanço e opinião no mesmo texto).
- Todas ainda estão `pendente`; nada mostra quem testou o quê, em qual build, nem o que ficou sem teste.
- Não há como o jogo ajudar: o log F12 existe, mas o tester copia à mão.

**Proposta:**
1. **Uma task = uma coisa pequena para testar.** Arquivo `.atena/tasks/TASK-NNN-slug.md`, com 4 blocos fixos e
   curtos:
   - **O que testar** (1 a 2 linhas) e a spec/build mínimo;
   - **Como fazer** (no máximo 7 passos numerados);
   - **Evidência** — *o que é* ("print do resultado do teste com o d20 e o custo") e *como gerar* ("aperte F10 logo
     depois; anexe o `.zip`");
   - **Perguntas** (no máximo 3, de sim/não ou nota de 1 a 5).
2. **Uma resposta = um registro curto**: `resultado` (passou / estranho / falhou), build, personagem e nível, a
   evidência anexa e 1 a 2 linhas de nota. Guardado em `.atena/tasks/resultados/TASK-NNN/<tester>-<data>.md`.
3. **Painel gerado** (`.atena/generated/tasks-status.md` e o post do Discord): cada task com **não testada / N
   testes / quem testou / último resultado / evidências**.
4. **Triagem separada:** o que o tester escreve fora do roteiro (ideias, mudanças) vira `FB-NNN` (como este FB-002),
   com ids `H1..`, e **não** entra como evidência. Assim "evidência" fica só com fatos.
5. **Fechar o legado:** `EVID-001..004` viram históricos; as verificações abertas que ainda valem viram tasks.
6. **Exportar evidência pelo jogo (F10):** salva numa pasta `evidencias/` um `.zip` com print da tela, as últimas
   200 linhas do log dev, versão, personagem, nível, grupo e resumo do save. O tester só anexa o arquivo. É isso que
   resolve o "como fazer a evidência".

**Discord do Marizverso:**
- **Canais:** `#anuncios`, `#downloads` (executáveis por jogo e por versão), `#demos` (para jogadores), e um fórum
  `#playtest-tasks` do Nottcard AI (uma thread por task, com a etiqueta *não testada / em teste / validada / falhou*).
- **Sem hospedagem no começo:** `scripts/tasks_discord.py` publica e atualiza as threads (webhook + token de bot,
  guardados fora do git) e faz `sync` lendo as respostas do fórum; depois você roda o script quando quiser. Um bot
  sempre ligado (`/tasks`, `/evidencia`) fica como fase 2, quando houver onde hospedar.
- **Executáveis:** o CI já publica o `.exe`; um passo novo posta o link da build no `#downloads` (webhook).
- **[decisão]** Tokens e webhooks são seus (nunca ficam no repositório). Você cria o servidor e me passa a estrutura
  de canais que quiser; eu deixo o script lendo de um arquivo local ignorado pelo git.

### 3.3 Primeira pessoa (`SPEC-049`) → F5

**O que as referências mostram (Shroom and Gloom):**
- **Cena em primeira pessoa**: corredor com portas e correntes; ao escolher, a câmera avança pela porta.
- **Combate de frente**: os inimigos em fileira, no fundo do corredor, cada um com a **barra de PV e os status**
  logo abaixo e a **intenção do ataque** (espada + valor) logo acima; a mão em **leque** na borda inferior; os
  dois "livros" nos cantos (baralho e descarte, com a contagem) e os orbes (energia e PV).
- **Tela de recompensa** ("A gift from below"): três cartas emolduradas sobre um fundo verde, uma em destaque.
- **A câmera acompanha o mouse**: o cenário se desloca com um pequeno paralaxe.

**Como encaixar (2D em pygame, sem 3D de verdade):**
1. **Câmera com o mouse (protótipo, sem arte nova):** o cenário é desenhado ~8% maior e se desloca até ±4% da
   tela seguindo o mouse, com suavização; os inimigos ficam em camadas com deslocamento diferente (profundidade).
   Vale para o combate e a exploração. Opção "reduzir movimento" nas configurações, e o deslocamento nunca passa
   de um limite (a mão e o HUD ficam parados). Os cliques nos inimigos usam o retângulo já deslocado.
2. **Layout de combate da referência:** intenção do inimigo acima dele, PV e status abaixo (hoje é só a barra), a
   mão em leque, os **livros nos cantos como as pilhas clicáveis do H3**, o orbe de PV e os indicadores de
   Ação/Bônus/Reação onde a referência põe energia e PV. O grupo (SPEC-037) vira orbes pequenos empilhados.
3. **Exploração por portas:** o mapa de nós (`WorldMap`, que não muda) passa a ser apresentado como um corredor com
   as portas dos vizinhos; escolher uma porta faz a câmera "entrar" (zoom + fade). Situações (d20) e a Sorte
   aparecem sobre a cena; as salas trancadas e o cadeado da referência podem representar as salas ainda não
   liberadas.
4. **Recompensas:** a tela "Escolha 1 de 3" ganha o fundo e a moldura da referência (só apresentação).
- **Arte nova necessária (fica para prompts quando a spec for aprovada):** corredores e portas em camadas (fundo,
  meio, primeiro plano) para as 7 salas; molduras de carta de recompensa; livros e orbes. Os cenários de hoje
  (1280×720) já servem de fundo do protótipo do passo 1.
- **[decisão] (Higor e Guilherme):** a **intenção do inimigo** passa a ficar **sempre visível** (como na referência)?
  Hoje ela só aparece com Localizar Criatura e Visão Verdadeira; mostrar sempre muda o valor dessas cartas.
  Recomendo mostrar só o **tipo** (ataque físico ou mágico) sempre, e o **valor** só com as cartas.
- **Risco:** é a fase de mais arte e de mais retrabalho de interface; por isso vem depois de a loja, o baralho e o
  equipamento terem telas estáveis. O passo 1 (câmera) pode sair antes, sem esperar a arte.

## 4. Tasks já previstas (primeiro lote, para o Discord)

| Task | Testa | Quem |
|---|---|---|
| T-001 | H1: o nome, o "?" e "CA · CAM" ficam legíveis em todos os personagens | qualquer um |
| T-002 | H2/H9: o dano de um Golpe em Corrente x1 a x4 bate com a conta do log (Durvall) | Higor |
| T-003 | H10: Sylas contra o grupo de slimes e o chefe (turnos, PV, Cópia viva) | Higor e mais 1 |
| T-004 | H11: Kayron contra o grupo de slimes e o chefe | qualquer um |
| T-005 | H3: pilhas clicáveis, só a lista (sem ordem) | qualquer um |
| T-006 | H12: grupo de 2 personagens (formação, alvo, queda, exploração) | Higor |
| T-007 | H12: grupo de 3 personagens | Higor |
| T-008 | H4: loja de upgrades (compra, nível, preço, teto) | qualquer um |
| T-009 | H5: baralho com núcleo travado e regras de validade | qualquer um |
| T-010 | H6/H7: falha crítica e uso da Sorte em cada sala | qualquer um |

## 5. O que preciso de decisão (respostas rápidas)

1. **H2:** o flat do modificador entra uma vez por carta e inteiro mesmo fora da cor. (recomendo sim)
2. **H10:** aplicar (a) tag `sombra` só no dano e (b) cura da Cópia uma vez por turno, medir e só então (c). (recomendo sim)
3. **H4:** upgrades globais, tabela inicial como acima, e o 2º baralho sai. (recomendo sim)
4. **H5:** núcleo = as 12 cartas do sorteio, mais as regras de validade. (recomendo sim)
5. **H6/H7:** padrão de falha crítica igual para todas as salas; Sorte por personagem, 1 por missão (+1 no nível 3 e no 5). (recomendo sim)
6. **H8:** armas com carta própria; números da tabela como ponto de partida. (recomendo sim)
7. **Brook:** ~~a ficha (jovem) ou o concept (idoso)?~~ **Decidido em 2026-09-20 (Guilherme): vale o concept, anão mais velho, por enquanto.** O `ART-PROMPTS-012` já segue o concept; a ficha `PERS-brook-franca` fica com a divergência anotada, sem ser editada.
8. **Primeira pessoa:** mostrar sempre só o tipo do ataque do inimigo; o valor só com as cartas. (recomendo sim)
9. **Arte não commitada:** 37 arquivos em `assets/` (raras, pergaminhos, telas, ícones) e `scripts/process_art.py`
   estão fora do git, então o `.exe` do CI **não leva essa arte** (só a build local leva). Autoriza commitar?
10. **Discord:** você cria o servidor e me passa os nomes dos canais; tokens ficam só com você.

## 6. Riscos e cuidados

- **H2 e H9 mudam o equilíbrio de todos os personagens ao mesmo tempo.** Por isso a simulação vem primeiro e o
  playtest do Higor (T-002 a T-004) fecha.
- **Migração de save:** tirar o pacote e o 2º baralho e travar o núcleo mexe no `SaveState`. O plano é uma migração
  que devolve as moedas dos itens removidos e preserva coleção, títulos e layouts comprados.
- **Escopo:** F3 e F5 são grandes. Cada uma vai com a própria spec, e nenhuma começa sem aprovação.
- **Dependência de terceiros:** o Discord é externo; o jogo e o repositório continuam funcionando sem ele (as tasks
  são arquivos; o Discord é só a vitrine).
