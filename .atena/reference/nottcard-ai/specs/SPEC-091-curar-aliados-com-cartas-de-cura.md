---
id: "SPEC-091"
type: "spec"
title: "Cartas de cura podem curar outro personagem do grupo"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-037-grupo-de-ate-3]]"
  - "[[SPEC-005-acao-bonus]]"
  - "[[SPEC-036-mochila-e-itens]]"
  - "[[SPEC-092-testes-de-morte-do-personagem-caido]]"
sources:
  - "Responsável, 2026-09-20: cartas de cura devem poder curar outros personagens (ex.: Durvall usa Poção de Cura em Sylas ou Kayron); Segundo Fôlego só em si mesmo, seguindo as regras do D&D 5.5 (2024)"
---

# Curar aliados

> Aprovada pelo responsável em 2026-09-20 (`execution_approval: per-spec`), incluindo a §2.1 (aliado caído, regra do D&D 2024). Muda regra de combate em grupo (SPEC-037): não afeta o solo.

## 1. Regra
Com **mais de 1 personagem vivo em cena**, uma carta de cura pode ter como alvo **qualquer personagem vivo do grupo** (inclusive quem a joga). Com 1 personagem o jogo é o de hoje (cura em si, sem escolha).

**Quem fica só em si mesmo** (novo campo `Card.self_only: bool`):
- **Segundo Fôlego** (Durvall): no D&D 2024 é uma característica de classe, ação bônus, "você recupera PV". Só em si.
- **Imagem Espelhada** (`heals_clone`): a cura vai para a Cópia Sombria de quem joga.
- **Redenção Divina** (`redeems`): remove a **Desonra** de quem joga, que é estado pessoal. **[decisão]** recomendo só em si; alternativa: curar aliado sem remover a Desonra.

**Podem ter aliado como alvo** (o resto de `kind == "cura"`): Poção de Cura (todas as cópias por classe), Luz Mais Pura, Toque Curativo, Palavra Curativa, Mãos Celestiais, Mãos Consagradas e os pergaminhos Curar Ferimentos, Curar Ferimentos Maior e Palavra Curativa (`scrolls.py`).

## 2. Como resolve
- Quem **joga** a carta gasta a Ação/Ação Bônus dela, o dado, o modificador (`modifier_attr` do **lançador**) e alimenta a **Corrente de Classe do lançador** (a cor da carta conta para ele, SPEC-037 §2). O bônus/penalidade de **Desonra** também é do lançador (cura pela metade).
- Os PV vão para o **alvo**: `target.player.heal(total)`, respeitando o PV máximo. O `stats.healing` soma a cura efetiva.
- Uso único (`single_use`) é consumido do baralho do **lançador**.
- **Alvo com PV cheio:** desabilitado (a carta não se perde por engano).
- **Alvo caído (0 PV): pode ser curado e volta ao combate** (ver §2.1).
- Log e narração: "Durvall usa Poção de Cura em Sylas: +4 (PV 3 → 7)". F12 e log de combate trazem o detalhe.

## 2.1 Aliado caído (recomendação com base no D&D 2024)
**No D&D 5.5:** a 0 PV o personagem fica **Inconsciente** e faz salvaguardas contra a morte; **qualquer cura o faz recuperar a consciência** com os PV curados (é a tática clássica de "levantar" com *Palavra Curativa* ou uma poção). Dano e cura não têm memória: ele volta com o que foi curado, não com PV cheio.

**Regra** (a SPEC-037 §1 passa a dizer isso no lugar de "fica fora até o fim do combate"):
- Uma carta de cura (não-`self_only`) em aliado a **0 PV** o **levanta**: `PV = cura efetiva` (mínimo 1) e ele volta a estar vivo em cena, com a mão e a pilha que tinha ao cair e a **Corrente de Classe zerada** (conferir o que `Party`/`Player` fazem hoje ao cair e manter igual).
- **Custo de levantar:** o aliado levantado **não age no turno em que foi levantado** (no D&D ele gasta parte do movimento para se levantar; aqui isso vira "perde a ação daquele turno"). Volta a agir a partir do turno seguinte. Sem essa trava, uma carta de ação bônus daria cura **mais** uma ação inteira grátis.
- **Testes de morte:** o caído que ninguém cura faz 1 teste de morte por rodada (SPEC-092). A cura antecipa isso: levanta na hora e zera o contador. Levantar alguém antes de o último cair evita a derrota (todos a 0 PV = derrota).
- **Quem não é levantado** faz os **testes de morte** da SPEC-092 (1d20 por rodada; 3 sucessos revivem com 1 PV, 3 falhas matam). A cura zera o contador. O que acontece com o caído no fim do combate está na SPEC-092 §3.
- Cartas `self_only` não levantam ninguém. O lançador caído não joga cartas, então não há caso de "levantar a si mesmo".
- **A Poção de Cura** (uso único) também levanta, como no D&D (dar a poção a um inconsciente o levanta).
- **Alternativa (mais fácil, se o playtest mostrar abuso):** só as cartas de ação bônus/pergaminho de "Palavra Curativa" levantam. Não recomendo agora: a regra geral é a do D&D e a mais simples de explicar.

## 3. Interface (`CombateScreen`)
- Ao selecionar uma carta de cura **não-`self_only`** com grupo > 1, os **retratos do grupo** (trilho do jogador) acendem os alvos válidos (o lançador incluso); os inválidos ficam apagados com o motivo ("PV cheio").
- **Clicar no retrato** confirma o alvo e joga a carta. Clicar de novo na carta (ou no lançador) cura a si mesmo, como hoje, para não exigir um clique extra no caso comum; Esc limpa a seleção (o Esc de carta selecionada já só limpa a seleção). O retrato de um aliado **caído** também acende como alvo, com o rótulo "Levantar".
- Carta `self_only`: joga direto, sem escolha, como hoje. O texto da carta mostra "Só em si" nesses casos e "Alvo: aliado" nas outras.
- O número de cura (`+N`) e o `player_hp_shown` animam **no retrato do alvo**, não no de quem jogou.
- **Duplo clique** e demais atalhos das SPEC-018..024 continuam valendo: para cartas de cura em grupo o duplo clique cura o lançador.

## 4. Fora do escopo
- **Poção da mochila** (SPEC-036) e curas de itens fora de combate: a mochila já tem seleção de personagem; conferir se a poção da mochila já permite aliado e, se não, abrir spec própria.
- Cura em área (nenhuma carta hoje).
- Inimigos que curam aliados.

## 5. Testes
- `core`: `heal_ally(caster, target, card)` cura o alvo (não o lançador), respeita PV máximo, usa o modificador do lançador, aplica a metade em Desonra do lançador e alimenta a Corrente do lançador; PV cheio recusa.
- Aliado a 0 PV: cura o levanta com `PV = cura efetiva` (mínimo 1), ele não age naquele turno e age no seguinte; sem cura fica caído; levantar um caído zera o contador de testes de morte dele; `self_only` não levanta; a Poção levanta.
- `Card.self_only`: Segundo Fôlego, Imagem Espelhada e Redenção Divina recusam alvo que não seja o lançador; as demais aceitam.
- Poção de Cura de Durvall em Sylas: consome do baralho de Durvall, cura Sylas, não cura Durvall.
- Solo: nenhuma mudança (sem seleção de alvo). Grupo de 3: cada retrato válido é alvo; o inválido não reage ao clique.
- UI: o retrato do alvo mostra o número; o texto da carta mostra "Só em si"/"Alvo: aliado".
- Regressão: os 1284+ testes de combate solo seguem passando.
