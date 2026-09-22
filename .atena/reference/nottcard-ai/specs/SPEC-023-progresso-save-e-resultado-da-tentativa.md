---
id: "SPEC-023"
type: "spec"
title: "Progresso por personagem, save temporário e resultado da tentativa"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SIS-005-progressao-de-nivel-maestria]]"
  - "[[SPEC-011-personagem-como-dado-characterdef]]"
  - "[[SPEC-018-pausa-e-interacao-de-cartas]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
sources:
  - "SIS-005 (canon, 2026-09-19): regras, curva de XP, fontes, persistência e resultado"
---

# Progresso, save temporário e resultado da tentativa

## Problema

O jogo não tem progressão: cada run começa igual e nada persiste. O SIS-005 define a maestria
por personagem; falta o mecanismo (XP, nível, save) e a tela que mostra o resultado.

## Regras

### 1. Progresso (`core`, sem pygame)
- `Progress` por personagem: `level` (1–5), `xp` (acumulado), `unlocked` (cartas liberadas).
- **Limiares acumulados:** `(100, 350, 950, 1950) × XP_SCALE` para os níveis 2, 3, 4, 5;
  `XP_SCALE = 1.0` (constante única para o tempo de grind). Nível 5 é o teto; o excedente é ignorado.
- `add_xp(amount)` devolve a lista de subidas (`LevelUp(level, rewards)`). Nunca reduz o nível.
- O nível só sobe **no fim da missão**; durante a run o baralho e os atributos não mudam.

### 2. XP da tentativa (`RunLedger`)
Acumulado em linhas (`fonte`, `quantidade`) durante a run, sem aplicar até o fim:

| Fonte | XP |
|---|---|
| Inimigo derrotado | `Enemy.xp`: Criatura 10, Slime 5 (10 se enfrentado na sala 4 opcional), Guardião cópia 15, Guardião verdadeiro 25 |
| Evento da rachadura (sala 3) | 10 |
| Conclusão da dungeon | 20 (só se a missão for concluída) |

Total da rota principal: **100** (110 com o Slime opcional). Valores em dado declarativo
(`Room.xp`, `Enemy.xp`), não no código do `app`.

### 3. Desfechos
| Desfecho | XP aplicado |
|---|---|
| Vitória | 100% |
| Desistência (pausa → Desistir, SPEC-018) | 100% do acumulado |
| Derrota | `floor(50%)` do acumulado **da tentativa** |

O chefe e a conclusão só existem se a missão for concluída; desistir antes deles os perde.

### 4. Save temporário (uma instância, todos os personagens)
- `SaveState`: `dict[character_id → Progress]`, criado com todos no nível 1.
- `SaveStore` (protocolo `load() / save(state) / clear()`) com `MemorySaveStore` agora: vale
  enquanto o `.exe` estiver aberto. Trocar por arquivo JSON depois muda só uma classe.
- **Menu:** **Continuar** (aparece se houver progresso; leva à seleção) e **Novo jogo** (apaga o
  save, com confirmação quando há progresso). A seleção mostra nível e barra de XP por personagem.
- `App.start_run` monta o baralho e os atributos a partir do `Progress` (SPEC-024).

### 5. Estatísticas (`RunStats`, `core`)
Dano causado e sofrido, cura, inimigos derrotados, cartas jogadas, maior Corrente, turnos,
acertos, erros e críticos, tempo. Coletado por eventos do combate, sem pygame.

### 6. Tela "Resultado da tentativa"
Depois de vitória, derrota ou desistência:
- **Log de XP**, linha a linha ("Criatura corrompida +10 …"), o ajuste do desfecho
  ("Derrota −50%") e o total.
- **Barra de nível** e a faixa "Nível N! Nova carta: X" (ou passiva e atributo do nível 5).
- **Estatísticas** em duas colunas. Botão **Continuar** → menu.
- O nível aparece também no painel do jogador durante o combate ("Nv N").

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/progress.py` (novo) | `Progress`, `LevelUp`, limiares, `RunLedger`, `RunStats`, `SaveState`, `SaveStore`, `MemorySaveStore`. |
| `game/core/rooms.py`, `enemies.py` | `Room.xp`, `Enemy.xp`, dados declarativos. |
| `game/app.py` | Ledger e stats alimentados pelo combate; desfechos; `ResultadoScreen`; menu Continuar/Novo jogo; seleção com nível. |
| `game/ui/hud.py` | "Nv N" no painel do jogador. |
| Testes | Limiares e subida de nível; derrota 50% arredondado para baixo; desistência 100%; teto no nível 5; save em memória e Novo jogo apaga; log e stats corretos por combate simulado; XP só aplicado no fim. |

## Fora do escopo

Save em arquivo, XP de baú e de outras missões, divisão de XP no grupo, cartas e passivas por nível (SPEC-024).

## Critérios de aceite

- [x] Uma vitória da M1 rende ~100 XP e leva o personagem ao nível 2.
- [x] Derrota aplica 50%; desistência mantém 100% do acumulado.
- [x] O save vive entre runs na mesma sessão; Novo jogo apaga tudo.
- [x] A tela de resultado mostra log de XP, subida de nível e estatísticas.
- [x] Testes passam.

## Ordem de execução

1. `progress.py` com testes. 2. Dados de XP em salas e inimigos. 3. `RunLedger`/`RunStats` no combate. 4. `ResultadoScreen`. 5. Menu, seleção e save. 6. Playtest da curva.
