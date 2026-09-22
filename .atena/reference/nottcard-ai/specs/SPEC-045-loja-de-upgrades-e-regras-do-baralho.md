---
id: "SPEC-045"
type: "spec"
title: "Loja de upgrades (sem pacote) e regras do baralho: núcleo obrigatório e validade"
status: "approved"
created: "2026-09-20"
reviewed: "2026-09-20"
relations:
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-041-colecao-de-cartas-baralho-aleatorio-chefes-e-pacotes]]"
sources:
  - "Higor (game designer), 2026-09-19, playtest da v0.6.0: H4 (tirar o pacote; loja de upgrades) e H5 (algumas cartas obrigatórias no baralho)"
  - "Responsável, 2026-09-20: tudo aprovado nas recomendações do PLAN-001; o núcleo do baralho é uma LISTA FIXA, conforme a preferência do Higor (o Higor confirma a lista)"
---

# Loja de upgrades e regras do baralho

> **Aprovada pelo responsável em 2026-09-20** (`execution_approval: per-spec`). Números da tabela são o ponto de partida; o Higor calibra com o
> simulador e o playtest.

## 1. Escopo

**Entra:** o pacote de figurinhas sai; o 2º baralho sai; a loja vende **upgrades permanentes por nível** (custo crescente); o baralho ganha um
**núcleo obrigatório** (lista fixa) e **regras de validade**; migração de saves. **Fica de fora:** falha crítica e Sorte (a Sorte só ganha o
upgrade aqui; a regra é da `SPEC-046`), equipamento (`SPEC-047`).

## 2. Upgrades (loja)

Globais (valem para o jogador, todos os personagens). "Novo jogo" os zera (a moeda também recomeça, como já é hoje). Layouts de carta
continuam à venda (cosmético). Cada compra sobe 1 nível; o preço do próximo nível sobe.

| Upgrade | Efeito por nível | Níveis | Custo (moedas) |
|---|---|---|---|
| Força Bruta | +4% no dano base dos dados de ataque (teto +20%) | 5 | 100, 200, 400, 800, 1600 |
| Vitalidade | +2 PV máximo | 5 | 80, 160, 320, 640, 1280 |
| Mão Cheia | +1 carta na mão inicial | 2 | 500, 1500 |
| Rerrolagem | +1 rerrolagem de recompensa por missão | 3 | 150, 450, 1350 |
| Sorte | +1 uso de Sorte por missão (`SPEC-046`) | 3 | 300, 900, 2700 |
| Bolso Fundo | +1 slot na mochila | 1 | 600 |
| Ganância | +10% de moedas por tentativa | 3 | 200, 600, 1800 |

- **Força Bruta** multiplica a **soma dos dados** da carta por `(1 + 0,04 × nível)` **antes** da Corrente e da compatibilidade de cor; o modificador de
  atributo (`SPEC-044`) não é multiplicado. Nunca passa de +20%. Pergaminhos não recebem.
- **Trava contra quebrar o jogo (pedido do Higor):** cada upgrade tem teto; nada cura, multiplica a Corrente nem dá dano por fora do teto.
- **Rerrolagem:** botão "Rerrolar (N)" na tela "Escolha 1 de 3" (recompensa do chefe): sorteia a oferta de novo. N = nível do upgrade; zera a cada missão.
- **Ganância:** as moedas ganhas ao fim da tentativa saem multiplicadas por `1 + 0,10 × nível` (arredonda para cima).
- **Mão Cheia:** a mão inicial de cada personagem tem `3 + nível` cartas (o teto de 5 continua).
- **Bolso Fundo:** a mochila passa de 3 para 4 slots.
- **Dados (core, sem pygame):** `game/core/upgrades.py` (`UPGRADES`, `level`, `cost_of_next`, efeitos); `SaveState.upgrades: dict[str, int]` (no `save.json`);
  `shop.buy` compra upgrades (`availability`: `max` quando no teto).

## 3. Sai da loja

- **Pacote de figurinhas:** removido (item, texto e o fluxo do pacote). A oferta "escolha 1 de 3" **fica só para a recompensa do chefe**.
- **2º baralho:** removido (com o núcleo travado ele perde o sentido). `MAX_DECKS = 1`.
- **Migração de save:** quem tem o 2º baralho comprado recebe **500 moedas de volta** e volta a 1 baralho; uma oferta de **pacote** pendente devolve
  **100 moedas** e some (a oferta de chefe pendente continua).

## 4. Núcleo obrigatório do baralho (lista fixa, preferência do Higor)

O baralho do jogador tem **até 20 cartas** (`DECK_CAP`, fora as de assinatura). **O núcleo fica travado**: as cartas dele não saem do baralho nem
podem ser trocadas; só as vagas livres (até 20) são editáveis.

- **A lista** (dado em `collection.CORE_DECK`; **o Higor confirma ou troca**; proposta inicial de 8 cartas que já cumpre as regras de validade):
  **2× Golpe**, **2× Chama Menor**, **2× Toque Curativo**, **2× Poção de Cura**.
