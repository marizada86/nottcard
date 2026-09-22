---
id: "SPEC-016"
type: "spec"
title: "Layout do combate: o jogador embaixo, o inimigo em cima (trilho da direita)"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-005-economia-de-turno]]"
  - "[[SPEC-010-carta-de-reacao]]"
  - "[[SPEC-013-tela-de-tutorial-e-pausa-em-combate]]"
  - "[[SIS-003-fileira-de-inimigos-exploracao-com-cartas-hud]]"
sources:
  - "Pedido do responsável em 2026-09-19: Ação/Bônus/Reação do lado direito do baralho; 'Passar Ação' e 'Comprar Carta' embaixo do baralho, para testar; manter os indicadores; deixar o log como está; símbolos do baralho maiores"
---

# Layout do combate — o jogador embaixo, o inimigo em cima

> **Registrada depois do fato e aprovada em 2026-09-19.** O layout abaixo foi implementado como
> teste a pedido do responsável (2026-09-19), antes desta spec.

## Conceito

**O que está do lado de cá (embaixo) é do jogador; do lado de lá (em cima) é do inimigo.**
Tudo que o jogador controla ou consulta para agir sai da metade de cima e vai para a
de baixo, junto da mão.

## Regras

1. **Trilho do jogador** à direita da mão (`x ≥ 1050`, de 470 a 694 de altura):
   - **Baralho e descarte** no topo, como ícone + número; o ícone é cortado até o desenho e
     escalado a 56 px, porque a arte tem margem transparente grande.
   - **Indicadores Ação / Bônus / Reação** (círculos verde/vermelho, "Ação x2" com Surto) à direita
     do baralho, com 40 px entre eles. Continuam **só indicadores** (não clicáveis).
   - **Botões**, de cima para baixo, abaixo do baralho: "Passar a Ação (0)",
     "Comprar carta (Bônus)" (ou "Ação Bônus usada") e "Encerrar turno (Enter)" / "Não reagir (Enter)".
2. **Mão:** o limite direito passa a ser `x = 1040` (`HAND_RIGHT_MARGIN = 240`); mãos grandes
   se apertam antes de tocar o trilho. Início mínimo `x = 190` (orbe de PV) inalterado.
3. **Log, orbe de PV, atributos, nome, CA/CAM e timer do chefe** ficam onde estão (decisão do
   responsável: "deixe o log como está"). A metade de cima continua só com inimigos, barras e
   números flutuantes.
4. Posições viram constantes `RAIL_*` em `game/app.py` (`RAIL_X`, `RAIL_TOP`, `RAIL_WIDTH`,
   `RAIL_INDICATORS_X`, `RAIL_INDICATOR_SPACING`). Os nomes `pass_button`, `bonus_button` e
   `end_button` não mudam.
5. Nenhuma regra de jogo muda; só desenho e posição de hitbox.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/app.py` | Constantes `RAIL_*`; retângulos dos 3 botões; posição dos contadores e dos indicadores; rótulo "Comprar carta (Bônus)". |
| `game/ui/hud.py` | `draw_action_indicators(..., spacing=60)`; `draw_pile_counter` com ícone recortado e maior (`PILE_ICON_SIZE`). |
| `game/ui/cards_widget.py` | `HAND_RIGHT_MARGIN = 240`. |
| Tutorial | Página "Ação, Bônus e Reação" descreve o trilho (já atualizado). |

## Decisões em aberto (para o responsável)

1. **Indicadores clicáveis?** Fundir o switch da Ação com "Passar a Ação" e o do Bônus com
   "Comprar carta" tiraria dois botões. *Recomendação:* manter separado por ora (é o que você
   pediu) e decidir depois do playtest.
2. **Faixa neutra no meio** (log, "Turno do inimigo", timer do chefe): mover o log para lá? Você
   preferiu deixar como está; o timer do chefe também.
3. **Encerrar turno** no trilho ou no centro? Está no trilho, embaixo dos outros dois.

## Fora do escopo

Arte do baralho como pilha de cartas, espelho do lado do inimigo (próximo ataque especial),
redimensionamento de janela.

## Critérios de aceite

- [x] 240 testes passam com o layout novo.
- [x] Render de verificação: trilho legível, ícones de baralho e descarte visíveis, botões sem sobrepor a mão.
- [ ] Playtest: os botões e indicadores são encontrados sem procurar; a mão de 5+ cartas não cobre o trilho.
- [x] Aprovação do responsável (2026-09-19).
