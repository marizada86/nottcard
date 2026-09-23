---
id: "M5-001"
type: "ficha-de-producao"
title: "M5 — Ficha de produção do Santuário de Astherion"
status: "promoted"
created: "2026-09-23"
promoted_to: "[[M5-001-santuario-astherion]]"
sources:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21]]"
---

# M5 — Ficha de produção do Santuário de Astherion

## Leitura confirmada

M5 investiga o desaparecimento de Bromnor e a fratura no cemitério de Dagruve,
atravessa para o Santuário de Astherion e sela a Tarn de Dagruve. Há dois
Notívagos e Astherion em duas fases. Sylvaris aparece somente em flashback;
seu colar ainda não é identificado como artefato de Ghaunadaur.

Astherion reage de modo anormal a Durvall, mas a razão não pode ser explicada
nem mecanizada. O Colar de Visão Verdadeira é a recompensa narrativa.

## Material final disponível

| Papel | Arquivo | Situação |
|---|---|---|
| Chefe, fase 1 | `assets/enemies/astherion_fase_1.png` | Importado. |
| Chefe, fase 2 | `assets/enemies/astherion_fase_2.png` | Importado. |
| Inimigo-base | `assets/enemies/notivago.png` | Importado. |
| Recompensa | `assets/items/colar_visao_verdadeira.png` | Importado. |

Não existem salas M5, props do santuário, retrato/flashback de Sylvaris,
texturas próprias, dados de missão ou comportamento de segunda fase.

## Fluxo proposto — precisa de aprovação

1. **Cemitério partido:** situação de investigação do rastro de Bromnor e
   combate contra dois Notívagos.
2. **Limiar da dimensão:** exploração curta entre lápides e névoa, com a bacia
   que alimenta a fratura como prop de cena.
3. **Santuário de fogo azul:** Astherion começa com golpes de pressão e
   paralisia; no limiar de vida absorve a névoa da bacia, troca para a arte e
   o conjunto de ataques da fase 2. A vitória sela a Tarn e concede o Colar.

## Extensão técnica mínima proposta

Acrescentar a `EncounterScript` um único modo declarativo de **substituição de
fase**, disparado uma vez abaixo de uma porcentagem de PV:

- retira somente o chefe portador do combate;
- insere um `Enemy` sucessor no mesmo lugar visual, preservando os demais;
- a UI apresenta uma mensagem curta e atualiza sprite/nome/ataques;
- não cria máquina genérica de cinematics, múltiplas transformações ou IA.

Esse é o menor contrato que representa a troca real de Astherion e pode ser
reutilizado por futuros chefes somente se declararem explicitamente o mesmo
modo. A invocação de zumbis de M2 permanece inalterada.

## Backlog P0

| Entrega | Quantidade | Decisão |
|---|---:|---|
| Salas em camadas | 3 pares `bg`/`fg` | Cemitério, limiar e santuário/arena. |
| Props | 3 | Lápide, bacia de névoa e círculo de fogo azul. |
| Chefe de duas fases | 1 extensão estreita | Substituição única de fase. |
| Dados M5 | 1 missão + mapa + lore + situação | Liberada ao concluir M4. |
| Persistência | 2 chaves narrativas | `colar_visao_verdadeira` e `tarn_dagruve_selada`. |
| Flashback de Sylvaris | 0–1 arte | Só se a tela precisar dele; texto curto é suficiente no P0. |

## Não objetivos

- Não explicar a ligação de Durvall a Astherion/Ghaunadaur.
- Não fazer do Colar carta, equipamento ou poder jogável.
- Não criar puzzle de ritual, sistema de paralisia global ou mecânica de
  sangue; o selo é consequência narrativa da vitória.
- Não adaptar Interlúdio C nem o destino de Bromnor nesta missão.

## Aceite proposto

- M5 fica bloqueada antes de M4 e liberada depois dela.
- As duas fases usam sprites, nomes e ataques distintos no mesmo combate.
- Os três pares de cenário e props P0 carregam sem fallback nas telas reais.
- A vitória persiste o Colar e o selo da Tarn; M1–M4 passam em regressão.

## Decisão registrada

O recorte e a substituição única de fase foram aprovados em 2026-09-23. O
registro canônico e o contrato de execução ficam em
`[[M5-001-santuario-astherion]]` e `SPEC-008`.
