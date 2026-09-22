---
id: "PLAN-002"
type: "plano"
title: "Plano da primeira pessoa: quando entra, estrutura e especificidades"
status: "draft"
created: "2026-09-20"
relations:
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-044-ajustes-do-playtest-v0.6.0]]"
sources:
  - "Responsável, 2026-09-20: fazer o plano da primeira pessoa (quando entra, estruturas, especificidades)"
  - "PLAN-001 seção 3.3 (esboço da F5), agora detalhado aqui"
---

# Plano da primeira pessoa (`SPEC-049`, F5)

> Escrito para: Guilherme e Higor. Rascunho: nada aqui é regra até a `SPEC-049` ser aprovada
> (`execution_approval: per-spec`). Detalha a seção 3.3 do `PLAN-001`; em conflito, vale este.

## 1. O que "primeira pessoa" quer dizer aqui

**2D em camadas com paralaxe, não 3D.** Nada de raycasting nem engine de cena: o jogador continua vendo
imagens 1280×720 (pygame `SCALED`), mas o cenário se desloca com o mouse em camadas de profundidade e a
navegação vira "corredor com portas" em vez de mapa de nós. Motivos:

- O `core` não muda (`WorldMap`, `combat`, `exploration` ficam intactos; regra de `VSN-001`: UI só desenha).
- A arte já existe como imagem chapada por sala (`assets/rooms/*.png`); o protótipo roda sem arte nova.
- O custo de 3D real (modelos, iluminação, colisão) não paga o que a referência (Shroom and Gloom) mostra: o
  efeito vem de câmera parada + paralaxe + PV sobre os inimigos + mão em leque.

## 2. Quando entra

**Depois da F3, antes do Brook. O passo 1 (câmera) pode sair antes de tudo.**

| Marco | Entra quando | Por quê |
|---|---|---|
| **FP-0 Câmera com o mouse** | Já, em paralelo às F1–F3 | Só mexe no fundo e nos inimigos; não depende de loja, baralho nem equipamento. Dá para o Higor sentir o efeito no próximo playtest. |
| **FP-1 Combate de frente** | Depois da F3 (`SPEC-045/046/047`) | Reorganiza o HUD do combate, que hoje mostra Sorte, Guarda, equipamento e pilhas; o layout novo só pode ser desenhado quando esses elementos estiverem definidos. |
| **FP-2 Corredor e portas** | Depois do FP-1 | Substitui `draw_map`; usa o fundo e a câmera do FP-0. |
| **FP-3 Recompensas** | Junto do FP-2 | Só apresentação da tela "Escolha 1 de 3". |
| **FP-4 Arte em camadas** | Prompts logo após a aprovação da spec; entra por sala conforme fica pronta | Os fundos atuais servem de fallback, então a arte não bloqueia código. |

Pré-requisitos: (a) playtest das tasks `TASK-001..007` fechado (o layout do combate não muda debaixo do
tester); (b) `SPEC-045/046/047` aprovadas e implementadas; (c) a decisão da seção 6.

## 3. Estruturas (código)

Só desenho e input em `game/ui/`; `core` sem import de pygame, como hoje.

| Peça | Arquivo | Papel |
|---|---|---|
| Câmera | `game/ui/camera.py` (novo) | Estado + `update(dt, mouse)`; devolve deslocamento suavizado. Sem pygame além de tipos. Testável com números. |
| Cena em camadas | `game/ui/scene.py` (novo) | `Layer(image, depth)`; `Scene.draw(surface, camera)`. Cada camada é pré-escalada uma vez e guardada em cache. |
| Conteúdo declarativo | `game/ui/scenes_data.py` (novo) | Por sala: camadas (fundo, meio, frente), posição dos slots de inimigo, posição das portas. Dado, não código (`VSN-001`). |
| Combate | `game/ui/combat_view.py` (novo, extraído) | O desenho do `CombateScreen` sai de `app.py` (3037 linhas) **antes** de mudar o layout: primeiro refatoração sem mudar pixel, depois o layout novo. |
| Corredor | `game/ui/corridor_view.py` (novo) | Substitui `draw_map` (`map_view.py`); `MapaScreen` passa a chamá-lo. `node_at` vira `door_at`. |
| Transição | `game/ui/transition.py` (novo) | Zoom + fade ao entrar numa porta; reaproveita a camada de fade que já existe. |
| Ajuste | `game/ui/settings` (onde hoje ficam as preferências) | Opção "Reduzir movimento". |

