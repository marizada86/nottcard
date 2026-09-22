---
id: "SPEC-038"
type: "spec"
title: "Sylas Malafa (Clérigo das Sombras): Cópia Sombria, cartas de sombra/necrótico/psiônico e progressão"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[PERS-sylas-malafaia]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SIS-005-progressao-de-nivel-maestria]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-011-personagem-como-dado-characterdef]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
sources:
  - "PERS-sylas-malafaia-ficha-jogavel (Amarelo/Dano Mágico, Clérigo das Sombras, FOR 10 INT 16 CON 14 CAR 12; passiva da cópia aprovada em 2026-09-14)"
  - "Lore pública do vault: devoto de Mask, ilusão, Dominar Pessoa, energia psiônica, dano necrótico, colar de visão verdadeira, rituais contra a névoa"
  - "Referência de habilidades de clérigo das sombras (Shadow/Twilight Domain, D&D 5e): dano psíquico/necrótico, escuridão, visão no escuro, santuário do crepúsculo"
---

# Sylas Malafa (Clérigo das Sombras)

> **Aprovada em 2026-09-19** (responsável do projeto; pendências resolvidas pelas recomendações da spec). Todos os números são
> valores iniciais de playtest. **Nenhum texto de carta usa cânone reservado ao mestre**: a infância
> de Sylas, o ritual de transformação e a ligação com Ghaunadaur ficam de fora (ver "Notas de designer"
> da ficha). Em qualquer texto voltado ao jogador, o nome é **Sylas Malafa**.

Contraste com os outros dois: cor da classe **Amarelo** (Dano Mágico), como as cartas de fogo do
Maelor, mas o que o distingue é a **Cópia Sombria** (uma segunda barra de PV que absorve dano) e um
kit de **sombra**: ataques necróticos e psiônicos, controle por escuridão/cegueira, ilusão e
drenagem de vida.

## Referência de design: o que um Clérigo das Sombras faz

Habilidades tradicionais do arquétipo e como viram carta:

| Habilidade de referência | Vira |
|---|---|
| Ataque psíquico/necrótico (Mordida das Sombras, Infligir Ferimentos) | **Raio Sombrio**, **Farpa Psiônica** |
| Lâmina de energia sombria (Lâmina de Sombra) | **Lâmina de Sombra** (ignora CAM) |
| Dreno de vida (Toque Vampírico) | **Toque Vampírico** (HC) |
| Escuridão / Cegueira | **Escuridão** (área), **Cegueira** (alvo único) |
| Imagem Espelhada / Manto de Sombras | **Imagem Espelhada** (ligada à Cópia), **Passo Sombrio** |
| Dominar Pessoa (citada na lore, Sessão 16) | **Dominar Pessoa** (nível 4) |
| Visão no escuro / colar de visão verdadeira | **Visão Verdadeira** (nível 2) |
| Raio Enfraquecedor | **Raio Enfraquecedor** (nível 3) |

## Decisões já aprovadas (ficha, 2026-09-14/15)

1. Classe **Clérigo das Sombras**, raça **Tiefling**, cor de classe **Amarelo**.
2. Atributos **FOR 10 · INT 16 · CON 14 · CAR 12** → CA 10, **CAM 13**; bônus de cor: Amarelo +60%,
   Azul +40%, Roxo +20%, Vermelho +0%.
3. **Passiva:** Sylas tem uma cópia de si com metade da vida; as Correntes de Classe aumentam a vida
   da cópia; todo ataque a Sylas vai primeiro para a cópia; ataques em área acertam os dois.

## Passiva: Cópia Sombria (`passive_name`)

Texto de cartão: *"Uma cópia sombria de Sylas, com metade da vida, recebe os ataques primeiro. A Corrente
de Classe a fortalece."* Valores propostos (as pontas soltas estão em "Pendências"):

- **PV da cópia:** metade do PV máximo do Sylas (**10** com 20). Nasce **cheia** no início de cada combate.
- **Dano recebido:** todo ataque de inimigo a um alvo único vai **primeiro à cópia**. Se o dano passa dos
  PV dela, **o excedente transborda** para o Sylas (a cópia não vira parede de 1 PV contra um golpe de 10).
