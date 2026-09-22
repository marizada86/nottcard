---
id: "FB-001"
type: "feedback"
title: "Feedback de playtest: Higor e Caio (Cailou), 2026-09-19"
status: "approved-with-recommendations"
created: "2026-09-19"
relations:
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-010-reacao-cartas-escurecidas-e-ajustes-de-hud]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-013-tela-de-tutorial-e-pausa-em-combate]]"
  - "[[SPEC-015-atordoamento-e-onda-psionica]]"
sources:
  - "Higor, 2026-09-19 14:30 (recomendações de alteração)"
  - "Higor, 2026-09-19 14:42 (seguindo playtest do Caio/Cailou)"
  - "Caio, 2026-09-19 (recomendações sobre a passiva de classe)"
---

# Feedback de playtest (2026-09-19)

Rascunho: nada aqui é regra até o responsável aprovar. Cada item traz o estado
atual do código, a proposta do Higor e a recomendação da IA. Os itens estão
agrupados nas specs que os implementariam.

## Grupo A: interface de combate (sem mexer em regra)

### A1. Voltar ao menu / menu de pausa (Higor)
- **Hoje:** só existe pausa por tutorial (`?`/F1). `App.return_to_menu()` existe, mas só
  é chamado da seleção de personagem. Não há saída durante o combate.
- **Recomendação:** `ESC` abre um menu de pausa com **Continuar**, **Tutorial** e
  **Voltar ao menu** (com confirmação, porque perde a run). Reaproveita `Screen.pause()`
  (cronômetro do chefe e sequenciador já congelam). O `ESC` que hoje limpa a seleção da
  carta passa a fazer isso só quando há carta selecionada.

### A2. Passar o mouse mostra detalhes da carta (Caio)
- **Hoje:** carta selecionada sobe (`LIFT_OFFSET`); não há hover nem painel de detalhes.
- **Recomendação:** hover levanta a carta levemente e abre um painel ampliado (arte
  grande, nome, cor, dado, nota, custo Ação/Bônus/Reação, se conta para a Corrente e o
  multiplicador que aplicaria agora). O painel é só desenho em `game/ui/`, sem regra.

### A3. Duplo clique joga a carta no primeiro inimigo da esquerda (Caio)
- **Hoje:** clique seleciona; com carta de ataque selecionada, novo clique escolhe o alvo.
- **Recomendação:** duplo clique (janela ~350 ms) numa carta joga direto: ataque simples
  vai ao **primeiro inimigo vivo da esquerda para a direita**; carta sem alvo, de área ou
  de bônus é jogada direto. Se o alvo estiver eliminado, pula para o próximo vivo.
  Nunca joga carta que o `TurnState` não permite (mesma checagem do clique normal).

### A4. Destaque da Corrente efetiva e da quebrada (Higor)
- **Hoje:** `ComboTracker.streak` (0–3) e multiplicador 1–4 existem, mas a exibição é discreta.
- **Recomendação:**
  - Fonte maior para o multiplicador (`x2`, `x3`, `x4`) e para a sequência.
  - **Efetiva** (a carta jogada contou): borda dourada e pulso curto no indicador, e
    o número sobe com um "pop".
  - **Quebrada:** o indicador fica vermelho-oxblood, a corrente do `combo_icon` "parte"
    (troca para um estado rachado) e o valor volta a x1 com um tremor. Cor + forma, não só cor
    (acessibilidade).
  - Aproveita para usar o `combo_icon` (já gerado, falta só o passo de pipeline).

### A5. Mão cheia: escolher a carta a descartar (Higor)
- **Hoje:** o excedente cai sozinho no fim do turno (`discard_excess`, tira as últimas
  compradas). O jogador não escolhe.
- **Proposta do Higor:** ao passar do limite, escurecer todas as cartas menos a escolhida;
  clicar descarta.
- **Recomendação (refinando):**
  1. Modo "Descarte" com as cartas escurecidas (mesma linguagem visual da Reação da SPEC-010,
     pra ser consistente) e um aviso "Mão cheia: escolha N carta(s) para descartar".
  2. **Escurecer todas** ou **realçar todas**? Realçar a candidata sob o mouse (borda
     vermelha) e mostrar o painel de detalhes do A2, pra decidir com informação.
  3. Cartas **Reação** e de **uso único** entram na escolha normalmente.
  4. Quando o excesso é de mais de uma carta, repete a escolha.
  5. Momento: no fim do turno do jogador (regra atual). Alternativa a discutir: escolher
     **na hora da compra**, evitando o descarte cego. Recomendo manter no fim do turno.
  6. Tecla `1`–`5` também descarta, pra teclado.
  7. O tempo do cronômetro do chefe (45 s) **não** conta durante o descarte.

