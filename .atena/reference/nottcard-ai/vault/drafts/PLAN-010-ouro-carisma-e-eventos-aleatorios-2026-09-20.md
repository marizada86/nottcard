---
id: "PLAN-010"
type: "plano"
title: "Ouro com bônus de Carisma, bolsa da missão e eventos aleatórios (baú, mímico, loja e outros)"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
  - "[[SPEC-045-loja-de-upgrades-e-regras-do-baralho]]"
  - "[[SPEC-036-mochila-e-itens]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
  - "[[MUNDO-001-tarn-cupula-de-nottgard]]"
sources:
  - "Responsável, 2026-09-20: tudo aprovado conforme a recomendação para as pendências do Daniel; novo pedido: modificador de Carisma no ouro e eventos aleatórios na exploração"
---

# Ouro com Carisma e eventos aleatórios

Rascunho: nada aqui é regra até cada spec ser aprovada (`execution_approval: per-spec`). Onde há **[decisão]**, a recomendação vem
primeiro. Commit, merge e publicação seguem exigindo aprovação explícita.

## 0. O que já está decidido e onde isto entra na fila

- **Pendências do Daniel (`PLAN-009`): tudo aprovado como recomendado** (D15 a D18). Ficam valendo a ordem e as specs 067 a 072
  (dica de atributo, faixa de turno, recompensa recusável, dados do crítico, XP na seleção, correções pequenas), o ajuste do "Ação
  usada" e do Ctrl+F12 na SPEC-063, o descarte explicado no tutorial (D15), o botão "Sugerir baralho" (D16) e o recusar sem troca (D17).
  A **SPEC-069** (recompensa da exploração recusável) é vizinha do que vem abaixo: as duas usam a mesma tela "aceitar ou recusar".
- **Este plano** abre uma segunda trilha, independente da primeira. A parte do Carisma é pequena e pode entrar logo; os eventos são
  o trabalho grande e entram depois das specs do Daniel (seção 8).

## 1. Como o ouro funciona hoje (para calibrar)

- **1 moeda por XP líquido** ao fim da tentativa (`settle_run` e `App.finish_run`): vitória e desistência valem 100%, derrota a metade.
  Uma missão completa rende cerca de **100 a 120 moedas** (combates de 10 a 25 XP, o evento da Tarn, o slime opcional e 20 da conclusão).
- **Ganância** (upgrade da loja) soma **+10% por nível** (3 níveis), arredondando para cima (`upgrades.coins_with_greed`).
- Preços da loja: upgrades de 80 a 2700, a **Mão Maior** 600 e 1800. Ou seja, um upgrade médio leva de 3 a 15 missões.
- **Não existe ouro dentro da missão**: nada se ganha nem se gasta enquanto se explora. Isso muda com a bolsa da missão (seção 3).

## 2. Bônus de Carisma no ouro (SPEC-073, pequena e independente)

### 2.1 Regra pedida
Cada **+1 de modificador de Carisma dá +20% de ouro** ao fim da missão; o modificador continua sendo `(valor - 10) // 2`.

### 2.2 Recomendação

| Ponto | Recomendação | Motivo |
|---|---|---|
| **De quem é o Carisma** | O **maior modificador do grupo** vivo ou não, no fim da missão (o "negociador") | Com grupo de até 3 (SPEC-037) somar seria forte demais e usar só o líder ignora quem barganha; o melhor do grupo é simples e dá razão para escalar um Kayron ou um Brook |
| **Como soma com a Ganância** | **Aditivo**: `1 + 0,20 x mod de Carisma + 0,10 x nível de Ganância` | Multiplicar os dois estoura (3 níveis + Carisma +3 daria 2,08x); somar dá no máximo 1,9x |
| **Modificador negativo** | **Piso em 0** (não há penalidade) | Ninguém do elenco tem Carisma abaixo de 10, e uma penalidade só puniria uma escolha |
| **Teto** | **2,0x** no total (só uma trava de segurança) | Com os números atuais nunca é atingido |
| **Onde aparece** | Uma linha na tela de resultado: "Carisma +2 (Kayron): +40%", ao lado da linha da Ganância | O jogador vê de onde veio o ouro |
| **Arredondamento** | Para cima, como a Ganância | Igual ao que já existe |

