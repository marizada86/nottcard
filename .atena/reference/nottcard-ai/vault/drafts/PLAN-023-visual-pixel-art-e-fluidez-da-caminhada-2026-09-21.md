---
id: "PLAN-023"
type: "plano"
title: "Visual pixel art e fluidez da caminhada em primeira pessoa"
status: "draft"
created: "2026-09-21"
relations:
  - "[[PLAN-020-roteiro-geral-de-implementacao-2026-09-20]]"
sources:
  - "Responsável, 2026-09-21: entrevista de escopo (foco em qualidade do pixel art; dor na caminhada em 1ª pessoa; referência de dungeon crawler clássico)"
  - "game/ui/world_view.py, world_art.py, raycast.py, walk_screen.py (leitura em 2026-09-21)"
---

# Plano

> Objetivo: a caminhada em primeira pessoa deve parecer um dungeon crawler clássico (Eye of the Beholder / Dungeon Master): pixel **nítido**,
> luz de tocha e névoa **suaves**, movimento **fluido**. Tudo abaixo espera aprovação (`execution_approval: per-spec`); as SPECs saem depois do OK.

## Decisões da entrevista

| Tema | Decisão |
|---|---|
| Foco | Qualidade do pixel art (fluidez em segundo plano) |
| Onde dói | Caminhada em 1ª pessoa (`WorldRenderer`, `WalkScreen`) |
| Referência | Dungeon crawler clássico, movimento por grade |
| Resolução | Manter **480x270**, mas nítida (sem suavização) |
| Atmosfera | Luz de tocha e névoa suave |
| Fluidez hoje | "OK, mas não suave" — falta transição/balanço, não é queda de FPS |
| Stack | **Adicionar numpy** (vetorizar paredes e piso) |
| Arte nova | Sim; prompts vão para o **ChatGPT** (não o nano banana) |

## 1. Diagnóstico (o que o código faz hoje)

1. **Borrão por suavização.** `_load_texture` e `_door_texture` usam `smoothscale` ao trazer a arte para 128x128; o piso e o teto são
   calculados em 120x34 e ampliados com `smoothscale` (`world_view.py:81-82`). É a maior perda de nitidez.
2. **Névoa em degraus.** `SHADES` tem 4 faixas fixas (`SHADE_STEPS = 2, 4, 6,5` células): aparecem faixas visíveis de escuridão nas paredes.
   O piso usa outro gradiente por linha, então parede e piso não escurecem juntos.
3. **Sem luz.** Não há sombreamento por face (norte/sul contra leste/oeste), nem luz de tocha, tremulação ou vinheta.
4. **Custo em Python puro.** Paredes: 480 colunas por quadro, cada uma com `cast_ray`, `scale` e `blit`. Piso: `get_at`/`set_at` pixel a pixel,
   refeito a cada mudança de câmera. Sprites: `pygame.transform.scale` do cartaz refeito a cada quadro, sem cache.
5. **Movimento seco.** `walk_screen.py` já anima com `_smooth`, mas sem balanço de passo, sem inclinação ao girar e sem inércia de câmera.

## 2. Blocos de trabalho (em ordem)

### Bloco A — Medir primeiro (pequeno)
- Script `scripts/profile_walk.py`: renderiza N quadros de caminhada em cenas fixas e imprime ms por etapa (piso, paredes, sprites, ampliação).
- Guardar o resultado em `.atena/evidence/` como linha de base. Sem isso não dá para provar ganho.

### Bloco B — Nitidez (maior ganho visual, baixo risco)
- Trocar `smoothscale` por `scale` (nearest) em texturas, portas e ampliação final; piso/teto em resolução cheia, não 120x34.
- Reamostrar as texturas para o tamanho de pixel coerente com a resolução interna (128 px de textura em parede de ~270 px de altura).
- Aceite: captura antes/depois lado a lado, sem pixel borrado, sem *shimmer* nas bordas.

