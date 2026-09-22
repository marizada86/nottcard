---
id: "SPEC-043"
type: "spec"
title: "Cartas raras de chefe (M1) e classificação das cartas por raridade"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
revised: "2026-09-19 (Punição Divina substituída por Rajada de Golpes, aprovado pelo responsável)"
relations:
  - "[[SPEC-041-colecao-de-cartas-baralho-aleatorio-chefes-e-pacotes]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[SPEC-010-reacao-cartas-escurecidas-e-ajustes-de-hud]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
sources:
  - "Responsável, 2026-09-19: aprovado o conjunto de 6 raras inspirado em golpes de D&D (Sneak Attack, Reckless Attack, Divine Smite, Stunning Strike, Uncanny Dodge, Booming Blade)"
---

# Cartas raras de chefe (M1)

Conteúdo da `SPEC-041`: o pool que o **Guardião alado verdadeiro** oferece (3 raras, escolhe 1). Inspiradas em
golpes de D&D, com **nomes e textos próprios** (a mecânica é adaptada, o texto não é copiado).

## Regras gerais das raras

- `rarity = "rara"`. Só saem de chefe; nunca de pacote nem do baralho inicial.
- **Universais:** funcionam com qualquer personagem, sem depender de recurso próprio (Cópia Sombria, Poder
  Místico etc.). A cor decide a eficiência e a Corrente, como qualquer carta (`SIS-001`).
- **Orçamento de poder:** ~1,3 a 1,5 vezes uma incomum. Os dados abaixo são o primeiro palpite, **a calibrar no
  playtest**. Teste automático: toda rara tem raridade estritamente maior que toda carta de pacote.
- Reações usadas vão para o descarte (`SPEC-010`); as demais voltam ao baralho normalmente (não são de uso único).

## As 6 raras

| Carta | Origem (D&D) | Cor | Ação | Efeito |
|---|---|---|---|---|
| **Golpe Furtivo** | Sneak Attack | Vermelho | Ação | Ataque de **1d8**. Se o alvo estiver **atordoado, com CA/CAM reduzida ou marcado** (Localizar), causa **+2d6**. |
| **Ataque Imprudente** | Reckless Attack | Vermelho | Ação | Ataque de **2d8**. Até o fim do próximo turno inimigo, **os ataques contra você acertam sem teste** (sem crítico). |
| **Rajada de Golpes** | Flurry of Blows | Roxo | Bônus | **2d8 contundente** no alvo, sem teste de acerto. **Só pode ser usada se você acertou um ataque neste turno.** |
| **Golpe Atordoante** | Stunning Strike | Azul | Ação | **1d6** e o alvo **perde os próximos 2 ataques**, sem teste. |
| **Esquiva Sobrenatural** | Uncanny Dodge | Azul | Reação | **Reduz à metade** (arredonda para baixo) o dano de um ataque que te acertou, físico ou mágico. |
| **Lâmina Trovejante** | Booming Blade | Amarelo | Ação | Ataque de **1d8**. O alvo fica **marcado por trovão**: quando fizer o próximo ataque, **sofre 2d8** antes de agir (se morrer, o ataque não acontece). |

### Notas de cada carta

- **Golpe Furtivo:** o estado do alvo já existe no motor (atordoamento, `ca_penalty`, `marks_bonus`); o bônus
  soma como dados extras (dobram em crítico, como os demais). Sem estado, é um ataque comum de 1d8 (não
  supera o Golpe). Sinergia com Romper Armadura, Luz Reveladora, Atordoar e Localizar Criatura.
- **Ataque Imprudente:** o custo é real. O jogador não pode confiar em defesa no turno seguinte; a Esquiva
  Sobrenatural e o Aparar ainda funcionam (a Reação é sobre o dano, não sobre o teste). Campo novo `expoe` no
  jogador, que zera ao fim do turno inimigo.
