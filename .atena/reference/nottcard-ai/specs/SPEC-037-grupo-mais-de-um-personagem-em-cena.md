---
id: "SPEC-037"
type: "spec"
title: "Grupo: até 3 personagens em cena"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-19"
relations:
  - "[[SIS-003-fileira-de-inimigos-exploracao-com-cartas-hud]]"
  - "[[SPEC-014-combate-com-multiplos-inimigos]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[SPEC-086-luta-por-colisao-portas-travadas-e-confronto-por-falha]]"
  - "[[SPEC-091-curar-aliados-com-cartas-de-cura]]"
  - "[[SPEC-092-testes-de-morte-do-personagem-caido]]"
sources:
  - "Responsável, 2026-09-19: grupo de até 3 em cena; alvo dos inimigos pela menor CA; modo solo continua jogável"
  - "VSN-003: elenco disponível de 4 (M1) a 8 (fim do arco)"
  - "Responsável, 2026-09-20: alvo dos inimigos 100% aleatório (SPEC-086 §4, substitui a menor CA); cartas de cura podem curar e levantar aliado (SPEC-091)"
---

# Grupo: até 3 personagens em cena


## 1. Formação do grupo

- Antes da tentativa, o jogador escolhe **1 a 3 personagens** entre os disponíveis na missão (`VSN-003`).
  Com 1, o jogo é o solo de hoje.
- Cada personagem mantém **baralho, mão, PV, Corrente de Classe, nível e passiva próprios**. O progresso e o
  XP já são por personagem (SPEC-023) e seguem assim; o XP da tentativa vai para todos os que estiveram em cena.
- Personagem a 0 PV cai e fica fora do turno e do alvo dos inimigos **até ser levantado por uma carta de cura de
  aliado** (SPEC-091 §2.1: volta com os PV curados, mínimo 1, com a mão e a pilha que tinha e a Corrente zerada, e
  não age no turno em que foi levantado). Sem cura, o caído faz **1 teste de morte por rodada** (SPEC-092: 1d20,
  10 ou mais = sucesso; 3 sucessos revivem com 1 PV, 3 falhas matam; morto fica fora até o fim do combate, quando
  todo caído ou morto volta com 1 PV). **Todos a 0 PV = derrota** (a missão falha na hora; no solo, cair é derrota).

## 2. Turno

- O turno do jogador dá **1 Ação e 1 Ação Bônus por personagem vivo**, na ordem que o jogador quiser (o
  `TurnState` da SPEC-005 passa a ser por personagem).
- O jogador escolhe o personagem ativo clicando no retrato dele (trilho do jogador, SPEC-016).
- A Corrente de Classe é **por personagem** (cada um tem sua cor); uma carta jogada por um personagem não
  alimenta a Corrente de outro.
- O tempo de decisão de 45 s contra o chefe vale para o **turno inteiro** do jogador, não por personagem.

## 3. Alvo dos inimigos (regra nova, fecha a lacuna da SIS-003; alterada pela SPEC-086 §4)

- Um ataque de inimigo mira **um personagem vivo sorteado, com a mesma chance para todos** (100% aleatório). A regra
  original, "o de menor CA (CAM se mágico), sorteio no empate", foi substituída em 2026-09-20.
- Ataques em área atingem todos os personagens vivos.
- O restante do combate (teste de acerto, dano, reação) não muda.

## 4. Exploração

- **O jogador escolhe quem faz o teste** ao clicar numa opção (o atributo da opção destaca quem tem o melhor
  modificador). Um personagem, uma tentativa; sem ajuda de outros na v1.
- O custo de uma falha (PV, descarte de carta) recai sobre **quem fez o teste**.
- Isto dá sentido ao elenco: os atributos são distintos (`SIS-001`).

## 5. Restrições de conteúdo

- Cartas de área e a passiva do Erik (que depende delas) só entram junto com esta spec ou depois.
- **Companheiros de suporte** (o Livrinho, por exemplo) ficam fora: são um caso à parte.
- Nenhum personagem novo é criado aqui; só entram os que já têm ficha em `canon/nottcard/personagens/`.

## Arquitetura

`game/core/party.py` (`Party`: personagens vivos, ativo, `alive`, escolha de alvo sorteada entre os vivos); `TurnState` por
personagem; `CombateScreen` ganha o trilho de retratos (UI, sem regra); `SituacaoScreen` ganha a escolha de
quem testa. Testes de `core` sem pygame; o solo fica como caso particular de `Party` com 1 membro.

## Fora de escopo

Formação/posicionamento ("corredor vs. arena", adiado desde a SPEC-001); ajuda em testes; troca de
personagem no meio do combate; aliados controlados por IA; grupos de mais de 3.

## Critérios de aceite

- [x] Grupo de 1 se comporta exatamente como o solo atual (todos os testes existentes passam).
- [x] Com 2 ou 3, cada um tem Ação e Bônus próprias, Corrente própria e PV próprio.
- [x] Inimigos miram um personagem vivo sorteado (SPEC-086; antes, a menor CA); a área atinge todos.
- [x] Todos a 0 PV = derrota; um caído não age até ser levantado por cura (SPEC-091) ou reviver pelos testes de morte (SPEC-092).
- [x] Na exploração, o jogador escolhe quem testa e a falha recai sobre esse personagem.
- [x] XP entra em todos os personagens da tentativa.
- [x] `core` sem pygame (`game/core/party.py`, `tests/core/test_party.py`, `tests/ui/test_party_flow.py`).
- [ ] Playtest com um grupo de 3.

Notas de implementação:
- **Formação:** na seleção de personagem, cada cartão tem o botão "+ Grupo" (até 3, o 1º marcado é o líder); sem marcar ninguém, selecionar e confirmar segue começando o solo de sempre. "Jogar de novo" repete o grupo.
- **Turno:** cada personagem vivo tem a própria Ação, Bônus e Reação. Quando o ativo esgota as ações, o controle passa sozinho ao próximo que ainda tem o que fazer; clicar no retrato (canto superior direito) ou Tab troca o ativo à mão. "Encerrar turno" encerra o do grupo inteiro. O cronômetro de 45 s do chefe é um só, do turno inteiro.
- **Alvo:** sorteado entre os vivos, com a mesma chance (SPEC-086 §4; era a menor CA, CAM se mágico); o alvo entra em cena para reagir com a mão e a Reação dele. Um golpe em área (`Enemy.special_area`, nenhum inimigo do M1 usa ainda) atinge todos os vivos, com um d20 por alvo e o mesmo golpe. O caído fica fora do turno e do alvo até ser levantado por cura (SPEC-091) ou reviver pelos testes de morte (SPEC-092); todos a 0 PV = derrota.
- **XP e moeda:** o XP da tentativa entra em cada personagem do grupo; a moeda (SPEC-035) é creditada uma vez, igual ao XP líquido, e não é multiplicada pelo tamanho do grupo.
- **Exploração:** chips com o nome de cada personagem escolhem quem faz o teste (a estrela marca o melhor modificador para a opção sob o mouse); a falha recai sobre quem testou.
- A Cópia Sombria do Sylas absorve o golpe primeiro, então o PV dele só cai depois dela.
