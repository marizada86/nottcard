---
id: "SPEC-041"
type: "spec"
title: "Coleção de cartas: baralho inicial aleatório, cartas de chefe e pacotes de figurinhas"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-033-save-em-disco]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-039-pergaminhos-cartas-temporarias]]"
  - "[[SPEC-043-cartas-raras-de-chefe]]"
sources:
  - "Responsável, 2026-09-19 (atualização): um baralho para todos os personagens, com um 2º desbloqueável; demais pendências aprovadas"
  - "Responsável, 2026-09-19: ao iniciar um novo jogo o jogador ganha um baralho de cartas aleatórias do total do jogo; depois, os chefes dão cartas (escolher 1 de 3) e a loja vende pacotes de figurinhas com 3 cartas; cartas de chefe são sempre melhores que as de pacote"
---

# Coleção de cartas: baralho inicial aleatório, cartas de chefe e pacotes de figurinhas


## 1. Ideia

O jogo está ganhando cartas demais para um baralho fixo por personagem. O baralho passa a ser **uma coleção que
o jogador monta jogando**:

1. **Novo jogo:** o jogador recebe **um** baralho inicial de cartas **sorteadas** do total do jogo, para usar com todos os personagens.
2. **Chefes:** vencer um chefe oferece **3 cartas raras** e o jogador escolhe **1**.
3. **Loja:** vende **pacotes de figurinhas**; cada pacote traz **3 cartas**.
4. **Regra dura:** **toda carta de chefe é melhor que toda carta de pacote.**

Os **pergaminhos** (`SPEC-039`) continuam separados: são temporários, não entram na coleção.

## 2. Raridade (é o que garante "chefe > pacote")

`Card.rarity`, três níveis:

| Raridade | De onde vem | Papel |
|---|---|---|
| **Comum** | baralho inicial e pacotes | as cartas básicas (Golpe, Chama Menor, Segundo Fôlego...) |
| **Incomum** | só pacotes | melhores que as comuns (área, controle, efeitos de estado) |
| **Rara** | **só chefes** | as mais fortes e mais marcantes |

- Os **pools são disjuntos por origem**: o chefe só oferece raras; o pacote só sorteia comuns e incomuns; o
  baralho inicial só usa comuns.
- Um **teste automático** garante a regra dura: toda rara tem raridade estritamente maior que toda carta de
  pacote, e o orçamento de poder de uma rara é ~1,3 a 1,5 vezes o de uma incomum (validar no playtest).
- **Trabalho de conteúdo:** hoje não há cartas raras. Cada chefe precisa de um conjunto próprio; para o M1 (1
  chefe) são **ao menos 4 raras**, para a oferta de 3 variar. Candidatas já existentes a promover: Bola de Fogo e
  Onda Psiônica. As demais precisam ser desenhadas (uma spec de conteúdo à parte).
- A classificação das cartas existentes em comum/incomum é uma tabela declarativa, ajustável sem código.

## 3. Coleção e baralhos (um baralho para todos os personagens)

Decisão do responsável (2026-09-19): **o jogador tem 1 baralho para usar com todos os personagens.** É possível
**desbloquear um 2º baralho**.

- `SaveState.collection`: a coleção do **jogador** (não do personagem), com repetições (ex.: 5 Golpes).
- `SaveState.decks`: os baralhos do jogador. Existe **1 desde o início**; o **2º é desbloqueável** (recomendo
  comprá-lo na loja da `SPEC-035`, por um preço alto, ~500 moedas; ver "Decisões"). Cada baralho é uma lista de
  cartas da coleção, com no máximo as cópias que o jogador tem.
- Ao iniciar uma tentativa o jogador escolhe o personagem e, se tiver 2, o baralho.
- **Baralho da tentativa = o baralho escolhido + as cartas de assinatura do personagem** (as cartas de nível da
  `SPEC-024` e as habilidades de classe dele, que **não** estão na coleção compartilhada: entram sozinhas). Assim
  nenhuma carta de coleção é exclusiva de um personagem.