- **Rajada de Golpes:** roxa, então **quebra a Corrente de quem não é Roxo** (`SPEC-005`); a troca é dano alto de
  Bônus contra perder o multiplicador, e o jogador decide. Condição nova "acertou um ataque neste turno"
  (`TurnState.hit_this_turn`). O dano é contundente (não radiante, para não colidir com o tema do Maelor e da Brook); combina com Golpe Contundente e Golpe Perfurante, que abrem o acerto.
- **Golpe Atordoante:** reusa o estado de atordoamento, mas o efeito dura 2 ataques, e não há teste
  (`stun_on_hit` deixa de rolar). Não afeta inimigos com `stun_immunity`.
- **Esquiva Sobrenatural:** abre a janela "Reagir?" para qualquer tipo de ataque, e devolve metade do dano
  ao jogador. Campo novo `halves_damage`.
- **Lâmina Trovejante:** campo novo no inimigo (`thunder_mark`), consumido no próximo ataque dele. Um ataque
  cancelado por morte não conta para o contador de habilidade especial.

## Oferta de chefe

- `boss_offer("guardiao_verdadeiro")` sorteia **3 das 6**, sem repetir na oferta. O jogador escolhe 1; a carta vai
  para a coleção e, com espaço, para o baralho ativo (`SPEC-041` §5).
- Outros chefes do arco trarão os seus pools em specs próprias.

## Classificação das cartas existentes (universais)

As cartas de **assinatura** (habilidades de classe, cartas de nível e ligadas a recurso de um personagem) **não
entram** na coleção compartilhada nem no sorteio: vêm sozinhas com o personagem (`SPEC-041` §3).

| Raridade | Cartas |
|---|---|
| **Comum** (baralho inicial e pacotes) | Golpe, Golpe Perfurante, Chama Menor, Toque Curativo, Palavra Curativa, Aparar, Poção de Cura |
| **Incomum** (só pacotes) | Névoa Fria, Contrafeitiço, Golpe Contundente, Atordoar, Luz Reveladora, Raio Enfraquecedor, Surto de Ação, Chama Sagrada, Onda Psiônica, Bola de Fogo |
| **Assinatura** (fora da coleção) | Segundo Fôlego, Romper Armadura, Reação Instintiva, Amarrar e Saltar, Localizar Criatura, Comunhão com Sendrinah, Luz Mais Pura, Asas Negras, Leitura Abissal, Visão Verdadeira, Descarga Estelar, Dominar Pessoa |

Tabela declarativa, ajustável sem código. Bola de Fogo e Onda Psiônica são incomuns, abaixo das raras.

## Fora de escopo

Raras de outros chefes; a arte das 6 cartas (prompts à parte, formato de `ART-PROMPTS-004`); as reservas de
golpes de D&D (Revide, Varredura, Ataque Ameaçador, Golpe Preciso), que podem virar incomuns depois.

## Critérios de aceite

- [x] As 6 cartas existem como dado, com `rarity = "rara"` e os efeitos da tabela.
- [x] Golpe Furtivo soma +2d6 só com alvo atordoado, enfraquecido ou marcado.
- [x] Ataque Imprudente faz os ataques inimigos acertarem sem teste até o fim do próximo turno inimigo.
- [x] Rajada de Golpes só pode ser jogada depois de um acerto no mesmo turno, e não tem teste de acerto.
- [x] Golpe Atordoante faz o alvo perder 2 ataques sem teste, salvo imunidade.
- [x] Esquiva Sobrenatural reduz o dano à metade, físico ou mágico, e a carta vai ao descarte.
- [x] Lâmina Trovejante causa 2d8 no próximo ataque do alvo, e a morte cancela esse ataque.
- [x] **Teste:** toda rara tem raridade maior que toda carta de pacote; nenhuma carta de assinatura está na coleção.
- [x] `boss_offer` devolve 3 raras distintas do pool do chefe.
- [x] `core` sem pygame; testes de cada efeito (`tests/core/test_rare_cards.py`, `tests/ui/test_rare_cards_flow.py`).
- [ ] Playtest dos números.
