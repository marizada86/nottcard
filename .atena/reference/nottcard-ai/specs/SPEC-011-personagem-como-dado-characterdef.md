---
id: "SPEC-011"
type: "spec"
title: "Personagem como dado (CharacterDef): tirar o Durvall de dentro do core"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[VSN-001-visao-inicial]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
sources:
  - "Pedido do responsável em 2026-09-19: plano para criar os próximos personagens, começando por Maelor, em contraste com Durvall"
---

# Personagem como dado (CharacterDef)

## Declaração

Hoje o `core` só sabe ser o Durvall: `DURVALL_CLASS_COLOR`, `DURVALL_COLOR_BONUS`,
`DURVALL_ATTRIBUTES`, a passiva de dados psiônicos em `combat.py` e um único
`build_starting_deck()`. Esta spec troca isso por um **`CharacterDef` declarativo**
(como a VSN-001 já pede: conteúdo como dado), **sem mudar nenhum comportamento do
Durvall**. É pré-requisito de qualquer personagem novo.

## Regras

1. `CharacterDef` (dataclass congelada, em `game/core/characters.py`): `id`, `name`,
   `class_name`, `class_color`, `attributes`, `max_hp`, `passive`, `build_deck`.
2. **Bônus de cor derivado dos atributos** (SIS-001: +20% por ponto de modificador),
   não mais uma tabela por personagem. Deve reproduzir exatamente a tabela atual do
   Durvall (0.60 / 0.40 / 0.20 / 0.00).
3. **Compatibilidade** (100% na cor da classe, 50% fora) passa a usar `class_color`
   do personagem.
4. **Corrente de Classe:** o `ComboTracker` pergunta à passiva do personagem se uma
   carta conta para a Corrente (`counts_for_chain(card)`). Padrão: `card.color == class_color`.
5. **Passiva** é um objeto/estratégia registrado por personagem, com dois ganchos:
   `counts_for_chain(card)` e `chain_bonus(card, mult)` (dado extra em 2x/3x/4x).
   - Durvall: gatilho padrão; bônus = `PASSIVE_DICE_BY_MULT` (1d6/2d6/3d6) só em ataque.
   - Maelor: ver SPEC-012.
6. `Player(character)` recebe o `CharacterDef`; atributos, PV e baralho vêm dele.
7. As HC (SPEC-009) pertencem ao baralho de cada personagem; **não são compartilhadas**.
   Segundo Fôlego e Surto de Ação passam a ser exclusivas do Durvall.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/characters.py` (novo) | `CharacterDef`, `DURVALL`, registro `CHARACTERS`. |
| `game/core/combat.py` | Remove constantes `DURVALL_*`; usa o personagem do `Player`. **Mudança de core.** |
| `game/core/state.py` | `Player(character)`. |
| `game/core/cards.py` | `build_starting_deck()` vira `DURVALL.build_deck`. |
| `game/app.py` | Instancia o personagem escolhido (por ora fixo em Durvall). |
| `game/ui/devlog.py` | Deixa de importar `DURVALL_COLOR_BONUS`. |
| Testes | Os testes atuais do Durvall passam **sem alteração**; novo teste: bônus derivado == tabela antiga. |

## Fora do escopo

Tela de seleção de personagem; qualquer carta ou regra do Maelor (SPEC-012).
