---
id: "M9-001"
tipo: "ficha-de-producao"
titulo: "M9 — O Confronto com Kein"
status: "promoted"
created: "2026-09-23"
sources:
  - "VSN-003-estrutura-de-missoes-arco-01"
  - "PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21"
---

# M9 — O Confronto com Kein

## Recorte canônico

M9 encerra o Ato 1 no Plano Abissal (raiz) e no templo. O confronto escala em
três fases: Kein, Beholder e Death Tyrant. A vitória causa a queda da Tarn,
registra o sacrifício de Helion, inaugura o Véu e entrega o Martelo da Glória.

Esses eventos pertencem explicitamente a M9. Não serão acrescentados o
rescaldo do Interlúdio E, a condição de Aila, a reação de Thalion, conteúdo de
M10 ou qualquer pista sobre a traição futura de Durvall.

## Decisão de implementação proposta

Como o marco de elenco ainda não foi implementado, M9-A mantém o elenco
jogável atual. Os recrutas narrativos de M7/M8 continuam disponíveis apenas
como flags de história.

Rota linear proposta:

1. **Raiz do Plano Abissal** — situação de travessia e leitura das raízes.
2. **Templo da Tarn** — situação que localiza o altar e o Martelo da Glória.
3. **Altar do Véu** — combate de chefe encadeado: Kein → Beholder → Death
   Tyrant. As três formas usam os sprites já importados.

O desfecho aparece apenas no texto final da missão: a luz de Helion sustenta a
retirada, a Tarn se desfaz e o Véu toma seu lugar. Não haverá retrato de Helion
nem uma HQ adicional nesta entrega.

## Conteúdo técnico

- Criar três pares de cenas e props da raiz, templo e altar; criar o ícone do
  Martelo apenas se a carta existente não puder ser usada como item.
- Configurar três fábricas de inimigo e fases encadeadas com o mecanismo de
  encontro já usado em Astherion.
- Criar dungeon/lore/situações M9, ligar M9 após M8 e registrar
  `martelo_da_gloria`, `tarn_caida`, `sacrificio_helion` e `veu_nascido`.
- Reutilizar kits 3D existentes para a caminhada; a identidade visual principal
  estará nas cenas de encontro e de combate.

## Critérios de aceite

- M9 exige M8, contém três salas e apresenta as três fases na ordem canônica.
- O fim persiste as quatro chaves narrativas e não desbloqueia o elenco tardio.
- Sprites existentes e novas cenas/props carregam sem referência ausente.
- Contrato M9, combate das fases, fluxo/UI, auditoria e regressão passam.

## Não objetivos

- Implementar recrutamento selecionável de Korrak, Leoric e Erik.
- Criar um sistema global de transformação de chefes além da cadeia local.
- Adicionar o Interlúdio E, eventos de M10 ou spoilers de M21.

## Decisão aprovada

O usuário aprovou a M9-A com três salas, o confronto encadeado Kein → Beholder
→ Death Tyrant e o desfecho textual da queda da Tarn, sacrifício de Helion,
nascimento do Véu e obtenção do Martelo da Glória.
