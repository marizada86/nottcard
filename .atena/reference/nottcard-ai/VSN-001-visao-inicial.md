---
id: "VSN-001"
type: "vision"
title: "Visão inicial do Nottcard AI"
status: "canon"
created: "2026-09-18"
reviewed: "2026-09-18"
relations:
  - "[[VSN-001-visao-inicial]] (nottcard)"
  - "[[VSN-002-fichas-jogaveis-elenco]] (nottcard)"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]] (nottcard)"
  - "[[SIS-002-destaque-visual-de-mecanica-em-carta]] (nottcard)"
  - "[[SIS-003-fileira-de-inimigos-exploracao-com-cartas-hud]] (nottcard)"
  - "[[SIS-004-direcao-de-arte-pixel-art]] (nottcard)"
  - "[[SPEC-001-vertical-slice-m1-solo]] (nottcard)"
sources:
  - "Declaração do responsável pelo projeto em 2026-09-18"
  - ".atena/vault/canon/nottcard/ (cópia local do design aprovado em nottcard, importada em 2026-09-18 — ver correção abaixo)"
  - "prototype/durvall_m1_solo.py (cópia local do protótipo CLI que já validou a lógica da fatia M1 solo)"
---

# Visão inicial do Nottcard AI

## Declaração proposta

Reimplementar o mesmo jogo de cartas já aprovado em `games/nottcard/`
(personagens, cores de carta, sistema de atributos, fórmula de dano, a
fatia jogável M1 solo) inteiramente em código — sem motor de jogo — como um
executável desktop. A parte visual segue o mesmo processo (prompts
autocontidos para o nano banana, `SIS-004` como guia de estilo).

`nottcard-ai` é um projeto próprio, com seu próprio ciclo de design,
arquitetura e evolução — não uma medição formal contra `nottcard`. Os dois
projetos nascem do mesmo design de jogo e são conduzidos em paralelo pelo
responsável do projeto; qual abordagem (engine vs. código) é melhor é uma
decisão dele, tomada ao vivenciar os dois, não um critério documentado
aqui.

## Contexto confirmado

**Correção de 2026-09-18 (pós-aprovação):** esta seção descrevia o design
como vivendo só em `games/nottcard/`, citado por referência cruzada entre
repositórios. O responsável do projeto pediu independência total — as
imagens e specs sendo feitas em pastas separadas estavam atrapalhando o
fluxo de trabalho. Ver "Este projeto não redefine design" abaixo, que essa
correção substitui, para a política atual.

- `games/nottcard/.atena/vault/canon/` já tinha design aprovado: visão
  (`VSN-001`, `VSN-002`), sistema de atributos e eficiência por cor
  (`SIS-001`), destaque visual de mecânica em carta e fileira de inimigos
  (`SIS-002`, `SIS-003`), direção de arte pixel art (`SIS-004`), e uma spec
  completa e aprovada da primeira fatia jogável (`SPEC-001`: Durvall, 12
  cartas, 6 salas, fórmula de dano com Corrente de Classe).
- Essa fatia já foi validada logicamente num protótipo CLI em Python
  (`prototype/durvall_m1_solo.py`), sem interface gráfica — boa parte da
  sua lógica (`Card`, `ComboTracker`, `resolve_card`, `Enemy`, `Player`, as
  6 funções de sala) é reaproveitável quase 1:1 na versão gráfica deste
  projeto.
- `nottcard/game/` está migrando essa mesma fatia para uma versão gráfica
  em Godot, em paralelo a este projeto — sem dependência entre os dois.

## Este projeto não redefine design (mas agora mantém cópia própria)

**Correção de 2026-09-18 (pós-aprovação):** a versão original desta seção
dizia que `nottcard-ai` só *citava* os documentos de `games/nottcard/`, sem
duplicá-los, corrigindo qualquer divergência lá. O responsável do projeto
reverteu essa decisão no mesmo dia: gerar imagens e escrever specs
alternando entre duas pastas de dois repositórios diferentes estava
atrapalhando o fluxo de trabalho dele. A partir desta correção:

- Os documentos citados (`VSN-001/002`, `VSN-003/004`, `SIS-001..004`,
  `SPEC-001-vertical-slice-m1-solo`, `MUNDO-001`, `PERS-durvall`,
  `ART-PROMPTS-001`, `EVID-001`, `prototype/durvall_m1_solo.py`) foram
  **copiados** para dentro deste repositório, em
  `.atena/vault/canon/nottcard/`, `.atena/specs/nottcard/`,
  `.atena/generated/nottcard/`, `.atena/evidence/nottcard/` e
  `prototype/`, mantendo os IDs e nomes de arquivo originais (por isso a
  pasta extra `nottcard/` — evita colisão com os IDs próprios deste
  projeto, como o próprio `VSN-001`).
