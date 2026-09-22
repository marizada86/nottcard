---
id: "SPEC-013"
type: "spec"
title: "Tela de tutorial (botão \"?\") com pausa do combate"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-004-cadencia-do-combate]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-010-reacao-cartas-escurecidas-e-ajustes-de-hud]]"
sources:
  - "Pedido do responsável em 2026-09-19: tela de tutorial explicando as mecânicas, acessível por um \"?\" em pleno combate, que pausa o contador"
  - "game/app.py (cronômetro do chefe: BOSS_DECISION_SECONDS baseado em time.time(); sequência de batidas por dt)"
---

# Tela de tutorial (botão "?") com pausa do combate

## Problema

O jogo já tem muitas regras (Ação/Bônus/Reação, d20 vs CA/CAM, crítico, Corrente
de Classe, HC, uso único, atributos) e nenhum lugar in-game que as explique. Um
jogador novo (ou um espectador de live) precisa sair do jogo pra entender o que
está vendo. O pedido: um **"?"** no combate que abre a explicação **sem perder
a partida**.

## 1. Comportamento

1. **Botão "?"** fixo no canto superior direito do combate (tecla **F1** também).
   Também aparece no **Menu**, pra ler antes de jogar.
2. Abre um **painel por cima do combate** (não é outra `Screen`: o estado do combate
   fica intacto e o jogador volta exatamente onde estava).
3. **Pausa total** enquanto aberto:
   - a sequência de batidas (dados rolando, números flutuantes, animações) **congela**;
   - o **cronômetro de decisão do chefe (45 s)** **para** e, ao fechar, continua
     de onde parou (o tempo com o tutorial aberto **não conta**);
   - **nenhuma entrada** chega ao combate (cartas, botões, Enter) até fechar.
   - Funciona **em qualquer momento**, inclusive no meio do turno do inimigo e na
     janela "Reagir?" (SPEC-010): ao fechar, a janela ainda está lá.
4. Fecha com **"?"/F1/Esc** ou botão **Fechar**. O **F12** (log dev) continua independente.
5. **Navegação por páginas**: setas ◀ ▶ / ← → e lista de tópicos à esquerda;
   cada página é curta (cabe sem rolar).
6. **Abre na página do contexto** *(proposta)*: durante a janela "Reagir?" abre em
   **Reação**; senão em **Objetivo e turno**.

## 2. Conteúdo (uma página por tópico)

| # | Tópico | Explica |
|---|---|---|
| 1 | Objetivo e turno | Baralho, mão (máx. 5), compra 1 por turno, descarte do excesso no fim do turno; vitória e derrota. |
| 2 | Ação, Bônus e Reação | Os 3 círculos (verde livre / vermelho gasto); qualquer ordem; o turno passa sozinho quando Ação e Bônus acabam; "Encerrar turno"; "Passar a Ação". |
| 3 | Atacar: o d20 | d20 + modificador vs CA/CAM; 20 natural = crítico (dobra a quantidade de dados), 1 natural erra; Golpe Perfurante. |
| 4 | Cores e Corrente de Classe | Vermelho/Amarelo/Azul/Roxo; compatibilidade de cor (50%); Corrente 2x/3x/4x e o que a quebra (carta roxa). |
| 5 | Reação | 1 por rodada, janela "Reagir?", Aparar (físico) e Contrafeitiço (mágico). |
| 6 | Habilidades de Classe e uso único | HC (1 uso por combate, volta no próximo); Poção (uso único na tentativa). |
| 7 | Atributos | Força, Inteligência, Constituição, Carisma; modificador = ⌊(valor−10)/2⌋; CA/CAM. |
| 8 | Dicas e atalhos | Cartas escurecidas não podem ser usadas agora; 1–5 escolhe carta, 0 passa a Ação, Enter encerra o turno, F1 tutorial, F12 log dev. |

**Fonte de verdade:** os números do texto (mão máx., 45 s do chefe, CA/CAM do Durvall,
ganho por modificador) **vêm das constantes do `core`**, não digitados no texto, pra
o tutorial não desatualizar quando um valor mudar. O texto explica; **não redefine**
nenhuma regra (as regras são as das SPEC-005/006/009/010 e do canon).

## 3. Arquitetura

- **Conteúdo como dado declarativo** (`game/ui/tutorial_content.py`): lista de
  `TutorialPage(id, title, lines)`; linhas com marcadores `{MAX_HAND}`, `{BOSS_SECONDS}`, etc.
  substituídos por valores reais na hora de mostrar.
- **`game/ui/tutorial.py`**: `TutorialOverlay` (estado: aberta?, página; `handle_event`,
  `draw`). Só desenho e input; sem regra de jogo.
