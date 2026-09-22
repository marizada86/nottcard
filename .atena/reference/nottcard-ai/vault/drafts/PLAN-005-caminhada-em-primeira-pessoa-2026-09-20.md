---
id: "PLAN-005"
type: "plano"
title: "Caminhada em primeira pessoa: andar para frente e para trás e virar pelo caminho"
status: "draft"
created: "2026-09-20"
relations:
  - "[[PLAN-002-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-053-corredor-portas-e-recompensas-primeira-pessoa-fp2-fp3]]"
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-049-camera-com-o-mouse-primeira-pessoa-fp0]]"
sources:
  - "Responsável, 2026-09-20: o jogador deve conseguir andar para frente e para trás e se virar para os lados pelo caminho"
  - "Medições de 2026-09-20 (protótipos descartáveis no scratchpad): raycast de paredes e piso em Python puro"
---

# Caminhada em primeira pessoa

> Escrito para: Guilherme e Higor. Rascunho: nada aqui é regra até a aprovação de cada spec (`execution_approval: per-spec`).
> **Reabre uma decisão do PLAN-002**, que descartou raycasting quando a primeira pessoa era só paralaxe e portas. Agora o
> pedido é andar de verdade, e as medições abaixo mudam a conta de custo.

## 1. O que é pedido e o que muda

Hoje (SPEC-053) a exploração é uma **cena parada por sala**: você clica numa porta e a próxima sala chega. O pedido é **andar
pelo caminho**: avançar, recuar e virar (esquerda e direita) por corredores e salas, vendo o mundo se mover.

| Continua igual | Muda |
|---|---|
| `WorldMap` (o grafo lógico de 7 salas), regras de sala limpa, mochila, save | como o jogador **vai** de uma sala a outra: por passos numa grade, não por clique |
| Combate (SPEC-049/052) com o cenário pintado como pano de fundo | a tela de exploração vira um mundo 3D simples (`WalkScreen`) |
| Situações de d20 (SPEC-031/046), recompensas (SPEC-053) | portas passam a ser objetos do mundo (usam a arte `assets/doors/`) |
| Cartas, dados, HUD do combate | o mapa de nós vira **automapa** (M) |

## 2. Como renderizar: três caminhos e a recomendação

| Opção | Como | Arte que exige | Custo em código | Risco |
|---|---|---|---|---|
| **A. Salas paradas com 4 direções** | Cada sala tem 4 vistas pintadas (frente, esquerda, direita, trás); virar troca a vista, andar é fade | 7 salas x 3 vistas novas (bg e fg) = 42 imagens, e sem "andar" de verdade | P | Não cumpre o pedido: não há caminho contínuo |
| **B. Raycaster texturizado (recomendado)** | Grade de células; para cada coluna da tela, um raio encontra a parede e desenha a fatia da textura; piso e teto por projeção; sprites (inimigos, adereços) como cartazes | Texturas **ladrilháveis** (parede, piso, teto) por ambiente, mais adereços: fácil de gerar e reaproveitar | M/G | Aparência diferente das cenas pintadas do combate (mitigável, ver 6) |
| **C. Fatias de parede pré-pintadas** (estilo Eye of the Beholder) | Conjuntos de paredes por profundidade (1 a 4), frente e lados | 30 a 60 imagens em perspectiva coerente por ambiente: difícil de gerar com consistência | M | Arte cara e frágil |

**Recomendação: B, com um protótipo de decisão antes de qualquer spec.** Motivos:
- A arte é a parte que o projeto já sabe gerar (texturas e sprites no mesmo estilo pixel art sombrio).
- Dá giro suave e passo suave sem arte extra por direção.
- **O desempenho não é o risco que parecia.** Medi protótipos em Python puro, sem numpy, desenhando em 1280x720:

| Medição (protótipo descartável) | Resultado |
|---|---|
| Paredes texturizadas, 160 colunas de raio | 1,3 ms por quadro |
| Paredes texturizadas, 320 colunas | 2,5 ms por quadro |
| Paredes texturizadas, 640 colunas | 5,6 ms por quadro |
| Piso texturizado por pixel em 160x45 (o teto espelha o piso) | 4,7 ms por quadro |

