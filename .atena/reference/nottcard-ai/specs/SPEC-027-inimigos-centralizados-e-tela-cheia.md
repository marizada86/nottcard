---
id: "SPEC-027"
type: "spec"
title: "Inimigos centralizados e janela redimensionável / tela cheia"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-014-combate-com-multiplos-inimigos]]"
sources:
  - "Playtest do Higor e do Hiago, 2026-09-19 (pedido direto do responsável)"
---

# Inimigos centralizados e tela cheia

## Regras

1. **Inimigos centralizados.** A fileira de inimigos, de um só ou de um grupo, fica centralizada
   horizontalmente na tela (antes: um inimigo à direita, grupo alinhado à direita). `ENEMY_POS` e
   `enemy_positions` calculam a partir da largura da tela.
2. **Janela redimensionável e tela cheia.** O jogo continua desenhando em 1280×720; a janela abre com
   `pygame.SCALED | pygame.RESIZABLE`, então o botão de maximizar do sistema funciona e a imagem escala mantendo
   a proporção (barras nas sobras), com o mouse já convertido. **F11** ou o botão redondo no topo alternam
   tela cheia. Sem suporte do driver de vídeo, cai na janela fixa de sempre. Nos testes (driver `dummy`) usa a
   janela simples.
3. **Topo da tela** (da direita para a esquerda): ajuda "?", tela cheia, pausa "II" e velocidade "1x/2x"
   (as duas últimas só no combate). Pausa e velocidade se moveram uma posição pra dar lugar ao botão novo.

## Critérios de aceite

- [x] Um inimigo e grupos aparecem centralizados.
- [x] F11 e o botão alternam tela cheia; a janela é redimensionável.
- [ ] Conferir na máquina do Higor e do Hiago.
