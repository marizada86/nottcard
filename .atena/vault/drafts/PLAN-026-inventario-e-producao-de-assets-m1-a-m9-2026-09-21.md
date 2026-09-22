---
id: "PLAN-026"
type: "plano"
title: "Inventário e produção de assets — M1 a M9"
status: "approved"
created: "2026-09-21"
reviewed: "2026-09-21"
relations:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[PLAN-017-producao-imagens-m2-art-prompts-022-2026-09-20]]"
  - "[[SPEC-106-auditoria-de-assets-textos-de-ajuda-e-integracao-de-arte]]"
---

# Inventário e plano de assets até M9

## Objetivo e regra de escopo

Levar o Ato 1 inteiro, de M1 a M9 e os interlúdios A–D, de fallback funcional
para arte final integrada.  Este documento separa o que já existe no projeto,
o que pode ser especificado agora e o que depende da ficha da missão.  Assim,
não se cria inimigo, sala ou revelação narrativa que o cânone ainda não definiu.

**Aprovação de produção (2026-09-21):** o responsável aprovou a geração de
todas as imagens previstas até M9. A execução segue em lotes verificáveis;
aprovação de arte não altera o cânone narrativo nem substitui a ficha de cada
missão quando ela for necessária para fechar ids e encontros.

**Contrato para cada asset final:** nome estável em `assets/`, origem bruta fora
do Git em `assets/_raw/`, processamento pela categoria apropriada, auditoria,
e aprovação no contexto real (combate, exploração ou HQ). Cenas são pares
`bg` opaco + `fg` com chroma; mundos são `wall`, `floor`, `ceiling` ladrilháveis;
sprites de inimigo têm fundo magenta; props e portas, fundo verde.

## Foto atual do projeto

| Bloco | Situação | Consequência |
|---|---|---|
| M1 | Completo visualmente: 7 pares de sala, 7 ambientes de mundo, 4 inimigos, props, porta, itens e `hq_001` | Só manutenção e eventual retrabalho de qualidade. |
| M2 | No disco: 6 pares de sala, 6 ambientes (18 texturas), 5 inimigos, porta, props, 2 retratos e 3 itens | Integrar/validar. Faltam as HQs narrativas `hq_002` e `hq_003`. |
| M3–M6 | Só há componentes reutilizáveis: `biblioteca`, `docas`, o sprite de mímico e os retratos do elenco inicial | Cada missão precisa da própria ficha de produção antes de gerar. |
| M7–M9 | Nenhum asset específico ou rota no catálogo de missões | Planejar e produzir integralmente após as fichas de conteúdo. |
| Base comum | 177 cartas, 5 retratos jogáveis, HUD, dados, molduras, telas e portas já existem | Reutilizar; não duplicar por missão. |

`hq_002` e `hq_003` são referenciadas em `core/missions.gd`, mas suas imagens
ainda não existem. O fallback mantém o jogo jogável, porém elas são prioridade
de acabamento de M2.

## Relação de assets por unidade

Legenda: **existente** = arquivo final presente; **novo** = precisa ser criado;
**definir** = o conceito existe, mas quantidade, nomes e rota dependem da ficha
da missão. A contagem "mín." evita transformar detalhe ainda não aprovado em
fato de produção.

