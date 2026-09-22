# SPEC-004 — F4–F6: interface e fluxo jogável (fatia vertical)

Status: aprovada (PLAN-001). Executada em parte em 2026-09-21; o restante está em `generated/PORT-STATUS.md`.

## Arquitetura
- `GameApp` (ui/game_app.gd, script da cena principal): estado global, troca de telas, opções (câmera, FPS, tremulação, movimento suave, playtester), save e aviso.
- Telas são `UiScreen` (handle_input / update / draw) desenhadas em `_draw()` sobre o mesmo canvas 1280x720, como o pygame (`Gfx` traduz pygame.draw/blit/font).
- `RunSession` (core) faz o que o `App` do Python orquestra: começar a missão, sortear eventos, avançar salas, terminar (XP, conquistas, moedas, oferta do chefe, save).
  `CombatSession` (core) é a lógica de um combate (cartas, turnos, reações, mortes, reforços, descarte); a tela só desenha e clica.
- Primeira pessoa: piso e teto por shader, paredes por raycast em GDScript (uma faixa de textura por coluna interna de 480), cartazes com zbuffer e luz de tocha por shaders.

## Telas portadas
Menu (opções e "Novo jogo"), escolha do inicial, seleção de personagem/grupo, missões, caminhada, situação/eventos (d20, Sorte, recompensa, remain), combate
(alvo, reação, descarte, Comunhão, grupo de até 3, números flutuantes), oferta "1 de 3" (carta rara e pergaminho) e resultado.

## Verificação
- `tests/cases/test_ui_smoke.gd`: um bot dirige as telas reais (Caminhada → Combate → Oferta → Resultado) sem erro.
- `tests/cases/test_run_flow.gd`: bots jogam M1 e M2 inteiras pelo core (vitória com o chefe, derrota, save coerente, grupo de 3).
- Capturas de tela em `.atena/evidence/telas-2026-09-21/` (geradas com `godot -- --shot=<tela> --out=<png>`).
- O runner agora reprova teste que dá erro de execução (antes um erro passava em silêncio).
