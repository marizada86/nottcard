---
id: "SPEC-012"
type: "spec"
title: "Maelor Menezes (Clérigo da Luz): passiva de fogo, Corrente em todos os efeitos, cartas e HC"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[PERS-maelor]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-011-personagem-como-dado-characterdef]]"
sources:
  - "Decisões do responsável em 2026-09-19 (cartas novas, Corrente em todos os efeitos, HC próprias) e respostas às pendências na mesma data"
  - "PERS-maelor-ficha-jogavel (Azul/Suporte, FOR 10 INT 13 CON 16 CAR 12)"
---

# Maelor Menezes (Clérigo da Luz)

Depende da SPEC-011. Contraste com o Durvall: cor da classe Azul (Suporte), Corrente que
**amplia tudo** (dano e cura) em vez de somar dados psiônicos, HC próprias, ataques mágicos.

## Decisões do responsável (2026-09-19)

1. **Elemento nas cartas:** `Card.element` novo. Cartas de **fogo** e **radiante** entram
   na passiva do Maelor.
2. **Passiva:** a Corrente de Classe do Maelor continua com cartas **Azuis** *e* com cartas
   de **elemento fogo**. Cartas de fogo são **Amarelas** (fora da cor Azul), então causam
   **50% de dano** (regra de compatibilidade mantida); o ganho é poder **combar** fogo com
   magias de suporte sem quebrar a Corrente.
3. **Corrente vale para todos os efeitos:** o multiplicador 2x/3x/4x aumenta o dano das
   cartas de fogo **e** a cura. Não há dados extras (isso é do Durvall).
4. **HC não são compartilhadas:** Segundo Fôlego e Surto de Ação **não** entram no baralho
   do Maelor.
5. **Modificador de acerto:** magias usam **INT** por padrão; as **cartas de fogo do Maelor
   usam CON** (override da passiva dele). Mira sempre na CAM do alvo.

## Cartas novas

| Carta | Cor | Tipo | Efeito | Elemento | Custo |
|---|---|---|---|---|---|
| **Chama Sagrada** | Amarelo | ataque | 1d6 (mesmo dado da Chama Menor; a diferença é o elemento extra) | fogo + radiante | Ação |
| **Bola de Fogo** (HC) | Amarelo | ataque em **área** | 3d6 em todos os inimigos vivos, **1 uso por combate** | fogo | Ação |
| **Palavra Curativa** (HC) | Azul | cura | 1d4 + mod. de CON | — | Ação Bônus |
| **Toque Curativo** (HC) | Azul | cura | 1d6 + mod. de CON | — | Ação |
| **Golpe Contundente** | Vermelho | ataque | 1d4 (Força escala o dano) | — | Ação |
| **Atordoar** (HC) | Azul | atordoamento | o alvo perde o próximo ataque (SPEC-015) | — | Ação |

As quatro HC seguem a SPEC-009 (1 cópia, saem do baralho até o fim do combate, voltam no
próximo, etiqueta "· HC").

## Baralho inicial (proposta a ajustar em playtest — 13 cartas)

| Carta | Qtd | Origem |
|---|---|---|
| Chama Sagrada | 4 | nova |
| Chama Menor (Amarelo, fogo) | 2 | existente (ganha `element="fogo"`) |
| Toque Curativo (HC) | 1 | nova (1d6+CON, Ação) |
| Golpe Contundente | 1 | nova (2026-09-19) |
| Atordoar (HC) | 1 | nova (2026-09-19, SPEC-015) |
| Névoa Fria (Azul, controle) | 1 | existente |
| Bola de Fogo (HC) | 1 | nova |
| Palavra Curativa (HC) | 1 | nova |
| Poção de Cura | 1 | existente |

Como só a Névoa Fria, o Toque e a Palavra são Azuis, a Corrente do Maelor depende de
alternar Azul e fogo na ordem certa; carta Roxa (Poção) ou Amarela sem fogo a quebra.

**Ajuste de balanceamento (2026-09-19):** toda cura do Maelor passa a ser **1 uso por combate**
(HC). O Toque Curativo, antes 3 cópias comuns, virou 1 cópia HC; o baralho caiu para 11 cartas e
foi completado a **13** com Golpe Contundente e Atordoar (SPEC-015). A Poção de Cura já
é de uso único por tentativa.

## Corrente aplicada aos efeitos

- **Ataque de fogo:** como hoje, `ceil(dado × mult × compat × (1 + bônus_de_cor))`, com
  `compat = 0.5` (Amarelo fora da classe). Sem dados extras.
- **Cura:** `dado × mult`, **depois** soma o modificador de CON (não multiplicado).
  Ex.: Palavra Curativa a 3x com CON 16: `1d4 × 3 + 3`.
- **Controle (Névoa Fria):** a redução também é multiplicada pela Corrente.

## Bola de Fogo em área

- **Um d20 de acerto por inimigo vivo**, cada um contra a própria CAM, com o modificador
  de CON (regra 5). Um crítico vale só para aquele alvo (dobra os dados de dano dele).
- **Dano por alvo:** rola os 3d6 **uma vez por inimigo acertado**, cada um com
  `ceil(dado × mult × 0.5 × (1 + bônus_de_cor))`.
- Conta como **uma** carta jogada para a Corrente (avança 1 vez, não uma por alvo).
- Depende do combate com vários inimigos, que é a **SPEC-014**.

## Seleção de personagem

Tela própria entre Menu e Exploração (`Screen`): um cartão por personagem com retrato
(fallback: retângulo com nome), classe, atributos e passiva. Lista vem de `CHARACTERS`
(SPEC-011), então os próximos personagens aparecem sem mexer na tela. Por ora: Durvall e
Maelor, os dois na mesma M1 (com a sala nova da SPEC-014).

## PV e balanceamento

- **PV inicial: 20**, igual ao Durvall (decisão de 2026-09-19); `CharacterDef.max_hp`
  guarda o valor, então dá para mudar por personagem depois do playtest.
- A cura do Maelor (Toque, Palavra, Corrente) é o que deve compensar o dano baixo.
  Ajuste fino fica para o playtest (`EVID-004`), não para esta spec.

## Pendências

1. Arte (retratos, cartas novas) segue a SIS-004; o Maelor tem armadura dourada/branca e
   chama azul-branca na mão. Sem asset, o jogo usa o retângulo com nome.
2. Nome definitivo do tipo HC segue em aberto (SPEC-009).

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | `Card.element`, `Card.area`; cartas novas; `MAELOR.build_deck`. **Mudança de core.** |
| `game/core/characters.py` | `MAELOR` com passiva de fogo e override de modificador de acerto (CON). |
| `game/core/combat.py` | Multiplicador da Corrente aplicado a cura e controle; modificador de acerto vindo da passiva; ataque em área. |
| `game/ui/cards_widget.py` | Etiqueta de elemento (SIS-002) e "· HC". |
| `game/app.py` + `game/ui/` | Tela de seleção de personagem entre Menu e Exploração. |
| Testes | Fogo mantém a Corrente; cura e controle multiplicados; acerto de fogo usa CON e o resto INT; HC do Maelor 1x/combate e volta; Segundo Fôlego/Surto ausentes do baralho dele. |

## Fora do escopo

Missões além da M1; Sylas, Kayron e os demais; balanceamento fino (playtest).
