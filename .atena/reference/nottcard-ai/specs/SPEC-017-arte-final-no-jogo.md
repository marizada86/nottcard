---
id: "SPEC-017"
type: "spec"
title: "Arte final no jogo: pipeline de asset e cenário de combate"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-014-combate-com-multiplos-inimigos]]"
  - "[[SPEC-016-layout-do-jogador-trilho-direito]]"
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
sources:
  - "Análise das imagens geradas em 2026-09-19 (16 cartas, 4 inimigos, 2 retratos, arma do Durvall, salas 1 e 2, combo_icon)"
  - ".atena/generated/ASSETS-PENDENTES-001.md e ART-PROMPTS-001-m1-pixel-art.md"
---

# Arte final no jogo

## Problema

A arte gerada entrou crua em `assets/` e o jogo ainda não a aproveita bem:

- **Peso:** `assets/` tem 94 MB (57 MB sem `_raw`); as cartas sozinhas, 30 MB (16 PNGs de
  1536×1024 mostrados a ~134×92 px). O CI empacota `assets/` inteiro (`--add-data`), então o
  `.exe` sairia de 23,7 MB para cerca de 80 MB e extrairia mais devagar a cada abertura.
- **Redução ruim:** `load_image` usa `smoothscale`; reduzir 1536 px para 134 px borra a pixel art
  (a SIS-004 pede downscale com nearest-neighbor). `process_art.py` só normaliza cartas,
  inimigos e retratos, sem redimensionar.
- **Combate sem cenário:** `CombateScreen.draw` só preenche `BACKGROUND_COLOR`; as salas aparecem
  como miniatura de 320×200 na exploração. O prompt da sala do corredor já assume o cenário como
  fundo do combate ("o chão fica livre para três inimigos").
- **Inimigos com fundo opaco** (azul-escuro liso): aparecem como quadrados sobre o fundo.
- **Faltam 5 cenários** (salas 3, 4, 5, 6 e 7) e o `combo_icon` tem fundo preto opaco e não é
  carregado por nenhum código.

## Regras

### 1. Pipeline de tamanho (`scripts/process_art.py`)

Cada categoria ganha um tamanho final. As matrizes grandes ficam em `assets/_raw/` (fora do
git e do exe).

| Categoria | Origem | Tamanho final | Exibido em |
|---|---|---|---|
| `cards` | 1536×1024 | 480×320 | ~134×92 |
| `enemies` | 1254×1254 | 512×512 | 160×160 |
| `portraits` | 1536×1024 | 640×427 | ~300×190 |
| `items` | 1254×1254 | 512×512 | — |
| `rooms` | 1672×941 | 1280×720 | 1280×720 (combate) / 320×200 |

- **Passo 0 (decisão visual, antes de processar tudo):** comparar em 2 cartas o redimensionamento
  **suave** (Lanczos) com o **nearest-neighbor em grade real** (ex.: 256×171, exibida com fator
  inteiro). A arte gerada não é uma grade de pixels de verdade, então nearest pode serrilhar; o
  responsável escolhe olhando. **Decidido em 2026-09-19: opção A (suave, Lanczos).**
- O script é **idempotente** e só lê de `assets/_raw/`; a saída sobrescreve `assets/<categoria>/`.
- **Orçamento:** `assets/` versionado fica abaixo de ~20 MB.
- Mover as imagens 1536×1024 já geradas para `assets/_raw/<categoria>/` antes de processar
  (hoje elas estão direto em `assets/<categoria>/`).

### 2. Cenário de combate

- O `CombateScreen` recebe o `asset_id` da sala e desenha `rooms/<asset_id>.png` a 1280×720 como
  fundo, com um escurecimento (`draw_scrim`, alfa a calibrar em ~130–160) para manter a leitura
  da mão, das barras e do trilho.
- Sem arte da sala (ainda não gerada), cai no fundo liso atual — não bloqueia.
- O log, o orbe e os textos continuam legíveis: critério de aceite visual, não só de teste.

### 3. Sprites dos inimigos

O fundo opaco dos inimigos vira parte do desenho: **moldura fina** (borda + leve sombra) em volta
do retrato, em vez de tentar recortá-lo. Recorte/alfa fica para uma regeração futura com chroma.

### 4. `combo_icon`

Fora deste escopo de código: **regenerar com fundo chroma verde** (como os outros ícones de HUD)
quando a UI passar a usá-lo; por ora, sai da lista de pendências críticas.

### 5. Pendências de arte

Atualizar `ASSETS-PENDENTES-001` (fonte: `ART-PROMPTS-001`) marcando o que já existe e a ordem
de geração dos 5 cenários: **corredor (sala 6)** primeiro, porque é onde os 3 inimigos aparecem
lado a lado; depois ritual (7), livros (5), entrada do porão (4) e rachadura (3).

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `scripts/process_art.py` | Tamanhos finais por categoria; leitura de `_raw`; saída idempotente. |
| `game/ui/assets.py` | Sem mudança de API; recebe imagens já no tamanho final. |
| `game/app.py` | `CombateScreen` recebe o cenário da sala e o desenha com scrim. |
| `game/ui/hud.py` | Moldura do retrato do inimigo. |
| `.atena/generated/ASSETS-PENDENTES-001.md` | Checklist e ordem de geração atualizados. |
| Testes | Combate desenha com e sem arte de sala; tamanhos de saída do pipeline; smoke do `draw` com cenário. |

## Fora do escopo

Regerar arte, sprites animados, música, recorte de alfa dos inimigos, os 5 cenários novos
(só a ordem de geração), redimensionamento de janela.

## Critérios de aceite

- [x] `assets/` versionado em 16 MB e `.exe` local em 31,6 MB (meta: ~20 MB e ~45 MB).
  - **Atualização 2026-09-19:** com os 7 cenários e os ícones novos o `assets/` versionado chegou a 22 MB; as cenas passaram a PNG indexado de 256 cores (octree, `process_art.py`) e ficaram em 12 MB; `.exe` local em 27,7 MB.
- [x] O combate mostra o cenário da sala 2 com o HUD legível (verificado em render; falta playtest).
- [x] Salas sem arte continuam funcionando com o fundo liso (teste).
- [ ] As cartas ficam nítidas no tamanho exibido (playtest visual). Passo 0 decidido: A.
- [x] Testes (250) e `build_local.py` passam. [ ] `EVID` do playtest visual ainda a registrar.
- [x] Aprovação do responsável (2026-09-19).

## Ordem de execução (após aprovação)

1. Passo 0: amostra Lanczos × nearest em 2 cartas → responsável escolhe.
2. Pipeline + mover as matrizes para `_raw` + processar tudo.
3. Cenário de combate e moldura dos inimigos.
4. Build local, conferir peso do `.exe`, playtest visual.
5. Atualizar `ASSETS-PENDENTES-001`.