## Grupo B: regras e balanceamento (exigem spec e decisão)

### B1. Chama Menor × Chama Sagrada iguais (Higor)
- **Hoje:** ambas Amarelas, 1d6, fogo. A Sagrada acrescenta radiante (sem efeito
  mecânico hoje) e o baralho do Maelor tem 4 Sagradas e 2 Menores.
- **Proposta do Higor:** Sagrada cai para 1d4 e vira **Ação Bônus**.
- **Análise:**
  - Uma ação bônus que causa dano dá ao Maelor um ataque extra por turno **sem gastar a
    Ação**, o que é forte, e por isso o 1d4 compensa.
  - Mas disputa o slot de Bônus com Palavra Curativa, Poção e "comprar 1 carta".
    Com 4 cópias, a mão dele vai encher de Bônus que ele só joga uma por turno.
- **Recomendação:** aceitar a proposta do Higor com dois ajustes:
  1. Reduzir de **4 para 3** cópias da Chama Sagrada (senão trava a mão).
  2. Dar identidade radiante real: **+1 dado extra (1d4) contra inimigos corrompidos**
     ou ignorar 1 ponto de CAM (mesmo padrão do Golpe Perfurante). Decidir na spec; sem
     isso a diferença é só "mais fraca e mais barata".
- **Ponto de decisão:** Bônus que ataca **conta na Corrente Amarela**? Recomendo que sim
  (é Amarela), mas isso amplia combos: Sagrada (bônus) + Bola de Fogo (ação) vira x2 fácil.

### B2. Ação compra 2 cartas (Higor)
- **Hoje:** o Bônus básico é "comprar 1 carta". A Ação básica só tem "Passar".
- **Proposta:** análogo, Ação = comprar **2** cartas.
- **Análise:** é o "passar a Ação" hoje sem efeito, ganhando valor. Risco: a mão cheia
  (limite 5) fica quase sempre acima do limite, o que **reforça a necessidade do A5**.
  Também reduz a tensão do baralho (ciclo do descarte, embaralhamento).
- **Recomendação:** aprovar, **com a compra limitada pelo espaço**: comprar até 2, mas
  o excesso passa pelo descarte do A5 no fim do turno (sem perder carta cega). Renomear
  o botão "Passar Ação" para "Comprar 2" e manter a opção de passar sem comprar só se
  houver motivo (o baralho vazio, por exemplo).
- **Depende de:** A5.

### B3. Névoa Fria em área (Higor)
- **Hoje:** controle em 1 alvo; `resolve_control` gera uma redução de `ceil(dado × Corrente × compat × (1+bônus))`
  aplicada em `next_attack_reduction`.
- **Recomendação:** aplicar a mesma redução a **todos os inimigos vivos** (como
  `resolve_area_attack`: um rolamento, o mesmo valor pra todos). Para não ficar forte demais
  contra 3 inimigos, sugiro **compat reduzida** em área (ex.: ×0,75 do valor) ou fazer dela
  Habilidade de Classe (1 uso por combate), como já são Onda Psiônica e Bola de Fogo.
- **Ponto de decisão:** área com valor cheio ou com desconto?

### B4. Golpe Contundente do Maelor com chance de atordoar (Higor)
- **Hoje:** Vermelho, 1d4, Força escala o dano. O "Atordoar" já existe, mas é carta
  separada, automática, HC de 1 uso (SPEC-015).
- **Proposta:** chance de atordoar por **teste de dados**.
- **Recomendação:** após acertar, rola **d20 + mod. Força** contra uma **CD de atordoamento**
  do inimigo, novo atributo, `Enemy.cd_stun` (ex.: Criatura 12, Slime 10, Guardião cópia 14,
  Guardião verdadeiro 16, chefe **imune ou +4** para não ser trivial). Sucesso: `stunned=True`.
  Reaproveita a animação do d20 e o log do devlog. Alternativa mais simples: **d6, 5–6 atordoa**
  (33%), sem atributos novos; menos tático.
  - **Regra de limite:** o atordoamento não pode se **acumular** (alvo já atordoado ignora)
    e o chefe não deve ser atordoável em turnos seguidos.
  - Atordoar continua existindo como carta garantida, então a diferença é: aqui é probabilístico
    e vem "de graça" com o ataque.
- **Ponto de decisão:** teste d20 vs CD (tático) ou d6 simples?

## Grupo D: passiva de classe em destaque (Caio)

