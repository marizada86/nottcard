# PLAN-001 — Porte do nottcard-ai (Python/pygame) para Godot

Status: **APROVADO em 2026-09-21 pelo Guilherme.** Decisões: GDScript; paridade de regras + visual equivalente usando as artes já geradas (assets/ copiado da origem, sem `_raw` e `concepts`); tudo aprovado (escopo completo exceto ferramentas de playtest/Discord, adiadas); origem congelada em v0.18.0 (`c118d16`); GUT via addon (baixar na F1); referência da origem em `.atena/reference/nottcard-ai/` (somente leitura).

## 1. Objetivo
Reproduzir o `nottcard-ai` v0.18.0 (`D:\dev\nottgard\games\nottcard-ai`) no Godot 4.7.2, com **paridade funcional e visual**: mesmas regras, números, telas, arte, save e comportamento. Fonte de verdade das regras = o código Python + specs `SPEC-001..109` do projeto de origem.

## 2. Inventário da origem
| Parte | Tamanho | Observação |
|---|---|---|
| `game/core/` | ~7k linhas, 30+ módulos | lógica pura, **sem pygame** → porte quase 1:1 |
| `game/ui/` | ~8k linhas, 40+ módulos | desenho/input → vira cenas/Control/Node2D |
| `game/app.py` | 4k linhas | máquina de estados → cenas + autoload |
| `tests/` | ~20k linhas, 1920 testes | é a **especificação executável** |
| `assets/` | ~110 MB úteis (+731 MB `_raw`) | PNG/JPG/TTF; `_raw` NÃO migra |
| Especiais | dados 3D procedurais (`dice_mesh`), raycast primeira pessoa (`raycast`, `walk_screen`), névoa/luz de tocha, dano flutuante | partes de maior risco |

## 3. Decisões de arquitetura (propostas)
1. **Linguagem: GDScript** (o exe em `D:\Godot` é a build padrão, sem .NET/mono).
2. **Camadas espelhadas**: `core/` (RefCounted/Resource puros, zero Node) e `ui/` (cenas). Mantém a regra da origem: nenhuma regra de jogo na UI.
3. **Conteúdo declarativo**: cartas, inimigos, salas, itens, eventos → `Resource` (`.tres`) ou JSON gerado, não montado em código.
4. **Máquina de estados**: `app.py` → autoload `Game` + `SceneManager`; cada `Screen` vira uma cena (Menu, Exploração, Combate, Game Over, Loja, Coleção, Baralho, Mochila, Equipamento, Tutorial, Pausa…).
5. **Caminhada em 1ª pessoa**: primeira tentativa reproduz o raycaster 2.5D em `_draw`/shader 2D (pixel nítido, mesma resolução interna) para paridade exata; **não** trocar por 3D real (mudaria o visual).
6. **Dados d4–d20**: MeshInstance3D em SubViewport com as mesmas texturas/faces, animação equivalente à `dice_widget`.
7. **Resolução/pixel-art**: viewport base igual à da origem, `stretch_mode=viewport`, filtro nearest.
8. **Save**: mesmo formato JSON e mesma semântica (`user://` ≈ `%APPDATA%/nottcard-ai`), com leitor de saves antigos como bônus.
9. **RNG**: `RandomNumberGenerator` com seed injetável, para testes de paridade determinísticos.

## 4. Como garantir "cópia exata" (o ponto crítico)
- **Testes de paridade**: exportar do Python vetores golden (JSON): dano, combo/Corrente, vantagem/desvantagem, IA de inimigos, loja, progressão, eventos — dado seed+entrada, saída esperada. O porte GDScript deve reproduzi-los bit a bit.
- **Simulador**: `scripts/simulate.py` gera baselines (`SIM-*.md`); rodar o equivalente em Godot headless e comparar métricas.
- **Framework de teste**: GUT (addon, precisa de aprovação por `dependencies: allowlist-with-plan`) ou runner próprio em `--headless -s`.
- **Visual**: screenshots lado a lado por tela (origem vs Godot) guardados em `.atena/evidence/`.
- Bugs da origem são copiados também (paridade > correção); divergências intencionais viram spec.