| Unidade | Cenários e exploração | Personagens, inimigos e retratos | Props, itens e narrativa | Estado |
|---|---|---|---|---|
| **M1 — Docas** | 7 pares de sala; 7 ambientes; portas e props de doca/porão | criatura corrompida, 2 guardiões, slime; elenco inicial | carta chamuscada, arma de Durvall; `hq_001` | **Existente** |
| **Interlúdio A** | 1 fundo modular de Castle Rodhe/QG | retratos novos: Cassandra, Helion, Zynara; Brook já existe | Broche Celestial; 2–3 quadros de HQ compostos | **Novo/definir** |
| **M2 — Praça da Loucura** | 6 pares de sala; 6 ambientes; igreja, porta e props | 3 cultistas, sacerdote, zumbi; Arlindo e garoto | mapa, gema e poção; props de ritual | **Existente; validar** |
| **Saída de M2** | — | — | `hq_002_q1..q3` e `hq_003_q1..q3`; variante de briefing da missão se a tela genérica não bastar | **Novo: 6–7 imagens** |
| **M3 — Biblioteca Corrompida** | biblioteca de 3 andares; pares de cena e props de puzzle; validar o ambiente `biblioteca` já existente | gárgula (base + variações somente se a ficha pedir); retrato de Aila; Livrinho como prop/companheiro | Ampulheta do Silêncio Eterno, diário das gárgulas, recorte de jornal; 4 pesadelos de personagem se virarem cartas | **Novo/definir** |
| **Interlúdio B** | Castle Rodhe/portão em chamas, reutilizando o fundo de A quando possível | retratos de Kein e Bella; Helion/Zynara reutilizados | cena de sequestro/protesto; 1–2 quadros compostos | **Novo/definir** |
| **M4 — Rodhe's Bridge** | estrada, ponte e carroças; pares de perseguição/combate; 2 ambientes novos no mínimo | rebeldes (família com variantes), prisioneiros; Kein/Bella reutilizados | carroça, cavalos, algemas e 5 cadernos mágicos | **Novo/definir** |
| **M5 — Santuário de Astherion** | cemitério, dimensão do santuário e arena; 2–3 ambientes; pares de chefe | 2 notívagos; Astherion fase 1 e fase 2; retrato/flashback de Sylvaris | círculo de fogo azul, bacia de névoa, lápides; Colar de Visão Verdadeira | **Novo/definir** |
| **Interlúdio C** | Fateridge e salão do banquete; memória do Massacre Celestial | retratos de Thalion e, se necessário, Bromnor em memória; Arlindo reutilizado | banquete e quadros narrativos (2–3) | **Novo/definir** |
| **M6 — Willie** | variante de arena nas Docas, reaproveitando texturas `docas`; props de doca vazia | Willie/Amálgama com 5 tentáculos independentes; aura de névoa verde | poção de sopro de fogo, óleo, diário/gancho de Willie | **Novo/definir** |
| **Interlúdio D** | base dos Greenholders, praça de Ailalore e flashback de Eléstria; 2–3 fundos modulares | retratos de Wonka, Gilly, Hrothgar, Nyrelia e Helion; Arlindo/Bella reutilizados | diário de Willie, Papiro Diário, estrela Ailalore; 3–4 quadros de HQ | **Novo/definir** |
| **M7 — O Espeto de Pau** | ferraria abandonada, salas de portais gêmeos e puzzle; 2 ambientes no mínimo | mímico já existe, mas precisa ser validado; retratos de Korrak e Leoric | forja, portais, diário de Bromnor e achados do puzzle | **Novo/definir** |
| **M8 — Vila das Sombras** | vila, pousada-armadilha e Igreja das Sombras; 3 ambientes no mínimo | demônio sedutor e demais inimigos a definir; retrato de Erik | props da pousada/igreja e artefatos de Bromnor | **Novo/definir** |
| **M9 — Confronto com Kein** | raiz do Plano Abissal, templo e arena de chefe; 2–3 ambientes no mínimo | Kein, Beholder e Death Tyrant como fases distintas; retratos/expressões de Helion se a cena exigir | queda da Tarn, nascimento do Véu, sacrifício de Helion e Martelo da Glória | **Novo/definir** |

## Pacotes reutilizáveis e limites

Não são novos assets por missão: molduras de carta, dados, HUD, fontes, portas
genéricas, tela-base de missão, os cinco retratos jogáveis atuais, cartas já
implementadas e as texturas `docas`/`biblioteca`. Cada reutilização ainda passa
por teste de leitura e coerência de paleta.