Soma típica (320 colunas + piso): ~7 a 8 ms de 16,6 ms (60 fps), com folga para HUD, névoa e sprites. **Sem dependência
nova** (numpy não é necessário). Os números são de um protótipo simples, sem sprites nem névoa: a etapa W0 confirma no jogo.

## 3. Estruturas (código)

Regra de `VSN-001` mantida: `core` sem pygame, `ui` só desenha.

| Peça | Arquivo | Papel |
|---|---|---|
| Mapa em grade | `game/core/gridmap.py` (novo) | `GridMap`: células (parede, chão, porta), regiões por sala, gatilhos, leitura de mapas em texto. Dados, não código |
| Mapa do M1 | `game/core/dungeon_m1.py` (novo) | O desenho do M1 em texto (legenda: `#` parede, `.` chão, `D` porta, dígito = sala, `S` partida) |
| Caminhante | `game/core/walker.py` (novo) | Posição (x, y), direção (N/L/S/O), regras: andar, recuar, virar, bater na parede, abrir porta; devolve **eventos** ("entrou na sala 4", "porta") |
| Raycaster (matemática) | `game/ui/raycast.py` (novo, sem desenho) | DDA por coluna, distância, coluna da textura, piso: função pura, testável sem janela |
| Desenho do mundo | `game/ui/world_view.py` (novo) | Texturas em fatias pré-cortadas (cache), névoa por profundidade, sprites ordenados, piso e teto |
| Tela | `WalkScreen` em `game/app.py` (ou `game/ui/walk_screen.py`) | Substitui `MapaScreen` como exploração; entrada, animação de passo e giro, HUD de exploração |
| Automapa | `game/ui/automap.py` (novo) | Células visitadas reveladas; a visão de nós atual continua como resumo |
| Dados de arte | `game/ui/world_art.py` (novo) | Qual textura de parede, piso, teto e adereço cada sala usa (declarativo) |

`WorldMap` **não muda**: a grade só **produz** a mesma chamada de hoje (`move_to_node`) quando o jogador cruza a soleira de uma
sala vizinha. O caminho físico segue exatamente as arestas do grafo (1-2, 2-3, 2-4, 4-5, 5-6, 6-7), então nenhuma regra nova.

## 4. Movimento e controles

**Movimento em grade, passo a passo (recomendado):** a cada comando o jogador vai uma célula ou gira 90°, com animação suave
(estilo dos "dungeon crawlers" clássicos e da referência Shroom and Gloom). Vantagens: colisão trivial, encontros previsíveis,
testes sem tempo, e serve aos cartões de combate por turnos.

| Ação | Teclado | Mouse | Detalhe |
|---|---|---|---|
| Avançar | W, seta para cima | botão de seta na tela | 1 célula, 0,28 s, aceleração e desaceleração suaves |
| Recuar | S, seta para baixo | botão | 1 célula para trás **mantendo a frente** (não vira 180°) |
| Virar à esquerda / direita | A e D, ou setas esquerda e direita | botões | 90° em 0,22 s |
| Meia-volta | (opcional) X | | 180° em 0,35 s |
| Abrir a porta à frente | espaço (também abre ao andar) | clique na porta | animação curta |
| Mochila / mapa | as mesmas teclas de hoje, M abre o automapa | botões de hoje | |
| Olhar (paralaxe do mouse) | | mover o mouse | balanço leve (±2 a 3° visuais) reaproveitando a `Camera`; some com "reduzir movimento" |

- **Buffer de entrada:** um comando fica na fila enquanto o passo anterior termina; segurar a tecla repete. Nada de deslizar
  pelas paredes: bater na parede mostra um "empurrão" curto (2 px, 0,08 s) e um som de aviso (quando houver som).
- **Reduzir movimento** (já existe na SPEC-049): passos e giros viram **cortes instantâneos** (sem glide), preservando a
  navegação por grade.
- **Strafe (Q e E):** fora da v1 (o pedido não cita); é barato de acrescentar depois porque a grade já o permite.
- **Bússola:** N, L, S, O e o nome da sala no topo; setas na tela para quem joga só com mouse.
- **Câmera e overlays:** pausa, tutorial, mochila, notas (F5, F6, F7) seguem funcionando; o print da evidência sai sem HUD extra.

