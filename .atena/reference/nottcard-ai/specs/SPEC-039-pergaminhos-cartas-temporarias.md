---
id: "SPEC-039"
type: "spec"
title: "Pergaminhos: cartas temporárias ganhas em combate"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-028-slime-corrosivo-pv-dos-inimigos-e-palavra-curativa]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-033-save-em-disco]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
  - "[[SPEC-037-grupo-mais-de-um-personagem-em-cena]]"
sources:
  - "Responsável, 2026-09-19: cada combate finalizado entrega uma carta temporária; efeitos de pergaminhos de D&D; escolha de 1 entre 3; as cartas passam de missão e de arco e só se perdem ao perder; usar um pergaminho gasta uma Ação e não atrapalha a Corrente; teto inicial de 3; pergaminho de magia de Ação Bônus gasta a Ação Bônus"
  - "Responsável, 2026-09-19 (alteração): os pergaminhos entram na Corrente de Classe e também a quebram, como qualquer carta"
---

# Pergaminhos: cartas temporárias ganhas em combate


## 1. Ideia

Cada combate vencido oferece **3 pergaminhos** e o jogador escolhe **1**, que entra no baralho. É uma carta de
**uso único**, com um efeito de magia de D&D. O estoque de pergaminhos **continua de tentativa em tentativa, de
missão em missão e de arco em arco**, e só se perde ao **perder**.

## 2. Ciclo de vida

- **Ganha:** ao vencer cada combate, **incluindo o do chefe** (a carta é escolhida na tela de resultado/Interlúdio
  depois do chefe, e vale para a missão seguinte).
- **Usa:** o pergaminho usado é **consumido para sempre** (sai do estoque). Diferente do uso único da Poção, ele
  **não volta** na próxima tentativa.
- **Não usou:** ao fim do combate, o pergaminho não usado volta ao estoque.
- **Perde tudo:** ao **ser derrotado** e ao **desistir**. Desistir também perde, senão seria uma forma de fugir
  da perda quando a derrota é certa.
- **Não perde:** vencer, fechar o jogo (o estoque vai para o save) e trocar de missão.
- **"Novo jogo"** apaga o estoque junto do progresso.
- O estoque é **por personagem**, coerente com o progresso (SPEC-023) e com o baralho próprio de cada um
  (SPEC-037).
- A tela de resultado lista os pergaminhos **perdidos** numa derrota ou desistência.

## 3. Teto do estoque

Como o estoque passa de missão em missão, sem limite ele incharia o baralho. **Teto inicial de 3 pergaminhos**
(constante única `SCROLL_CAP`, para poder subir depois sem mexer nas regras). Com o estoque cheio, a escolha de
1 entre 3 ganha a opção de **trocar por um já guardado** ou de **recusar**. No M1, quem não usar nenhum chega
ao Corredor com o estoque cheio, o que empurra o jogador a usá-los.

## 4. Escolha da recompensa

- A tela **"Escolha 1 pergaminho"** aparece ao vencer o combate, antes de voltar ao mapa. Mostra 3 cartas com o
  efeito e o grau.
- As 3 vêm do **grau da sala**, sem repetir na mesma oferta. Repetidos no estoque são permitidos.
- O **grau é dado da sala** (`Room.reward_tier`), não código: Cais e slime opcional = I; Sala de livros = II;
  Corredor = III; chefe = III.
- A escolha não pode ser pulada (recusar só quando o estoque está cheio).

## 5. Regras das cartas (todos os pergaminhos)

- **Gastam a mesma ação da magia que representam** (regra do responsável): a maioria custa uma **Ação**; as
  magias que são **Ação Bônus** gastam a **Ação Bônus** quando usadas em pergaminho. A coluna "Ação" do
  catálogo diz qual. O tipo de ação é dado do pergaminho, não regra de código.
- **Nenhum é Reação:** até o Escudo Arcano, que em D&D é Reação, custa uma **Ação** aqui e protege até o início
  do seu próximo turno.
- **Têm cor e participam da Corrente de Classe** (alteração de 2026-09-19): cada pergaminho tem a cor da sua
  magia (coluna "Cor" do catálogo). Usar um pergaminho da cor da Corrente do personagem **a estende**; de outra
  cor, **a quebra**, exatamente como uma carta comum (`counts_for_chain`). A Corrente pode, portanto,
  ser mantida ou perdida por um pergaminho.
- **Sem multiplicador e sem eficiência de atributo:** mesmo dentro da Corrente, o pergaminho **não recebe o
  multiplicador da Corrente nem o bônus de atributo** (dado fixo, para o orçamento de força do catálogo não
  explodir). Só o streak conta.
- **Dano fixo e sem teste:** os de dano **nunca erram** e **nunca causam crítico**. Como nunca erram, nunca
  quebram a Corrente por erro (SPEC-025).
- Etiquetas na carta: **"PERGAMINHO"** e **"USO ÚNICO"** (SPEC-026).
- Entram no baralho **no início de cada combate** (embaralhados) e valem na mão como qualquer carta. Mão máxima
  segue em 5 (SPEC-020).

## 6. Catálogo (14 pergaminhos)

A coluna "Ação" segue a magia em D&D. A coluna "Cor" define como o pergaminho se comporta na Corrente: Azul
(suporte), Amarelo (dano mágico) ou Roxo (universal). As duas linhas marcadas **(novo)** são as magias de Ação
Bônus que acrescentei para o catálogo usar a regra; podem sair se você preferir só as de Ação.

