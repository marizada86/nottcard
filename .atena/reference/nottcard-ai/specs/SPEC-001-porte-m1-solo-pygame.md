---
id: "SPEC-001"
type: "spec"
title: "Porte da fatia M1 solo (Durvall) para pygame-ce"
status: "canon"
created: "2026-09-18"
reviewed: "2026-09-18"
relations:
  - "[[VSN-001-visao-inicial]]"
  - "[[SPEC-001-vertical-slice-m1-solo]] (nottcard)"
sources:
  - "prototype/durvall_m1_solo.py (cópia local, lógica já validada em EVID-001, fonte do porte)"
  - ".atena/specs/nottcard/SPEC-001-vertical-slice-m1-solo.md (cópia local — números e regras não redefinidos aqui)"
  - ".atena/vault/canon/VSN-001-visao-inicial.md (arquitetura core/ui/app, pipeline de asset)"
---

# Porte da fatia M1 solo (Durvall) para pygame-ce

## Declaração proposta

`durvall_m1_solo.py` (CLI, `nottcard`) já validou a lógica completa da fatia
M1 solo — baralho de 12 cartas, Corrente de Classe, fórmula de dano em duas
camadas, 4 inimigos, 6 salas (`EVID-001`). Esta spec **não redefine nenhum
número ou regra** — só decide como essa lógica já aprovada vira código em
`game/core/` e ganha uma interface gráfica em `game/ui/`/`game/app.py`,
conforme a arquitetura já aprovada em `VSN-001`.

O corte é o menor possível: mesma fatia (M1, Durvall, solo), primeiro em
pé na tela — sem porta pra outros personagens, sem Missões futuras, sem
empacotamento em `.exe` ainda (isso já existe como esqueleto separado, ver
`game/main.py` atual).

## 1. Módulos de `game/core/` (lógica pura, sem import de pygame)

Recorte quase 1:1 de `durvall_m1_solo.py`, separado por responsabilidade
em vez de um único arquivo:

| Módulo | Conteúdo | Origem no protótipo |
|---|---|---|
| `cards.py` | `Card` (dataclass), `build_starting_deck()` | linhas 48–70 |
| `combat.py` | `ComboTracker`, `resolve_card()`, fórmula de dano completa (camadas 1 e 2) | linhas 76–107 |
| `enemies.py` | `Enemy` (dataclass), `act()`, e os 4 construtores (`criatura_corrompida`, `slime_corrosivo`, `guardiao_copia`, `guardiao_verdadeiro`) | linhas 113–156 |
| `state.py` | `Player` (PV, mão, baralho, descarte, `draw()`, `discard_excess()`, `is_alive()`) | linhas 161–190 |
| `rooms.py` | as 6 funções de sala, **sem** `print`/`input` — recebem e devolvem dados, a UI decide como mostrar | linhas 300–342, reescritas sem I/O de terminal |

- `combat.py` fica sem laço de turno bloqueante (`run_combat`/`player_turn`/
  `enemy_turn` do protótipo misturam lógica com `print`/`input`); essa
  separação é o próprio ponto desta spec — a UI em pygame que decide como
  perguntar "qual carta jogar" e como mostrar o resultado, não o `core`.
- Timeout do chefe (`BOSS_DECISION_SECONDS = 45`): o `core` expõe só o
  número (constante reaproveitada) e uma função pura que decide o efeito de
  estourar o tempo (perder a Ação); **quem mede o tempo real é o laço de
  eventos do pygame**, não `time.time()`/`input()` como no protótipo CLI.

## 2. Representação de dados de conteúdo

`VSN-001` deixa em aberto "dataclass vs. JSON, schema de carta/inimigo/
sala" — esta spec decide: **dataclasses Python simples**, como já está no
protótipo, não JSON.

- Razão: o conteúdo desta fatia é fixo e pequeno (12 cartas, 4 inimigos, 6
  salas); JSON só compensaria se o conteúdo fosse editado por alguém sem
  tocar em código, o que não é o caso agora. Reavaliar se/quando `nottcard-ai`
  ganhar mais de uma Missão ou mais de um personagem jogável.
- Identificador de cada carta/inimigo (usado depois pro nome de arquivo de
  asset, `VSN-001`) é um `slug` derivado do nome (`"Golpe"` → `golpe`,
  `"Guardião alado (verdadeiro)"` → `guardiao_alado_verdadeiro`), gerado uma
  vez em `build_starting_deck()`/nos construtores de inimigo, não mantido
  solto em outro lugar.

## 3. Telas (`game/app.py` + `game/ui/`)

Máquina de estados já prevista em `VSN-001`: `Screen` com
`handle_event`/`update`/`draw`. Quatro telas para esta fatia:

| Tela | Responsabilidade | Equivalente no protótipo |
|---|---|---|
| **Menu** | título + "Iniciar" | não existe no CLI (`main()` começa direto) |
| **Exploração** | mostra a sala atual, texto/escolha quando a sala pede (ex.: Sala 4 "enfrentar o slime?"), avança pro próximo nó do mapa | `room_1_docas`, `room_3_rachadura`, `room_4_porao` (parte de escolha) |
| **Combate** | HUD de PV (jogador + inimigo), mão de cartas clicável, contador visível no turno do chefe, log das últimas 2–3 ações | `run_combat`/`player_turn`/`enemy_turn` |
| **Game Over** | PV chegou a 0 → mensagem + opção de reiniciar a tentativa (mesma regra da seção 6 de `SPEC-001` do `nottcard`: reinício imediato, sem sobrevivente) | trecho final de `run_combat`/`main` |