- **Teto de 20 cartas por baralho** (sem contar as de assinatura). Cartas além do teto ficam na coleção.
- **Tela "Baralho"** (no Interlúdio, `SPEC-034`): lista a coleção, marca as cartas de cada baralho e permite trocar
  respeitando o teto. É o único deckbuilding do jogo, propositalmente simples.
- Cartas novas entram no baralho ativo se houver espaço; senão ficam só na coleção.
- **Como as cartas funcionam com qualquer personagem:** a cor da carta decide a eficiência (bônus do atributo
  correspondente do personagem) e a Corrente, como já é hoje; carta de outra cor vale 50% e quebra a Corrente
  (`SIS-001`). Por isso o baralho compartilhado deve ter **variedade de cores** (ver §4).
- O catálogo (`SPEC-026`) mostra a coleção, as cartas descobertas e a raridade de cada uma.

## 4. Novo jogo: baralho inicial sorteado

- Em "Novo jogo", o jogador recebe **1 baralho de 12 cartas comuns sorteadas** do pool comum e o guarda no save
  (não re-sorteia a cada tentativa). "Novo jogo" apaga tudo e sorteia de novo.
- **Garantias**, para o baralho compartilhado nunca nascer injogável com qualquer personagem:
  - **pelo menos 2 cartas de cada cor** (Vermelho, Amarelo, Azul e Roxo);
  - **pelo menos 1 carta de cura** e **2 de ataque**;
  - só cartas **universais** (nenhuma exclusiva de personagem, o que já vale pelo modelo da §3).
- Isso substitui o baralho fixo de `build_deck` como ponto de partida: o conteúdo atual dos baralhos iniciais vira
  o **pool comum**, menos as habilidades de classe e as cartas de nível, que passam a ser de assinatura.

## 5. Chefe

- Ao vencer um chefe, a tela **"Escolha 1 carta rara"** mostra 3 raras do pool daquele chefe, sem repetir na
  oferta. A escolhida entra na coleção (e no baralho, se houver espaço).
- Convive com o pergaminho da `SPEC-039`: vencer o chefe dá **os dois** (o pergaminho temporário e a carta rara
  permanente). A escolha da carta rara não pode ser pulada.
- No M1 só há um chefe (o Guardião alado verdadeiro); os demais chefes do arco (`VSN-003`) trazem seus pools.

## 6. Pacotes de figurinhas

- Item da loja (`SPEC-035`): **Pacote de figurinhas**, **100 moedas** (a 1 moeda por XP, ~1 vitória por
  pacote; ajustar no playtest).
- **Revisão de 2026-09-19 (responsável): o pacote mostra 3 cartas e o jogador escolhe 1.** As 3 são: cada uma
  **75% comum, 25% incomum**, com **pelo menos 1 incomum** garantida entre elas.
- **Abertura:** a mesma tela de escolha da recompensa do chefe ("Escolha 1 de 3"). A escolhida vai para a
  coleção; as outras somem, sem reembolso; **não dá para pular**. Repetidas são permitidas.
- **Oferta pendente:** a oferta (pacote ou chefe) fica no save até a escolha, então fechar o jogo no meio não perde
  a compra nem a recompensa.
- Só a **moeda do jogo** compra (sem dinheiro real, regra do `ART-001`).
- Duplicatas em excesso não têm troca na v1.

## 7. Arquitetura

- `game/core/collection.py` (sem pygame): `Rarity`, pools por origem, `starting_deck(rng)`, `open_pack(rng)`,
  `boss_offer(boss_id, rng)` e `Deck` (cartas, teto, trocas).
- `Card.rarity` e a tabela de raridades; `Card.signature` marca as cartas de assinatura (fora da coleção). O
  `CharacterDef` deixa de ditar o baralho inicial e mantém só as cartas de assinatura.
