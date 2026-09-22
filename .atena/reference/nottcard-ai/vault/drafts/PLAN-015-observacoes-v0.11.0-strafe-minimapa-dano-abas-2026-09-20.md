---
id: "PLAN-015"
type: "plano"
title: "Observações da v0.11.0: andar de lado sem virar, minimapa, números de dano e abas deslizantes"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[SPEC-064-teclas-da-caminhada]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
  - "[[SPEC-003-feedback-de-golpe]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
sources:
  - "Responsável, 2026-09-20: quatro observações sobre a v0.11.0, com print da tela Catálogo e conquistas"
---

# Observações da v0.11.0

Rascunho: nada aqui é regra até cada spec ser aprovada (`execution_approval: per-spec`). Onde há **[decisão]**, a recomendação vem primeiro.
Commit, merge e publicação seguem exigindo aprovação explícita.

| # | Observação | Onde mora hoje | Tamanho | Spec proposta |
|---|---|---|---|---|
| 1 | A/D andam de lado sem virar a visão | `Walker.strafe_*` (`game/core/walker.py`), `WalkScreen` | pequeno | SPEC-090 |
| 2 | Minimapa no canto inferior esquerdo, com seta | `automapa.py` (o mapa do M), `walk_screen.py` | médio | SPEC-083 |
| 3 | Números de dano maiores, com estilo e efeitos | `damage_fx.py` (`FloatingNumber`), pontos de `spawn` no `app.py` | médio | SPEC-084 |
| 4 | Abas do catálogo passam da tela: deslizar e arrastar | `collection.py` | pequeno | SPEC-085 |

Ordem recomendada: **4, 1, 2, 3** (do que destrava mais rápido ao que mais mexe em desenho). Nenhuma depende de arte nova.

---

## 1. Andar de lado (A e D) sem virar a visão

### Hoje
A SPEC-064 (D12 do PLAN-008) definiu A/D como "gira e anda": `strafe_left()` = `turn_left() + forward()`. A tela enfileira o giro e depois o passo, e a
câmera acaba virada 90 graus. O pedido reverte isso: **a visão fica reta**.

### Como fica
- `Walker.strafe_left()/strafe_right()` passam a dar **um passo lateral sem alterar `facing`**: a célula alvo é a da esquerda/direita da frente atual
  (`DIRS[(facing - 1) % 4]` / `[(facing + 1) % 4]`, a conferir a ordem de `DIRS` no núcleo). Eventos: `Moved` (com um campo novo `side` para a UI
  saber que é lateral) ou `Blocked`; abrir porta e entrar em sala funcionam como no passo à frente.
- `WalkScreen`: o passo lateral usa a **mesma animação de movimento**, com `vis_angle` fixo (o raycast já desenha o deslocamento pela posição). O
  giro em fila e o "primeiro giro, depois passo" (SPEC-064) deixam de existir para A/D.
- **Bater na parede ao lado:** a batida (`bump`) empurra para o lado em vez de para a frente (hoje usa o vetor de frente).
- **Segurar A/D:** repete o **mesmo passo lateral** (hoje repete só o passo à frente, já que o giro era feito uma vez).
- Q/E, ←/→ continuam virando; W/S, X e M não mudam. Setas ←/→ seguem como giro.
- Textos: rótulos "Esquerda (A)"/"Direita (D)" e a legenda "A/D andar de lado" já servem; a página "Explorar" do tutorial e o guia do playtester ganham "a
  visão não gira".
- Modo clássico de portas e o mapa de nós: intocados.

### Testes
Núcleo: nas 4 direções, o passo lateral muda `x,y` e **não muda `facing`**; contra parede vira `Blocked` sem girar; abre porta e entra na sala. Tela: `vis_angle`
não muda durante o passo; a batida vai para o lado; segurar A repete lateral; a SPEC-064 é atualizada (os testes que esperavam `Turned` em A/D mudam).

### Decisão
**D1.** Reverter a SPEC-064 nesse ponto (recomendado). Alternativa: manter o comportamento antigo numa opção do perfil ("A/D viram").

---

## 2. Minimapa da exploração

### O que é
Um painel pequeno e estilizado, no canto **inferior esquerdo** da caminhada, que resume o mapa do **M** para orientar o jogador, com uma **seta** que marca onde
ele está e para onde olha.

### Design
- **Área:** o painel fica em x 12 a 164 e y 604 a 708 (152x104), fora dos seis botões (que começam em x 165) e da legenda. O Mochila/Mapa e a Bolsa ficam no
  canto superior esquerdo, sem conflito.
