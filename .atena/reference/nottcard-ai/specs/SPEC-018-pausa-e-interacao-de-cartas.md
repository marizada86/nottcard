---
id: "SPEC-018"
type: "spec"
title: "Menu de pausa, detalhes da carta ao passar o mouse e duplo clique"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-013-tela-de-tutorial-e-pausa-em-combate]]"
  - "[[SPEC-016-layout-do-jogador-trilho-direito]]"
  - "[[SPEC-023-progresso-save-e-resultado-da-tentativa]]"
sources:
  - "FB-001 A1, A2, A3 (Higor e Caio, 2026-09-19), aprovado com as recomendações"
---

# Menu de pausa, detalhes da carta e duplo clique

## Problema

- Não há saída durante o combate: `App.return_to_menu()` só é chamado da seleção de personagem.
  A única pausa é o tutorial (`?`/F1).
- A carta na mão só mostra a arte pequena (~134×92); não há como ler o efeito completo sem jogá-la.
- Jogar uma carta exige clicar nela e depois no alvo, mesmo quando só há um inimigo.

## Regras

### 1. Menu de pausa
- **ESC** abre o menu de pausa quando **não há carta selecionada**; com carta selecionada, o ESC
  continua só limpando a seleção. Um botão pequeno "Pausa" no canto também abre o menu.
- O menu é uma sobreposição do `App`, como o `TutorialOverlay`, e vale **a qualquer momento do
  combate**, inclusive durante batidas (`busy`). Usa `Screen.pause()`/`resume()` já existentes
  (batidas, dados e cronômetro do chefe congelam).
- Opções: **Continuar**, **Tutorial** (abre o tutorial existente) e **Desistir** (volta ao menu).
- **Desistir** pede confirmação: "A missão falha, mas o XP acumulado é mantido". Depois da
  SPEC-023 o desfecho é `desistencia` (XP 100% do acumulado, tela de resultado). Antes dela,
  só chama `return_to_menu()`.
- ESC dentro do menu fecha (= Continuar); dentro da confirmação, cancela.

### 2. Detalhes da carta ao passar o mouse
- **Hover** levanta a carta uns `LIFT_OFFSET / 2` px (a selecionada continua mais alta) e abre
  um **painel ampliado** acima da mão, sem cobrir o inimigo alvo nem o log:
  arte em 480×320 (1:1), nome, cor, dado, nota, **custo** (Ação / Ação Bônus / Reação), tag de
  **HC** ou **uso único**, e uma linha "Corrente: conta / não conta; próximo multiplicador xN".
- O painel é só desenho (`game/ui/`); nenhum dado novo em `core`, salvo o que já existe em `Card`
  e em `ComboTracker.multiplier_for`.
- Funciona também durante batidas e no modo de descarte (SPEC-020), mas nunca joga a carta.
- Cartas sob a janela de Reação escurecidas (SPEC-010) mostram o painel normalmente.

### 3. Duplo clique
- Dois cliques na **mesma carta da mão** em até **350 ms** jogam a carta:
  - carta com alvo (`targets_enemy`): o **primeiro inimigo vivo da esquerda para a direita**;
  - carta de área, de bônus sem alvo ou de cura/surto: joga direto.
- Passa pela mesma checagem do clique normal (`TurnState.can_play`, HC já usada, Reação):
  o que não pode ser jogado gera a mesma mensagem de sempre.
- O primeiro clique continua selecionando (a carta sobe); o segundo executa. Um clique em outra
  carta ou fora zera a janela.
- Só vale com `busy=False` e sem `reaction_pending`.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/ui/cards_widget.py` | `slot_at` já existe; hover com elevação e `draw_card_detail(surface, card, combo)`. |
| `game/ui/pause.py` (novo) | `PauseOverlay` com os botões e a confirmação. |
| `game/app.py` | Sobreposição de pausa no `App`; ESC; duplo clique em `_handle_click` (tempo do último clique e índice). |
| `game/ui/tutorial_content.py` | Página nova: pausa, hover e duplo clique. |
| Testes | Duplo clique joga no 1º vivo; pulo do eliminado; janela expirada só seleciona; ESC abre pausa sem carta selecionada e limpa a seleção com carta; pausa congela o cronômetro do chefe; Desistir volta ao menu. |

## Fora do escopo

Desfecho de desistência com XP (SPEC-023), som, atalhos de teclado além do ESC, mudar o layout do trilho.

## Critérios de aceite

- [x] ESC abre e fecha a pausa em qualquer momento do combate; o cronômetro do chefe não corre pausado.
- [x] O painel de detalhes aparece ao passar o mouse e mostra o multiplicador atual.
- [x] Duplo clique joga no primeiro inimigo vivo da esquerda; carta de área sai direto.
- [x] Desistir com confirmação volta ao menu.
- [x] Testes existentes (251) continuam passando; os novos passam.

## Ordem de execução

1. Pausa (`PauseOverlay`) e ESC. 2. Hover e painel. 3. Duplo clique. 4. Tutorial. 5. Testes.