- `SaveState.collection` (lista global) e `SaveState.decks` (1 ou 2). Saves antigos, sem coleção, ganham uma
  **migração**: a coleção passa a ser a **união das cartas universais dos baralhos fixos atuais** (com
  repetições) e o baralho 1 é montado dela, para ninguém perder cartas que já usa.
- UI: `PackOpenScreen`, `BossRewardScreen` (1 de 3), `DeckScreen` (Baralho, com a troca entre os 2 baralhos) e
  a loja com o pacote e o 2º baralho.
- Arte: cada carta nova precisa de ilustração; sem arte, cai no retângulo com o nome. O pacote precisa de uma
  arte de "figurinha" (a definir).

## Decisões (2026-09-19)

Respondidas pelo responsável:
1. **Um baralho para todos os personagens, com um 2º desbloqueável** (mudou o desenho da §3; a coleção deixou
   de ser por personagem).
2. **"Tudo aprovado"** para as demais pendências. Adotei as recomendações desta spec: sorteio só de cartas
   universais com garantia de cores, teto de 20 por baralho com a tela "Baralho", pacote a 150 moedas (75%
   comum, 25% incomum, 1 incomum garantida) e raridade comum/incomum/rara.

3. **Cartas raras:** definidas na `SPEC-043` (6 raras de chefe para o M1, inspiradas em golpes de D&D), aprovadas
   em 2026-09-19.
4. **Classificação das cartas atuais em comum/incomum/assinatura:** tabela da `SPEC-043`.
5. **2º baralho:** desbloqueado na loja (`SPEC-035`), ~500 moedas, a ajustar no playtest.

## Fora de escopo

Troca de cartas entre jogadores, dinheiro real, venda de cartas de volta por moeda, cartas raras de todos os
chefes do arco (só o do M1 primeiro), pacotes de raridade maior.

## Critérios de aceite

- [x] "Novo jogo" sorteia **um** baralho inicial de 12 comuns para o jogador, uma vez, e o guarda no save.
- [x] O baralho inicial respeita as garantias (2 de cada cor, cura, ataque) e só usa cartas universais.
- [x] O jogador usa o mesmo baralho com qualquer personagem; as cartas de assinatura de cada um entram sozinhas.
- [x] O 2º baralho começa bloqueado e, desbloqueado, é escolhido antes da tentativa. (compra na loja; a escolha fica no seletor de personagem)
- [x] Vencer o chefe oferece 3 raras e o jogador escolhe 1; não é possível pular.
- [x] O pacote mostra 3 cartas, com ao menos 1 incomum, e o jogador escolhe 1, que vai para a coleção.
- [x] A oferta (pacote ou chefe) sobrevive a fechar o jogo e não pode ser pulada.
- [x] **Teste:** toda carta de chefe tem raridade maior que toda carta de pacote.
- [x] O baralho respeita o teto de 20; o excedente fica na coleção e a tela "Baralho" faz a troca.
- [x] Saves antigos migram para uma coleção global (união das cartas universais dos baralhos atuais).
- [x] As cartas de nível e as habilidades de classe seguem garantidas e fora do sorteio e da coleção.
- [x] `core` sem pygame; testes de sorteio (garantias), pacote, oferta de chefe, teto e migração (`tests/core/test_collection.py`, `tests/core/test_shop.py`, `tests/ui/test_collection_flow.py`).
- [ ] Playtest.

Notas de implementação: a recompensa do chefe vem antes da HQ e do resultado. A tentativa usa `Player.for_character(..., deck_names=...)` (baralho do jogador + `signature_cards`). As cartas comuns de habilidade de classe (Toque Curativo, Bola de Fogo...) mantêm a marca HC quando vêm da coleção. O `App` sorteia o baralho na 1ª tentativa e migra saves antigos ao iniciar a tentativa. O menu com 8 botões passou a duas fileiras.
