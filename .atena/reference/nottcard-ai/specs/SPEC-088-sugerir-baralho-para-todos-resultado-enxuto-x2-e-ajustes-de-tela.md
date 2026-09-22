---
id: "SPEC-088"
type: "spec"
title: "Sugerir baralho para qualquer personagem, resultado enxuto, x2 nas rolagens e ajustes de tela"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-072-tela-baralho]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-031-modo-exploracao]]"
sources:
  - "Higor, playtest da v0.11.0 (Hiago), 2026-09-20: itens 5, 6 e 8"
  - "Leoric, EV-Leoric-20260920-212314, notas 1, 7, 8 e 10"
---

# Sugerir baralho, resultado enxuto, x2 e ajustes de tela

> Aprovada pelo responsável em 2026-09-20 (`execution_approval: per-spec`). Só interface: nenhuma regra de jogo muda.

## 1. "Sugerir baralho" para qualquer personagem (item 5)
**Hoje:** na tela Baralho (`deck_screen.py`), o botão "Sugerir baralho para <personagem da última missão>" só serve esse personagem.
**Passa a ser:** o botão vira **"Sugerir baralho"**. Ao clicar, abre uma lista com **todos os personagens liberados** (retrato + nome + nível); escolher um aplica `collection.suggest_deck` (o preenchimento de vagas livres com cartas da cor da classe **dele**) ao baralho ativo e mostra o resumo do que entrou. Esc/clique fora fecha sem mudar nada. Com um único personagem liberado, aplica direto.
- A regra de `suggest_deck` não muda; só quem é o alvo.

## 2. Resultados enxutos (item 6)
Há o log de dano e o F12 para o detalhe; a tela passa a mostrar **só o total**.
- **Combate:** a narração de cada golpe (`combat_narration.py`) vira uma linha só, ex.: "Durvall acerta Slime: **7 de dano**" / "Slime erra Maelor" / "Falha crítica!". Sem a soma dos dados, modificadores e CA na tela.
- **Interações/eventos:** o resultado de um teste mostra "**d20 + mod = total** contra DC — passou/falhou" numa linha (o número do dado em destaque); o detalhe de bônus por origem (SPEC-067) fica no log e no F12.
- O log de combate e o F12 continuam completos (fonte do detalhe).
- Fora daqui: os números flutuantes de dano (SPEC-084 do PLAN-015).

## 3. Botão "x2" nas rolagens de eventos e interações (item 8)
O botão redondo 1x/2x (`game/ui/speed.py`, hoje só no combate) passa a aparecer também na **`SituacaoScreen`** (eventos e interações de exploração) e acelera a rolagem do dado e o revelar do resultado (`scale = self.speed` também nessa tela, `app.py:3518`). O estado 1x/2x é o **mesmo** do combate e continua guardado enquanto o jogo roda; o cronômetro de decisão do chefe segue em tempo real. "Reduzir movimento" pula a animação como hoje.

## 4. Achados das notas do Leoric
| Nota | Problema | Ação |
|---|---|---|
| 1 | Textos se sobrepondo na escolha de carta (`ChooseCardScreen`, "O cais atacado") | Reposicionar/quebrar linha; teste de layout com os textos mais longos |
| 7 | "Cartas extras indo para todos os baralhos" (combate, "O ritual") | **Investigar primeiro** (recompensa/carta temporária entrando no baralho de cada membro?); corrige se for bug, senão explica na tela |
| 8 | A bolsa cobre o botão de equipamento (`WalkScreen`) | Reposicionar a bolsa/os botões da caminhada sem sobreposição |
| 10 | O sinal do teste de Constituição cobre o bônus do 3º personagem (Docas) | Ajustar a coluna de testes com 3 membros |
| 4 e 6 | Pilha de livros e pilha de ossos são só cenário | **Decisão pendente:** deixar como cenário (recomendado, já é a SPEC-054) ou dar interação; **não** entra neste corte |

## 5. Esc abre o menu também na exploração
**Causa:** `App._can_pause()` (`app.py`) devolve verdadeiro só para `CombateScreen`, então o Esc (e o botão "II") não fazem nada na caminhada, no modo de portas e nas telas de evento/interação.
**Passa a ser:** `_can_pause()` vale também para `WalkScreen`, a exploração por portas e a `SituacaoScreen`, **exceto** com uma sobreposição própria aberta (mochila, automapa, tutorial, bloco de notas, catálogo, seleção de opções com confirmação), onde o Esc continua fechando essa sobreposição primeiro. Fora do combate o Esc **sempre** abre o menu.
- As telas de exploração já têm `pause()`/`resume()` (`walk_screen.py`); o menu reaproveita `PauseMenu`.
- Itens do menu fora do combate: Continuar, Tutorial, Catálogo, Bloco de notas, Print, Exportar, Movimento da câmera e **Desistir** (mesma regra: a missão falha e o XP acumulado é mantido). A tela de resultado e o Login não abrem o menu.
- O botão "II" e o "x2" (§3) aparecem nessas telas.
- **Conferir:** onde a `SituacaoScreen` já usa Esc (`app.py:1077`/`1307`, ex.: fechar a confirmação) vale o mais interno primeiro.

## 6. Testes
- Esc na caminhada, nas portas e numa situação abre o menu e pausa; Continuar retoma no mesmo passo; Desistir falha a missão mantendo o XP; com a mochila/automapa/tutorial abertos o Esc fecha só eles.
- Sugerir baralho: escolher cada personagem aplica a cor da classe certa; cancelar não muda; com 1 personagem aplica direto; baralho cheio não muda e avisa.
- Resultado: as strings de combate e de teste trazem só o total (sem "CA", sem lista de modificadores); o log/F12 mantém o detalhe.
- x2: `SituacaoScreen` acelera (dt × 2), o botão alterna e o estado é compartilhado com o combate; o cronômetro do chefe não acelera.
- Layouts das notas 1, 8 e 10: nenhuma sobreposição de retângulos com 1, 2 e 3 personagens (teste de geometria dos rects).
- Nota 7: teste que reproduz a recompensa e prova em quem o baralho muda.
