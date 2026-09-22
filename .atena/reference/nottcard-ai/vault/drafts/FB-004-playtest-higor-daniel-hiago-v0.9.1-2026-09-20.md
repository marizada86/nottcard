---
id: "FB-004"
type: "feedback"
title: "Relatório de playtests do Higor (Higurino), com o Daniel e o Hiago, build v0.9.1, 2026-09-20"
status: "draft"
created: "2026-09-20"
relations:
  - "[[FB-003-notas-higor-guia-botoes-mao-corrente-2026-09-20]]"
  - "[[PLAN-008-retorno-dos-playtesters-v0.9.1-2026-09-20]]"
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
sources:
  - "Higor (game designer), relatório de 2026-09-20 sobre a v0.9.1, com as considerações do playtester Daniel; o Hiago também reportou o item 4"
---

# Relatório de playtests, v0.9.1 (2026-09-20)

Regra do responsável: as notas do Higor têm prioridade. Ids `H17`..`H20` (continuam o `FB-003`); o que o código faz hoje e a
proposta de cada item estão no `PLAN-008`.

## 1. Índice

| Id | Origem | Tipo | Resumo |
|---|---|---|---|
| H17 | Daniel | clareza | Carta de cor diferente da classe tem dano ×0,5: destacar na carta e/ou no dano |
| H18 | Daniel | interface | Exploração livre: W A S D não é óbvio; mudar as teclas e explicar no tutorial "?" |
| H19 | Daniel (via Higor) | ferramenta | Devlog detalhado (Ctrl+F12), no estilo do log de combate do Baldur's Gate 3; o F12 fica como está |
| H20 | Hiago e Daniel | balanceamento | Os inimigos acertam demais; subir a CA e a CAM base de quem tem pouca cura (o Kayron foi o mais citado) |

## 2. As notas, como enviadas

1. (H17) Ao utilizar uma carta sem proficiência, destacar no dano e/ou na carta que existe uma penalidade de 50% (0,5 de compatibilidade)
   quando usar cor diferente do personagem.
2. (H18) Melhorar a interface do modo exploração livre: "W, A, S, D" fica subentendido quando se trata de jogos, mas pode-se adicionar ao
   tutorial "?" as opções "virar", "avançar" e "recuar" por setas. Vamos substituir "A, D" (virar) por "Q, E", e "A, D" deve andar para a
   esquerda ("A") e para a direita ("D"); a tela vira automaticamente para a direção em que andar.
3. (H19) Melhorar a opção "F12": adicionar um Devlog mais detalhado (mostrar modificadores, tipo de dano, quanto tirou cada dado, quem
   jogou o dado etc.) para os playtesters analisarem a fórmula dos combates. Sugestão: "Ctrl+F12" para o Devlog, mantendo o "F12" como está,
   com as fórmulas de dano. Como exemplo, o Daniel citou o log de combate e interações do Baldur's Gate 3, que aparece no chat de texto para
   os jogadores conferirem a jogada com detalhes.
4. (H20) Ambos os playtesters, "Hiago" e "Daniel", dizem que os inimigos estão acertando muitos golpes. Sugestão: aumentar a CA e a CAM
   base dos personagens que não possuem muita opção de cura; o Kayron foi o exemplo mais citado pelos playtesters.

## 3. Resposta do Higor ao plano `PLAN-007` (decisão D5)

> A conquista que libera a Mão Maior: seguir a recomendação. Ao finalizar a primeira missão, ganhar a conquista para aumentar a mão
> máxima em +1.

Leitura registrada: a conquista é a **Fechadura Aberta** (concluir a missão) e ela **libera a compra da Mão Maior na loja**, como no H15.
Se o Higor quis dizer que a conquista dá o +1 **automaticamente**, sem comprar, o `PLAN-007` muda (ver a decisão D5 lá).