`WorldMap.neighbors(current)` continua sendo a fonte de verdade de quais portas existem; a UI só decide
onde desenhá-las.

## 4. Especificidades por marco

### FP-0 Câmera com o mouse (sem arte nova)
- Fundo desenhado a **108%** e deslocado até **±4% da tela** (±51 px em x, ±29 px em y) seguindo o mouse.
- Suavização exponencial (`offset += (alvo - offset) * (1 - exp(-8·dt))`), para não tremer com o mouse.
- Profundidade: fundo `0,4` · meio `0,7` · inimigos `1,0` · frente `1,4` (fator sobre o deslocamento).
  Com uma imagem só (hoje), só o fundo e os inimigos se mexem.
- **Não se mexem:** mão, HUD, log, pilhas, dado, tela de pausa e qualquer overlay.
- **Cliques:** o retângulo do inimigo usado no clique e no hover é o **já deslocado** (uma função
  `enemy_rect(slot, camera)` para desenho e input; sem duas contas). Cuidado com o alvo "andando" sob o cursor
  durante o duplo clique da carta (`SPEC-018`): no clique, congelar o deslocamento por 150 ms.
- **Pausa:** com pausa (`SPEC-013/018`), overlay ou tutorial aberto, `update` da câmera para.
- **Reduzir movimento:** ligada, o deslocamento é 0. Padrão desligada; lembrar da preferência entre sessões.
- **Desempenho:** camada pré-escalada a 108% uma vez por sala (não `smoothscale` por quadro); o `blit` usa
  offset inteiro. Meta: sem queda perceptível a 60 fps.
- **Testes:** `camera` com mouse no centro/cantos/fora da janela, suavização convergindo, reduzir movimento;
  `enemy_rect` batendo com o desenho.

### FP-1 Combate de frente
- Inimigos em fileira no fundo do corredor; **PV e status abaixo** de cada um, e a **intenção acima** só quando uma carta a revela (hoje é só a
  barra).
- Mão em **leque** na borda inferior (arco calculado a partir do número de cartas; hover eleva e endireita a
  carta; vale para mão cheia, `SPEC-020`).
- **Livros nos cantos** = pilhas de compra e descarte do H3 (`pile_overlay.py` já existe; muda só a posição e o
  desenho). **Orbe de PV** no lugar do painel de PV; indicadores de Ação / Bônus / Reação onde a referência põe
  a energia.
- Grupo (`SPEC-037`): personagens viram orbes pequenos empilhados; o ativo em destaque.
- Passo interno: (1) extrair `combat_view.py` sem mudar pixel, com os 1119 testes verdes; (2) trocar o layout.
- **Intenção:** só aparece quando uma carta a revela (decisão 1); sem revelação, o espaço acima do inimigo fica vazio.

### FP-2 Corredor e portas
- Cada sala vira uma cena com **portas** nos slots definidos em `scenes_data.py`, uma por vizinho de
  `WorldMap`. Rótulo: nome da sala, ícone de tipo (`node_*.png` já existem) e estado (limpa, opcional, chefe).
- Hover: porta se ilumina e mostra o nome. Clique: `WorldMap.move_to` como hoje, e a câmera **entra** (zoom
  ~1,25× + fade, 400 ms, pulável com clique).
- **Salas bloqueadas / não visíveis:** portas trancadas com cadeado (como a referência) quando o nó existe mas
  ainda não está liberado. A bifurcação da Rachadura (SPEC-031) aparece como duas portas na mesma cena.