| Grau | Pergaminho (D&D) | Ação | Cor | Efeito | Custo de implementação |
|---|---|---|---|---|---|
| I | Curar Ferimentos | Ação | Azul | cura 2d6 | reusa cura |
| I | Palavra Curativa **(novo)** | Bônus | Azul | cura 2d4 | reusa cura |
| I | Mísseis Mágicos | Ação | Amarelo | 3d4 em 1 alvo, nunca erra | campo `auto_hit` |
| I | Escudo Arcano | Ação | Azul | o primeiro ataque contra você é anulado até o início do seu próximo turno | efeito novo de proteção |
| I | Escudo da Fé **(novo)** | Bônus | Azul | +2 CA até o fim do combate | bônus temporário de CA |
| I | Bênção | Ação | Roxo | +2 no acerto das suas cartas até o fim do combate | contador novo |
| II | Restauração Menor | Ação | Azul | remove a CA corroída (SPEC-028) e o atordoamento | limpar `ca_penalty` |
| II | Ajuda | Ação | Azul | cura 5 e +5 PV máximo até o fim da missão | altera `max_hp` |
| II | Mãos Flamejantes | Ação | Amarelo | 2d6 de fogo em área | reusa ataque em área |
| II | Imobilizar Pessoa | Ação | Roxo | o alvo perde os próximos 2 ataques, sem teste | variante do Atordoar |
| III | Bola de Fogo | Ação | Amarelo | 3d6 de fogo em área | reusa ataque em área |
| III | Aceleração | Ação | Roxo | +1 Ação extra neste turno e +1 no próximo | variante do Surto de Ação |
| III | Proteção contra a Morte | Ação | Azul | ao cair a 0 PV neste combate, fica com 1 PV | reusa `last_stand` |
| III | Curar Ferimentos Maior | Ação | Azul | cura 3d4 | reusa cura |

Cada grau tem pelo menos 4 opções, então a oferta de 3 varia. Valores iniciais, **a ajustar no playtest**. Os
nomes "Pergaminho de Bola de Fogo" e "Pergaminho de Palavra Curativa" são próprios porque essas cartas já
existem no jogo.

## 7. Dados e arquitetura

- `game/core/scrolls.py` (sem pygame): `ScrollDef` declarativo (id, nome, grau, efeito), o catálogo, a oferta
  (`offer(tier, rng)`), o estoque (`ScrollStock`: `add`, `consume`, `clear`, teto) e a conversão em `Card`.
- `Card` ganha `scroll: bool` e os campos novos dos efeitos acima. A cor da carta é a da magia (Azul, Amarelo ou Roxo), então a Corrente as trata como qualquer carta; só o multiplicador e o bônus de atributo ficam de fora.
- `SaveState.scrolls: dict[personagem, list[id]]` (SPEC-033).
- `Room.reward_tier`. `Player` monta o baralho com o estoque no início de cada combate; usar o pergaminho o
  marca como consumido no fim do combate.
- UI: `ScrollRewardScreen` (escolha 1 de 3); a mão marca o pergaminho; o resultado mostra os perdidos.
- Arte: 14 ilustrações 3:2 (`ART-PROMPTS-004`), com o retângulo com nome como fallback.

## Fora de escopo

Comprar pergaminhos na loja (a loja da SPEC-035 vende só layouts); pergaminhos de Reação; efeitos que dependem
de posicionamento; o catálogo de pergaminhos descobertos (pode entrar na `SPEC-026` depois).

## Critérios de aceite

- [x] Vencer um combate oferece 3 pergaminhos do grau da sala e o jogador escolhe 1.
- [x] O pergaminho usado é consumido para sempre; o não usado volta ao estoque.
- [x] Derrota e desistência limpam o estoque e o resultado lista o que foi perdido; vitória e fechar o jogo não.
- [x] Usar um pergaminho gasta a ação da magia (Ação, ou Ação Bônus nas magias de Ação Bônus), estende a Corrente se
  for da cor dela e a quebra se for de outra, sem receber multiplicador nem bônus de atributo.
- [x] Os de dano nunca erram e nunca causam crítico; nenhum pergaminho recebe bônus de atributo nem multiplicador.
- [x] O teto de 3 (`SCROLL_CAP`) vale e a troca ou recusa funcionam com o estoque cheio.
- [x] O estoque é por personagem, persiste no save (SPEC-033) e "Novo jogo" o apaga.
- [x] `core` sem pygame; testes de oferta, estoque, consumo, perda e Corrente (`tests/core/test_scrolls.py`, `tests/ui/test_scrolls_flow.py`).
- [ ] Playtest dos números e das ofertas por grau.

Notas de implementação:
- A oferta usa a mesma tela "Escolha 1 de 3" do pacote e do chefe, com a oferta guardada no save até a escolha (`pending_offer` com `for` e `chosen`, então fechar o jogo no meio, inclusive na troca do estoque cheio, retoma no mesmo ponto).
- Num grupo (SPEC-037) o pergaminho ganho vai para quem tem menos guardados (o 1º, no empate).
- O chefe dá a carta rara (SPEC-041) e depois o pergaminho de grau III, antes da HQ e do resultado.
- Estoque cheio: escolher o novo abre "qual pergaminho sai?" com o botão "Recusar o novo".
- O estoque do save entra no baralho no início de cada combate (as pilhas são limpas de pergaminhos antes, para não duplicar); usar o pergaminho o tira do save na hora.
- Efeitos de estado (Escudo Arcano, Escudo da Fé, Bênção, Proteção contra a Morte) acabam com o combate; o Escudo Arcano também acaba no início do próximo turno; a Ajuda dura a missão. A Restauração Menor limpa só a CA corroída (SPEC-028); o "atordoamento" da tabela não tem efeito hoje porque o jogador não pode ser atordoado. A Aceleração soma 1 Ação neste turno e 1 no próximo.
- Etiquetas "PERGAMINHO" e "USO ÚNICO" na arte; o título da carta perde o prefixo "Pergaminho de".
