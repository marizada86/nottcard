---
id: "SPEC-035"
type: "spec"
title: "Loja e títulos (moeda do jogo)"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[ART-001-pacotes-de-arte-de-carta-e-titulos]]"
  - "[[SPEC-030-pacotes-de-arte-de-carta-selecao-livre]]"
  - "[[SPEC-023-progresso-save-e-resultado-da-tentativa]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-033-save-em-disco]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
sources:
  - "Responsável, 2026-09-19: moeda 1 por XP; a loja da v1 vende só os 10 layouts; título 1 para 1"
  - "ART-001 (rascunho): compra só com moeda do jogo; título permite comprar, compra permite equipar"
---

# Loja e títulos


## 1. Moeda

- **Só moeda do jogo**, sem dinheiro real nem loja externa.
- **Ganho:** ao fim da tentativa, junto do XP, pelo mesmo `RunLedger`: **1 moeda por XP líquido ganho**
  (o valor final já com o ajuste do desfecho, como a derrota que vale metade). Uma vitória (~100 XP) rende
  ~100 moedas.
- O saldo é único (não por personagem) e vive no `SaveState`. Não há perda de moeda; só gasto.
- A tela de resultado mostra "+N moedas" junto do XP.

## 2. Títulos

- Um **título por conquista** (`achievements.py`): ganhar a conquista concede o título de mesmo id.
- **Ter o título permite comprar** o item ligado a ele; **comprar permite equipar**; título sozinho não
  equipa nada (`ART-001`).
- Na v1, título e item são **1 para 1**. Um item sem título requerido é vendido desde o início.
- O catálogo de conquistas (SPEC-026) passa a mostrar, junto de cada uma, o título e o item que ela libera.

## 3. Loja da v1

- Vende **os 10 layouts de carta** da SPEC-030: zero custo de arte. O Clássico é o padrão e é grátis.
- **Preços** (a ajustar no playtest): 100 moedas para layouts simples, 200 para os elaborados.
- O layout comprado fica disponível no seletor da SPEC-030, que passa a listar **só os comprados** (o ponto de
  troca já está deixado na spec). O bloqueado aparece na loja, não no seletor.
- Compra confirmada por clique; sem saldo, o botão fica desabilitado e mostra o preço faltante.
- Onde abre: menu e Interlúdio (`SPEC-034`). **Nunca durante uma tentativa.**
- A loja **não vende itens de jogo** (isso é a `SPEC-036`, que não mistura com moeda de cosmético); vende layouts e, com a `SPEC-041`, pacotes de cartas.

### Pacote de figurinhas (`SPEC-041`)

A `SPEC-041` acrescenta um segundo tipo de item à mesma loja: o **Pacote de figurinhas**, com 3 cartas
(`ShopItem(tipo="pacote")`, **100 moedas**). Ele não exige título. Comprar abre a escolha de 1 entre 3 cartas
(revisão de 2026-09-19) e a carta escolhida vai para a coleção do jogador. As cartas de pacote nunca são melhores
que as de chefe.

### 2º baralho (`SPEC-041`)

O jogador tem 1 baralho para todos os personagens; o **2º baralho** é desbloqueável e a loja o vende (item único,
preço alto, ~500 moedas, a ajustar no playtest). Comprado, ele aparece na tela "Baralho" e na escolha antes da
tentativa.

### Fase 2 (fora desta spec)

Pacotes de ilustração por carta (`ART-001` §1–§3), quando houver arte. O modelo de dados do `ART-001`
(`id`, `nome`, `titulo_requerido`, `preco`, `cartas`) serve, e o pacote entra como mais um tipo de item da
mesma loja.

## Dados

`ShopItem(id, nome, preco, titulo_requerido=None, tipo="layout")`, catálogo declarativo em `game/core/shop.py`.
`SaveState` ganha: `coins`, `titles`, `owned` (ids comprados). `buy(state, item_id)` valida título, saldo e
duplicidade e devolve o resultado; nada de pygame.

## Critérios de aceite

- [x] Concluir uma tentativa credita moedas = XP líquido, e o resultado mostra o valor.
- [x] Conquistas concedem o título; sem o título, o item requerido não pode ser comprado.
- [x] Comprar debita o saldo, é persistente (`SPEC-033`) e não permite comprar duas vezes.
- [x] O seletor de layout só lista os comprados; o Clássico sempre.
- [x] A loja não abre durante a tentativa.
- [x] `core` sem pygame; testes de compra, saldo, título e persistência (`tests/core/test_shop.py`, `tests/ui/test_shop_flow.py`).
- [ ] Playtest dos preços.

Notas de implementação: o título é derivado das conquistas (`shop.titles_of`), sem campo próprio no save. Vitral, Ferro Rúnico e Brasa exigem os títulos Fechadura Aberta, Dois Veteranos e Sorte de Sendrinah. "Novo jogo" zera moedas, coleção e 2º baralho, mas mantém os layouts comprados (gosto). O Ctrl+O+P libera todos os itens e dá 9999 moedas. A revelação do pacote (`PackRevealScreen`) já entra aqui, uma carta por clique.