### 2.3 O que isso vale com o elenco atual (Carisma base, e no nível 5 com o bônus de atributo)

| Personagem | Carisma | Mod | Bônus no nível 1 | No nível 5 |
|---|---:|---:|---:|---:|
| Durvall | 10 | 0 | +0% | +0% |
| Maelor | 12 | +1 | +20% | +20% |
| Sylas | 12 | +1 | +20% | +20% |
| Kayron | 14 → 16 | +2 → +3 | +40% | +60% |
| Brook | 14 → 16 | +2 → +3 | +40% | +60% |

Numa missão de 110 moedas, um grupo com o Kayron ou o Brook ganha **+44** (nível 1) a **+66** (nível 5), sem passar do teto. Isso ajuda
justamente quem tem Carisma como cor principal e defesa menor (o Kayron), sem tocar em combate. **[decisão D19]** o melhor do grupo;
alternativa: só o personagem que fechou a missão.

### 2.4 Implementação
Função pura `upgrades.gold_multiplier(upgrades, charisma_mod)` (ou módulo `economy.py`), lida por `App.finish_run` no lugar do
`coins_with_greed`; `RunResult` ganha as linhas de Carisma e de Ganância separadas. Testes: mod 0, +1, +2, +3, negativo, com e sem
Ganância, teto 2,0, arredondamento, derrota (metade do XP) e o melhor Carisma de um grupo de 3.

## 3. Bolsa da missão (o ouro dentro da missão), base dos eventos (SPEC-073, mesma spec)

Baú e loja precisam de ouro **dentro** da missão. Recomendação: uma **bolsa da missão** separada das moedas da cidade.

- Ouro achado (baú, mímico, eventos) vai para a **bolsa da missão**; a loja da exploração gasta **só a bolsa**. As moedas da cidade
  (as da loja de upgrades) não se gastam em missão, para não haver dois sistemas de preço se misturando.
- No fim da missão o que **sobrou na bolsa** vira moedas da cidade **com as mesmas regras do XP**: 100% na vitória ou na desistência,
  **50% na derrota** (arredondado para baixo), e depois recebe o bônus de Carisma e a Ganância. Assim gastar na loja é uma escolha
  real: cada moeda gasta é uma moeda a menos no fim.
- Aparece no HUD como "Bolsa: 35" com o ícone `assets/hud/moeda_icon.png` (**já existe e hoje não é usado**), na exploração e no combate.
- Não vai para o `save` no meio da missão (a missão inteira é em memória hoje); só o total convertido entra no save.
**[decisão D20]** bolsa separada, com o resto convertido no fim (recomendado); alternativa: usar direto as moedas da cidade.

## 4. Eventos aleatórios: a frequência

### 4.1 O pedido tem dois números que não fecham
"10% a 20% por sala" e "1 evento a cada 2 ou 3 missões" **se contradizem**: a missão tem **7 salas** (6 sem o chefe). Com 15% por sala,
o jogador veria em média **1 evento por missão** (6 x 15% = 0,9), umas 2,5 vezes mais do que o desejado. Para ficar em "1 a cada 2 ou
3 missões" a chance por sala teria de ser de **5% a 7%**. Recomendo definir a taxa **por missão**, não por sala, e escolher a sala depois.

### 4.2 Modelo recomendado: sorteio por missão com azar protegido e sorte
Um sorteio no início da missão (`start_run`), com três números que o Higor ajusta num arquivo de dados:

| Parâmetro | Valor inicial | Efeito |
|---|---:|---|
| Chance base | **25%** por missão | Sozinha daria 1 evento a cada 4 missões |
| Proteção contra azar | **+10 pontos por missão sem evento** (teto 75%) | Zera quando um evento aparece; garante que a seca acabe |
| Segundo evento (sorte) | **10%** de chance, quando já há um evento | O "às vezes vem mais" que você pediu |
| Salas elegíveis | 2 a 6 (não a 1 nem o chefe), só as ainda não limpas | O evento não some no prólogo nem na luta final |

