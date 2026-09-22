---
id: "SPEC-049"
type: "spec"
title: "Primeira pessoa, passo FP-0: câmera com o mouse (paralaxe do cenário e dos inimigos)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-002-primeira-pessoa-2026-09-20]]"
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[SPEC-014-combate-com-multiplos-inimigos]]"
  - "[[SPEC-018-pausa-e-interacao-de-cartas]]"
  - "[[SPEC-032-arte-da-exploracao-no-jogo]]"
sources:
  - "Responsável, 2026-09-20: referências de primeira pessoa com a câmera acompanhando o mouse; FP-0 liberado como protótipo para o playtest (decisão 4 do PLAN-002)"
---

# Câmera com o mouse (FP-0)

> **Aprovada pelo responsável em 2026-09-20** (`execution_approval: per-spec`), com as recomendações 2 e 5 do PLAN-002. **Não muda regra de jogo, `core` nem save.** Só
> apresentação. Sem arte nova: usa os cenários atuais (`assets/rooms/`).

## 1. Objetivo

O cenário e os inimigos se deslocam com o mouse, em profundidades diferentes, dando a sensação de olhar para dentro da sala.
É o protótipo do que o PLAN-002 chama de primeira pessoa; serve para o Higor sentir o efeito no próximo playtest antes de
qualquer redesenho de layout.

## 2. Escopo

- **Entra:** combate (`CombateScreen`) e exploração (`SituacaoScreen`), os dois que desenham `assets/rooms/<sala>.png`.
- **Fica de fora:** mapa (`MapaScreen`), menus, loja, baralho, resultado, login, tutorial e qualquer overlay.
- **Não se mexem, nem no combate:** mão, painel do jogador e do grupo, log, pilhas, dado, botões. Os floaters de dano
  seguem o inimigo (ver 3.4).

## 3. Especificação

### 3.1 Módulo `game/ui/camera.py` (novo, sem pygame)
```
CameraConfig(amplitude_x=0.04, amplitude_y=0.04, smoothing=8.0, overscan=1.08)   # ±4% da tela, 108%
class Camera:
    def set_target(self, mouse, size) -> None   # mouse -> alvo normalizado -1..1
    def update(self, dt) -> None                # offset += (alvo - offset) * (1 - exp(-smoothing * dt))
    def offset(self, depth) -> tuple[int, int]  # em pixels, inteiro, já multiplicado pela profundidade
    def freeze(self, seconds) -> None           # ver 3.4
    reduced: bool                               # True => offset() devolve (0, 0)
```
- Mouse fora da janela ou sem foco: o alvo volta a 0 (centro). O alvo é limitado a [-1, 1].
- `dt` grande (tela travada) é limitado a 0,1 s para não dar salto.
- Amplitude e suavização vêm de `CameraConfig` (ajustáveis no playtest; decisão 5 do PLAN-002).

### 3.2 Profundidades
| Camada | Fator | Observação |
|---|---|---|
| Fundo (cenário da sala) | 0,4 | |
| Inimigos (sprite, PV, rótulo) | 1,0 | o painel do inimigo se move inteiro |

Com as camadas de arte (SPEC-054) entram meio 0,7 e frente 1,4; `Camera.offset(depth)` já aceita qualquer fator.

### 3.3 Desenho do fundo
- O cenário é escalado **uma vez** a `overscan` (1280×720 → 1382×778), escurecido com o mesmo `BACKDROP_SCRIM_ALPHA` de hoje e
  guardado em cache (o atual `_backdrop_surface`), e desenhado centralizado e deslocado por `offset(0.4)`. Nunca escalar por quadro.
- O deslocamento máximo do fundo (0,4 × 4% = 1,6% da tela) cabe no overscan de 8%: nunca aparece borda.
- Sem arte da sala: o fundo liso continua, sem deslocamento.

### 3.4 Cliques, hover e duplo clique
- **Uma única conta:** `EnemySlot.rect` (`game/app.py`) passa a devolver o retângulo **já deslocado** (`enemy_rect(pos)` +
  `offset(1.0)`). O desenho, o hover, o clique de alvo (hoje `slot.rect.collidepoint`) e a origem dos floaters usam esse mesmo
  `rect`. Proibido recalcular o deslocamento em outro lugar.
- **Congelar no clique:** ao clicar numa carta ou num alvo, `camera.freeze(0.15)`: a câmera segura o offset por 150 ms. Assim o
  duplo clique da SPEC-018 e o clique no alvo não erram um inimigo que "anda" sob o cursor.
- **Efeitos ancorados:** tremor de acerto, sangue, avanço do telégrafo (`lunge`) e fade da morte são relativos ao slot já
  deslocado; os floaters nascem em `slot.rect.center`.

### 3.5 Pausa e estado
- Pausa (SPEC-013/018), tutorial, overlays (pilhas, mochila, log) e diálogos: `Camera.update` não roda; o offset fica onde
  estava. Ao retomar, o alvo é recalculado do mouse atual (a suavização absorve o salto).
- Trocar de sala ou tela recria a câmera com offset 0.

### 3.6 Reduzir movimento
- Opção **"Movimento da câmera: normal / reduzido"**, padrão normal. No pause do combate e no menu principal.
- Guardada no `perfil.json` (`"reduzir_movimento": true/false`, junto de `"boas_vindas"`; `FileProfileStore` ganha o
  atributo). Sem perfil (o `App()` dos testes): vale só na sessão e não toca o disco.
- Reduzido: `offset()` sempre `(0, 0)` e o cenário é desenhado sem overscan.

## 4. Critérios de aceite
1. Mouse parado no centro: nada se mexe. Nas bordas: fundo desloca até 1,6% e inimigos até 4% da tela, sem borda visível.
2. Movimento suave (sem tremor); mouse fora da janela volta ao centro.
3. Reduzido ligado: nenhum deslocamento e nenhuma diferença visual em relação à versão atual.
4. Clicar (e dar duplo clique) num inimigo acerta o inimigo certo com a câmera em movimento; floaters aparecem sobre ele.
5. Pausa e overlays: câmera parada.
6. Nenhum quadro perceptivelmente mais lento (sem escala por quadro).
7. Testes existentes seguem verdes.

## 5. Testes
- `camera`: centro, cantos, fora da janela, convergência por `dt`, `dt` limitado, `freeze`, `reduced`, fatores 0,4 e 1,0.
- `EnemySlot.rect` com câmera deslocada bate com onde `draw_enemy_panel` desenha; clique no retângulo deslocado seleciona o
  alvo, no antigo não.
- Perfil: grava e lê `reduzir_movimento`; sem perfil não toca disco.
- Overlay aberto não atualiza a câmera.

## 6. Fora do escopo
Layout novo do combate (SPEC-052), corredor e portas (SPEC-053), arte em camadas (SPEC-054), som, rotação da imagem.

## 7. Riscos
- `EnemySlot.rect` é usado em muitos pontos de `app.py` (floaters, efeitos): conferir todos; um teste garante a fonte única.
- Incômodo com movimento: mitigado por "reduzido" e pelo limite de 4%.
