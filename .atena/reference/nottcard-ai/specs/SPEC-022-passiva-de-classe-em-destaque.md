---
id: "SPEC-022"
type: "spec"
title: "Passiva de classe em destaque: na seleção e durante a partida"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-011-personagem-como-dado-characterdef]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-018-pausa-e-interacao-de-cartas]]"
sources:
  - "FB-001 D1 e D2 (Caio, 2026-09-19), aprovado com as recomendações"
---

# Passiva de classe em destaque

## Problema

- Na seleção de personagem a passiva aparece em fonte 20, igual ao resto do cartão, e **um clique
  já inicia a run** (`start_run`). Não existe o momento de "selecionar".
- Durante a partida a passiva só está no tutorial, de forma geral.
- A passiva não tem nome: `CharacterDef.passive_text` é só texto.

## Regras

### 1. Nome da passiva (dado)
`CharacterDef.passive_name`: **Durvall = "Corrente Psiônica"**, **Maelor = "Chama Devota"**.
A descrição continua em `passive_text`. (Nomes aprovados em 2026-09-19.)

### 2. Seleção de personagem em dois passos
- O **primeiro clique seleciona** o cartão: sobe, ganha brilho na cor da classe e o outro escurece.
- O botão **Começar** (ou Enter, ou clique de novo no mesmo cartão) confirma e chama `start_run`.
  **Voltar** continua igual.
- **Painel de destaque da passiva** abaixo do cartão selecionado: `passive_name` em fonte de título
  (`card_title_font`, ~34), descrição em ~24, com contorno e cor da classe. Atributos e resto do
  cartão ficam menores.
- **Efeito ao selecionar:** pulso curto no cartão e partículas na cor da classe (branco-azulado
  no Durvall, âmbar no Maelor), reaproveitando as partículas de `damage_fx`. Só código.
- Emblema opcional (`passiva_durvall`, `passiva_maelor`, ART-PROMPTS-002 item 4) ao lado do nome; sem o
  arquivo, o painel funciona igual.

### 3. Clicar no nome do personagem durante a partida
- O nome no painel do jogador (`draw_player_panel`) vira **botão**, com dica visual ("?" ao lado)
  e cursor de mão no hover.
- O clique abre o **cartão da passiva**, o mesmo componente do painel de destaque da seleção,
  mais o multiplicador atual da Corrente como exemplo. Mostra **só a passiva**.
- **Pausa** o combate (`Screen.pause()`); fecha com clique fora ou ESC. Só abre com `busy=False`.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/characters.py` | `passive_name` em `CharacterDef` (dado declarativo). |
| `game/ui/passive_card.py` (novo) | `draw_passive_card(...)`, partículas de seleção. |
| `game/app.py` | `CharacterSelectScreen` com seleção + Começar; nome clicável em `CombateScreen`; pausa ao abrir. |
| `game/ui/hud.py` | Nome do painel do jogador com área clicável e dica. |
| Testes | Primeiro clique só seleciona; Começar confirma; nome clicável abre e fecha o cartão; pausa e retoma o cronômetro. |

## Fora do escopo

Passiva de nível 5 (SPEC-024), lista de HC usadas, novos personagens, som.

## Critérios de aceite

- [x] Selecionar destaca a passiva com nome grande e efeito; confirmar inicia a run.
- [x] Clicar no nome durante o combate mostra a passiva e pausa o jogo.
- [x] Testes passam.

## Ordem de execução

1. `passive_name`. 2. `passive_card` e a seleção em dois passos. 3. Nome clicável no combate. 4. Testes.
