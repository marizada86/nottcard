---
id: "SPEC-010"
type: "spec"
title: "Reação (Aparar, Contrafeitiço), cartas indisponíveis escurecidas e ajustes de HUD"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[SPEC-008-ajustes-pos-playtest-evid-003]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
sources:
  - "Pedido do responsável em 2026-09-19 (3 itens: cartas escurecidas, Reação com Parry/Counterspell, posição dos números de dano e tamanho do orbe)"
  - "Aprovação do responsável em 2026-09-19: todas as propostas da spec aceitas; acrescentou o nome do personagem abaixo do orbe, atributos acima dele, e letras maiores e mais estéticas nas cartas"
---

# Reação, cartas indisponíveis escurecidas e ajustes de HUD

## 1. Cartas que não podem ser usadas ficam escuras

Pedido: usar a Ação Bônus escurece as cartas de Bônus, sinalizando que não dá pra jogá-las.

- Uma carta na mão é **escurecida** quando `can_play(carta)` é falso agora: Ação gasta → cartas de Ação escuras; Bônus gasto → cartas de Bônus escuras; HC/Poção já gastas nem estão na mão.
- **Cartas de Reação ficam escuras durante o seu turno** (só se acendem na janela de reação, §2).
- Clicar numa carta escura continua mostrando a mensagem do log ("Ação Bônus já usada…"), sem mudar nada.
- Só visual + a mesma regra que o core já usa (`can_play`); nenhuma regra nova.

## 2. Reação

Terceiro espaço de ação, ao lado de **Ação** e **Ação Bônus**.

**Regras**
1. **1 Reação por rodada**: renova quando **começa o seu turno** (como no D&D). Gasta, fica vermelha até lá.
2. Com **mais de um inimigo**, a Reação continua sendo **uma só até o fim do turno**: não dá pra reagir a um segundo inimigo (pedido do responsável).
3. Só cartas de Reação usam esse espaço; elas **não gastam Ação nem Bônus** e **não avançam a Corrente de Classe** *(proposta: reação acontece fora do seu turno)*.
4. **Janela de reação**: quando um ataque inimigo vai atingir o Durvall e ele tem a Reação livre e uma carta de Reação **compatível** na mão, o jogo pausa e mostra **"Reagir?"**: as cartas compatíveis acendem, o resto fica escuro, e há o botão **"Não reagir"** *(proposta)*. Sem carta compatível, não há pausa.
5. A janela abre **depois do d20 do inimigo acertar** e antes do dano ser aplicado *(proposta: reagir só ao que realmente acertaria)*.
6. Carta de Reação usada vai pro **descarte** (não é HC nem uso único).

**HUD:** terceiro círculo **Reação** (verde = livre, vermelho = gasta), igual aos outros dois.

**Cartas novas** (nomes traduzidos do D&D 2024 em português)

| Carta | Cor | Reage a | Efeito *(proposta)* |
|---|---|---|---|
| **Aparar** (Parry) | Vermelha | ataque **físico** (CA) | Reduz o dano em **1d8 + modificador de Força** (Durvall +3). Reduzido a 0 = ataque anulado. |
| **Contrafeitiço** (Counterspell) | Azul | ataque **mágico** (CAM: hoje o Grito Abissal) | **Anula** o ataque por completo, sem rolagem. |

- Baralho inicial: **+1 Aparar, +1 Contrafeitiço** → **15 cartas** *(proposta)*.
- O dado do Aparar rola na tela como os outros; o número da redução aparece riscando o dano original, como a redução da Névoa Fria.

## 3. Ajustes de HUD

- **Números de dano do Durvall** (o que ele recebe e cura) passam pra perto das cartas, **centralizados na tela** logo acima da mão, no lugar de junto do orbe.
- **Orbe de vida um pouco maior**: raio 46 → **58**, número mais legível. *(Com 6–7 cartas na mão o orbe fica coberto: proposta de recuar a mão ou encolher o espaçamento só nesse caso.)*
- Os números do inimigo não mudam.
- **Nome e atributos (aprovação):** o **nome do personagem** aparece **abaixo do orbe**, e os **atributos** (FOR, INT, CON, CAR) aparecem **acima** dele. A **CA/CAM** continua abaixo (agora abaixo do nome).
- A mão passa a **recuar pra direita** quando 6+ cartas cobririam o orbe (encolhe o espaçamento).

## 3b. Letras das cartas

- **Letras maiores** nas cartas (nome, tipo/dado e nota); carta um pouco maior (140×190 → 154×210) pra caber.
- **Fonte mais estética**: nome da carta em **Cinzel Decorative Bold** e texto em **Alegreya Sans** (ambas SIL OFL, incluídas em `assets/fonts/` com as licenças). Só nas cartas por enquanto; o resto da UI mantém a fonte atual.

## 4. Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | `action_type="reacao"`; `Card.reacts_to` (`"fisico"`/`"magico"`); cartas Aparar e Contrafeitiço; baralho de 15. **Mudança de core.** |
| `game/core/turn.py` | `reaction_available` no estado de turno; gasta, renova no início do turno do jogador; `can_play` conhece Reação. |
| `game/core/combat.py` | `resolve_reaction(card, ataque)` → dano reduzido/anulado. |
| `game/app.py` | Janela "Reagir?" na sequência do inimigo (SPEC-004); botão "Não reagir"; reposiciona números do Durvall. |
| `game/ui/` | Cartas escurecidas; círculo de Reação; orbe maior; nome e atributos ao redor do orbe; fontes e tamanho das cartas; mão recua se cobrir o orbe. |
| `assets/fonts/` | Cinzel Decorative Bold, Alegreya Sans Regular/Bold e as licenças OFL. |
| Testes | Escurecimento por `can_play`; Reação renova só no início do turno e é 1 por rodada; Aparar reduz físico e não age em mágico; Contrafeitiço anula mágico e não age em físico; sem carta compatível não há janela; "Não reagir" aplica o dano cheio; Reação não avança a Corrente. |

## 5. Decisões

Todas as propostas acima foram **aprovadas em 2026-09-19** (efeito de Aparar e Contrafeitiço, janela após o d20 acertar, Reação sem avançar a Corrente, 1 cópia de cada, mão recuada). Itens que eram *(proposta)*: efeito exato de Aparar e Contrafeitiço, janela depois do d20 acertar, Reação não avançar a Corrente, 1 cópia de cada no baralho, e o que fazer com a mão de 6+ cartas cobrindo o orbe.

## 6. Fora do escopo

Reações de outros tipos (ataque de oportunidade), reações do inimigo, Reação como HC ou recompensa de sala, arte final das cartas (fallback de retângulo, como as demais).
