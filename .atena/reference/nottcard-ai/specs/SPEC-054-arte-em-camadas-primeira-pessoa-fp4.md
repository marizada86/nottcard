---
id: "SPEC-054"
type: "spec"
title: "Primeira pessoa, passo FP-4: arte em camadas por sala, molduras, livros e orbes"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-002-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-049-camera-com-o-mouse-primeira-pessoa-fp0]]"
  - "[[SPEC-053-corredor-portas-e-recompensas-primeira-pessoa-fp2-fp3]]"
  - "[[SPEC-032-arte-da-exploracao-no-jogo]]"
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
sources:
  - "PLAN-002 seção 4 (FP-4) e decisão 2 recomendada: cenas próprias por sala, 2 camadas obrigatórias"
---

# Arte em camadas (FP-4)

> **Aprovada e implementada em 2026-09-20** (pedido do responsável: finalizar o FP-4 antes de enviar aos playtesters). **Nunca bloqueia código:** sem a camada, o jogo usa o `sala_N_*.png` atual.

## 1. Convenção de arquivos
`assets/rooms/<sala>/bg.png` (fundo, opaco), `fg.png` (frente, com alfa: colunas, arcos e teias que passam na frente) e,
opcional, `mid.png` (com alfa). `<sala>` = `asset_id` da sala (`sala_1_docas`...). Todas em 1280×720 (o overscan da câmera é do
código). Fatores de profundidade: `bg` 0,4 · `mid` 0,7 · inimigos 1,0 · `fg` 1,4.

## 2. Conteúdo
- **Mínimo:** 7 salas × 2 camadas = **14 imagens** (até 21 com `mid`).
- **Novas de interface:** moldura de carta de recompensa e fundo verde de recompensa; livros (baralho e descarte); orbes (PV e
  Ação/Bônus/Reação); cadeado e porta (normal, hover, trancada).
- `fg` deixa livres o terço inferior (mão) e as posições dos inimigos. **O `bg` não tem porta nenhuma**: a parede do fundo
  fica lisa no centro e o **código desenha as portas** por cima (`assets/doors/`, 4 sprites por ambiente do destino e o
  cadeado), nos slots de `game/ui/scenes_data.py`.
- Total gerado: 14 (cenas) + 5 (portas e cadeado) + 2 (recompensa) + 2 (livros) + 4 (orbe e gemas) = **27 imagens**.

## 3. Pipeline
- Prompts em `.atena/generated/ART-PROMPTS-0NN-primeira-pessoa-*.md` (gerados só depois da aprovação), seguindo `SIS-004`.
- Saída bruta em `assets/_raw/`; `scripts/process_art.py` trata a **camada com alfa** (chroma-key só em `fg` e `mid`; PNG
  indexado nas cenas cheias, como hoje) e as peças que **mantêm a proporção** (`FIT_MAX_SIDE`: portas e moldura até 480 px, o
  cadeado até 128 px); os demais ícones de HUD seguem quadrados de 128 px.
- Carregador em `game/ui/backdrop.py` (`Backdrop`, sobre `assets.py`): procura `rooms/<sala>/<camada>.png` e cai em `rooms/<sala>.png` se não achar; sem nenhum,
  retângulo com o nome (regra do projeto).
- PyInstaller: subpastas já cobertas pelo `--add-data assets`; conferir o `.exe` do CI.

## 4. Aceite
1. Sala com `bg` e `fg`: os dois se movem em profundidades diferentes; sem `fg`, só o fundo.
2. Sem arte nenhuma: jogo igual ao de hoje.
3. As 7 salas com as 2 camadas, conferidas no `.exe` empacotado (o CI só leva a arte se `assets/` estiver commitado: ver
   pendência 9 do PLAN-001).
4. Testes: carregador com fallback (camada ausente, sala ausente); `process_art` com alfa.

## 5. Riscos
- Custo de arte (14+ imagens); as salas entram uma a uma, sem bloquear o resto.
- Coerência de enquadramento entre `bg`, `fg` e as posições de inimigo e porta: revisar junto do `scenes_data`.

## 6. Implementação e verificação (2026-09-20)

- **Carregador:** `Backdrop` usa `rooms/<sala>/bg.png` (fundo, com escurecimento no combate) e `fg.png` (por cima dos inimigos),
  com folga de escala por camada para o deslocamento máximo nunca mostrar borda (fundo 108%, frente ~112%); sem camada cai no
  `rooms/<sala>.png`; sem nenhum, no fundo liso.
- **Aceite:** (1) `bg` e `fg` se movem em profundidades diferentes: testado; (2) sem arte o jogo é o de antes: testado; (3) as 7
  salas têm as 2 camadas (dimensão, modo, alfa e centro do `fg` livre conferidos por teste), portas, cadeado, livros, orbe,
  gemas, moldura e fundo da recompensa versionados; (4) fallback do carregador e `process_art` (alfa e proporção) testados.
- **Pendência de empacotamento:** a arte só chega ao `.exe` do CI se `assets/` for commitado (ver pendência 9 do PLAN-001); o
  `.exe` local (`scripts/build_local.py`) já a leva.
- **Fora do escopo, sem prompt:** a camada `mid` (opcional).
