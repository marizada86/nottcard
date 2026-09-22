---
id: "SPEC-104"
type: "spec"
title: "Caminhada em 1ª pessoa: nitidez, luz de tocha, chamas animadas e opção de 30/60 FPS"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-023-visual-pixel-art-e-fluidez-da-caminhada-2026-09-21]]"
  - "[[SPEC-056]]"
  - "[[SPEC-057]]"
  - "[[SPEC-058]]"
sources:
  - "Responsável, 2026-09-21: foco em qualidade do pixel art na caminhada; dungeon crawler clássico; manter 480x270 nítido; luz de tocha e névoa suaves; tremulação ligada por padrão; chamas animadas; opção de escolher 30 ou 60 FPS; 'bonito e fluido'"
  - "Assistente, 2026-09-21: metas de fluidez (60 FPS no PC do dono, ≥30 em PC modesto, nenhum quadro acima de ~33 ms) e primeira entrega = A + B + névoa contínua"
---

# Caminhada: nitidez, luz de tocha, chamas animadas e FPS

> Primeira entrega do PLAN-023 (blocos A, B, D e a parte de chamas do F/G). **Fora desta SPEC:** numpy (bloco C), balanço de passo e inclinação
> (bloco E), cache de sprites (bloco F). Eles vêm numa SPEC-105, decididos com base na medição do item 1.
> Só desenho: `game/core/` não muda, exceto o campo novo do perfil. Nada de regra de jogo.

## 1. Medir (bloco A)
- `scripts/profile_walk.py`: monta o mundo de M1 e de M2 em posições fixas (corredor longo, sala com inimigo, sala com tochas), renderiza 300 quadros
  girando e andando, sem janela visível (`SDL_VIDEODRIVER=dummy`), e imprime **ms médio, p95 e máximo** por etapa (piso/teto, paredes, sprites, ampliação)
  e por quadro. Grava o resultado em `.atena/evidence/PERF-caminhada-<data>.md`.
- Roda **antes** de qualquer mudança (linha de base) e **depois** de cada item abaixo; a evidência final compara os dois.
- Metas (não são teste automático, são critério de aceite da evidência): média ≤ 16 ms no PC do dono a 60 FPS; p95 ≤ 33 ms; nenhum quadro > 50 ms
  fora de carregamento. Em 30 FPS o orçamento é 33 ms.

## 2. Opção de FPS: 30 ou 60
- `Profile.fps_cap` (`game/core/profile.py`), valores `30` ou `60`, padrão **60**; entra no JSON do perfil; valor ausente ou inválido cai em 60.
- O laço `App.run` (`game/app.py`) usa `clock.tick(profile.fps_cap)` no lugar de `tick(60)` fixo. Toda animação e movimento já usam `dt`, então a
  velocidade do jogo **não** muda com o FPS; o teste garante isso (item 7).
- A escolha fica no menu de pausa/opções, ao lado da opção de exploração já existente (SPEC-057): "Quadros por segundo: 30 | 60". Vale na hora, sem
  reiniciar, e persiste no perfil.
- O `dt` é limitado (`min(dt, 0.1)`) para um engasgo isolado não teleportar a câmera.

## 3. Nitidez (bloco B)
- Nenhum `smoothscale` no caminho da caminhada. Em `world_art.py`: `_load_texture` e `_door_texture` trazem a arte para `TEX` (128) com
  `pygame.transform.scale` (nearest); o fallback de recorte de `bg.png` também.
- Piso e teto em `world_view.py` deixam de ser calculados em 120x34 e ampliados com `smoothscale`. Passam a ser calculados em **240x68** (metade da
  largura interna, metade da altura de cada faixa) e ampliados **2x inteiros** com `scale` (nearest): cada pixel do piso vira um bloco 2x2, coerente com
  o pixel do resto. Se a medição do item 1 mostrar que o custo passa do orçamento, cai para 160x45 (fator 3, também inteiro) — decisão registrada na evidência.
- A ampliação final de 480x270 para a janela (1280x720, fator 2,67) usa `scale` (nearest) já hoje; conferir que a janela em tela cheia usa fator inteiro
  quando possível (letterbox se não for) para não haver pixels de larguras diferentes.
- Aceite: capturas antes/depois em `.atena/evidence/` (corredor de M1, sala de M2) sem pixel borrado.

## 4. Névoa contínua e luz (bloco D)
- **Névoa contínua:** `SHADES` de 4 faixas vira **16 níveis** de brilho por distância, com curva suave (`level = 1 - (1 - min_light) * smoothstep(d / MAX_DIST)`),
  `min_light` ≈ 0,18. 16 níveis não têm degrau perceptível e mantêm o cache de fatias (`Look.wall_strips`, hoje 4 por textura, passa a 16). Paredes, portas,
  sprites e o gradiente de piso/teto usam a **mesma** função (`fog_level(dist)`), então tudo escurece junto. `shade_index`/`SHADE_STEPS` são substituídos;
  testes que os citam são ajustados.