- **Recorte:** mostra uma **janela local** de 19x13 células a 8 px, **centrada no jogador** (o mapa inteiro tem 51x24 e a 4 px ficaria ilegível).
- **Só o que o jogador viu:** reusa `revealed_cells` do automapa (células pisadas e as vizinhas). Sem nada revelado além disso, a névoa da guerra fica escura.
- **Estilo:** fundo escuro translúcido, moldura fina na cor do painel do jogo, células com a mesma paleta do automapa (chão, visitado, parede só onde toca chão
  conhecido, porta em âmbar, sala atual mais quente), bordas suaves e um leve brilho no chão pisado. Rótulo "M" no canto para lembrar que o mapa completo abre com M.
- **Seta do jogador:** triângulo âmbar com contorno escuro e pequeno halo, apontando para o `facing`. Usa o **ângulo e a posição animados** (`vis_angle`,
  `vis_pos`), então gira e desliza junto com a câmera. Sem "N" fixo: a orientação do mapa é a do mundo (norte para cima) e a seta mostra a direção.
- **Marcadores opcionais (não obrigatórios):** pontinho para sala não resolvida à vista e para evento por perto (usa `event_marker_cells`), se a leitura não poluir.
- **Quando aparece:** só na caminhada, sem sobreposições abertas (mochila, mapa, tutorial, pausa) e some no modo clássico de portas. O F6 (print) inclui o minimapa.
- **Reduzir movimento:** a seta salta sem interpolar.

### Código
Módulo novo `game/ui/minimap.py` com funções puras (`window_cells(grid, known, center, cols, rows)`, `arrow_points(center, angle, size)`) e `draw_minimap(surface, rect, walker, world, pos, angle)`;
`WalkScreen._draw_hud` chama. Reusa `revealed_cells` e as cores do `automap.py` (mover as constantes para um lugar comum).

### Testes
Janela centrada e recortada nas bordas do mapa; só células reveladas; a seta aponta para cada `facing` e acompanha `vis_angle`; o painel não cobre os botões (retângulos
disjuntos); desenha sem erro com o mapa vazio, no canto do mapa e com a sala atual; não desenha no modo de portas.

### Decisões
**D2.** Janela local centrada (recomendado) ou o mapa inteiro em miniatura. **D3.** Marcadores de sala/evento no minimapa: incluir (recomendado só para
evento, que ajuda a guiar) ou deixar só o terreno.

---

## 3. Números de dano com mais presença

### Hoje
Os números vêm de `FloatingNumber` (`game/ui/damage_fx.py`): fonte **padrão do sistema** (`theme.font`, a fonte reserva do pygame), base 44 px, x1,25 a partir
de 10 de dano e x1,5 a partir de 20, contorno de 2 px em 8 direções, sobe 70 px e some em 1,6 s. É re-renderizado a cada quadro. Vários pontos do `app.py` criam números
(dano da carta, bônus de passiva e de Poder Místico, dano no jogador, cura, "Acertou!", "Crítico!").

### O que muda
1. **Fonte:** uma fonte de exibição em vez da padrão. Candidatas já no projeto: **Cinzel Decorative Bold** (a dos títulos) e **Alegreya Sans Bold**. Passo 1 da
   implementação: renderizar uma folha de amostra com os dígitos de cada uma e escolher; se nenhuma agradar, propor uma fonte livre (OFL) nova (com o `OFL-*.txt`
   junto, como as atuais).
2. **Tamanho:** base do dano da carta de 44 para **64 px**, degraus x1,3 (10+) e x1,7 (20+); os demais números (cura, bônus, estados) sobem na mesma proporção.
   O número é mantido dentro da tela (recorte nas bordas).
3. **Estilo:** preenchimento com **degradê vertical** (mais claro em cima, cor cheia embaixo), **contorno grosso** escuro de 3 px, **sombra projetada** e, no crítico e
   nos danos altos, um **halo** na cor do dano. A cor de cada tipo continua a de hoje (por cor de carta, cura verde, bloqueio cinza).
4. **Movimento:** **"pop"** de entrada (escala 0,5 → 1,25 → 1,0 em 0,18 s), subida com leve arco lateral, permanência e fade nos últimos 30%. Crítico e dano
   alto ganham **tremor curto** e o número fica um pouco mais na tela.
5. **Efeitos:** ao aparecer, um punhado de **faíscas** na cor do número (reusa o sistema de partículas do `HitEffect`); no **crítico**, uma explosão dourada e o
   texto "CRÍTICO!" com o mesmo estilo; no dano que **elimina** o inimigo, faíscas maiores. Efeitos no máximo por número, para não lotar a tela em ataques em área.