Os retratos jogáveis que faltam até M9 são **Korrak, Leoric e Erik**. Os retratos
de NPCs acima são necessários apenas se o roteiro usar diálogo com retrato; se
a HQ transmitir a cena, ela substitui esse retrato e o item sai do lote.

## Ordem de produção

### Lote 0 — preparar o pipeline (antes de nova arte)

1. Implementar e rodar `audit_assets.py` da SPEC-106; ele é a lista automática
   de nomes que o código realmente pede.
2. Registrar uma ficha de asset por missão: salas/ids, encontros, recompensas,
   locais, personagens, spoilers permitidos e rota final.
3. Aprovar uma amostra técnica por categoria: inimigo, cena em camadas, textura,
   porta/prop, retrato, item e HQ. Só então abrir lote dessa categoria.

### Lote 1 — fechar M2 (não bloqueia a especificação de M3)

1. Validar no jogo os 54 arquivos finais já presentes para M2: 5 inimigos,
   12 camadas de cena, porta/props, 18 texturas, retratos e itens.
2. Criar as 6 HQs: `hq_002_q1..q3` e `hq_003_q1..q3`.
3. Decidir se `screens/missao.png` é genérica ou se M2 precisa de uma variante
   própria; criar apenas se o layout/composição realmente exigir.
4. Auditar, testar a missão inteira e marcar os arquivos aprovados.

### Lote 2 — pré-produção de M3 a M6

Fazer quatro fichas de missão, uma por vez, nesta ordem: M3, M4, M5, M6. Cada
ficha fecha ids antes de gerar e alimenta a próxima. Ordem de produção interna:

`cenário-chave → inimigo de referência → pares bg/fg → texturas → props/itens → retratos/HQ → cartas`.

M3 valida o padrão de puzzle e a biblioteca; M4 cria a família de rebeldes e a
perseguição; M5 congela o padrão de chefe em duas fases; M6 reutiliza Docas e
prova o chefe formado por partes independentes.

### Lote 3 — elenco e expansão de M7 a M9

1. Antes de M7, criar e aprovar Korrak e Leoric; antes de M8, Erik.
2. Especificar M7, M8 e M9 antes de gerar qualquer inimigo adicional. A ordem
   narrativa é também a de direção de arte: ferraria → vila sombria → abismo/
   templo. Isso preserva escala e evita antecipar o chefe final.
3. M9 recebe um piloto próprio para as três fases do chefe e para o efeito de
   queda da Tarn/Véu, porque são assets de maior risco visual e de spoiler.

### Lote 4 — polimento transversal

1. Animações de tocha e braseiro (`tocha_0..2`, `braseiro_0..2`) e variantes de
   parede, conforme SPEC-104, primeiro validadas em Docas.
2. Cartas de item, chefe e memória só após seu efeito e recompensa estarem
   congelados. Nunca gerar arte para uma mecânica ainda móvel.
3. Reexecutar auditoria, verificar costura 3×3 das texturas e fazer um percurso
   visual completo M1→M9.

## Gate de aceite de cada lote

- ids, rotas e spoiler permitido aprovados antes da geração;
- até três candidatas brutas por asset e uma aprovação explícita;
- chroma limpo, textura sem emenda e leitura a 64 px/150 px;
- teste dentro da cena real, não apenas no visualizador;
- auditoria sem faltas obrigatórias e regressão de M1/M2 verde;
- somente os finais aprovados entram em `assets/`; brutos ficam em `_raw/`.

## Decisões necessárias antes de transformar este plano em fila de geração

1. Confirmar se interlúdios devem usar **HQs compostas**, **retratos em diálogo**
   ou ambos; isto muda significativamente a quantidade de imagens.
2. Aprovar a criação das fichas de conteúdo M3–M9, começando por M3. O cânone
   atual não define sua topologia, todos os encontros ou recompensas finais.
3. Para cada missão, aprovar a lista fechada que a auditoria vai tornar
   obrigatória; só então a contagem deixa de ser estimativa e vira backlog final.