- **Ataque em área** (Onda, Bola, ataques em área de inimigos): acerta a cópia **e** o Sylas, cada um
  levando o dano cheio, sem transbordo entre eles.
- **Corrente:** cada carta que **continua** a Corrente (atinge 2x, 3x ou 4x) cura a cópia em **+2 / +3 /
  +4 PV** (o valor do multiplicador atingido; teto: PV máximo da cópia). Quebrar a Corrente não fere a cópia.
- **Queda:** a 0 PV a cópia some até o fim do combate. Só **Imagem Espelhada** a recria. O Sylas a 0 PV
  é derrota, com ou sem cópia viva.
- A cópia **não age** na v1 (não ataca, não conta como alvo de carta, não tem CA própria: usa a do Sylas).
- **Corrente e elemento:** cartas do elemento `sombra` também ativam a Corrente (mesmo padrão de
  `chain_elements` do Maelor com fogo). Cartas de sombra fora do Amarelo causam 50% de dano (compat);
  o ganho é combar controle e ilusão com ataques sem quebrar a Corrente.

## Modificador de acerto

Cartas Amarelas usam **INT**, que já é o padrão de `hit_attribute`; **sem override** de
`hit_attr_by_element` para o Sylas. Mira sempre na CAM do alvo.

## Cartas do baralho inicial (13)

| Carta | Qtd | Cor | Tipo | Efeito | Elementos | Custo |
|---|---|---|---|---|---|---|
| **Raio Sombrio** | 3 | Amarelo | ataque | 1d6, dano necrótico | necrótico, sombra | Ação |
| **Farpa Psiônica** | 2 | Amarelo | ataque | 1d4, dano psiônico | psiônico | Ação Bônus |
| **Lâmina de Sombra** | 2 | Amarelo | ataque | 1d8; **ignora 1 ponto de CAM** do alvo | necrótico, sombra | Ação |
| **Toque Vampírico** (HC) | 1 | Amarelo | ataque | 1d6 necrótico; o Sylas **cura metade do dano causado** (arredonda para cima) | necrótico, sombra | Ação |
| **Escuridão** | 1 | Azul | controle, **área** | 1d4: reduz o próximo ataque de **todos** os inimigos | sombra | Ação |
| **Cegueira** | 1 | Azul | controle, alvo único | 1d6: reduz o próximo ataque do alvo | sombra | Ação |
| **Imagem Espelhada** (HC) | 1 | Roxo | cura da cópia | cura a **cópia** em 1d6 + Carisma; se ela caiu, **a recria** com esse valor de PV | sombra | Ação Bônus |
| **Passo Sombrio** (HC) | 1 | Roxo | reação | reação a ataque **físico**: **anula** o ataque | sombra | Reação |
| **Poção de Cura** | 1 | Roxo | cura | uso único: 1d4 + Constituição (a mesma dos outros) | — | Ação Bônus |

Total: 3+2+2+1+1+1+1+1+1 = **13**. Cores: 8 Amarelas (Corrente), 2 Azuis e 2 Roxas de sombra (mantêm a
Corrente), e a Poção Roxa, que a quebra, como nos outros dois baralhos.

Notas de balanceamento:
- As quatro HC (Toque Vampírico, Imagem Espelhada, Passo Sombrio; e, por nível, Dominar Pessoa) seguem a
  SPEC-009: 1 cópia, saem do baralho até o fim do combate, voltam no próximo, etiqueta "· HC".
- **Segundo Fôlego e Surto de Ação** (do Durvall) **não** entram no baralho dele.
- O Sylas tem dano bruto parecido com o do Maelor, mas **PV efetivo maior** (cópia) e **cura menor**
  (só o Toque Vampírico, a Poção e a Imagem Espelhada, que cura a cópia e não ele).
- O Toque Vampírico cura o próprio Sylas, **não** a cópia.

## Cartas por nível (uma cópia cada, entram na run seguinte; SPEC-024)

