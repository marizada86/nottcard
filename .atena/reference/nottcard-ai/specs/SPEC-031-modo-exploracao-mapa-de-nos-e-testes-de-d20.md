---
id: "SPEC-031"
type: "spec"
title: "Modo exploração: mapa de nós navegável e testes de d20"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SIS-003-fileira-de-inimigos-exploracao-com-cartas-hud]]"
  - "[[SPEC-001-vertical-slice-m1-solo]]"
  - "[[SPEC-002-animacao-dado-d20-procedural-3d]]"
  - "[[SPEC-023-progresso-save-e-resultado-da-tentativa]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
sources:
  - "Pedido do responsável do projeto, 2026-09-19: plano do modo exploração; mapa com nós navegáveis; demais recomendações aprovadas"
---

# Modo exploração: mapa de nós navegável e testes de d20


## Objetivo

Trocar a sequência linear de salas por um **mapa de nós** (point-crawl, `SPEC-001` §4) que o jogador
percorre escolhendo o próximo destino, e resolver as situações de exploração por **teste de d20 + modificador
de atributo** (`SIS-003` §2), sem cartas.

## 1. Mapa de nós

- O mapa é dado declarativo: nós (`MapNode`) e arestas (`edges`). Cada nó é uma sala existente (`Room`) com
  tipo `exploracao`, `evento` ou `combate`.
- Mover-se entre nós **não custa nada** (`SPEC-001` §5). O jogador vê os nós já visitados, o atual e os
  vizinhos alcançáveis; nós além dos vizinhos ficam ocultos.
- Nó de combate só se resolve uma vez: depois de vencido, vira "limpo" e pode ser atravessado sem lutar.
- Nó de exploração/evento também se resolve uma vez (o resultado fica registrado; revisitar não rola de novo).
- Vencer o nó do chefe conclui a missão. Derrota ou desistência seguem como hoje (`SPEC-023`).

### Mapa do M1 (proposta)

```
As Docas ─ O cais atacado ─┬─ A rachadura na Tarn   (opcional, beco)
                           └─ Porão: entrada (opcional slime) ─ Sala de livros ─ Corredor ─ O ritual (chefe)
```

- Salas 1 e 2 são o começo linear. Depois do cais há **bifurcação**: a Rachadura é um beco opcional
  (pista e XP); o caminho ao chefe passa pelo porão.
- O chefe só é alcançável pelo Corredor. A Rachadura nunca bloqueia a missão.
- A ordem por dentro do porão continua fixa; a bifurcação é o único ponto de escolha do M1.

## 2. Testes de d20

- Resolução: `1d20 + modifier(atributo)` contra a DC. Faixas: **Fácil 10, Médio 15, Difícil 20**.
- Cada situação declara **2 ou mais opções**, cada uma com atributo e DC próprios (ex.: forçar a passagem
  com Força contra procurar outro caminho com Inteligência). O botão mostra atributo e DC ("Força · DC 15").
- Sem vantagem/desvantagem e **sem rerrolagem**: cada situação é uma decisão única.
- **Natural 20** = sucesso automático; **natural 1** = falha automática (coerente com a `SPEC-026`).
- Bônus fixos podem vir de ganchos do jogador. `mist_immune` (Durvall, nível 5) vira **+2** no teste da
  Sala 1 em vez de imunidade.
- A rolagem usa o dado d20 3D (`SPEC-002`) e mostra `d20 + mod = total vs DC`, depois o texto do desfecho.

## 3. Sucesso e falha

- **Sucesso:** ganha o benefício da opção (pista, XP de evento no ledger, avanço).
- **Falha:** custo leve, escolhido por situação entre: perder o XP do evento; perder 1–3 PV (nunca deixa o
  jogador em 0); descartar uma carta da mão. **Nunca** reinicia a tentativa nem trava a missão.
- Perder PV por falha não conta como derrota nem aciona a falha crítica de combate.

## 4. Situações do M1 (DCs iniciais, a ajustar no playtest)

Balanceamento de 2026-09-19: todo sucesso dá um pequeno benefício, a falha continua leve e cada personagem tem
uma opção de ao menos 45% em toda situação (nenhuma passa de 75%). DC 20 fica reservada para quando houver
bônus de item.

| Nó | Opções | Sucesso | Falha |
|---|---|---|---|
| As Docas | Inteligência DC 10 · Constituição DC 10 | compra 1 carta (até o limite da mão) | descarta 1 carta |
| Rachadura na Tarn | Inteligência DC 15 · Força DC 15 · Constituição DC 15 | +10 XP | +3 XP de consolo |
| Porão: entrada | Carisma DC 10 · Inteligência DC 10 · Combate (opcional, XP 10) | +5 XP | perde 1–3 PV |

O efeito da Rachadura sobre o chefe ("cópia depois verdadeiro" ou direto o verdadeiro) fica **fora desta
spec**: hoje a Sala 5 já é o guardião-cópia, e mudar isso é rebalanceamento a decidir depois.

## 5. Arquitetura

- `game/core/exploration.py` (sem pygame): `Situation`, `Option`, `Outcome`, `CheckResult`,
  `resolve_check(player, option, rng)`.
- `game/core/rooms.py`: `Room` ganha `situation`; entra `MapNode`/`WorldMap` com `neighbors()` e estado
  (`visited`, `cleared`). `ROOMS` linear dá lugar ao mapa do M1.
- `game/ui/map_view.py`: desenho do mapa e clique nos nós; `SituacaoScreen` substitui a antiga `ExploracaoScreen` (removida) para a situação
  com opções e a rolagem do d20. Nenhuma regra fora do `core`.
- `game/app.py`: `_enter_room`/`_advance_room` deixam de usar `room_index`; passam a navegar o mapa.
  Pausa, tutorial e devlog (F12) continuam valendo nas novas telas.
- Arte de nó/mapa ausente cai no retângulo com nome (não bloqueia a lógica).

## Fora de escopo

Mapa em primeira pessoa; mochila/itens; descanso; vantagem/desvantagem; mais de um personagem em cena;
mapas de M2 em diante.

## Critérios de aceite

- [x] O mapa do M1 abre com só o nó inicial e vizinhos visíveis; clicar num vizinho move o jogador.
- [x] Nós de combate, exploração e evento resolvem uma vez e ficam registrados.
- [x] Testes de d20 usam `d20 + modificador` contra DC; nat 20/1 forçam sucesso/falha.
- [x] Falha aplica só custos leves e nunca zera o PV nem encerra a tentativa.
- [x] Missão concluída só pelo chefe; a Rachadura é opcional.
- [x] `game/core/` segue sem import de pygame; testes novos em `tests/core/` e `tests/ui/`.
- [x] Testes existentes passam (ajustados onde dependiam de `ROOMS` linear).
- [ ] Playtest.

Implementado em 2026-09-19: `game/core/exploration.py`, `game/core/worldmap.py`, `game/ui/map_view.py`, `MapaScreen` e
`SituacaoScreen` em `game/app.py`; 574 testes (`tests/core/test_exploration.py`, `tests/ui/test_exploration_flow.py`).
`ROOMS` e `Room` seguem como catálogo de salas; `room_index` aponta a sala do nó atual.