- **Pausa** *(o ponto delicado)*: `App` guarda `self.tutorial`; enquanto aberto, o laço
  **não chama `screen.update(dt)`** (congela batidas, dados e números) e o combate
  recebe `pause()`/`resume()`: no `resume`, `turn_start += tempo_pausado`, então o
  cronômetro (baseado em `time.time()`) não perde segundos.
- Eventos: `App.handle_event` manda tudo pro overlay enquanto aberto; F1/"?" abre/fecha.
- Devlog (F12) registra "Tutorial aberto/fechado" (útil pra explicar tempo parado numa live).
- **Arte:** sem asset novo; o botão "?" é círculo desenhado em código. Fonte das
  cartas (Alegreya Sans / Cinzel) reaproveitada.

## 4. Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/ui/tutorial_content.py` (novo) | Páginas como dado; substituição de constantes. |
| `game/ui/tutorial.py` (novo) | Overlay, navegação, desenho. |
| `game/app.py` | Botão "?" no combate e no menu; F1; pausa no laço; `pause()/resume()` do `CombateScreen`. |
| `game/core/` | **Nenhuma mudança de regra.** No máximo expor constantes já existentes. |
| Testes | Pausa congela batidas e cronômetro e o resume compensa o tempo (relógio falso); entrada não chega ao combate; abre/fecha por "?", F1, Esc; fecha com janela de reação aberta e ela continua; páginas cobrem todos os tópicos e nenhum marcador fica sem substituir; smoke de desenho de cada página. |

## 5. Decisões (resolvidas pelo responsável em 2026-09-19)

1. O cronômetro do chefe continua sendo o único contador a pausar.
2. "?" no canto superior direito do combate.
3. Também no Menu.
4. **Não abre sozinho**, nem na primeira partida.
5. **Nada abre automaticamente**: só ao clicar no "?" (ou F1). Clicando durante a janela "Reagir?", abre na página de Reação; senão, em Objetivo e turno.
6. Só texto, com o **mínimo de ilustração**: apenas os círculos verde/vermelho (página 2) e amostras de cor (página 4), desenhados em código.

Histórico das propostas originais:

1. **"Contador" = cronômetro de decisão do chefe (45 s)?** É o único contador em tempo real
   hoje; o número do turno é discreto e já não avança sozinho. *(sim, é o que o plano assume)*
2. **Onde fica o "?"**: canto superior direito do combate. *(sim)*
3. **Também no Menu?** *(sim)*
4. **Abrir sozinho na primeira partida?** *(não: só sob demanda, pra não atrapalhar quem já conhece)*
5. **Abre na página do contexto** (Reação na janela de reação)? *(sim)*
6. **Só texto ou também exemplos ilustrados** (mini-carta, dado d20 desenhado)? *(só texto na 1ª versão; ilustrar depois)*

## 6. Fora do escopo

Tutorial interativo/guiado (combate de treino com passos forçados), setas apontando
elementos da tela, tradução para outros idiomas, arte/ilustração dedicada,
persistir "já viu o tutorial", tutorial das mecânicas ainda não implementadas
(Vantagem/Desvantagem, testes de morte etc.).

## 7. Critérios de aceite

- [x] "?" e F1 abrem o tutorial no combate e no menu; "?", F1, Esc e Fechar o fecham.
- [x] Com o tutorial aberto, dados, números flutuantes e batidas ficam parados.
- [x] No combate de chefe, o tempo com o tutorial aberto **não** é descontado dos 45 s.
- [x] Nada do combate reage a cliques/teclas enquanto aberto; ao fechar, o estado é idêntico (inclusive a janela "Reagir?").
- [x] As 8 páginas existem, navegam por setas/lista e usam valores reais do `core`.
- [x] O tutorial não altera nenhuma regra de jogo.

## 8. Ordem de execução (após aprovação)

1. Conteúdo declarativo + testes de cobertura das páginas.
2. `TutorialOverlay` (desenho e navegação).
3. Pausa: laço do `App`, `pause()/resume()`, testes de tempo com relógio falso.
4. Botão "?" no combate e no menu, F1, contexto da página inicial.
5. Playtest (chefe com o tutorial aberto por 20 s; abrir na janela "Reagir?") e registro em `EVID-00X`.

## 9. Atualização de 2026-09-19 (conteúdo)

O tutorial passou de 8 para **11 páginas** para cobrir SPEC-012, 014 e 015 e o novo trilho do jogador (baralho, indicadores e botões à direita da mão). Novas: **Tipos de carta**, **Combate em grupo** e **Personagens**. Revisadas: Ação/Bônus/Reação (posição dos botões), Atacar (fogo do Maelor usa CON), Cores e Corrente, Habilidades de Classe (HC de cada personagem), Atributos e Dicas (atalhos da janela "Reagir?"). Só descreve regras já existentes; a lista de tópicos ajusta o espaçamento ao número de páginas.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Hoje o tutorial tem 13 páginas (eram 8 na spec original); o teste de conteúdo cobre os valores reais do `core`.
