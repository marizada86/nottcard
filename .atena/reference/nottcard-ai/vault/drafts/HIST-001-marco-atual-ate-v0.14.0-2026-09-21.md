---
id: "HIST-001"
type: "historico"
title: "Marco atual do CLAUDE.md até a v0.14.0 (diário de versões)"
status: "draft"
created: "2026-09-21"
relations:
  - "[[SPEC-106-auditoria-de-assets-textos-de-ajuda-e-integracao-de-arte]]"
sources:
  - "CLAUDE.md, seção 'Marco atual', movida para cá em 2026-09-21 (SPEC-106 §5): o CLAUDE.md passou a ter um resumo curto"
---

# Histórico do "Marco atual" (até a v0.14.0)

> Texto movido do `CLAUDE.md` sem alterações. Proposta para o vault (promover a `canon/` com aprovação do responsável).

## Marco atual

Fatia M1 solo portada e jogável com quatro personagens (Durvall, Maelor, Sylas e Kayron; SPEC-038 e 040). Em 2026-09-19 as
SPEC-018 a 024 foram implementadas (pausa e hover/duplo clique, indicador da Corrente, descarte por
escolha e "Comprar 2", rebalanceamento, passiva em destaque, progressão por nível com save em memória e
tela de resultado, cartas e passivas por nível) — verificação em `EVID-005`; **falta o playtest** e ajustar os números. Em
2026-09-19 a SPEC-030 trouxe 10 layouts de carta (corpo da carta) com seletor opcional na seleção de
personagem, todos liberados (loja/títulos ficam pra depois; ver `ART-001`) — 555 testes. CI builda e publica o `.exe` a cada push em `main`
(`.github/workflows/build-release.yml`). Em 2026-09-19 a SPEC-031 trouxe o modo exploração: mapa de nós navegável (bifurcação na Rachadura) e situações
resolvidas por d20 + atributo contra DC (`game/core/exploration.py`, `worldmap.py`) — 604 testes, falta playtest e ajuste das DCs. Em 2026-09-19 a SPEC-033 passou o save para disco (JSON em
`%APPDATA%/nottcard-ai/save.json`, `game/core/save_file.py`); o `App` sem argumento segue em memória, então os testes não tocam o disco.
Em 2026-09-19 entraram, em sequência, a SPEC-041 (coleção: baralho do jogador sorteado, raridade, recompensa do chefe e pacotes em "escolha 1 de 3", tela Baralho), a SPEC-043 (6 raras de chefe), a SPEC-035 (loja e títulos), a SPEC-037 (grupo de até 3), a SPEC-039 (pergaminhos) e a SPEC-036 (mochila e itens) — 998 testes; falta playtest de todas e ajustar os números. A tentativa agora joga o baralho do jogador (`game/core/collection.py`) mais as cartas de assinatura de cada personagem; o save (`SaveState`) guarda coleção, baralhos, moedas, compras, oferta pendente e pergaminhos. Próximo passo: playtest das SPEC-018..024 e gerar a arte das 6
cartas por nível (prompts em `.atena/generated/ART-PROMPTS-002-*.md`); as cenas
de tela cheia agora saem em PNG indexado (`scripts/process_art.py`). Em 2026-09-20 a SPEC-044 (atributo flat, psiônico 1d4 fixo, Sylas, pilhas clicáveis, `scripts/simulate.py`) e a SPEC-048 (tela de login com nome, F10 exporta evidência, `.atena/tasks/` com `scripts/tasks.py` e `tasks_discord.py`) foram implementadas — v0.7.0; a SPEC-050 (modo playtester: boas-vindas depois do login) e a SPEC-051 (F5 bloco de notas, F6 print, F7 gera um `.zip` com o pacote da sessão) também — v0.7.1, 1119 testes; em seguida a SPEC-045 (loja de upgrades por nível, sem pacote nem 2º baralho; núcleo obrigatório e validade do baralho), a SPEC-046 (falha crítica e Sorte) e a SPEC-047 (armaduras e armas com carta própria, menu Equipamento, furtividade) — v0.8.0, 1171 testes; falta playtest (TASK-001..011), a confirmação da lista do núcleo pelo Higor e o Discord do Marizverso. Em 2026-09-20 entrou a primeira pessoa (SPEC-049 câmera com o mouse, SPEC-052 combate de frente, SPEC-053 exploração por portas e recompensa, SPEC-054 arte em camadas: 27 imagens em `assets/rooms/<sala>/`, `assets/doors/` e HUD) — v0.8.3, 1238 testes; falta playtest (TASK-012..014). Ainda em 2026-09-20 entrou a caminhada em primeira pessoa (SPEC-055 mapa em grade e caminhante em `game/core/gridmap.py`, `walker.py`, `dungeon_m1.py`; SPEC-056 raycast em `game/ui/raycast.py`, `world_view.py`, `world_art.py`; SPEC-057 `WalkScreen`, automapa e modo clássico de portas no perfil) — v0.9.0, 1284 testes; falta playtest (TASK-015..017) e as texturas do mundo (SPEC-058, prompts em `ART-PROMPTS-016`); os prompts de cada face dos dados estão em `DICE-FACES-PROMPTS-001`.

Em 2026-09-20 (v0.14.0) entraram as SPEC-086 a 092 (luta por colisão e portas travadas, eventos e "O infeliz", mercador com as moedas do perfil, sugerir baralho, resultado enxuto, x2 e Esc na exploração, cura de aliados e testes de morte) e a **M2 — A Praça da Loucura** (SPEC-093 a 097): catálogo de missões (`game/core/missions.py`, `MissionDef`), campanha no save (`missions_completed`), tela de Missão, elenco com 1 inicial, grupo por conquista ("Dupla" e "Trio") e compra de personagens na Loja (`game/core/roster.py`), M2 nos dois modos de exploração e o sacerdote que invoca 4 zumbis (`EncounterScript`); regras de elenco só valem em saves reais (`SaveState.roster_rules`). Falta playtest de tudo e a arte restante de M2 (`ART-PROMPTS-022`: salas 5 e 6, texturas, adereços, retratos, itens e HQs).