| Nível | Carta | Cor / custo | Regra inicial |
|---|---|---|---|
| 2 | **Visão Verdadeira** (colar) | Amarelo, Ação Bônus | Tipo `localizar`: revela nome e dado do próximo ataque do alvo (`peek_action`) e dá **+3 no acerto** do próximo ataque do Sylas contra ele. Amarelo mantém a Corrente. |
| 3 | **Raio Enfraquecedor** | Amarelo, Ação | Tipo `enfraquecer`: **CA e CAM do alvo −2** até o fim do combate (acumula como Luz Reveladora). Amarelo mantém a Corrente. |
| 4 | **Dominar Pessoa** (HC) | Roxo, Ação | Tipo `atordoamento`: o alvo **perde o próximo ataque**, mesma regra de Atordoar (SPEC-015) e **sombra** mantém a Corrente. Lore: Sessão 16, pública. |
| 5 | **Passiva: Sombra Persistente** | — | **1 vez por combate**, quando a Cópia Sombria cai, ela **volta com 5 PV** no início do turno seguinte do jogador (gancho `shadow_return`). **+2 Constituição** (14→16, teto 18). |

O baralho cresce 13→16 até o nível 4, como Durvall (16→19) e Maelor (12→15).

## Regras novas no `core`

- **Elementos** novos em `Card.elements`: `necrótico`, `psiônico`, `sombra` (a UI mostra a etiqueta pela
  SIS-002). `sombra` entra em `chain_elements` do Sylas.
- **Campos novos em `Card`** (só o que as cartas acima precisam):
  - `drain_frac: float`: fração do dano causado que cura o Sylas (Toque Vampírico = 0.5).
  - `heals_clone: bool`: a cura vai para a Cópia, e a recria se ela caiu (Imagem Espelhada).
  - `negates_hit: bool`: a Reação anula o ataque em vez de só reduzi-lo (Passo Sombrio).
- **Estado do jogador:** `clone_hp` e `clone_max_hp` (None em quem não tem a passiva), mais
  `shadow_return_used` (o gancho do nível 5), no padrão de `last_stand_used`.
- **Onde aplicar o dano:** em `combat.py`, onde hoje `player.hp -= damage` (perto da linha 437). Passa a
  passar por um `apply_damage_to_player(player, damage, area)`, único ponto que decide cópia, transbordo,
  ganchos (`last_stand`, `shadow_return`) e o retorno para a UI (o `EnemyAttackResult` ganha `clone_damage`
  e `clone_fell`).
- **Corrente:** no ponto onde o multiplicador atinge 2x+, o `core` chama `player.grow_clone(mult)`.

## Interação com SPEC-037 (grupo)

A Cópia é **por personagem** e **não** é um alvo separado do grupo: o inimigo mira um personagem sorteado (SPEC-086 §4)
e o dano passa pela Cópia do escolhido. Na SPEC-037, a Cópia Sombria fica junto do retrato do Sylas.

## Interface e arte

- `game/ui/`: segunda barra de PV (a da cópia) ao lado do retrato, sombra do Sylas translúcida atrás dele,
  dano flutuante na cópia, aviso "Cópia caiu!" e cor da passiva em `passive_card.py` (roxo-índigo).