- **Sombreamento por face:** parede voltada para N/S recebe um fator 0,82 sobre o brilho de L/O (`hit.side` já sai de `cast_ray`; se não sair, incluir).
  Fatia cacheada por (textura, nível, face).
- **Luz de tocha do jogador:** um halo quente ao redor do centro da tela, aplicado uma vez por quadro sobre o buffer 480x270: máscara radial pré-calculada
  (`pygame.Surface` 480x270, gerada uma vez) com `BLEND_RGB_ADD` de um tom quente (≈ `(38, 24, 10)` no centro) e vinheta escura nas bordas (`BLEND_RGB_MULT`,
  bordas ≈ 0,7). Custo: dois `blit` de tela cheia por quadro.
- **Tremulação (padrão ligada):** a intensidade do halo e da vinheta varia com ruído de baixa frequência (soma de 2 senos em ≈ 0,7 e 1,9 Hz, fases
  fixas, sem `random` por quadro), **amplitude de 5 a 10%**. Determinística em função de `time` — assim os testes e as capturas de evidência são repetíveis.
  `Profile.torch_flicker` (padrão `True`); desligado, a luz fica fixa. Opção "Tremulação da luz: ligada | desligada" ao lado da de FPS.
- **Luz local (props):** tochas e braseiros (`props/tocha`, `props/braseiro`) clareiam o sprite e a parede/piso ao redor por um halo circular somado
  na posição projetada, com o brilho caindo com a distância, e só quando visíveis (passaram no teste de `zbuf`). Máximo de 4 halos por quadro (os mais
  próximos), para limitar o custo.

## 5. Chamas animadas (arte + desenho)
- Tocha e braseiro passam a ter **3 quadros**: `assets/world/props/tocha_0.png … tocha_2.png` e `braseiro_0.png … braseiro_2.png` (mesmo tamanho e mesma
  âncora do PNG único atual, para não mexer no posicionamento). O PNG único atual (`tocha.png`, `braseiro.png`) continua sendo o **fallback**: sem os
  quadros, o adereço aparece estático e o jogo funciona igual. Velas e demais props ficam só com a tremulação de luz.
- `world_art.prop_billboard(slug, frame)` escolhe o quadro; `WorldRenderer` calcula `frame = int(time * 6) % 3` (≈ 6 quadros por segundo) com deslocamento
  de fase por posição na grade (`(x * 7 + y * 3) % 3`), para duas tochas vizinhas não piscarem em uníssono.
- Arte: prompts para o **ChatGPT** em `.atena/generated/ART-PROMPTS-0NN-*.md` (números seguem a sequência do repositório), no estilo e paleta de `SIS-004`,
  fundo chapado para chroma-key, processados por `scripts/process_art.py` (o mesmo caminho dos outros props). **Validar um ambiente primeiro** (`docas`)
  antes de gerar os demais.
- A arte é independente do código: a SPEC é entregue e aprovada sem ela.

## 6. Ordem de implementação
1. Item 1 (medição) e a linha de base.
2. Item 3 (nitidez) + medição.
3. Item 2 (opção de FPS).
4. Item 4 (névoa, faces, halo, tremulação, luz local) + medição.
5. Item 5 (código do quadro de chama; a arte entra quando existir).

## 7. Testes
- `test_profile.py`: `fps_cap` padrão 60, aceita 30, valor inválido volta a 60; `torch_flicker` padrão verdadeiro; ida e volta no JSON.
- `test_world_art.py`: nenhuma textura/porta carregada usa suavização (tamanho e pixels de uma textura sintética de 2x2 ampliada ficam em blocos sem
  cores intermediárias); `fog_level` é monótono decrescente, contínuo (diferença entre níveis vizinhos < 1/16) e `1` a distância 0.
- `test_world_view.py`: quadro renderizado com câmera fixa é igual duas vezes (determinístico, inclusive com tremulação); com `torch_flicker=False` a
  luz não muda entre `time=0` e `time=1`; com `True` muda dentro da faixa de 5 a 10%; face N/S mais escura que L/O; halo respeita o máximo de 4.
- `test_prop_frames.py`: sem quadros na pasta, `prop_billboard` devolve o PNG único; com quadros, o quadro muda com o tempo e difere por posição.
- `test_fps.py`: a mesma sequência de passos com `dt` de 1/30 e de 1/60 termina na mesma posição/ângulo (tolerância de quadro); `dt` muito grande é limitado.
- Os testes existentes de raycast e mundo (`test_raycast.py`, `test_world_view.py`) continuam passando; a geometria não muda.

## 8. Critérios de aceite
- Evidência de desempenho (item 1) com linha de base e resultado final; metas do item 1 atendidas ou desvio justificado.
- Capturas antes/depois sem pixel borrado, sem degraus de névoa e com o halo de tocha.
- Opções de FPS e tremulação funcionam na hora e persistem.
- Playtest do dono confirma "bonito e fluido" (é o critério final, como acordado); sem ele a SPEC fica "implementada, aguardando playtest".
