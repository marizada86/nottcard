---
id: "SPEC-021"
type: "spec"
title: "Rebalanceamento: Chama Sagrada, Névoa Fria em área e Golpe Contundente atordoante"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-015-atordoamento-e-onda-psionica]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[SPEC-020-mao-cheia-descarte-por-escolha-e-acao-compra-2]]"
sources:
  - "FB-001 B1, B3, B4 (Higor, 2026-09-19), aprovado com as recomendações"
---

# Rebalanceamento das cartas

Todos os números abaixo são **valores iniciais de playtest**, ajustáveis sem nova spec
(registrar em EVID).

## Problema

- **Chama Menor e Chama Sagrada** são iguais no jogo (Amarelo, 1d6, fogo); a Sagrada tem 4 cópias.
- **Névoa Fria** afeta um alvo só, e com 3 inimigos (SPEC-014) fica fraca.
- **Golpe Contundente** do Maelor é só um ataque 1d4; o atordoamento existe só como carta separada.

## Regras

### 1. Chama Sagrada
- **1d4**, **Ação Bônus** (`action_type="bonus"`), fogo + radiante, Amarelo (**conta na Corrente Amarela**).
- **Ignora 1 ponto de CAM** do alvo no teste de acerto (campo novo `ignores_cam`, análogo ao
  `ignores_ca` do Golpe Perfurante). É a identidade "radiante".
- **3 cópias** no baralho do Maelor (eram 4): o baralho passa de 13 para **12 cartas**.
- Chama Menor não muda (1d6, Ação).

### 2. Névoa Fria em área
- `area=True`: sem alvo, atinge **todos os inimigos vivos**; um rolamento, o mesmo valor para todos:
  `reduction = ceil(dado × Corrente × compat × (1 + bônus da cor) × 0,75)`.
- O `0,75` é a constante `AREA_CONTROL_FACTOR` (desconto por ser em área; não é HC).
- Vale para Durvall e Maelor (a mesma carta). Nova função `resolve_area_control` no `core`.
- Avança a Corrente como qualquer carta (Azul).

### 3. Golpe Contundente atordoa por teste de dados
- Depois de **acertar** (dano aplicado), rola **d20 + modificador de Força** contra a
  **CD de atordoamento** do inimigo (`Enemy.stun_dc`). Sucesso: `stunned = True` (perde o próximo ataque).
- Campo de carta novo: `stun_on_hit`. Só o Golpe Contundente o usa.
- **Sem acúmulo:** alvo já atordoado ignora o teste.
- CDs iniciais e chances do Maelor (Força 10, mod +0):

| Inimigo | CD | Chance |
|---|---|---|
| Slime corrosivo | 10 | 55% |
| Criatura corrompida | 12 | 45% |
| Guardião (cópia) | 14 | 35% |
| Guardião verdadeiro (chefe) | 16 | 25% |

- **Chefe:** depois de atordoado, fica **imune ao atordoamento no turno seguinte**
  (`stun_cooldown`), para não ser encadeado.
- Animação: reaproveita a batida do d20 (`_dice_beat`) com o rótulo "atordoar" e o devlog registra
  rolagem, CD e resultado. Atordoar (carta de HC) continua garantido e sem teste.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | Chama Sagrada (1d4, bônus, `ignores_cam=1`, ×3); Névoa Fria (`area=True`); Golpe Contundente (`stun_on_hit`); campos `ignores_cam`, `stun_on_hit`; asserts de tamanho (Maelor 12). |
| `game/core/combat.py` | `roll_to_hit` respeita `ignores_cam` na defesa mágica; `resolve_area_control`; `resolve_stun_check`. |
| `game/core/enemies.py` | `stun_dc`, `stun_cooldown`. |
| `game/app.py` | Fluxo de Névoa em área (sem alvo) e de teste de atordoamento após o acerto. |
| `game/ui/tutorial_content.py` | Texto dos três casos. |
| Testes | Sagrada bônus/1d4/CAM; deck do Maelor com 12; Névoa reduz todos os vivos com o fator; atordoa em sucesso, não em falha, não acumula; cooldown do chefe. |

## Fora do escopo

Regerar arte (a arte atual já serve, ver ART-PROMPTS-002), balanceamento fino, novas cartas.

## Critérios de aceite

- [x] Chama Sagrada é bônus 1d4, ignora 1 CAM, conta na Corrente; baralho do Maelor com 12.
- [x] Névoa Fria sem alvo reduz o próximo ataque de todos os vivos.
- [x] Golpe Contundente pode atordoar com teste visível; não acumula; chefe tem cooldown.
- [ ] Playtest registrado (EVID) com os números ajustados.

## Ordem de execução

1. `core` com testes (campos, funções). 2. Fluxos no `app`. 3. Tutorial. 4. Playtest e ajuste dos números.