### Bloco C — Renderizador com numpy
- Piso e teto vetorizados (mapa de coordenadas por linha, uma indexação de textura por quadro) em resolução cheia.
- Paredes: raios calculados em lote (DDA vetorizado) e colunas montadas por indexação, sem 480 `blit`.
- Zona de profundidade (`zbuf`) como `ndarray`, usada pelos sprites.
- Manter `raycast.py` como referência de teste: o resultado numpy deve bater com o de `cast_ray` (teste de paridade).
- Verificar empacotamento: numpy no `requirements` e no PyInstaller (tamanho do `.exe` cresce; medir).

### Bloco D — Luz e névoa
- Névoa contínua por distância (sem faixas), igual para parede, piso, teto e sprites.
- Sombreamento por face (paredes N/S mais claras que L/O) — dá volume ao corredor.
- Luz de tocha do jogador: halo quente na frente, com tremulação lenta (ruído de baixa frequência, pouca amplitude) e vinheta suave.
- Tochas e braseiros como fontes de luz local (`props`) que clareiam paredes próximas.
- Aceite: opção de intensidade nas configurações (acessibilidade: tremulação desligável).

### Bloco E — Movimento fluido
- Balanço de passo (bob) curto no avanço; inclinação leve ao girar; curva de aceleração/desaceleração no lugar de `_smooth` simétrico.
- Interpolação de ângulo e posição desacoplada do passo de grade (a lógica continua por grade).
- Transição de porta/sala com fade curto, no espírito de `transition.py`.

### Bloco F — Sprites e props
- Cache de sprites já redimensionados por (slug, tamanho, faixa de luz) — hoje é refeito a cada quadro.
- Adereços e inimigos recebem a mesma luz/névoa contínua do mundo.
- Sombra de contato no chão sob inimigos e adereços.

### Bloco G — Arte nova (ChatGPT)
- Texturas ladrilháveis por ambiente (`assets/world/<ambiente>/{wall,floor,ceiling}.png`) já existem para 7 ambientes; revisar as que estão
  fracas após o Bloco B (a nitidez vai expor defeitos que a suavização escondia).
- Variantes de parede (rachada, com musgo, com grade) para quebrar a repetição — hoje é uma textura só por ambiente.
- Texturas de tocha/braseiro com quadros de chama (2 a 4 quadros) para animar.
- Prompts em `.atena/generated/ART-PROMPTS-0NN-*.md`, escritos para o **ChatGPT**, seguindo a paleta e as regras de `SIS-004`.

## 3. Riscos

- **numpy no PyInstaller:** aumenta o `.exe`; o CI (`build-release.yml`) precisa continuar passando. Medir tamanho antes/depois.
- **Paridade visual:** o renderizador numpy não pode mudar a geometria (mesmos raios, mesma oclusão de sprites). Teste de paridade obrigatório.
- **Nitidez expõe arte fraca:** ao tirar a suavização, texturas geradas por IA podem mostrar ruído; parte do Bloco G pode virar retrabalho.
- **Tremulação de luz:** pode incomodar; precisa de opção de desligar.
- **Fora do escopo:** combate, HUD, menus e telas de cartas (ficam para outro plano).

## 4. Ordem e entregas

1. A (linha de base) → 2. B (nitidez) → 3. C (numpy) → 4. D (luz) → 5. E (movimento) → 6. F (sprites) → 7. G (arte, em paralelo a partir do B).
Cada bloco vira uma SPEC pequena, com captura antes/depois em `.atena/evidence/` e testes; nenhum bloco depende do playtest.

## 5. Decisões do responsável (2026-09-21)

- **Meta:** "ficar bonito e fluido" — sem número fixo de FPS. O Bloco A serve para provar que fluidez melhorou (ms por quadro antes/depois) e
  para detectar quedas; o critério de aceite é visual + sensação de movimento contínuo, sem engasgos.
- **Tremulação de tocha:** ligada **por padrão** (com opção de desligar nas configurações, por acessibilidade).
- **Chamas:** **animar** com quadros (2 a 4) de tocha/braseiro, além da tremulação de luz. O Bloco G passa a incluir essa arte como obrigatória
  (prompts para o ChatGPT), e o Bloco F desenha props animados por quadro.

Sem perguntas em aberto; aguardando aprovação para escrever as SPECs (começando por A e B).