- Seleção e direcionamento de carta (clique-arrasta-clique): clicar numa
  carta com alvo no inimigo (`ataque` ou `controle`) a **destaca** — ela sobe
  alguns pixels acima das demais cartas da mão, ficando em estado
  "selecionada". A partir daí, uma linha acompanha o cursor entre a carta
  destacada e o mouse, indicando o caminho do ataque. Clicar no inimigo
  confirma o alvo e resolve a carta contra ele; clicar em qualquer outro
  ponto da tela, ou apertar `Esc`, cancela a seleção (a carta volta pra
  posição normal na mão, sem gastar Ação nem sair da mão). Cartas sem alvo
  inimigo (`cura`, `equipável`) não entram nesse fluxo de destaque + linha:
  clicar na própria carta já ativa o efeito na hora, sem etapa de
  confirmação — não há inimigo pra mirar.
- Como esta fatia só tem 1 inimigo em cena por combate (sem posicionamento,
  já decidido em `SPEC-001` do `nottcard`), o clique de confirmação só tem
  um alvo possível — a interação existe mesmo assim porque é o mesmo fluxo
  que vale sem mudança quando uma Missão futura tiver múltiplos inimigos.
- Teclas numéricas 1–5 continuam como atalho equivalente ao clique: apertam
  a mesma seleção/destaque (carta `ataque`/`controle` levanta e mostra a
  linha até o inimigo, já que só há um alvo, ou ativa na hora se `cura`/
  `equipável`); `0`/`Esc` passa a Ação. Ação Bônus (comprar 1 carta extra)
  vira um botão/tecla separado na tela de Combate, não um prompt sequencial.
- Log de combate: lista de texto rolável mostrando as últimas mensagens
  (equivalente aos `print()` do protótipo), não todo o histórico da tentativa.
- Fallback visual (carta/inimigo/sala sem asset): retângulo colorido com o
  nome por cima, já decidido em `VSN-001` — todas as telas desta fatia usam
  esse fallback, já que `assets/` está vazio.

## 4. Cache e carregamento de asset

Ainda sem asset real nesta fatia (seção 3), mas o cache central já previsto
em `VSN-001` entra desde já como uma função única em `game/ui/` (ex.:
`load_image(slug, categoria)`) que tenta carregar
`assets/<categoria>/<slug>.png` e cai no fallback retangular se não
existir — evita duas implementações quando a arte começar a chegar.

## O que esta spec NÃO resolve (fora de escopo)

- Qualquer número, regra, personagem ou inimigo novo — tudo isso é
  `SPEC-001` de `nottcard`, já aprovada; divergência se corrige lá.
- Arte final e `scripts/process_art.py` — chegam numa spec própria quando
  o nano banana gerar os primeiros assets desta fatia.
- Empacotamento `PyInstaller --add-data`/`sys._MEIPASS` para incluir
  `assets/` — só relevante quando houver asset real para empacotar.
- Kayron, Sylas, Maelor, M2+ — ficam para depois desta fatia estar jogável
  de ponta a ponta em pygame.

## Verificação proposta

1. Suite `pytest` em `tests/core/` cobrindo `game/core/` 1:1 com o que
   `EVID-001` já validou manualmente no CLI: baralho fecha em 12 cartas,
   multiplicador da Corrente (1x/2x/3x/4x, zera fora de classe, zera a cada
   novo combate), fórmula de dano das duas camadas (casos da tabela da
   seção 3 de `SPEC-001` do `nottcard`, com `random` mockado/seedado para
   determinismo), `discard_excess` no limite de 5, baralho esgotado
   reembaralha o descarte.
2. Playtest manual da fatia completa em pygame (Menu → 6 salas → Combate
   final ou Game Over), medindo se a UI gráfica preserva o ritmo de
   15–30 min já observado em `EVID-001`.
3. Registrar o playtest em `.atena/evidence/EVID-001-...md` (a criar) — se
   algo precisou ser decidido na hora que esta spec não previu, é sinal de
   lacuna, mesmo padrão já usado em `SPEC-001` do `nottcard`.

## Próxima decisão solicitada

Revisar a divisão de módulos (`core`/`ui`/`app`), a decisão de dataclass
sobre JSON, e o mapeamento de telas acima, e aprovar para começar a
implementação (`execution_approval: per-spec`, `.atena/add.yaml`).

## Review record

- Proposed by: Claude, a partir da solicitação do responsável pelo projeto
  em 2026-09-18, seguindo o "Próxima decisão solicitada" de `VSN-001`.
- Reviewed by: responsável pelo projeto, em 2026-09-18.
- Approval decision: aprovada — divisão de módulos (`core`/`ui`/`app`),
  dataclasses sobre JSON, mapeamento de telas e a interação de seleção de
  carta (destaque + linha de mira até o inimigo; cartas sem alvo ativam no
  próprio clique) confirmados.