Medi este modelo com uma simulação de 200 mil missões: **0,41 evento por missão (1 a cada 2,4 missões)**; 63% das missões sem evento,
34% com um, **4% com dois**; a maior seca simulada foi de 11 missões. Outras combinações que testei: chance 20% dá 1 a cada 2,7;
30% dá 1 a cada 2,2. Fica dentro de "2 ou 3" com folga para o playtest apertar.
O contador de proteção vai no save (`SaveState.event_pity`) e **só sobe quando uma missão termina** (vitória, derrota ou desistência),
para reiniciar uma missão à toa não fabricar eventos. **[decisão D21]** sorteio por missão com esses valores.

### 4.2b Sugestão extra: a Sorte também puxa
Cada nível do upgrade **Sorte** (que hoje só dá rerrolagens de teste) poderia somar **+2 pontos** na chance base. É opcional, dá mais
sentido a um upgrade e mexe pouco. Deixo como sugestão, fora do primeiro corte.

### 4.3 Onde o evento aparece e some
- **Caminhada (SPEC-057):** um marcador na célula livre da sala, como o cartaz das situações; chegar perto abre o evento.
- **Portas (modo clássico, SPEC-053):** uma opção a mais no corredor da sala ("Investigar o baú").
- Depois da interação o evento **some da sala** e fica registrado como resolvido (não volta na mesma missão); a caminhada e o mapa
  deixam de mostrar o marcador. O sorteio e o resultado entram no log de desenvolvimento ("Evento: baú, sala 5, chance 0,35, proteção 1").

## 5. Cartas e itens temporários

Boa notícia da arquitetura: o `Player` e a mochila **já nascem novos a cada tentativa** e o baralho da coleção não é tocado por eles.
Então "temporário" é o comportamento natural: uma carta ou item dado por evento entra **no `Player` da tentativa** e some sozinho
no fim da missão, sem tocar em coleção, baralho ou save. Nada de flag nova de persistência.
Travas de balanceamento recomendadas:
- Só cartas **comuns e incomuns** (nenhuma rara de chefe), e no máximo **2 cartas temporárias e 1 item temporário por missão**.
- Uma carta temporária entra no **baralho de compra** (embaralhada), não na mão; o item vai para a mochila (se cheia, segue o fluxo da
  SPEC-036).
- Marcar a carta na mão ("temporária") com um selo, como o de "USO ÚNICO", para o jogador saber que ela some.
- Pergaminhos (SPEC-039) continuam sendo o prêmio dos combates; os eventos não os duplicam.

## 6. O catálogo de eventos

### 6.1 Os três pedidos

| Evento | Como funciona | Risco e recompensa |
|---|---|---|
| **Baú** | Ao chegar, o jogador escolhe: **Abrir** (sem teste, mais rápido) ou **Examinar** (teste de Inteligência CD 12) antes de abrir. Dentro: ouro na bolsa da missão (**15 a 35**, sobe com a sala) e, em 40% dos baús, uma **carta ou item temporário** | Baú trancado em 25%: **Arrombar** (Inteligência) ou **Forçar** (Força); falhar = 1d4 de dano da armadilha, sem perder o baú |
| **Mímico** | Um **baú disfarçado**: em **25% dos "baús"** o que se abre é um inimigo. Combate contra um só inimigo (PV da sala x 1,3, CA e CAM médias, dá dano alto e uma mordida que **prende** o alvo: perde a próxima Ação se falhar um teste de Força) | Recompensa **maior que a do baú** (o dobro do ouro e sempre um item temporário) e XP. É o "risco de abrir sem examinar" |
| **Loja da exploração** | Um mercador com **3 cartas temporárias e 1 item temporário**, todos pagos com a **bolsa da missão** (cartas 20 a 35, itens 25 a 45, poção 15); "Trocar a oferta" custa 10 | O ouro gasto aqui não vira moeda da cidade no fim: é a escolha da seção 3 |

