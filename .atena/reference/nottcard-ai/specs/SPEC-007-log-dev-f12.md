---
id: "SPEC-007"
type: "spec"
title: "Log dev (F12): cálculos de cada jogada em overlay semitransparente"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-004-cadencia-do-combate]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
sources:
  - "Pedido do responsável em 2026-09-19: F12 abre um log semitransparente no topo central com os cálculos de cada jogada (dano, Corrente de Classe, passiva)"
  - "game/core/combat.py (AttackResult, HitResult, HealResult, EnemyActionResult: os números já vêm do core)"
---

# Log dev (F12)

## Problema

Os números do combate (dano da carta, Corrente de Classe, compatibilidade de
cor, bônus de atributo, passiva psiônica, teste de acerto, redução) são
calculados no `core`, mas na tela só aparece o resultado. Pra balancear e
achar erros é preciso ver **a conta inteira** de cada jogada.

## Declaração proposta

**F12** liga/desliga um painel de log **semitransparente no topo central** da
janela, com o cálculo passo a passo de cada jogada do jogador e de cada ação
do inimigo. É uma ferramenta de desenvolvimento/playtest: **não muda nenhuma
regra**, só lê o que o `core` já devolve.

## 1. Comportamento

- **F12 alterna** (abre/fecha), em qualquer tela; o log só recebe conteúdo do combate.
- **Grava sempre, mesmo fechado**: ao abrir, o histórico já está lá (limite de ~300 linhas; as mais antigas caem).
- **Posição:** topo central, ~640 px de largura, fundo preto ~70% opaco, fonte pequena monoespaçada-like, ~14 linhas visíveis. **Desenhado por cima de tudo** (inclusive do aviso de eliminação) e **não bloqueia o mouse nem o teclado do jogo**.
- **Rolagem:** roda do mouse rola o histórico enquanto o painel está aberto; por padrão mostra as linhas mais recentes.
- Cada jogada é um **bloco** com cabeçalho `[T3] …` (T = número do turno), e as linhas do bloco recuadas.
- O bloco é escrito **quando a jogada é resolvida** (os números já estão decididos); uma linha curta de **PV antes → depois** é acrescentada no momento do impacto.

## 2. Conteúdo (formato de exemplo)

Ataque do jogador:
```
[T3] Durvall usa Golpe (Vermelho · 1d8 · Ação)
  Acerto   d20 15 + Força +3 = 18 vs CA 10 (Golpe Perfurante: −1) → ACERTOU
  Dados    1d8 → [5]  base = 5
  Corrente 2x (sequência vermelha: 1)
  Fórmula  ceil(5 × 2x × compat 1.0 × (1 + 0.60 Força)) = ceil(16.0) = 16
  Passiva  2x → 1d6 → [4] = +4
  Total    16 + 4 = 20   →  Criatura 30 → 10 PV
```
Crítico: mostra os dados dobrados (`2d8 → [5, 3]`) e a conta sobre a soma.
Erro: `→ ERRARIA/ERROU`, "0 de dano, Corrente avança (2x → 3x), passiva não entra".

Cura/Poção: `dado [3] + Constituição +1 = 4 → cura 4 (PV 10 → 14)`.
Controle: `1d4 [4] → redução ceil(4 × 0.5 × 1.2) = 3 no próximo ataque`.
Surto de Ação: `+1 Ação (Ação: 1, Bônus: gasto)`.
Comprar carta / Passar a Ação / Encerrar turno: linha curta com o estado `Ação`/`Bônus`.
Ataque do inimigo:
```
[T3] Criatura corrompida usa ataque básico
  Acerto   d20 9 + 2 = 11 vs CA 13 → ERROU
[T3] Criatura corrompida usa Investida
  Acerto   d20 17 + 3 = 20 vs CA 13 → ACERTOU
  Dano     1d8 → [6] − redução 3 = 3   →  Durvall 20 → 17 PV
```

## 3. Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/ui/devlog.py` (novo) | `DevLog`: buffer de linhas, visível/oculto, rolagem; funções puras `describe_attack(...)`, `describe_enemy_action(...)`, `describe_heal(...)` etc. que transformam os resultados do `core` em linhas de texto (testáveis sem tela); `draw(surface)`. |
| `game/core/combat.py` | `AttackResult` ganha o campo aditivo `attr_bonus` (o `0.60` da fórmula) pra o log mostrar a conta exata sem duplicar constantes. **Mudança de core — precisa da sua aprovação.** Nenhum cálculo muda. |
| `game/app.py` | `App` dono do `DevLog`; F12 no laço de eventos (antes de repassar à tela); `CombateScreen` escreve os blocos ao resolver cada jogada/ação; `draw` do log por último. |
| Testes | Formatação de cada tipo de bloco (acerto, erro, crítico, combo 2x/3x, passiva, compat 0.5, cura+modificador, redução, especial do inimigo); buffer cortando no limite; F12 alterna; log não bloqueia input do jogo. |

## 4. Decisões (aprovadas em 2026-09-19, todas como recomendado)

1. **Só em memória** — sem arquivo por enquanto.
2. **Disponível em todos os builds**, inclusive o .exe do playtester.
3. **Português.**
4. **Registra também eventos de turno** (Ação/Bônus gastos, comprar carta, passar Ação, encerrar turno, eliminação), em linhas curtas.

## 5. Fora do escopo

Console de comandos/cheats, gravação de replays, gráficos, exportar em JSON, filtros por tipo, painel arrastável/redimensionável.

## 6. Critérios de aceite

- [x] F12 abre/fecha o painel semitransparente no topo central, por cima de todos os elementos, sem bloquear o jogo.
- [x] Cada ataque do jogador mostra teste de acerto, dados, Corrente, compatibilidade, bônus de atributo, fórmula com o resultado arredondado, passiva e total.
- [x] Erro e crítico aparecem corretamente (erro: 0 de dano, Corrente avança; crítico: dados dobrados).
- [x] Ação do inimigo mostra o teste de acerto, os dados, a redução e o PV antes → depois.
- [x] Cura, controle, Surto de Ação, compra de carta, passar Ação e encerrar turno aparecem.
- [x] O histórico persiste com o painel fechado e a roda do mouse rola.
- [ ] Nenhum cálculo do `core` muda (só o campo aditivo `attr_bonus`).

## 7. Ordem de execução (após aprovação)

1. `DevLog` + formatadores puros, com testes.
2. Ligar F12 e o desenho no `App`.
3. Escrever os blocos em cada resolução de `CombateScreen`.
4. Playtest do log com uma partida e registro em `EVID-00X`.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Aberto: o critério de `core` inalterado (só `attr_bonus`) não vale mais como está.
