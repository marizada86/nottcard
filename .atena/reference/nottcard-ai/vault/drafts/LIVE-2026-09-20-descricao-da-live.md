---
id: "LIVE-2026-09-20"
type: "roteiro"
title: "Descrição para a próxima live: primeira pessoa e retorno do playtest"
status: "draft"
created: "2026-09-20"
---

# Roteiro da live (não é para publicar)

## Abertura (1 min)
- Nottcard AI: mesmo jogo do Godot, sem engine, só Python + pygame-ce.
- Hoje (20/09) foi de v0.7 a v0.9.2.

## Mostrar (ordem sugerida)
1. **Combate de frente**: mão em leque, livros, orbe de PV, intenção do inimigo revelada.
2. **Câmera com o mouse** e a opção de reduzir movimento.
3. **Caminhada em primeira pessoa**: raycast, automapa, encontros. Modo clássico de portas ainda existe.
4. **Texturas do mundo e faces dos dados** (7 salas, 8 props).
5. **Brook Franca**, a quinta personagem: Guarda e Desonra.
6. **F5 / F6 / F7**: bloco de notas, print, pacote `.zip` da sessão.

## Contar
- Arquitetura: `core` sem pygame, tela só desenha. O raycaster nasceu em cima disso.
- Como o playtest funciona: Higor + Daniel + Hiago → FB-004 → PLAN-008 → specs 060 a 066.
- Método ADD: nada vira código sem spec aprovada.

## Retorno dos playtesters (o assunto forte)
- Inimigos acertam demais (Kayron mais citado): medir no simulador antes, cada ponto de CA = 5 pp.
- A Corrente quebrava antes do dado: só muda na revelação.
- Cor diferente da classe (×0,5) passa batido: destacar.
- Teclas: Q/E viram, A/D andam de lado.
- Ctrl+F12: log estilo BG3.
- Mão Maior liberada pela Fechadura Aberta.

## Status honesto
- Specs 060 a 066 aprovadas; implementação começou pelos números de defesa/PV.
- Falta playtest da caminhada e das texturas (TASK-015..017 e seguintes).
- Falta a confirmação da lista do núcleo pelo Higor e o Discord do Marizverso.

## Perguntas para o chat
- Qual personagem parece mais forte/fraca depois dos números novos?
- A caminhada em primeira pessoa está confortável ou enjoa?
