---
id: "SPEC-081"
type: "spec"
title: "Faces ilustradas nos dados 3D e malhas do d10 e do d12"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-002-animacao-dado-d20-procedural-3d]]"
  - "[[PLAN-006-producao-faces-de-dados-2026-09-20]]"
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'o layout dos dados não mudou' (as 60 faces já estavam em assets/dice/textures, mas o dado 3D ainda desenhava faces lisas; a integração ficou adiada na D9 do PLAN-007)"
---

# Faces ilustradas nos dados 3D

Escrita junto da implementação, a partir do pedido do responsável; a decisão D9 do `PLAN-007` ("entram no pacote, sem integração neste
build") deixa de valer.

## O que muda
- Cada face do dado 3D mostra a textura `assets/dice/textures/d<lados>_face_<NN>.png`, onde NN é o **valor gravado na face** (a malha
  já sabe o número de cada face). O numeral vem da própria arte; o numeral por código só aparece nas faces sem textura (reserva).
- **d10 e d12 ganham malha 3D** (antes caíam no sprite 2D): d10 = trapezoedro pentagonal (12 vértices na esfera unitária, 10 pipas
  planas, primeira posição de cada face = o polo), d12 = dodecaedro (12 pentágonos). Faces opostas somam lados + 1.
- Cada face tem uma **caixa** (direita, cima, largura, altura no modelo); a textura, recortada rente ao contorno, ocupa essa caixa.
  "Cima" é a referência do numeral (vértice 0 nos triângulos, pentágonos e pipas; ponto médio da primeira aresta no cubo).
- A textura é projetada por uma matriz 2x2 (decomposta em girar, esticar e girar, só com `pygame.transform`), escurecida pela luz e
  **recortada pelo polígono da face**; o fundo da face usa a cor média da textura. Face de lado demais ou espelhada volta à face lisa.
- Os fantasmas do borrão de movimento continuam lisos (custo). Medido: d20 texturado ~1,3 ms por quadro.
- `_build` passa a calcular a normal pelo plano da face (a soma dos vértices só servia nas faces regulares, não nas pipas do d10).

## Fora
Perspectiva exata por pixel (a projeção é afim por face), d4 com numerais nas três arestas, brilho de borda do d20 (`d20_edge_glow`),
malhas de outros dados.

## Testes
As 60 texturas existem pelo nome; as malhas novas são sólidos fechados (Euler = 2), com faces planas, normais para fora e opostas
somando lados + 1; a orientação final mostra cada face ao observador; d10/d12 animam em 3D e terminam no valor; a face texturada difere
da lisa e sem textura cai na lisa com numeral; a matriz de projeção da textura (identidade, escala, giro, espelho, de lado).
