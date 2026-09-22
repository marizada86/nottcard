---
id: "SPEC-003"
type: "spec"
title: "Dano flutuante e aviso de eliminação no combate"
status: "approved"
created: "2026-09-18"
reviewed: "2026-09-18"
relations:
  - "[[SPEC-001-porte-m1-solo-pygame]]"
  - "[[SPEC-002-animacao-dado-d20-procedural-3d]]"
sources:
  - "Pedido do responsável em 2026-09-18"
  - "game/ui/damage_fx.py (HitEffect: shake + partículas de sangue já existentes)"
---

# Dano flutuante e aviso de eliminação no combate

## Declaração proposta

Duas melhorias de feedback visual no combate. Nenhuma regra, número ou
fórmula muda; `game/core/` fica intocado.

1. **Dano flutuante.** Quando uma criatura toma dano, o valor aparece em
   tela e "voa" a partir dela: nasce no centro do inimigo, sobe com leve
   deriva lateral e desaceleração, e desvanece. Vem depois da rolagem do
   dado, no mesmo instante do efeito de acerto atual (shake + sangue).
2. **Aviso de eliminação.** Quando um inimigo morre, aparece
   "**<Nome> foi eliminado**" em destaque na tela de combate, e a saída
   do combate é atrasada até o aviso ser lido.

## 1. Comportamento

### Dano flutuante
- Valor exibido = `result.total` (dano final já calculado pelo core), não um re-cálculo.
- **Um número por fonte de dano** (aprovado em 2026-09-18). A cor identifica a origem; a forma identifica o tipo:
  - `dano_carta` → versão **clara** da cor da carta (fundo escuro exige mais luminosidade que `theme.CARD_COLORS`), contorno escuro de 2 px.
  - `bonus_passiva` (efeito de classe, Corrente ≥ 2x) → número **separado**, menor, com prefixo "+", **Roxo claro** com **contorno dourado**; sai ~0,15 s depois do primeiro, levemente deslocado. O contorno dourado + "+" o distingue de uma carta roxa.
  - Ataque do inimigo → cor de sangue do inimigo (clareada), saindo do painel do Durvall.
  - Cura → verde. Dano zerado (Controle) → "0" cinza, sem contorno.
  - Nenhum valor novo é calculado: são os campos que o core já devolve.
- Multiplicador > 1 deixa o número da carta maior.
- Duração ~1.0 s; sobe ~70 px; ease-out; alfa 1 → 0 no último terço; leve contorno escuro para legibilidade.
- Vários números podem coexistir (lista de instâncias).

### Sprite de quem recebeu o dano treme
- Inimigo atingido: shake do sprite (já existe, mantido).
- Jogador atingido: o painel do Durvall também treme (mesma mecânica do `HitEffect`, aplicada à posição do painel). Cura não treme.

### Eliminação
- Texto: `"{enemy.name} foi eliminado"` (Nome do dado do inimigo, ex.: "Criatura corrompida pela névoa foi eliminado").
- Aparece centralizado, fade-in rápido, segura ~1.2 s.
- Também entra no log de mensagens.
- O input fica bloqueado durante o aviso (mesmo mecanismo do `roll_queue`); depois segue o fluxo atual (`combat_finished(victory=True)`).
- Vale para inimigos comuns e chefe.

## 2. Módulos

| Módulo | Camada | Mudança |
|---|---|---|
| `game/ui/damage_fx.py` | ui | Novo `FloatingNumber` + lista gerenciada por `HitEffect` (ou classe irmã), com `spawn(value, origin, color)`, `update`, `draw`. |
| `game/ui/banner.py` (novo) ou dentro de `damage_fx.py` | ui | `EliminationBanner(text)` com `update/draw/finished`. |
| `game/app.py` | app | `_apply_attack` dispara número; `_end_player_turn` em vez de `_finish` imediato inicia o banner; `_apply_enemy_result` dispara número no jogador; `update`/`draw` atualizam e desenham ambos. |

## 3. Fora do escopo

Som, números de cura/dano com física real, log rolável, novas animações de
morte do sprite (dissolver etc.).

## 4. Critérios de aceite

- [x] Ao acertar o inimigo, o número do dano sai voando da criatura e some.
- [x] O número mostrado é exatamente o dano aplicado ao PV; carta e efeito de classe saem como números separados, cada um na sua cor.
- [x] O sprite/painel de quem recebeu dano treme (inimigo e jogador).
- [x] Ao zerar o PV, aparece "<Nome> foi eliminado" e o combate só termina depois do aviso.
- [x] Input bloqueado durante o aviso; sem duplo `combat_finished`.
- [x] Testes: ciclo de vida de `FloatingNumber` (nasce, sobe, morre) e `EliminationBanner` (termina após a duração).

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Tremor de sprite: implementado em `damage_fx` (`SHAKE_DURATION`), sem teste dedicado.
