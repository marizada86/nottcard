---
id: "SPEC-078"
type: "spec"
title: "Sabor de lore na M1: entrada das salas, inimigos e fim da tentativa"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-011-lore-no-jogavel-2026-09-20]]"
  - "[[MUNDO-001-tarn-cupula-de-nottgard]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
sources:
  - "Responsável, 2026-09-20: plano e textos da Camada 1 aprovados (PLAN-011, seção 4)"
---

# Sabor de lore na M1

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Só implementar depois de aprovada. Textos já
> aprovados em `PLAN-011` §4; esta spec só os leva ao jogo.

## 1. O que muda
Texto, sem mecânica: nenhuma regra, custo, dano ou XP muda.

- **Entrada de sala:** 1 a 2 frases ao entrar em cada uma das 7 salas de `game/core/rooms.py`.
- **Ficha curta de inimigo:** uma linha de sabor para criatura corrompida, slime corrosivo, guardião alado (cópia) e
  guardião alado (verdadeiro).
- **Fim da tentativa:** frase de vitória, derrota e desistência na tela de resultado.
- **Situações da exploração:** os textos das salas 1 e 3 (`game/core/exploration.py`) passam para a 3ª pessoa; os
  efeitos (`Outcome`) ficam idênticos.

## 2. Onde vive
- Dado declarativo novo em `game/core/lore_m1.py`, sem import de pygame: `ROOM_INTRO: dict[int, str]`,
  `ENEMY_FLAVOR: dict[str, str]`, `RUN_END: dict[str, str]`, indexados pelo id da sala, pelo nome do inimigo e pelo
  desfecho.
- A UI (`game/ui/`) só lê e desenha; nenhuma regra de jogo lá.
- Faltando a chave, a UI não mostra nada e segue (o jogo nunca bloqueia por texto ausente).

## 3. Regras de texto
- 3ª pessoa, tom sombrio contido, curto.
- Proibido: 2ª pessoa e os termos Astherion, Kein, Adam, Ghaunadaur, receptáculo e Brook (antes do Interlúdio A).
- A frase "Seremos um só" aparece nas salas 3 e 7.

## 4. Onde aparece (proposta, a confirmar na implementação)
- Entrada de sala: faixa de texto ao entrar na sala, na caminhada e no modo clássico de portas.
- Inimigo: linha no painel de detalhe do inimigo (hover/inspeção já existente), sem nova tela.
- Fim da tentativa: linha no topo do painel de resultado.

## 5. Testes
- Toda sala de `ROOMS` tem `ROOM_INTRO`; todo inimigo da M1 tem `ENEMY_FLAVOR`; os 3 desfechos têm `RUN_END`.
- Nenhum texto usa 2ª pessoa (lista de formas: "você", "seu", "sua", "te ") nem contém os termos proibidos.
- Salas 3 e 7 contêm "Seremos um só".
- As situações 1 e 3 mantêm os mesmos `Outcome` (draw, xp, item, hp) de antes.
- Chave ausente não levanta erro.
- O texto mais longo cabe na caixa da UI (medida com a fonte do tema).
- Saves antigos carregam sem mudança (nada novo no `SaveState`).

## 6. Fora desta spec
Códice, eventos de história (SPEC-077), Interlúdio A, M2 em diante.