Contramedidas do mímico (para não ser só azar): o teste de **Examinar** o revela; a carta **Localizar Criatura** (Maelor) o entrega
sem teste; passar o mouse no baú mostra "Baú (?)". Assim o jogador cuidadoso é premiado e o apressado assume o risco, exatamente como
pediu. **[decisão D22]** o mímico tem 25% de chance quando o evento sorteado é "baú".

### 6.2 Sugestões de outros eventos (com o mundo de Nottgard e o grupo)
Todos os textos ficam "spoiler-safe": nenhuma revelação de mestre no texto de tela, só clima (regra do projeto). Os nomes vêm do vault.

| Evento | Ideia | Ligação com o grupo e o mundo | Prioridade |
|---|---|---|---|
| **Altar de Sendrinah ou de Lliira** | Um santuário: oferecer ouro por **cura** ou por uma **bênção** (+1 no acerto no próximo combate) | O **Maelor** (clérigo da luz) ganha a bênção mais forte; o **Brook** (paladino de Lliira) pode limpar a **Desonra** ali | Alta |
| **Viajante ferido** | Um sobrevivente da Vila das Sombras pede ajuda: **ajudar** (Carisma) dá um item ou uma pista sobre a sala seguinte; **ignorar** não custa nada; **assaltar** dá ouro mas o Brook entra em Desonra | Reforça o Carisma que agora vale ouro; é o evento mais "de personagem" | Alta |
| **Fenda de névoa** | Um vazamento pequeno de névoa esverdeada: **atravessar** (teste de Constituição) dá XP, falhar tira PV | **Durvall no nível 5** (imune à névoa) passa sem teste, usando o gancho `mist_immune` que já existe; combina com a Tarn | Média |
| **Pergaminho abissal** | Um caderno com o alfabeto abissal das câmaras rituais: **ler** (Inteligência) dá uma carta temporária forte, falhar dá uma **maldição leve** (a próxima carta custa a Ação Bônus) | Sylas e Kayron (Inteligência e Carisma) leem melhor; puxa o tema do ritual | Média |
| **Apostador de dados** | Um jogador de rua desafia: aposta de ouro da bolsa num **d20 contra o dele**; a **Sorte** (que já existe) pode rerrolar | Combina com a identidade "dados" do jogo e dá uso à Sorte | Média |
| **Oficina abandonada** | Gastar ouro da bolsa para **afiar** uma arma ou **reforçar** a armadura **até o fim da missão** (+1 no dano ou +1 na CA) | Usa o equipamento da SPEC-047; o Kayron, com pouca defesa, aproveita | Média |
| **Emboscada na névoa** | Um combate extra contra 1 a 2 inimigos da sala, com recompensa de ouro e XP | Um "evento ruim" para não ser só presente; vale a XP | Baixa |
| **Cofre da taverna** | Uma chave achada antes abre este baú (a "pista" do sistema de itens é uma chave): recompensa maior | Dá uso ao item tipo **pista** da mochila, hoje sem função | Baixa |

**Recomendação de escopo:** o primeiro corte entrega o **motor de eventos** e os **três pedidos** (baú, mímico, loja). Os de história
(Altar, Viajante, Fenda) vêm num segundo corte, porque são os que mais dão "cara" ao jogo e precisam de textos aprovados. O resto
(apostador, oficina, emboscada, cofre) fica como banco de ideias.
Para não ter só recompensas: **50% dos eventos dão algo, 30% são risco e recompensa (mímico, fenda, pergaminho), 20% são escolhas de
personagem (altar, viajante)**; o sorteio pesa por esses grupos e por sala (mímico só depois da sala 3, para não punir o começo).

## 7. Arquitetura (resumo)