- **Coleção inicial** (save novo): o núcleo + **6 cartas comuns sorteadas** (sem as garantias antigas, que o núcleo já cumpre). O baralho inicial é
  a coleção toda (14 cartas). Vagas livres: 12; ganhos (chefe) entram na coleção e, com espaço, no baralho.
- **Save antigo:** a migração garante as cartas do núcleo na coleção e no baralho (se o baralho estava cheio, saem cartas não-núcleo, das
  mais comuns, para caber).

## 5. Regras de validade

O baralho só é aceito para **iniciar a tentativa** se tiver, contando as cartas do baralho (sem as de assinatura):
- pelo menos **2 cartas de cada cor** (Vermelho, Amarelo, Azul, Roxo), **1 de cura** e **2 de ataque**;
- no máximo **3 cópias** de cada carta (**1** para as raras; a Poção de Cura mantém o teto de 2).

A tela "Baralho" mostra o que falta ("faltam 1 cura", "Golpe passa de 3 cópias") e a seleção de personagem **recusa iniciar** com o aviso. O núcleo
(lista fixa) cumpre as regras sozinho, então só se quebra a validade ao **remover** vagas livres que não sejam do núcleo, e isso só pode deixar de
cumprir se a lista do núcleo for trocada; o teste de coerência confere que **o núcleo cumpre as regras**.

## 6. Arquivos

| Arquivo | Mudança |
|---|---|
| `game/core/upgrades.py` (novo) | catálogo, nível, custo, efeitos |
| `game/core/shop.py` | sem pacote nem 2º baralho; upgrades; `price`/`availability`; migração de moedas |
| `game/core/collection.py` | `CORE_DECK`, `Deck` com núcleo travado, `deck_problems`, coleção inicial, migração; `MAX_DECKS = 1` |
| `game/core/progress.py` | `SaveState.upgrades` (to_dict/from_dict) |
| `game/core/combat.py`, `state.py`, `items.py` | Força Bruta, Vitalidade (via `bonus_hp`), Mão Cheia, Bolso Fundo |
| `game/ui/shop_screen.py`, `deck_screen.py`, `choose_card_screen.py` | upgrades, núcleo travado e problemas, botão Rerrolar |
| `game/app.py` | ligações; Ganância; recusa iniciar com baralho inválido; migração ao abrir |
| `tests/` | ver seção 7 |

## 7. Testes

- **Upgrades:** custo crescente e teto por upgrade; compra debita e sobe o nível; saldo insuficiente e teto recusam; "Novo jogo" zera; cada efeito
  (Força Bruta +4% por nível com teto em +20% e sem multiplicar o atributo; Vitalidade +2 PV; Mão Cheia +1 carta; Bolso Fundo 4 slots; Ganância +10%;
  Rerrolagem sorteia de novo e conta por missão).
- **Migração:** 2º baralho comprado devolve 500 e volta a 1 baralho; oferta de pacote pendente devolve 100; save antigo ganha o núcleo.
- **Núcleo e validade:** o núcleo não sai (remover e trocar recusam); o núcleo cumpre as regras; `deck_problems` lista o que falta; a seleção recusa
  iniciar com baralho inválido; limite de cópias (3, 1 rara, 2 Poção).
- **Interface:** loja mostra níveis e preços; tela Baralho mostra o núcleo travado e os problemas; botão Rerrolar.
- `core` sem pygame; todos os testes passam (os do pacote e do 2º baralho mudam junto: esperado).

## 8. Critérios de aceite

- [x] A loja vende os 7 upgrades por nível e os layouts; o pacote e o 2º baralho não existem mais; moedas devolvidas na migração.
- [x] Cada upgrade faz o que a tabela diz, com os tetos.
- [x] O núcleo (lista fixa) está travado; a coleção inicial e a migração o garantem.
- [x] A validade impede iniciar a tentativa e a tela Baralho diz o que falta.
- [x] `core` sem pygame; todos os testes passam.
- [ ] Números calibrados após o playtest do Higor (e a lista do núcleo confirmada por ele).

## Registro da implementação (2026-09-20)

- Feito conforme a spec. **Núcleo:** lista fixa de 8 cartas (2 Golpe, 2 Chama Menor, 2 Toque Curativo, 2 Poção de Cura), em `collection.CORE_DECK`,
  **a confirmar pelo Higor** (o valor é um dado; trocar a lista não mexe em código). Coleção inicial = núcleo + 6 comuns sorteadas (14 cartas).
- A migração roda ao abrir o jogo (`shop.migrate_removed_items` e `ensure_collection`): 2º baralho comprado devolve 500, pacote pendente 100.
- A loja ganhou abas (Upgrades, Equipamento, Layouts). O cheat (Ctrl+O+P) dá as peças de equipamento e os layouts, mas não maxa os upgrades
  (dá moedas para comprá-los).
- Rerrolagem: o botão aparece só na recompensa do chefe (única oferta que restou); a oferta nova fica no save.
- Testes: `test_shop.py`, `test_collection.py`, `test_upgrade_effects.py`, `test_shop_flow.py`, `test_collection_flow.py`.

## Review record

- Proposed by: Claude, a partir de H4/H5 do PLAN-001.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20; decisão 6 (núcleo) pela preferência do Higor: lista fixa, com a proposta inicial acima para ele confirmar.
