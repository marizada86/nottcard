---
id: "SPEC-024"
type: "spec"
title: "Cartas por nível (2 a 4) e passiva do nível 5, por personagem"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SIS-005-progressao-de-nivel-maestria]]"
  - "[[SPEC-023-progresso-save-e-resultado-da-tentativa]]"
  - "[[SPEC-020-mao-cheia-descarte-por-escolha-e-acao-compra-2]]"
  - "[[SPEC-021-rebalanceamento-chama-nevoa-e-golpe-contundente]]"
sources:
  - "SIS-005 (canon) Propostas 2 e 3, aprovadas em 2026-09-19"
  - "vault/02_Personagens/Durvall.md e Maelor.md (fichas de mestre)"
---

# Cartas por nível e passiva do nível 5

Depende da SPEC-023 (`Progress`). Os números são valores iniciais de playtest.
**Nenhum texto de carta usa segredo de mestre** (Ghaunadaur/receptáculo e a traição do Durvall;
a família Vellen do Maelor).

## Regras

### 1. Recompensas (dado declarativo em `CharacterDef`)
`level_rewards: dict[int, LevelReward]`, com `LevelReward(cards, passive, attr_bonus)`.
Cada carta entra no baralho **na próxima run** (o baralho cresce 3 cartas até o nível 4:
Durvall 16→19, Maelor 12→15). `build_deck` passa a receber o nível.

### 2. Durvall
| Nível | Carta | Regra inicial |
|---|---|---|
| 2 | **Romper Armadura** (S7) | Vermelho, Ação, 1d6, acerto por Força. Ao acertar, a **CA do alvo cai 2 até o fim do combate** (acumula até −4). 1 cópia. |
| 3 | **Reação Instintiva** (S4) | Vermelho, **Reação** a ataque físico: reduz o dano em 1d4 e causa 1d4 ao atacante. Complementa o Aparar. 1 cópia. |
| 4 | **Amarrar e Saltar** (S5) | Roxo, Ação Bônus, **HC** (1 uso por combate): o alvo é **atordoado** (perde o próximo ataque) e a próxima carta que conta na Corrente conta como se `streak` fosse +1 (máx. 3). |
| 5 | **Em Casa na Névoa** (S1, S7) | Passiva: **imune ao Eco da Névoa** (o d6 da sala 1) e a futuros efeitos de névoa. **+2 Constituição** (12→14). |

### 3. Maelor
| Nível | Carta | Regra inicial |
|---|---|---|
| 2 | **Localizar Criatura** | Azul, Ação Bônus: revela nome e dado do **próximo ataque** do alvo (`Enemy.peek_action()`, sem avançar o contador) e dá **+2 no acerto** do próximo ataque do Maelor contra ele. 1 cópia. |
| 3 | **Comunhão com Sendrinah** (S23) | Azul, Ação Bônus, **HC**: mostra as **3 cartas do topo** do baralho; escolhe 1 para a mão e devolve as outras ao fundo. Usa o seletor da SPEC-020. |
| 4 | **Luz Mais Pura** (S14) | Azul, Ação Bônus, **uso único**: cura **2d6 + Constituição** (multiplicador da Corrente sobre o dado, como as outras curas). *A ideia inicial do SIS-005 de "remover condição" foi descartada: o jogador não tem condições.* |
| 5 | **Proteção de Sendrinah** (S13) | Passiva: **1 vez por combate**, ao receber dano que levaria o PV a 0 ou menos, o PV fica em **1**. **+1 Inteligência** (13→14, CAM 11→12). |

### 4. Atributos e passivas no `core`
- `effective_attributes(character, level)` soma o `attr_bonus` do nível 5; **teto 18**. `CharacterDef`
  continua imutável (o bônus vem de `Progress`).
- Passivas como ganchos declarativos em `CharacterDef`, no padrão de `chain_elements`:
  `mist_immune` (pula o `eco_da_nevoa`) e `last_stand` (aplicado onde o dano ao jogador é aplicado).
- A tela de subida (SPEC-023) mostra a carta nova, ou a passiva e o atributo do nível 5.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | 6 cartas novas e campos que precisarem (`peek`, `reveals_top`, `ca_penalty`, `reacts_damage_back`); `build_deck(level)`. |
| `game/core/characters.py` | `level_rewards`, ganchos `mist_immune` e `last_stand`. |
| `game/core/combat.py`, `enemies.py`, `rooms.py` | Regras das cartas; `Enemy.ca_penalty`, `peek_action`; o `eco_da_nevoa` foi substituído na SPEC-031 por um teste de d20 com +2 para `mist_immune`. |
| `game/app.py`, `game/ui/` | Seletor de 3 cartas (Comunhão); revelação do ataque (Localizar); efeitos e mensagens. |
| Arte | 6 cartas novas (prompts a gerar, mesmo formato das cartas, 480×320 final). Sem arte, cai no retângulo de fallback. |
| Testes | Baralho por nível (16/19 e 12/15); cada carta; passiva do nível 5 (imunidade e "última chance" uma vez por combate); atributo com teto 18; `Progress` libera as cartas certas. |

## Fora do escopo

Arte final das 6 cartas (gerar depois, ver `ART-PROMPTS`), outros personagens, mais de 5 níveis,
divisão de XP em grupo.

## Critérios de aceite

- [x] Cada nível libera a carta certa para o personagem certo e o baralho cresce na run seguinte.
- [x] No nível 5, Durvall tem Constituição 14 e a imunidade ao Eco; Maelor tem Inteligência 14 e a "última chance".
- [x] A tela de resultado mostra a recompensa da subida.
- [ ] Números registrados em EVID após o playtest do nível 5.
- [x] Testes passam.

## Ordem de execução

1. Estrutura (`level_rewards`, `build_deck(level)`). 2. Cartas do Durvall. 3. Cartas do Maelor (Comunhão depende da SPEC-020). 4. Passivas e atributos do nível 5. 5. Prompts de arte. 6. Playtest.