| Peça | Onde | Observação |
|---|---|---|
| Definições dos eventos | `game/core/events.py` (dado declarativo: id, peso, salas, texto, opções, recompensas) | Conteúdo como dado, como manda a arquitetura (`VSN-001`) |
| Sorteio e proteção contra azar | `game/core/event_plan.py`, RNG injetável | Puro e testável; a semente vai para o log de desenvolvimento |
| Estado na missão | `WorldState`: `events` por sala e `resolved` | Some depois da interação; não vai para o save no meio da missão |
| Bolsa da missão | `RunLedger` ou `Player` (`mission_gold`) | Vira moeda da cidade em `finish_run` |
| Interface | `game/ui/event_screen.py` (uma tela de opções, como a das situações) + marcador na caminhada + opção no corredor de portas | Reaproveita `SituacaoScreen` e a tela "aceitar ou recusar" da SPEC-069 |
| Mímico | um `Enemy` novo em `enemies.py` | Reaproveita todo o combate; só a fábrica é nova |
| Ferramentas de teste | atalho de desenvolvimento **Ctrl+O+E** força um evento na sala atual; `scripts/simulate_events.py` mede a frequência | Sem o atalho, o playtester levaria dezenas de missões para ver um evento |

## 8. Specs e ordem

| Ordem | Spec (nova) | O que entra | Porte |
|---|---|---|---|
| 1 | SPEC-067 a 072 | As pendências do Daniel, já aprovadas | (PLAN-009) |
| 2 | **SPEC-073** Ouro: Carisma e bolsa da missão | Bônus de Carisma, Ganância aditiva, bolsa da missão no HUD e no resultado | P |
| 3 | **SPEC-074** Motor de eventos | Sorteio por missão, proteção contra azar, colocação, "some depois", log e atalho de teste | M |
| 4 | **SPEC-075** Baú e mímico | Os dois eventos, o inimigo novo, o exame, a arte | M |
| 5 | **SPEC-076** Loja da exploração e cartas/itens temporários | O mercador, a compra com a bolsa, o selo de temporário e as travas | M |
| 6 | **SPEC-077** Eventos de história | Altar, viajante e fenda de névoa | M |
Motivo da ordem: a SPEC-073 é pequena, independente e já melhora o ouro; o motor (074) precisa existir antes de qualquer evento; o baú
e o mímico (075) são o primeiro conteúdo; a loja (076) depende da bolsa e das cartas temporárias.

## 9. Arte necessária (só para o Higor saber; os prompts vêm depois de aprovar)
Baú fechado e aberto (adereço da caminhada e cena), **mímico** (dois estados: baú e boca aberta), mercador (retrato) e ícone da bolsa
(**o `moeda_icon` já existe**). Os eventos de história pedem um altar e um viajante. Sem a arte, o jogo desenha o retângulo com o nome
(regra do projeto), então nada bloqueia a lógica.

## 10. Riscos e como medir
- **Inflação de ouro:** baú e Carisma somados podem encurtar demais o caminho até a Mão Maior (600 moedas = 5 missões). Medir com o
  simulador de economia (missões até o primeiro upgrade, antes e depois) e ajustar os valores do baú, que são dados.
- **Cartas temporárias fortes demais:** por isso só comuns e incomuns, no máximo 2 por missão.
- **O mímico injusto:** o exame e a Localizar Criatura tiram o azar; a chance de 25% e a dificuldade são números de dados.
- **Eventos que quebram o ritmo da caminhada:** o marcador só abre o evento perto da célula, como as situações; nada é obrigatório.
- **Texto com spoiler:** todo texto novo passa pela revisão do responsável antes de ir para a tela.

## 11. Decisões, para aprovar em bloco

| # | Decisão | Recomendação |
|---|---|---|
| D19 | Carisma que conta | O maior modificador do grupo |
| D20 | Ouro dentro da missão | Bolsa separada; o que sobra vira moeda no fim (100% ou 50% na derrota) |
| D21 | Frequência | Por missão: 25% + 10 por missão sem evento (teto 75%) + 10% de segundo evento |
| D22 | Mímico | 25% dos baús, com exame e Localizar Criatura como contramedidas |
| D23 | Ganância e Carisma | Aditivos, teto 2,0x, sem penalidade abaixo de 0 |
| D24 | Temporários | Só comuns e incomuns; máx. 2 cartas e 1 item por missão; entram no `Player`, nunca na coleção |
| D25 | Escopo do 1º corte | Motor, baú, mímico e loja; eventos de história depois |
| D26 | Sorte puxa evento | Opcional, fora do 1º corte |
