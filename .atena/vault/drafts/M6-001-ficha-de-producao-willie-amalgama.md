---
id: "M6-001"
type: "ficha-de-producao"
title: "M6 — Ficha de produção de Willie, o Amálgama Abissal"
status: "promoted"
created: "2026-09-23"
sources:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21]]"
---

# M6 — Ficha de produção de Willie, o Amálgama Abissal

## Leitura confirmada

M6 investiga as Docas anormalmente vazias e enfrenta o que restou de Willie.
Ele é um único chefe, sem segunda fase, formado por cinco tentáculos
independentes e um corpo central. Sua aura de névoa esverdeada atinge a área e
também o fere enquanto incha. Com sua morte, a névoa se dissipa sem ritual de
fechamento.

As últimas palavras de Willie sobre “sua coleção” são apenas gancho para
Interlúdio D; Wonka e o diário de Willie não entram nesta missão.

## Material final disponível

| Papel | Arquivo | Situação |
|---|---|---|
| Corpo do chefe | `assets/enemies/willie_amalgame.png` | Importado. |
| Ambientes existentes | `assets/world/docas/*`, `assets/world/cais/*` | Importados; podem apoiar a caminhada. |

Faltam tentáculo separado, salas M6, props, recompensas visuais, dados de
missão e a regra da aura que fere o próprio chefe.

## Fluxo proposto — precisa de aprovação

1. **Docas silenciosas:** situação de investigação entre barcos vazios;
   encontra óleo e uma poção de sopro de fogo como recompensas narrativas.
2. **Armazém inundado:** aproximação curta, com a névoa verde e os primeiros
   sinais dos tentáculos; sem combate separado para preservar o encontro único.
3. **Píer do Amálgama:** combate de seis slots: Willie + cinco tentáculos.
   Cada tentáculo é alvo independente; a vitória ocorre quando todos caem.

## Extensão técnica mínima proposta

Adicionar ao `Enemy` somente `special_self_damage`: quando uma habilidade
especial é resolvida, o portador pode receber dano fixo. Willie usa isso na
aura de névoa em área. Não cria status de corrupção, tick por turno, aura
genérica, alvo automático ou ordem obrigatória de tentáculos.

A UI atual já comporta seis slots (largura reduzida para grupos maiores que
três), portanto não precisa de painel novo. O corpo e os tentáculos usam
sprites distintos; o jogador pode escolher o alvo como em qualquer grupo.

## Backlog P0

| Entrega | Quantidade | Decisão |
|---|---:|---|
| Salas em camadas | 3 pares `bg`/`fg` | Docas vazias, armazém inundado e píer final. |
| Sprite de tentáculo | 1 | Reutilizado nos cinco slots independentes. |
| Props | 3 | Rede apodrecida, óleo e poção de fogo. |
| Recompensas | 2 itens narrativos | `pocao_sopro_de_fogo`, `oleo_willie`. |
| Dados M6 | 1 missão + mapa + lore + situação | Liberada ao concluir M5. |
| Regra | 1 campo estreito | `special_self_damage` somente ao resolver especial. |

## Não objetivos

- Não criar fase dois, ritual de fechamento, barra de corrupção ou sistema de
  auras recorrentes.
- Não obrigar ordem de alvo ou tornar o corpo invulnerável até os tentáculos.
- Não introduzir Wonka, diário de Willie ou revelações de Interlúdio D.
- Não converter óleo ou poção em cartas/equipamentos nesta fatia.

## Aceite proposto

- M6 exige M5 e mantém uma única luta de chefe com seis slots.
- A aura afeta o grupo e fere somente Willie de forma observável e única por
  resolução de habilidade.
- Salas, tentáculo e props carregam nas telas reais sem fallback.
- Vitória persiste as duas recompensas; M1–M5 passam em regressão.

## Decisão solicitada

Aprovado pelo usuário em 2026-09-23. A intenção foi promovida para o vault
canônico e está em execução dentro deste escopo.