- `nottcard-ai` **não redefine o design do jogo de origem** — a cópia é
  ponto de partida, não um novo ciclo de design. Mas divergências futuras
  entre os dois projetos **não se propagam mais automaticamente**: cada um
  evolui sua própria cópia a partir daqui.
- O design ainda **não é redefinido arbitrariamente** aqui — mudar um
  número/regra herdado da cópia é uma decisão consciente, registrada como
  qualquer outra mudança neste vault (spec própria, review record), não um
  ajuste silencioso.

## Decisões já fechadas para este projeto

- **Escopo:** mesmo design de `nottcard`, implementação própria — não é um
  experimento de design novo.
- **Metodologia:** ADD completo, como em `nottcard` (`.atena/add.yaml`,
  vault canon/drafts, specs, evidence, generated).
- **Stack técnica:** Python + pygame-ce (biblioteca de janela/input/desenho,
  sem editor nem cena) + PyInstaller (`--onefile`) para gerar o executável.
  Testes de lógica de jogo via `pytest`, ganho sobre a validação manual do
  protótipo CLI original.
- **Repositório:** git independente, próprio deste diretório.

## Arquitetura interna de código

- `game/core/` — lógica pura de jogo, sem import de pygame: `cards.py`
  (dataclasses de carta/baralho), `combat.py` (fórmula de dano, Corrente de
  Classe, passiva do Durvall), `rooms.py` (mapa de salas), `state.py`
  (`GameState`: PV, mão, baralho, descarte, sala atual). Recorte quase
  direto de `prototype/durvall_m1_solo.py`.
- `game/ui/` — só desenho e input (renderização de carta, HUD, portraits);
  nenhuma regra de jogo mora aqui.
- `game/app.py` — laço principal com uma máquina de estados simples
  (`Screen` com `handle_event`/`update`/`draw`): Menu → Exploração →
  Combate → Game Over.
- Conteúdo de carta/inimigo/sala como dado declarativo (dataclass/JSON),
  não montado imperativamente — reajustar números do `SPEC-001` não deve
  exigir tocar em lógica ou renderização.
- Cache de assets centralizado (carregar cada imagem uma vez, não a cada
  frame).

## Pipeline de asset

- Saída bruta do nano banana em `assets/_raw/` (fora do git); só o
  processado final é versionado em `assets/<categoria>/`.
- Script `scripts/process_art.py` (Pillow): downscale com nearest-neighbor
  quando precisar de pixel exato, conversão de chroma-key verde → alfa nos
  ícones de HUD, resize/pad pro tamanho final — mesmas specs técnicas já
  definidas em `SIS-004` (cópia local em
  `.atena/vault/canon/nottcard/regras/SIS-004-direcao-de-arte-pixel-art.md`).
- Nome de arquivo = identificador da carta/inimigo nos dados do `core`
  (`golpe` → `assets/cards/golpe.png`), carregado por convenção, sem mapa
  manual.
- Fallback visual quando o asset não existe: retângulo colorido com o nome
  por cima — desacopla o progresso de código do ritmo de geração de arte.
- `PyInstaller --onefile` não inclui `assets/` sozinho: empacotamento final
  precisa de `--add-data` e checar `sys._MEIPASS` em runtime.

## Hipóteses a validar

- Separar lógica pura (`core`) de renderização (`ui`) permite validar toda
  a regra de jogo via `pytest`, sem depender de janela gráfica nem de
  playtest manual (diferente do `EVID-001` do `nottcard`, que foi só
  playtest manual).
- O fallback visual para asset ausente permite avançar a lógica de jogo
  sem ficar bloqueado esperando a geração/curadoria de arte.

## Limites desta proposta

Esta visão não define o formato exato dos dados de conteúdo (dataclass vs.
JSON, schema de carta/inimigo/sala), nem a ordem de implementação das
telas (`Screen`). Também não decide se o resultado deste projeto será
mantido a longo prazo — isso é decisão do responsável do projeto, tomada
fora do escopo desta visão.

## Próxima decisão solicitada

Revisar esta proposta e aprovar para virar conteúdo canônico. Após
aprovação, abrir a primeira especificação técnica: porte da lógica de
`prototype/durvall_m1_solo.py` para uma UI gráfica em pygame-ce (mesma
fatia M1 solo, mesmos números de `SPEC-001`).

## Review record

- Proposed by: Claude, a partir da solicitação do responsável pelo projeto
  em 2026-09-18.
- Reviewed by: responsável pelo projeto, em 2026-09-18.
- Approval decision: aprovada.
