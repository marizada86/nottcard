---
id: "SPEC-053"
type: "spec"
title: "Primeira pessoa, passos FP-2 e FP-3: corredor com portas, transição e tela de recompensas"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-002-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-049-camera-com-o-mouse-primeira-pessoa-fp0]]"
  - "[[SPEC-052-combate-de-frente-layout-primeira-pessoa-fp1]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-041-colecao-de-cartas-baralho-aleatorio-chefes-e-pacotes]]"
sources:
  - "Referências de primeira pessoa (Shroom and Gloom): corredor com portas e cadeados, recompensa 'A gift from below'"
  - "Responsável, 2026-09-20: mapa de nós continua como visão secundária (decisão 3 do PLAN-002)"
---

# Corredor com portas e recompensas (FP-2 e FP-3)

> **Aprovada pelo responsável em 2026-09-20** ("seguindo", depois da SPEC-052). A arte das portas e da recompensa já foi
> gerada e processada. **`WorldMap`, `exploration` e o save não mudam.**

## 1. Navegação por portas (FP-2)
- `MapaScreen` deixa de desenhar o mapa de nós como tela principal e passa a mostrar a **cena da sala atual** (`Scene`,
  câmera da SPEC-049) com **uma porta por vizinho** de `WorldMap.neighbors(current)`.
- **Dados em `game/ui/scenes_data.py`** (declarativo): por sala, os slots de porta (retângulo, ordem) e, com a SPEC-054, as
  camadas. Sala sem entrada nesse arquivo cai num layout padrão (portas distribuídas em linha).
- **Cada porta mostra:** nome da sala, ícone de tipo (`node_*.png`) e estado (limpa, opcional, chefe, trancada).
- **Hover:** a porta ilumina e mostra o rótulo. **Clique:** `WorldMap.move_to`, como hoje.
- **Trancadas:** salas que existem mas ainda não estão liberadas mostram cadeado e não respondem ao clique. A bifurcação da
  Rachadura (SPEC-031) aparece como duas portas na mesma cena; a sala opcional traz "opcional".
- **Transição** (`game/ui/transition.py`): ao entrar, zoom de 1,0 a ~1,25× no cenário e fade, 400 ms, pulável com clique; ao
  chegar, o inverso. Com "reduzir movimento" (SPEC-049) só o fade.
- **Situações e d20** (`SituacaoScreen`) e a Sorte (SPEC-046) aparecem **sobre a cena**, sem tela de mapa no meio.
- **Mapa de nós:** botão "Mapa" e tecla **M** abrem o `draw_map` atual como visão de orientação (secundária); `Esc` volta.

## 2. Recompensas (FP-3)
- "Escolha 1 de 3" (`choose_card_screen.py`) ganha o fundo e a moldura da referência; três cartas em destaque, a de hover
  sobe. A regra (SPEC-041/045) e a rerrolagem não mudam. Fallback para o fundo atual se faltar a arte da SPEC-054.

## 3. Aceite
1. Percorrer o M1 inteiro (7 salas, incluindo o desvio da Rachadura e a sala opcional) só por portas.
2. O mapa de nós acessível por M em todas as cenas de exploração; portas trancadas não navegam.
3. Transição pulável; só fade com "reduzir movimento".
4. Testes: `door_at`; portas = vizinhos do `WorldMap` para cada nó; estado trancada/limpa. Testes do `WorldMap` intactos.

## 4. Riscos
- O corredor esconde a bifurcação: mitigado pelo mapa secundário e por rótulos claros nas portas.
- Slots de porta dependem do enquadramento da arte; até a SPEC-054, layout padrão sobre os fundos atuais.

## 5. Fora do escopo
Arte em camadas e molduras novas (SPEC-054), mudança de regra da exploração, som.

## 6. Implementação (2026-09-20)

- **`MapaScreen`** virou a exploração por portas: cena da sala atual (`Backdrop` + `Camera`, com a frente do cenário por cima)
  e uma porta por vizinho de `WorldMap.neighbors` (`game/ui/corridor_view.py`, dados em `game/ui/scenes_data.py`). A porta
  usa o sprite do **ambiente do destino** (madeira, arco de pedra, escada, portal do ritual) e o rótulo mostra o ícone de
  tipo, o nome, "opcional" e o selo de sala limpa. As portas ficam presas à parede do fundo (movem-se com a câmera).
- **Trancadas:** o desenho e o clique já suportam (`locked`, com o cadeado), mas o M1 não tranca nenhuma porta: nenhuma regra
  nova foi inventada; o `WorldMap` não mudou.
- **Mapa de nós:** `NodeMapScreen` (botão "Mapa" ou **M**; Esc, M ou "Voltar" retornam), sem nós clicáveis.
- **Chegada:** `game/ui/transition.py`; clicar numa porta (`move_to_node(via_door=True)`) troca de sala **na hora** e a nova
  cena chega com zoom 1,25x→1x e fade em 0,4 s (só o fade com "reduzir movimento"); qualquer clique ou tecla pula. O print da
  evidência sai sem o efeito. Desvio da spec: o efeito é de **chegada**, não de saída, para o estado do jogo não esperar por
  animação (os testes e o `WorldMap` não dependem de tempo).
- **Situação e d20:** já eram desenhadas sobre a cena da sala (SPEC-049/054), sem tela nova.
- **Recompensa:** fundo `screens/recompensa` e moldura `hud/moldura_recompensa` (o vidro da moldura envolve a carta), a
  carta sob o mouse ou escolhida sobe 10 px, a raridade fica no vidro e o efeito abaixo da moldura. Cartas menores (1,45x) e
  espaço maior entre elas; a regra e a rerrolagem não mudaram.
- Testes: `tests/ui/test_corridor.py` (14). Os testes de exploração e mochila passaram a clicar nas **portas**.