## 5. Fases (cada uma = 1+ specs, com evidência)
| Fase | Entrega | Critério de aceite |
|---|---|---|
| F0 | Projeto Godot, estrutura de pastas, ADD, import de assets (sem `_raw`), fontes, tema, config de pixel-art | abre no editor, roda cena vazia headless |
| F1 | Golden vectors + harness de teste | vetores gerados a partir do Python, runner falhando (vermelho) |
| F2 | `core/` completo: cartas, combate, Corrente, inimigos, estado, party, personagens, itens, equipamento | 100% dos golden vectors do core verdes |
| F3 | `core/` meta: progress, save, coleção, loja, missões, eventos, conquistas, pergaminhos, mochila | idem + save round-trip |
| F4 | UI de combate: HUD, cartas (layouts/molduras), dados, dano flutuante, log, dev-log F12 | combate M1 solo jogável, screenshots batem |
| F5 | Menus e telas: menu, login, tutorial, pausa, coleção, baralho, loja, equipamento, mochila, resultado | navegação completa |
| F6 | Exploração: mapa, automap, caminhada 1ª pessoa, névoa/tocha, portas/salas, eventos | M1 e M2 navegáveis; perf ≥ 60 FPS |
| F7 | Paridade final: M1+M2 do início ao fim com 4 personagens + Brook, opções (30/60 FPS, câmera), export de evidências | playtest comparativo + simulador dentro da tolerância |
| F8 | Export Windows (.exe), CI opcional | executável roda sem Godot instalado |

Ordem justificada: core primeiro (barato, verificável, é onde a "exatidão" mora); raycaster e dados 3D por último (maior risco visual).

## 6. Riscos
- **Raycaster/luz/névoa** em GDScript pode ficar lento → fallback: shader ou GDExtension (só com aprovação).
- **Dados 3D procedurais** difíceis de igualar; aceitar equivalência visual, não pixel exato.
- **app.py de 4k linhas** mistura regra e fluxo; extrair com cuidado, guiado pelos testes de UI existentes.
- **Divergência de aritmética** (int/float, arredondamento, `random`): Python `round` é bankers' rounding, GDScript não → mapear cada ocorrência.
- **Origem ainda evolui** (pendências M2 e arte): congelar em v0.18.0 (commit `c118d16`) e tratar mudanças novas como specs de sincronização.
- **Tamanho**: ~1920 testes = escopo grande; estimar em dezenas de specs.

## 7. Estrutura alvo
```
nottcard/                (raiz do projeto Godot)
  project.godot
  .atena/                add.yaml, vault, specs, evidence, generated
  core/                  lógica pura (espelha game/core)
  ui/                    cenas e scripts de tela (espelha game/ui)
  data/                  cartas, inimigos, salas (.tres/.json)
  assets/                sem _raw
  tests/                 paridade + unidade
  tools/                 export de golden vectors (Python), audit de assets
```

## 8. Perguntas em aberto (preciso da sua decisão)
1. **GDScript** confirmado? (C# exigiria a build .NET do Godot, que não está em `D:\Godot`.)
2. **"Cópia exata"** = paridade de regras + visual equivalente (recomendado), ou pixel-a-pixel inclusive nos dados 3D e caminhada?
3. **Addon GUT** aprovado, ou runner de testes próprio?
4. **Escopo**: portar tudo (M1+M2, loja, save, conquistas, dev-log, ferramentas de playtest/Discord) ou só o jogo jogável? Sugiro deixar `tasks_discord`, `evidence_export`, `playtest_guide` para depois.
5. **Congelar a origem** em v0.18.0 durante o porte?
6. Copiar `.atena` de specs/evidências da origem como referência (somente leitura) para este projeto?

## 9. Próximo passo (após aprovação)
Promover este plano a `canon/`, redigir `SPEC-001` (F0: bootstrap do projeto Godot) e só então executar.
