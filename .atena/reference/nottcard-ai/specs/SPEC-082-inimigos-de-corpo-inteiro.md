---
id: "SPEC-082"
type: "spec"
title: "Inimigos de corpo inteiro, recortados, com névoa de chão por código"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[ART-PROMPTS-021-inimigos-corpo-inteiro-2026-09-20]]"
  - "[[ART-PROMPTS-001-m1-pixel-art]]"
  - "[[SPEC-052-combate-de-frente]]"
  - "[[SPEC-054-arte-em-camadas]]"
  - "[[SPEC-079-layouts-de-classe-mortes-e-moldura-nevoa]]"
  - "[[PLAN-014-producao-imagens-molduras-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'No momento eles são quadrados como se fossem fotos de cartas. Eles devem ser inimigos de corpo inteiro. Em locais com névoa, deve haver névoa no ambiente'"
  - "Responsável, 2026-09-20: 'tudo aprovado de acordo com as recomendações' (abordagem A: sprite recortado + névoa de chão por código; Mímico incluído)"
---

# Inimigos de corpo inteiro

Hoje cada inimigo é um retrato quadrado 1024x1024 de fundo opaco (`ART-PROMPTS-001` §3), mostrado em 160x160 com borda no combate
e dissolvido por uma máscara redonda na caminhada. Passam a ser **figuras de corpo inteiro, verticais, com fundo transparente**, que
ficam sobre o cenário da sala. A névoa do ambiente vem de duas fontes: massas de névoa **opacas coladas ao corpo, desenhadas na arte**,
e uma **faixa de névoa translúcida de chão desenhada por código** nas salas que têm névoa.

## Arte (contrato de imagem)
- `assets/enemies/<slug>.png`, slugs inalterados: `criatura_corrompida`, `slime_corrosivo`, `guardiao_copia`, `guardiao_verdadeiro`,
  `mimico`.
- Bruto: 1024x1536 (2:3 vertical), fundo **magenta chapado `#FF00FF`** (o verde não serve: a névoa é esverdeada). Salvo em
  `assets/_raw/enemies/<slug>.png` (fora do git).
- Final: PNG RGBA de **320x480**. O pipeline **não recorta ao conteúdo**: a posição dos pés e a altura relativa de cada inimigo
  (definidas nos prompts) precisam sobreviver. Os pés ficam a ~94% da altura do quadro.
- Sem chão pintado, sem parede, sem sombra projetada, sem texto. A névoa dentro da arte é sempre opaca e de borda dura (névoa
  translúcida não sobrevive ao chroma-key).

## Processamento (`scripts/process_art.py`)
- A categoria `enemies` deixa de estar em `RESIZE_SIZES` (512x512 opaco) e ganha via própria: `_key_out_exact_magenta` (a mesma das
  molduras de carta), depois `_resize_nearest` para 320x480, sem `_crop_to_content`.
- Arte antiga (sem canal alfa) continua carregável: ver "Retrato legado" abaixo.

## Combate (`game/ui/hud.py`, `game/ui/combat_view.py`, `game/app.py`)
- `ENEMY_ART_SIZE` passa de `(160, 160)` para **`(160, 240)`**. A largura não muda, então `enemy_positions` (centro e espaçamento do
  grupo de 3) segue igual; só a altura cresce. O `y` inicial e o `ENEMY_BAR_DY` são revistos para que arte, nome, barra de PV, CA/CAM,
  status e "Próximo: ..." caibam na altura da tela de combate sem tocar a mão de cartas (validar em captura, com 1 e 3 inimigos; se
  apertar, subir o `y` da fileira antes de reduzir a arte).
- Some a **borda retangular** de 3 px (não há mais quadro). O contorno de mira (`is_target_hint`) passa a contornar a **silhueta**
  (máscara da arte, contorno de 2 px na cor `theme.AIM_LINE_COLOR`), não o retângulo. O `rect` continua sendo a área clicável.
- O fade de morte (escurece e some) continua igual.
- **Retrato legado:** se o PNG carregado não tem pixel transparente, ele é tratado como o retrato quadrado antigo: desenhado em
  160x160 alinhado à base do `rect`, com a borda antiga. Isso mantém o jogo inteiro enquanto a arte nova não chega, inimigo por
  inimigo.

## Névoa de chão (por código)
- Dado declarativo novo em `Room` (`game/core/rooms.py`): `fog: Optional[tuple[int, int, int]] = None`, a cor da névoa da sala.
  Valores: sala 2 (cais), 4 (entrada do porão) e 6 (corredor) = cinza-esverdeado escuro `(96, 120, 108)`; sala 7 (ritual) =
  arroxeado `(96, 70, 128)`; sala 5 (sala de livros) e demais = `None`. O `core` continua sem importar pygame.
- `draw_enemy_panel` recebe `fog: Optional[tuple]`. Com cor, desenha, **depois** da arte e **antes** das barras, uma faixa sobre os
  pés: a metade inferior da arte, ~30% mais larga que ela, feita de 5 a 7 elipses translúcidas (alfa máximo ~110, mais denso rente ao
  chão e ralo no topo) com deriva horizontal lenta (~6 px/s, fases distintas por inimigo) para não parecer estática. A superfície é
  montada uma vez por cor e reutilizada; só o deslocamento muda por quadro.
- A faixa é escurecida e some junto no fade de morte.
- O Mímico (evento pode acontecer em qualquer sala) usa a névoa da sala onde estiver.

## Caminhada em primeira pessoa (`game/ui/world_art.py`)
- `enemy_billboard` deixa de aplicar a máscara redonda: a arte já tem alfa e vira cartaz como `prop_billboard` (`BILLBOARD_SIZE`
  agora 256x384 para os inimigos, com o alfa preservado). Retrato legado mantém a máscara redonda de hoje. Sem névoa de chão por
  código no mundo (fora do escopo).

## Fora
Animação de idle por quadros, arte de golpe/ataque, sombra projetada, versão por sala do mesmo inimigo, névoa de chão na caminhada,
inimigos de outras missões (M2+).

## Testes
- `process_art`: `enemies` remove o magenta exato, não recorta, entrega 320x480 com alfa e mantém o pixel dos pés na mesma linha.
- `enemy_rect` tem 160x240; `enemy_positions` inalterado para 1, 2 e 3 inimigos.
- Arte com alfa: sem borda desenhada; arte opaca (legado): borda e 160x160 na base do `rect`.
- Névoa: `fog=None` não desenha nada; com cor, escurece só pixels dentro da faixa; `Room.fog` das salas 2, 4, 6 e 7 preenchido e das
  demais `None`; `core` continua sem import de pygame.
- Layout do combate (`test_combat_layout`): arte, barra e textos dentro da tela e sem sobrepor a mão, com 1 e 3 inimigos.
- `enemy_billboard` de arte com alfa preserva o alfa e não aplica a máscara; legado mantém.