- **Situações e d20** (`SituacaoScreen`) aparecem sobre a cena, sem trocar de tela; Sorte fica no canto.
- Sem tela de mapa como principal: uma **visão do mapa de nós** continua acessível (botão/`M`) para orientação,
  pois um corredor esconde a bifurcação. O `map_view.py` atual fica como essa visão.

### FP-3 Recompensas
- "Escolha 1 de 3" ganha fundo e moldura da referência; três cartas em destaque, a escolhida sobe. Só
  apresentação: `choose_card_screen.py` e a regra (`SPEC-041`) não mudam.

### FP-4 Arte
- **Por sala, 2 camadas obrigatórias (`bg`, `fg`) e `mid` opcional:** `assets/rooms/<sala>/bg.png`, `mid.png`, `fg.png` (fg com alfa). Se faltar arquivo, cai
  no `sala_N_*.png` atual (regra do projeto: nunca bloquear lógica por arte).
- Total: 7 salas × 2 = 14 imagens (até 21 com o meio), mais molduras de recompensa, livros e orbes. Prompts em
  `.atena/generated/ART-PROMPTS-0NN-*.md` só depois da aprovação da spec, seguindo `SIS-004`.
- `scripts/process_art.py` ganha o caso de camada com alfa (chroma-key só para `fg`/`mid`).

## 5. Ordem de trabalho e critério de aceite

1. FP-0 (spec própria pequena ou parte da `SPEC-049`; sem arte). **Aceite:** com o mouse parado, nada mexe;
   com "reduzir movimento", nada mexe; clicar num inimigo em movimento acerta o inimigo certo.
2. Refatoração `combat_view.py` sem mudança visual. **Aceite:** testes verdes, print antes/depois idêntico.
3. FP-1. **Aceite:** playtest (task nova) com 1, 2 e 3 personagens; nada ilegível na resolução 1280×720 e em
   tela cheia.
4. FP-2 + FP-3. **Aceite:** percorrer M1 inteiro (7 salas, com o desvio da Rachadura) só por portas.
5. FP-4 por sala, sem bloquear os passos anteriores.

Cada passo é commit/PR separado e **precisa da aprovação do responsável**; nada é publicado (push) sem ela.

## 6. Decisões

Respondidas pelo responsável em 2026-09-20:

1. **Intenção do inimigo:** só nas cartas (Localizar Criatura e Visão Verdadeira), como hoje. Nada de intenção
   sempre visível; o espaço acima do inimigo só mostra a intenção quando uma carta a revela.
3. **Mapa de nós:** continua como visão secundária (botão/`M`).
4. **FP-0 antes das outras fases:** liberado, como protótipo para o playtest.

Recomendações para aprovar (pendentes):

2. **Portas por sala:** cenas próprias por sala, mas com **2 camadas obrigatórias (fundo e frente)** e o meio
   opcional: 14 imagens no mínimo, em vez de 21. Mantém a identidade de cada sala (a `sala_5b_porao_corredor` já é um
   corredor). Fallback para o fundo atual até a arte chegar; o corredor genérico só serve como fundo provisório.
5. **Paralaxe:** ±4% como padrão. Ficam dois parâmetros em `camera.py` (amplitude e suavização), ajustados no
   playtest; a intensidade da referência só se o Higor pedir, com "reduzir movimento" sempre disponível.

## 7. Riscos

- **`app.py` com 3037 linhas:** mexer no combate ali dentro é o maior risco de regressão; por isso a extração
  vem antes do layout novo.
- **Enjoo/incômodo com movimento:** mitigado pelo "reduzir movimento" e pelo limite de deslocamento.
- **Arte:** 21+ imagens novas; o fallback para os fundos atuais mantém o jogo funcionando.
- **Dependência do playtest:** se as F1–F3 atrasarem, só o FP-0 sai; o resto espera.
- **Save:** nenhuma mudança em `SaveState`; a preferência de movimento fica junto do perfil/configuração.