- **Texto do tutorial** (`tutorial_content.py`): parágrafo do Sylas com PV, baralho e a Cópia.
- **Seleção de personagem** entra pelo `CHARACTERS` (SPEC-011), sem mexer na tela.
- **Arte**, com fallback de retângulo com nome enquanto não existir: retrato `assets/portraits/sylas.png`
  (a partir de `assets/concepts/characters/sylas_malafa_fullbody.png`), emblema `assets/hud/passiva_sylas.png`,
  ícone da cópia `assets/hud/copia_icon.png`, 8 cartas novas do baralho (a Poção reaproveita a existente) +
  3 de nível. Prompts em `.atena/generated/ART-PROMPTS-007-sylas-malafa-2026-09-19.md`, seguindo `SIS-004`.
  Identificador de asset = `asset_id` explícito da carta (o `slugify` não trata acentos: `escuridao`,
  `farpa_psionica`, `lamina_de_sombra`, `toque_vampirico`, `imagem_espelhada`, `passo_sombrio`, `raio_sombrio`,
  `cegueira`, `visao_verdadeira`, `raio_enfraquecedor`, `dominar_pessoa`).

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/attributes.py` | `SYLAS_ATTRIBUTES`. |
| `game/core/cards.py` | 12 cartas novas, `build_sylas_deck`, campos `drain_frac`, `heals_clone`, `negates_hit`. **Mudança de core.** |
| `game/core/state.py` | `clone_hp`, `clone_max_hp`, `shadow_return_used`, `grow_clone`. |
| `game/core/combat.py` | Dano ao jogador via cópia, transbordo, área; dreno; cura da cópia; reação que anula. |
| `game/core/characters.py` | `SYLAS` (com `chain_elements=("sombra",)`, `level_rewards` e gancho `shadow_return`), registro em `CHARACTERS`. |
| `game/ui/` | Barra e sprite da cópia, dano flutuante, etiquetas de elemento, passiva, tutorial. |
| Testes | Ver abaixo. |

### Testes

- Baralho de 13 (e 16 no nível 4), sem Segundo Fôlego/Surto; HC saem e voltam no combate seguinte.
- Cópia nasce com metade do PV e cheia em cada combate.
- Ataque único: cópia primeiro, transbordo pro Sylas; ataque em área acerta os dois cheios.
- Corrente 2x/3x/4x cura a cópia +2/+3/+4 sem passar do teto; quebrar não fere.
- Imagem Espelhada cura a cópia e a recria caída; Toque Vampírico cura o Sylas em metade do dano.
- Passo Sombrio anula ataque físico e não reage a mágico; Cegueira e Escuridão reduzem o próximo ataque.
- Cartas de `sombra` fora do Amarelo mantêm a Corrente com 50% de dano; Poção a quebra.
- Nível 5: `shadow_return` 1 vez por combate; CON 16, teto 18.
- Jogador sem a passiva (Durvall, Maelor) continua idêntico (`clone_hp is None`).

## Pendências (decisões do responsável)

1. **Transbordo do dano:** recomendo **com transbordo** (proposto acima). Sem transbordo a cópia absorveria
   qualquer golpe inteiro e seria forte demais.
2. **Corrente e a cópia:** "aumentam a vida" foi lido como **curar até o teto**. Alternativa: a Corrente
   **eleva o teto** da cópia (+1 PV máx por multiplicador, só naquela run).
3. **PV do Sylas:** 20 como os outros dois, ou menos (com a cópia ele já tem ~30 de PV efetivo)?
4. **Toque Vampírico** cura o Sylas (proposto) ou a cópia primeiro?
5. **Nível 5:** bônus de +2 Constituição (proposto, reforça o tema defensivo) ou +2 Inteligência?
6. **Passo Sombrio** anulando 100% de um golpe físico é forte para 1 uso HC; alternativa: reduzir em 2d6.
7. A cópia poderia **agir** (atacar com metade do dano) em uma v2, fora desta spec.

## Fora do escopo

Missões além da M1; outros personagens; loja/itens (colar de visão verdadeira como item equipável fica
para a SPEC-036); a cópia agindo por conta própria; balanceamento fino (playtest).

## Critérios de aceite

- [x] Sylas aparece na seleção de personagem, com passiva, PV e baralho de 13 cartas.
- [x] A Cópia Sombria absorve, transborda e recebe a Corrente como especificado, sem alterar Durvall e Maelor.
- [x] As 13 cartas do baralho (8 novas) e as 3 de nível funcionam, com etiquetas de elemento e "· HC".
- [x] Nível 5 libera Sombra Persistente e o bônus de atributo.
- [x] `core` sem pygame; todos os testes existentes continuam passando.
- [ ] Números registrados em EVID após playtest.

## Ordem de execução

1. Atributos e `SYLAS` sem a passiva (só as cartas de dano). 2. Cópia Sombria no `combat.py` e no estado.
3. Cartas de controle, ilusão e reação. 4. Cartas por nível e nível 5. 5. UI da cópia. 6. Prompts de arte. 7. Playtest.

## Nota de 2026-09-20 (SPEC-044, H10)

Playtest do Higor: a Corrente do Sylas vivia em x4 e a Cópia se curava sozinha. Agora só cartas **de dano** de sombra (`kind ataque`)
mantêm a Corrente (`chain_element_kinds`); Escuridão, Cegueira, Imagem Espelhada e Dominar Pessoa a quebram, como qualquer carta fora
da cor. A Cópia só é curada pela Corrente ao chegar em x3 ou x4, uma vez por turno (`Player.clone_chain_healed`).
