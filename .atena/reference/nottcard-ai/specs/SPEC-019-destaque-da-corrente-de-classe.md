---
id: "SPEC-019"
type: "spec"
title: "Indicador fixo da Corrente de Classe: efetiva e quebrada em destaque"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-016-layout-do-jogador-trilho-direito]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
sources:
  - "FB-001 A4 (Higor, 2026-09-19), aprovado com as recomendações"
  - "ART-PROMPTS-002-feedback-2026-09-19.md (ícones combo_icon, _ativo, _quebrado)"
---

# Indicador da Corrente de Classe

## Problema

A Corrente (`ComboTracker.streak`, multiplicador 1–4) só aparece como texto flutuante
("Corrente 2x") no momento do dano. Não há indicador fixo, e o jogador não vê se a Corrente
está viva, quanto vale a próxima carta nem quando ela quebrou.

## Regras

1. **Indicador fixo** no painel do jogador (perto do nome e dos PV), com três estados:

| Estado | Quando | Ícone | Destaque |
|---|---|---|---|
| **Neutro** | `streak == 0` (início do combate ou depois de a quebra expirar) | `combo_icon` | discreto |
| **Efetiva** | a última carta jogada **contou** para a Corrente (`streak ≥ 1`) | `combo_icon_ativo` | borda dourada, pulso curto, o número sobe com um "pop" |
| **Quebrada** | uma carta que **não conta** foi jogada com `streak > 0` | `combo_icon_quebrado` | vermelho-oxblood, tremor, some depois de ~1,5 s e volta a Neutro |

2. **Número:** o multiplicador da **próxima** carta que conta (`[1,2,3,4][min(streak,3)]`) em
   fonte grande (≥ 40 px, `card_title_font`), escrito "x2", e **3 marcadores** (○●) com a sequência
   atual. Forma e texto além da cor, para não depender só de cor.
3. **Quebra:** o painel mostra também o valor perdido, "Corrente x3 perdida", por ~1,5 s.
4. **Só o que conta muda o estado:** carta que não conta com `streak == 0` não faz nada.
   A Reação usada não avança nem quebra (regra atual, SPEC-010). Cada novo combate zera.
5. **`core` sem pygame:** `ComboTracker` ganha `last_event` (`"avancou"`, `"quebrou"` ou `None`)
   e `broken_from` (streak perdido). A UI só lê esses campos; nenhuma regra muda.
6. **Fallback:** sem os PNGs, desenha um retângulo com o nome (`load_image`).

## Arte

- `combo_icon.png` já está no pipeline (128×128 com alfa).
- `combo_icon_ativo` e `combo_icon_quebrado` vieram com um **xadrez de transparência falso**
  embutido no fundo (o `_raw` tem fundo claro e opaco, não o verde-chroma pedido). O pipeline
  precisa de um passo de recorte por **flood fill** de pixels claros e neutros a partir das
  bordas, mais a remoção dos "buracos" internos grandes (dentro dos elos), ou regerar com
  fundo `#00FF00`. Testado no scratchpad: as bordas saem limpas e os buracos são removíveis
  por tamanho de componente (>3000 px); o núcleo do brilho azul do `_ativo` precisa de
  conferência visual.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/combat.py` | `ComboTracker.last_event`, `broken_from` (dados de leitura). |
| `game/ui/hud.py` | `draw_combo_indicator(surface, combo, pos, t)` com animação (pop, tremor, pulso). |
| `game/app.py` | Chama o indicador; guarda o instante da última mudança para a animação. |
| `scripts/process_art.py` | Modo de recorte de fundo claro para a categoria `hud` (ou `combo_*`). |
| Testes | `last_event` avança/quebra/None; quebra com streak 0 não dispara; o indicador desenha nos 3 estados; recorte do pipeline produz alfa. |

## Fora do escopo

Mudar a regra da Corrente, novos multiplicadores, som.

## Critérios de aceite

- [x] Os três estados aparecem no combate e o número mostra o multiplicador da próxima carta.
- [x] Ao quebrar, mostra "Corrente xN perdida" e volta ao neutro.
- [x] Legível sem cor (forma e texto).
- [x] `combo_icon_ativo` e `combo_icon_quebrado` com fundo transparente no jogo.
- [x] Testes passam.

## Ordem de execução

1. `ComboTracker.last_event`. 2. Recorte no pipeline e reprocessar os ícones. 3. Indicador e animação. 4. Testes e playtest.