## 5. Integração com o jogo atual

1. **Entrada em uma sala:** cruzar a soleira chama `move_to_node(sala)`. Sala já limpa: só atravessa (como hoje). Sala nova:
   abre a situação (SPEC-031) ou o combate, com a mesma tela e o mesmo cenário pintado de agora.
2. **Encontros visíveis (recomendado):** os inimigos da sala aparecem como sprites no mundo (a arte `assets/enemies/*.png` já
   existe) e o combate abre ao chegar **adjacente** a eles ou ao passar da soleira da sala, o que vier antes. Depois de vencer, o
   sprite some. O grupo de slimes do corredor fica alinhado no corredor, como na fantasia da sala.
3. **Situações:** o "evento" da Rachadura vira um ponto de interação no fim do beco lateral; a bifurcação deixa de ser uma
   escolha de porta e passa a ser uma **encruzilhada física** no cais, onde você vira à esquerda ou à direita.
4. **Chefe e salas opcionais:** sem regra nova; as portas trancadas continuam podendo existir como células de porta com cadeado.
5. **Volta ao mundo:** depois do combate ou da situação, o jogador reaparece **na mesma célula e direção** (o `Walker` guarda).
6. **Save:** a posição e a direção **não** vão para o `SaveState` (a missão é toda em memória, como hoje); só o `WorldMap`
   (visitadas e limpas) segue como está. Nenhuma migração.
7. **Modo clássico:** manter o `MapaScreen` de portas (SPEC-053) como **opção nas configurações** durante os playtests. Se a
   caminhada falhar num teste, o jogador tem o modo anterior. Some quando a caminhada estabilizar.

### Esboço do M1 em grade (ilustrativo; a spec fecha o desenho)
Salas em retângulos, corredores de 1 célula de largura seguindo as arestas do grafo:

| Trecho | Tamanho | Observação |
|---|---|---|
| Sala 1, Docas | 7x5 | partida; cais e ruas |
| corredor 1→2 | 4 células | |
| Sala 2, cais (encruzilhada) | 9x5 | saídas: oeste (1), norte (3), sul (4) |
| corredor 2→3 e sala 3, Rachadura | 3 células + 5x5 | beco sem saída; evento da Tarn |
| corredor 2→4 e sala 4, porão (entrada) | 3 células + 5x5 | slime opcional |
| corredor 4→5 e sala 5, livros | 4 células + 7x5 | guardião-cópia |
| sala 6, corredor comprido | 9 células x 3 | grupo de 3 inimigos alinhado |
| sala 7, ritual | 9x7 | chefe |

O caminho 1→7 dá ~45 passos (cerca de 14 s andando sem parar); com combates e eventos, mais de uma sessão de jogo.

## 6. Arte necessária (só a lista; os prompts saem quando a spec for aprovada)

Reaproveitado sem mudança: **as 4 portas e o cadeado** (viram texturas de parede/porta no mundo), os **4 inimigos** (sprites), os
cenários pintados (continuam no combate), livros, orbe e gemas do HUD.

| Grupo | Itens (estimativa) |
|---|---|
| Paredes ladrilháveis | 7 ambientes (docas, cais atacado, pedra da Tarn, porão, biblioteca, corredor úmido, ritual): ~9 texturas |
| Piso e teto ladrilháveis | ~7 pisos e ~5 tetos (o exterior usa céu) |
| Céu / fundo do exterior | 1 a 2 (docas e cais sob a Tarn) |
| Adereços em cartaz | tocha, barril, caixote, livros, braseiro, cadáver de rede: ~8 |
| Marcadores | seta de porta, brilho de interação: 2 |

Total estimado: **35 a 40 imagens novas**, todas ladrilháveis ou em cartaz; nenhuma exige perspectiva. Para a coerência com o
combate, a paleta e a névoa por profundidade são as mesmas do bloco de estilo de `SIS-004`.

## 7. Fases, specs e critérios de aceite