### D1. Seleção de personagem destaca a passiva
- **Hoje:** `CharacterSelectScreen` mostra `passive_text` em fonte 20, igual ao resto do
  cartão, e **um clique já inicia a run** (`start_run`), sem etapa de seleção.
- **Recomendação:**
  1. Separar **selecionar** de **confirmar**: o primeiro clique seleciona o personagem
     (o cartão sobe, ganha brilho na cor da classe e o retrato "acende"); um botão
     **Começar** (ou segundo clique/Enter) confirma. Sem isso não existe "ao selecionar".
  2. Painel de destaque da passiva embaixo do cartão selecionado: **nome da passiva** em
     fonte de título (`card_title_font`, tamanho ~34) e a descrição em ~24, com contorno e cor
     da classe. Os atributos e o resto do cartão ficam menores para a passiva mandar.
  3. Efeito ao selecionar: partículas na cor da classe (psiônico branco-azulado no Durvall,
     âmbar/fogo no Maelor), pulso curto no cartão e o outro cartão escurece. É só código
     (`game/ui/`), sem arte nova obrigatória.
- **Precisa de nome:** hoje a passiva é só texto (`passive_text`), sem nome. Sugestão a validar:
  - Durvall: **"Corrente Psiônica"** (a Corrente soma dano psiônico: 2x=1d6, 3x=2d6, 4x=3d6).
  - Maelor: **"Chama Devota"** (cartas de fogo também ativam a Corrente; ela amplia dano, cura e controle).
  Isso exige um campo novo `passive_name` em `CharacterDef` (dado declarativo, como manda a VSN-001).

### D2. Clicar no nome do personagem em partida mostra a passiva
- **Hoje:** o painel do jogador (`draw_player_panel`, nome em `card_title_font(22)`) não é
  clicável, e o tutorial só cita a passiva de forma geral.
- **Recomendação:** o nome vira botão (com dica visual: sublinhado ou "?" ao lado e cursor de
  mão no hover). O clique abre um cartão de passiva com o mesmo estilo do D1 (nome grande,
  descrição, o multiplicador atual da Corrente como exemplo vivo). Fecha com clique fora ou ESC.
  - **Pausa:** o cartão pausa o combate como o tutorial (`Screen.pause()`), para não gastar o
    cronômetro do chefe. Clicar só faz sentido quando `busy` é falso (sem batida em andamento),
    igual ao resto da entrada.
  - Reaproveita o mesmo componente do D1, e o painel de detalhes de carta do A2 pode usar o
    mesmo desenho de "cartão ampliado".
  - Aproveita para mostrar também as **Habilidades de Classe (HC) de 1 uso** que já foram
    usadas no combate — mas só se o responsável quiser; fora do pedido do Caio.

## Grupo C: decisões (2026-09-19)

O responsável aprovou "tudo com as recomendações". Respostas adotadas:

| # | Pergunta | Decisão |
|---|---|---|
| 1 | B1 | Sagrada 1d4, Ação Bônus, **3 cópias**, **ignora 1 CAM**, **conta na Corrente Amarela**. |
| 2 | B2 | Ação-comprar-2 **convive** com "Passar" (o baralho vazio não impede passar). |
| 3 | B3 | Névoa Fria em área **com desconto ×0,75**, sem virar HC. |
| 4 | B4 | **d20 + Força vs CD de atordoamento** por inimigo; chefe com CD maior e sem acúmulo. |
| 5 | A5 | Descarte **no fim do turno**. |
| 6 | Durvall | Névoa em área e Ação-comprar-2 valem **para os dois** personagens. |
| 7 | D1 | Selecionar e depois confirmar; nomes **"Corrente Psiônica"** e **"Chama Devota"**. |
| 8 | D2 | O cartão mostra só a passiva. |

Implementação: SPEC-018 a SPEC-022 (esta seção) e SPEC-023/024 (SIS-005).

## Sequência sugerida de specs

| # | Spec proposta | Conteúdo | Depende de |
|---|---|---|---|
| 1 | Menu de pausa | A1 | nada |
| 2 | Interação de cartas | A2, A3 | nada |
| 3 | Destaque da Corrente | A4 (+ pipeline do `combo_icon`) | nada |
| 4 | Descarte por escolha | A5 | A2 (painel) recomendado |
| 5 | Ação compra 2 | B2 | A5 |
| 6 | Rebalanceamento do Maelor | B1, B3, B4 | decisões do Grupo C |
| 7 | Passiva de classe em destaque | D1, D2 (`passive_name` em `CharacterDef`) | nada (sem regra) |

Itens 1–3 e 7 não mudam regra de jogo, então podem sair antes do balanceamento.
Como os itens B mudam números, vale um novo playtest (EVID) depois de cada rodada.