6. **Desempenho:** guardar em cache a superfície estilizada por (texto, tamanho, cor, estilo); hoje ela é refeita a cada quadro.
7. **Acessibilidade:** com "reduzir movimento" (`App.reduce_motion`) não há pop, tremor nem faíscas: só fade e subida curta. O contraste com o fundo é garantido
   pelo contorno e pela sombra.

### Testes
Tamanho por faixa de dano; a fonte é a escolhida e o texto continua legível (contorno presente); o degradê difere entre o topo e a base; a linha do tempo do pop
(escala inicial, pico, final) e o fim de vida; `reduce_motion` desliga pop, tremor e faíscas; o cache devolve a mesma superfície; os limites da tela; as
faíscas nascem só nos casos previstos e param.

### Decisões
**D4.** Fonte: Cinzel Decorative Bold ou Alegreya Sans Bold (a decidir na folha de amostra); nova fonte só se você aprovar. **D5.** Intensidade: os efeitos
completos (faíscas, tremor, explosão) só no crítico e nos danos altos (recomendado), ou em todo número.

---

## 4. Abas do catálogo que deslizam

### Hoje
A fileira de abas do "Catálogo e conquistas" é fixa: **6 abas x (200 + 12 px) = 1272 px** dentro de um painel de 1180 px. A última ("Conquistas") sai do painel e da tela,
como no print. Com os três personagens que ainda vão entrar (Korrak, Leoric, Erik) seriam 9 abas.

### O que muda
Um componente reutilizável **`TabStrip`** (`game/ui/tab_strip.py`), usado pelo catálogo:
- A fileira fica **recortada na largura do painel** e desliza para a esquerda e a direita.
- **Arrastar** com o mouse (clicar e arrastar), com limiar de ~6 px para separar clique de arraste, e **roda do mouse**; opcionalmente inércia curta.
- **Setas "‹ ›"** clicáveis nas pontas, que somem quando não há mais para onde ir, e um **esmaecido** nas bordas onde há mais abas escondidas (a dica de "tem mais").
- A **aba ativa entra sempre na área visível** (ao abrir, ao trocar por teclado e ao clicar).
- **Teclado:** ←/→ (ou Q/E) trocam de aba; Tab avança.
- A fileira **não** desliza se as abas couberem (o comportamento de hoje, sem setas).
- Toque/clique curto continua trocando a aba; um arraste não troca.

### Aplicação
Catálogo e conquistas (agora) e qualquer tela futura com muitas abas. A loja tem só 2 abas e fica como está. O painel de **conquistas** dentro do catálogo também
não tem rolagem (linhas fixas de 104 px); anotar, sem entrar nesta spec, que ele precisa da mesma lógica quando passar de 4 conquistas.

### Testes
O recorte cobre as abas ocultas; arrastar move a fileira e nunca além dos limites; um clique sem arraste troca a aba e um arraste não; a roda desliza; as setas
aparecem só onde há mais; a aba ativa fica visível ao trocar; com poucas abas nada desliza; o print da tela mostra as 6 abas alcançáveis (a de Conquistas acessível).

### Decisão
**D6.** Deslizar e arrastar como você recomendou (recomendado). Uma correção mínima alternativa seria encolher as abas para 178 px e caberem as 6, mas ela
volta a estourar com o 7º personagem.

---

## Sequência e risco

1. **SPEC-085 (abas)**: isolada, sem risco de jogo. 2. **SPEC-090 (A/D)**: muda o núcleo e testes da SPEC-064; risco médio (filas de comando, batidas). 3. **SPEC-083
(minimapa)**: só desenho. 4. **SPEC-084 (números)**: mexe em muitos pontos do `app.py`; risco de desempenho e de legibilidade (por isso a folha de amostra e o cache).

Tudo isso entra numa versão 0.11.1 junto com o que já está pronto e sem commit (faces ilustradas dos dados, SPEC-081).

## Perguntas
1. D1: reverter a SPEC-064 nas teclas A/D? 2. D2/D3: minimapa com janela local, marcador só de evento? 3. D4/D5: fonte dos números e a intensidade dos efeitos?
4. D6: abas deslizantes como no plano?

## Review record
- Proposed by: Claude, 2026-09-20, a partir das quatro observações do responsável.
- Reviewed by: responsável do projeto, 2026-09-20 (pedido "crie as specs fazendo as mudanças": as decisões D1 a D6 seguiram as recomendações).
- Implementado em 2026-09-20: SPEC-085 (abas), SPEC-090 (A/D; o número 082 já era de outra spec, dos inimigos de corpo inteiro), SPEC-083 (minimapa) e SPEC-084 (números de dano).