| Fase | Spec (nova) | Entrega | Porte | Critério de aceite |
|---|---|---|---|---|
| **W0 Protótipo de decisão** | (sem spec; descartável, no scratchpad) | Corredor de teste com uma textura do jogo, virar e andar com HUD real de tela | P | 60 fps estáveis em 1280x720 numa máquina de teste; o Higor e você aprovam a "sensação" |
| **W1 Núcleo** | `SPEC-055` Mapa em grade e caminhante | `GridMap`, `Walker`, mapa do M1, eventos, testes puros | M | O caminho 1→7 é percorrível só por comandos; paredes bloqueiam; testes sem pygame |
| **W2 Mundo** | `SPEC-056` Renderizador do mundo | `raycast.py` e `world_view.py`: paredes, piso, teto, névoa, sprites, animação de passo e giro | G | passo e giro suaves; reduzir movimento corta; nada vaza pelas frestas |
| **W3 Integração** | `SPEC-057` Exploração por caminhada | `WalkScreen`, gatilhos de sala e encontros, automapa, modo clássico opcional, HUD | G | missão completa andando; combate e situação abrem e voltam à mesma célula |
| **W4 Arte do mundo** | `SPEC-058` Texturas e adereços | 35 a 40 imagens processadas, mapeadas por sala | G | as 7 salas com arte própria; fallback sem textura (cor lisa) |
| **W5 Ajuste e playtest** | tasks novas | tempos de passo e giro, névoa, controles | P | tasks de playtest aprovadas pelos testers |

Ordem: **W0 antes de tudo** (porta de decisão); W1 e W4 podem andar em paralelo (arte não depende de código); W2 depende do W1; W3
depende do W2. A arte do W4 pode começar assim que o W0 for aprovado, porque as texturas ladrilháveis não mudam com o código.

**Quando entra:** depois do playtest da 0.8.3 (TASK-012..014, que valida a primeira pessoa atual) e **não substitui** o
combate de frente; o W0 pode rodar já. O Brook (SPEC-042) e a caminhada são independentes.

## 8. Decisões (recomendações primeiro, para aprovar em bloco)

1. **Renderização:** raycaster texturizado (B), com o protótipo W0 como porta de decisão. (recomendo)
2. **Movimento:** em grade, passo a passo com giro de 90° (recomendo) ou livre, com WASD contínuo e mouse look (mais imersivo,
   mas quebra a colisão simples e os encontros previsíveis).
3. **Recuar:** um passo para trás mantendo a frente. (recomendo)
4. **Strafe (Q e E):** fora da v1. (recomendo)
5. **Encontros:** inimigos visíveis como sprites e combate ao chegar perto. (recomendo)
6. **Modo clássico de portas:** mantido como opção nas configurações durante os playtests. (recomendo)
7. **Paralaxe do mouse no mundo:** balanço leve, desligado por "reduzir movimento". (recomendo)
8. **Automapa:** revela as células visitadas; o mapa de nós atual continua como resumo. (recomendo)
9. **Encruzilhada física** no cais no lugar da escolha de porta da Rachadura. (recomendo)

## 9. Riscos

- **Aparência dupla:** o mundo texturizado e os cenários pintados do combate têm linguagens diferentes. Mitigação: mesmas paletas e
  névoa, e o combate continua sendo o "palco" pintado (como nos clássicos que trocam de tela ao lutar).
- **Desorientação:** virar demais sem referência. Mitigação: bússola, automapa e rótulo de sala.
- **Enjoo:** o giro e o passo suaves são movimento. Mitigação: "reduzir movimento" corta tudo em saltos instantâneos.
- **Arte ladrilhável gerada:** o gerador tende a errar a emenda. Mitigação: conferir a costura em uma amostra 3x3 antes de aceitar.
- **Escopo:** W2 e W3 são grandes. Cada uma com spec própria; nada começa sem aprovação; o modo clássico protege os playtesters.
- **Regressão:** `MapaScreen` e seus testes (portas) ficam intactos enquanto o modo clássico existir.

## 10. Validação (playtest)

Tasks previstas: andar e recuar em um corredor (colisão e ritmo), virar na encruzilhada do cais, chegar a cada sala e ver o
encontro ou a situação, abrir o automapa, jogar a missão inteira e voltar por salas limpas, e o mesmo com "reduzir movimento".
