---
id: "SPEC-002"
type: "spec"
title: "Animação de rolagem de dado procedural 3D (d20 primeiro)"
status: "approved"
reviewed: "2026-09-18"
created: "2026-09-18"
relations:
  - "[[SPEC-001-porte-m1-solo-pygame]]"
  - "[[VSN-001-visao-inicial]]"
sources:
  - "Referência: animação de d20 do Baldur's Gate 3 (frames fornecidos pelo responsável em 2026-09-18)"
  - "game/ui/dice_widget.py (animação atual: sprite 2D girando + número piscando)"
---

# Animação de rolagem de dado procedural 3D (d20 primeiro)

## Declaração proposta

Substituir a animação 2D atual de `DiceRollAnimation` por um dado 3D
desenhado proceduralmente em pygame (sem arte nova, sem engine 3D),
inspirado na referência de d20 do BG3. **Escopo: só o dado.** Painel,
contador de DC, "+N" de modificador e trilha de partículas ficam de fora
desta spec.

O valor real da rolagem continua sendo decidido em `game/core/`
(`roll()`); a animação só o revela e nunca re-rola. `game/core/` não
muda e continua sem import de pygame.

## O que a referência mostra (só o dado)

1. Entra pelo canto, girando rápido, borrão verde com faces piscando.
2. Atravessa a área com motion blur forte e variação de escala (profundidade).
3. Desacelera; faces ficam legíveis: verde, arestas brilhantes, numerais gravados.
4. Assenta com a face do resultado voltada pra câmera e segura.

## 1. Módulos

| Módulo | Camada | Conteúdo |
|---|---|---|
| `game/ui/dice_mesh.py` | ui | Dados declarativos: vértices e faces de tetraedro (d4), cubo (d6), octaedro (d8) e icosaedro (d20); mapa face → número; normal de cada face. |
| `game/ui/dice_widget.py` | ui | `DiceRollAnimation` reescrita, **mesma interface** (`sides`, `target_value`, `label`, `update(dt)`, `draw(surface, center)`, `finished`). |
| `game/app.py` | app | Só ajuste de duração se necessário; `roll_queue` e bloqueio de input inalterados. |

Nenhuma regra de jogo entra em `ui/`. `sides_of()` de `core/dice.py`
passa a aceitar 20 sem mudança (já é genérico).

## 2. Renderização

- Rotação por quaternion; projeção com perspectiva simples.
- Descarte de faces de costas e ordenação por profundidade (painter's algorithm).
- Preenchimento flat-shaded verde com uma luz direcional; arestas em verde claro para o brilho.
- Motion blur: 4–6 cópias fantasma das poses anteriores, alfa decrescente, proporcional à velocidade angular.
- Numeral: só na face voltada pra câmera quando a velocidade cai abaixo de um limiar (durante o giro rápido o número é ilegível, como na referência).

## 3. Movimento e timing (valores iniciais, ajustáveis no playtest)

| Fase | Duração | Comportamento |
|---|---|---|
| Arremesso | ~1.2 s | Arco de posição do canto até o centro, escala variando ±15%, velocidade angular aleatória decaindo com ease-out. |
| Assentar | ~0.3 s | Slerp da orientação atual até a que põe a face de `target_value` voltada pra câmera. |
| Segurar | ~0.5 s | Parado, legível. |

Total ~2.0 s (hoje 0.9 s). Aleatoriedade (eixo de giro, ponto de entrada) usa
`random` só de apresentação — não afeta o resultado.

## 4. Fallback e compatibilidade

- Se o dado não tiver malha (lado inesperado), cai no comportamento atual (sprite `assets/dice/dN.png` + número).
- Os sprites `d4/d6/d8.png` continuam existindo; não são apagados.
- d4/d6/d8 usam a mesma malha declarativa; d20 é o primeiro a ser validado visualmente.

## 5. Fora do escopo

Painel/moldura, contador de DC, "+N" de modificador, trilha de partículas
douradas, poeira/estrelas de fundo, som, física real de colisão.

## 6. Critérios de aceite

- [x] d20 gira em 3D com motion blur e assenta mostrando o número correto (verificado para os 20 valores por teste).
- [x] O valor exibido ao final é sempre `target_value`; `core` inalterado.
- [x] d4, d6 e d8 também funcionam com a mesma malha.
- [x] `roll_queue` continua bloqueando input durante a animação.
- [ ] Sem queda perceptível de FPS a 60 fps na janela padrão.
- [x] Testes unitários para `dice_mesh` (contagem de faces, mapa face→número completo, orientação final) e `DiceRollAnimation` (termina, mostra o alvo).

## 7. Ordem de execução (após aprovação)

1. `dice_mesh.py` + testes.
2. Renderer do icosaedro girando, sem blur.
3. Trajetória, easing e assentar na face correta.
4. Motion blur.
5. Demais dados + fallback.
6. Playtest e registro em `.atena/evidence/`.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Abertos: FPS a 60 fps (só medível rodando). O `roll_queue` do critério de bloqueio de input foi substituído pelo `Sequencer` (SPEC-004); o bloqueio está coberto por `test_input_is_blocked_while_beats_run`.
