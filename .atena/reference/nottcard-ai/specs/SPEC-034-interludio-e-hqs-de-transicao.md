---
id: "SPEC-034"
type: "spec"
title: "Interlúdio (hub entre missões) e HQs de transição"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[HQ-000-guia-de-producao-e-ficha-de-transicao]]"
  - "[[HQ-001-piloto-m1-para-interludio-a]]"
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[SPEC-033-save-em-disco]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-036-mochila-e-itens]]"
sources:
  - "Responsável, 2026-09-19: HQ como 4 quadros em tela cheia; Interlúdio como hub; só o piloto agora"
---

# Interlúdio e HQs de transição


## Decisão de formato (muda o `HQ-000`)

O guia fala em "1 página com 4 quadros", mas a arte é pedida em 1920×1080 por quadro; numa página única cada
quadro ficaria com ~640×360. **Cada HQ é uma sequência de 4 quadros em tela cheia**, com o texto composto
pela UI. O `HQ-000` deve ser ajustado a isto antes de virar canon.

## 1. HQ de transição

- **Dado declarativo** (`Hq`): `id`, `titulo` e uma lista de `Panel(image, speaker, text)`. Sem lógica.
- **Tela** (`HqScreen`): mostra um quadro por vez, em tela cheia, com uma faixa escura embaixo para o texto
  (a UI desenha legenda e fala; a arte nunca traz texto). Fade curto entre quadros.
- **Ritmo:** ~10 s no total (8–12 s). Clique ou Enter avança para o próximo quadro; **Esc pula a HQ inteira**.
  Sempre pulável.
- **Arte ausente:** cada quadro cai num fundo escuro liso com o texto por cima (mesma regra de fallback do
  projeto), então o piloto roda sem a arte pronta.
- **Quando aparece:** ao vencer a missão, **antes** da tela de resultado, **só na primeira vez** (id da HQ
  guardado em `SaveState.hqs_seen`). Derrota e desistência não mostram HQ.
- **Rever:** o menu ganha "Diário", que lista as HQs já vistas e permite reassistir. HQ não vista não
  aparece na lista.

## 2. Interlúdio (hub entre missões)

Tela leve que junta o que acontece entre duas missões. Na v1 só o piloto (M1 → Interlúdio A):

- Resultado da tentativa (o `ResultadoScreen` atual passa a ser o primeiro passo do Interlúdio).
- Botões: **Loja** (`SPEC-035`), **Mochila** (`SPEC-036`, quando existir), **Diário**, **Próxima missão**.
- Botões de modos ainda não implementados **não aparecem** (nada de botão desabilitado ou "em breve").
- O Interlúdio não escolhe grupo na v1; esse botão chega com a `SPEC-037`.
- "Próxima missão" na v1 volta à seleção de personagem, pois só o M1 existe.

## 3. Piloto

`HQ-001` (M1 → Interlúdio A): 4 quadros, 29 palavras. Elenco em cena no quadro é Durvall, Kayron, Sylas e
Maelor, embora o M1 jogável seja solo: é HQ narrativa, não reflete o grupo jogável. Os spoilers proibidos da
ficha valem integralmente.

## Arquitetura

- `game/core/hq.py`: `Hq`, `Panel` e o catálogo (`HQS`), dados puros, sem pygame.
- `game/core/progress.py`: `SaveState.hqs_seen: set[str]`.
- `game/ui/hq_screen.py`: `HqScreen`.
- `game/app.py`: `finish_run(VITORIA)` abre a HQ (se não vista) e depois o resultado; `InterludioScreen` no
  lugar de `ResultadoScreen` como raiz do hub; entrada "Diário" no menu.
- Imagens em `assets/hq/<hq_id>_q<n>.png` (ex.: `hq_001_q1.png`), 1920×1080 → 1280×720 (categoria nova `hq` no
  `process_art.py`, crop 16:9 e PNG indexado, igual a `rooms` e `screens`). Os arquivos ficam soltos em `assets/hq/`,
  sem subpasta por HQ, para o `load_image` da categoria achá-los pelo slug.
- `InterludioScreen` é uma subclasse de `ResultadoScreen` usada só depois de **vitória**; derrota e desistência
  seguem na `ResultadoScreen` com "Jogar de novo". O `DiarioScreen` recebe para onde "Voltar" leva (o menu ou o
  Interlúdio).
- Os botões do menu encolhem quando são 6 ou mais (o Diário é o 6º).

## Fora de escopo

As outras 21 HQs (só depois de validar o piloto); voz, animação e música; escolha de próxima missão
(depende de missão como dado).

## Critérios de aceite

- [x] Vencer o M1 mostra a HQ uma vez; da segunda vitória em diante não aparece.
- [x] Esc pula a HQ inteira; clique avança; ~10 s no ritmo normal.
- [x] Sem arte, os 4 quadros rodam com o fundo de fallback e o texto.
- [x] O Diário lista só HQs vistas e permite reassistir.
- [x] Derrota e desistência não mostram HQ.
- [x] O Interlúdio só mostra botões de modos que existem.
- [x] `core` sem pygame. Testes de fluxo.
- [ ] Playtest do piloto (e a arte dos 4 quadros, ainda por gerar).

Implementado em 2026-09-19: `game/core/hq.py`, `SaveState.hqs_seen`, `game/ui/hq_screen.py`, `InterludioScreen` e
`DiarioScreen` em `game/app.py`. O piloto roda sem a arte (fundo escuro com o texto); os 4 quadros de `HQ-001` ainda
precisam ser gerados em `assets/_raw/hq/`.
