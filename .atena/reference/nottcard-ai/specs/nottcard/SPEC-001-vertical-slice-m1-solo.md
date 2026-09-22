---
id: "SPEC-001"
type: "spec"
title: "Vertical slice jogável — M1 solo: A Fechadura da Fenda nas Docas"
status: "canon"
created: "2026-09-15"
reviewed: "2026-09-15"
relations:
  - "[[VSN-001-visao-inicial]]"
  - "[[VSN-002-fichas-jogaveis-elenco]]"
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SIS-002-destaque-visual-de-mecanica-em-carta]]"
sources:
  - "Nottgard Card Game/tmp/pdfs/build_design_pdf.py (regras-base: loop, combate, cartas, progresso — documento de design original de 31/08/2026)"
  - ".atena/vault/canon/missoes/VSN-004-elementos-adaptaveis-m1-m6.md (conteúdo narrativo de M1)"
  - ".atena/vault/canon/personagens/PERS-durvall-ficha-jogavel.md"
  - ".atena/vault/canon/regras/SIS-001-atributos-e-eficiencia-de-cor.md"
---

# Vertical slice jogável — M1 solo: A Fechadura da Fenda nas Docas

## Declaração proposta

`build_design_pdf.py` (Seção 05) lista 8 decisões necessárias antes da primeira especificação; a 8ª (recorte de lore autorizado) já está resolvida por `VSN-004`. Esta spec propõe números e regras concretas para as 7 restantes, no menor recorte possível: **M1, tentativa solo, um único personagem** — exatamente como o documento original já definia para a primeira tentativa.

**Correção de 2026-09-15 (pós-aprovação):** Nottgard Card Game é um **jogo de PC**, não um boardgame físico — referência confirmada pelo responsável do projeto: **Vampire Crawlers (poncle, 2026)**, um roguelike deckbuilder que entra em visão de primeira pessoa dentro de cada dungeon, mesmo modelo já previsto em `build_design_pdf.py`. Duas decisões vieram junto com essa correção: (1) o gatilho de combo da Corrente de Classe **permanece** o já aprovado — mesma classe/cor em sequência, **sem** sistema de custo de mana (Vampire Crawlers usa ordem crescente de mana; Nottgard não adota isso); (2) a primeira verificação jogável será um **protótipo em texto/CLI (Python)**, não cartas físicas — valida a lógica e os números antes de qualquer motor gráfico. O restante desta spec (números, inimigos, mapa) continua valendo; só a forma de verificação muda (ver seção "Verificação proposta").

Todos os números abaixo são **propostos por Claude, pendentes de aprovação** — o padrão de precisão (PV, dano, tamanho de baralho) é um ponto de partida testável, não um balanceamento final.

## 0. Personagem da fatia vertical

**Recomendação: Durvall**, não Kayron (que `build_design_pdf.py` cita primeiro, mas sem obrigar a ordem).

- **Por quê:** a passiva de Durvall (dano psiônico bônus por Corrente de Classe: 2x=1d6 | 3x=2d6 | 4x=3d6) expõe a mecânica central do jogo — a Corrente de Classe — da forma mais direta e legível possível. A passiva de Kayron (acumular "Carga de Poder Místico" antes de gastar) exige entender um recurso extra antes de entender o combo; melhor validar o loop-base primeiro.
- Sylas (cópia com metade da vida) e Maelor (gatilho por elemento fogo) ficam para a 2ª e 3ª iteração do protótipo, depois que o loop-base for validado com Durvall.

## 1. Vida, mão e baralho do jogador

| Parâmetro | Valor proposto | Racional |
|---|---|---|
| PV inicial | **20** | Sobrevive a 3–4 acertos médios sem trivializar risco; redondo o bastante para conta de cabeça num protótipo de papel. |
| Compra por turno | 1 carta (já definido em `build_design_pdf.py`) | — |
| Tamanho de mão | inicia com 3 (compradas no "Preparar"), máximo 5 em mão | Excedente é descartado ao fim do turno em que ultrapassar — regra padrão de deckbuilder, evita acúmulo infinito. |
| Tamanho do baralho inicial | **12 cartas** | Dá ~4 turnos completos de jogo antes de precisar embaralhar o descarte de volta — compatível com a meta de 15–30 min por Missão. |
| Descarte esgotado | ao comprar com o baralho vazio, embaralha o descarte e continua | Evita travar a partida no meio de um combate longo. |

## 2. Composição do baralho inicial (Durvall)

**Correção de 2026-09-16:** a arma inicial de Durvall **não é uma carta** —
é o item equipável que ele já começa a tentativa portando (ver seção 5).
A versão anterior desta seção colocava a arma como a 12ª carta do baralho,
o que duplicava o conceito (arma como item *e* como carta ao mesmo tempo).
Pra manter o baralho em 12 cartas (decisão do responsável do projeto), o
slot vago foi preenchido com uma 5ª cópia de "Golpe" em vez da carta de
arma — mesma carta já existente, sem novo número pra validar.

12 cartas, majoritariamente Vermelho (cor dele), com uma mistura para exercitar a regra de compatibilidade (50% fora de classe) desde o primeiro playtest:

| Qtd | Cor | Tipo | Efeito base proposto |
|---|---|---|---|
| 5 | Vermelho (classe) | Ataque | 1d8 dano físico |
| 2 | Vermelho (classe) | Ataque especial | 1d6 dano físico + ignora 1 ponto de redução de armadura |
| 2 | Roxo (Universal) | Suporte leve | recupera 1d4 PV |
| 2 | Amarelo (fora de classe → 50%) | Ataque mágico | 1d6 dano mágico (efetivo: metade, arredondado para cima) |
| 1 | Azul (fora de classe → 50%) | Controle | reduz o próximo ataque inimigo em 1d4 (efetivo: metade) |

- As 2 cartas Amarelo/Azul existem **de propósito**, para o próprio protótipo testar se a regra de compatibilidade de 50% é legível e vale a pena narrativamente (jogar "fora de classe" por flexibilidade vs. jogar sempre na cor própria para manter a Corrente).
- **Nota sobre a Corrente de Classe:** a seção 3 registra que "cartas equipáveis contam para a Corrente de Classe" — essa regra geral continua válida para personagens/itens futuros, mas **não se aplica a este baralho de Durvall**, já que não sobrou nenhuma carta equipável nele.

## 3. Resolução de dano (fecha a pendência aberta em SIS-001)

**Correção de 2026-09-15:** a versão anterior desta seção esquecia de integrar a **Corrente de Classe** (já definida em `build_design_pdf.py`, Seção 02) e o **bônus específico de passiva do Durvall** (`PERS-durvall`) na mesma fórmula. Isso só apareceu ao montar o protótipo CLI — exatamente o tipo de lacuna que a "Verificação proposta" existe para pegar. Fórmula corrigida, em duas camadas:

**Camada 1 — dano da carta em si:**

```
dano_carta = arredondar_para_cima( dano_base × multiplicador_corrente × modificador_compatibilidade × (1 + bônus_atributo) )
```

- `dano_base` = valor impresso na carta (ex.: 1d8).
- `multiplicador_corrente` = 1x / 2x / 3x / 4x, conforme a Corrente de Classe (jogar carta da mesma classe em sequência aumenta; carta de outra classe zera a corrente de volta a 1x). Cap em 4x.
- `modificador_compatibilidade` = 1.0 (carta da classe do personagem) ou 0.5 (fora de classe).
- `bônus_atributo` = bônus percentual de `SIS-001` para a cor da carta, no personagem que a jogou.
- Arredondar **só uma vez**, no final — nunca entre os fatores (evita que a ordem de multiplicação afete o resultado por causa de arredondamentos intermediários).
- **A Corrente de Classe zera ao entrar em um novo combate** — não persiste entre salas/inimigos diferentes. Decidido em 2026-09-15, após o protótipo CLI ter implementado (por omissão) o oposto e isso ter ficado visível jogando.
- **Cartas equipáveis contam para a Corrente de Classe** desde que sejam da cor da classe do personagem, mesmo sem causar dano diretamente — o que importa é a cor bater com a classe, não o tipo de efeito da carta. Confirmado em 2026-09-15.

**Camada 2 — bônus fixo de passiva (só Durvall, só quando ele mesmo joga a carta):**

- Se a corrente estiver em 2x, 3x ou 4x no momento em que Durvall joga uma carta, some um dano psiônico fixo **à parte** (não entra na multiplicação da Camada 1): 2x → +1d6 · 3x → +2d6 · 4x → +3d6.

**Exemplos completos (Durvall, Força 16 → +60% Vermelho):**

| Situação | Carta | Cálculo Camada 1 | Camada 2 (passiva) | Dano total |
|---|---|---|---|---|
| Primeira carta da corrente (1x) | Vermelho 1d8 (média 4.5) | 4.5 × 1 × 1.0 × 1.6 = 7.2 → **8** | corrente em 1x, sem bônus | **8** |
| Segunda carta da mesma classe (2x) | Vermelho 1d8 (média 4.5) | 4.5 × 2 × 1.0 × 1.6 = 14.4 → **15** | +1d6 (média 3.5 → **4**) | **19** |
| Carta fora de classe, corrente zerada (1x) | Amarelo 1d6 (média 3.5), Inteligência 14 → +40% | 3.5 × 1 × 0.5 × 1.4 = 2.45 → **3** | corrente em 1x, sem bônus (e a passiva de Durvall só soma em cartas jogadas *por ele*, independente da cor — mas exige corrente ≥2x) | **3** |

- Nota: a Camada 2 depende só da corrente estar ≥2x no momento do jogo, não da cor da carta jogada — é um bônus do personagem, não da carta.

## 4. Mapa e distribuição de salas (fatia solo de M1)

`build_design_pdf.py` descreve exploração "em primeira pessoa"; para um protótipo de papel, isso vira um **mapa de nós fixos** (point-crawl) — cada nó é uma sala com um tipo. Proposta de fórmula geral (reaproveitável em Missões futuras) e a instância concreta de M1:

**Fórmula geral proposta:** para uma Missão de 15–30 min, 5–7 salas, na proporção ~40% exploração/evento, 40% combate padrão, 20% clímax/chefe.

**M1 solo (6 salas, linear):**

| # | Sala | Tipo | Conteúdo |
|---|---|---|---|
| 1 | As Docas | Exploração | sem combate; pista + gancho ambiental (ver item 6) |
| 2 | O cais atacado | Combate padrão | criatura corrompida (ver item 7) |
| 3 | A rachadura na Tarn | Evento | examinar símbolos; decide se a Sala 6 é "cópia depois verdadeiro" ou direto o verdadeiro (ver nota do designer) |
| 4 | O porão — entrada | Exploração | encontrar o slime; interação opcional (pode ser evitado) |
| 5 | O porão — sala de livros | Combate padrão | guardião alado (cópia) |
| 6 | O ritual | Combate-clímax | guardião alado (verdadeiro) — mini-chefe da fatia |

## 5. Movimento, interações essenciais e equipamento

- **Custo de movimento:** nenhum custo em cartas/recursos para avançar de sala — mantém o ritmo de 15–30 min. Ao entrar numa sala nova, role 1d6: 1–2 = "eco da névoa" (efeito ambiental leve, ex.: descartar 1 carta ao acaso); 3–6 = nada especial. Aplica-se só a salas de Exploração/Evento, não a salas de Combate (que já têm seu próprio encontro).
- **Interações essenciais:** Examinar (revela pista/item), Descansar (só em salas sinalizadas como tal — nenhuma nesta fatia solo, de propósito, para manter tensão), Usar item de progressão (ex.: nenhum broche nesta fatia — ela é anterior à promoção a Guardião).
- **Equipamento:** 1 arma + 1 acessório equipados por vez. Durvall começa a tentativa já com sua arma de assinatura equipada (não é uma carta — ver correção de 2026-09-16 na seção 2). Trocar entre salas não custa nada; trocar **durante** um combate custa a Ação do turno. Itens encontrados vão para uma mochila temporária de até 3 slots, descartada ao fim da tentativa (baralho e itens são "por tentativa", conforme já definido em `build_design_pdf.py`, Seção 04).

## 6. Cura e a adaptação solo da regra de "queda"

`build_design_pdf.py` define: *"Se houver sobreviventes, um personagem caído retorna com 1 PV ao fim do combate. Sem sobreviventes, a Missão reinicia."* Isso pressupõe grupo — **numa tentativa solo isso não se aplica**: não há sobrevivente para reviver o personagem caído.

- **Regra adaptada proposta:** em tentativa solo, chegar a 0 PV reinicia a Missão imediatamente (mesmo efeito de "sem sobreviventes"), preservando Conquistas já obtidas (regra geral de progresso já vale).
- **Cura entre salas:** nenhuma automática. As únicas fontes de cura nesta fatia são as 2 cartas de Suporte do próprio baralho (item 2) — decisão deliberada para testar se 20 PV + 2 cartas de cura é osso duro demais ou fácil demais no primeiro playtest.

## 7. Inimigos da fatia (estatísticas propostas)

| Inimigo | Sala | PV | Ataque básico | Habilidade especial |
|---|---|---|---|---|
| Criatura corrompida pela névoa | 2 | 8 | 1d6 físico | — (combate tutorial, sem complicação) |
| Slime corrosivo | 4 (opcional) | 6 | 1d4 físico | acerto reduz em 1 o dano das cartas de arma física de Durvall até o fim da sala |
| Guardião alado (cópia) | 5 | 12 | 1d8 físico | "Investida": a cada 2 turnos, ataque causa 1d8+2 em vez de 1d8 |
| **Guardião alado (verdadeiro) — mini-chefe** | 6 | 20 | 1d8+2 físico | "Grito Abissal" (a cada 2 turnos): 1d6 de dano + próximo ataque de Durvall sofre -1; usa cronômetro de decisão (ver item 8) |

- A Sala 4 (slime) é marcada opcional para que o protótipo também teste o ritmo de uma Missão "mais curta" vs. "completa" no mesmo material.

## 8. Regras de chefe (fecha a pendência sobre o cronômetro)

`build_design_pdf.py` já define que chefes "usam um cronômetro por turno para jogar cartas" e têm "habilidades não fixas", mas não diz o que acontece se o tempo esgotar. Proposta:

- **Tempo por decisão:** 45 segundos para escolher e jogar uma carta no turno do jogador contra o chefe — enforçado de verdade pelo software (input com timeout), já que não é mais um protótipo de papel.
- **Se esgotar:** o personagem "hesita" — perde a Ação daquele turno (sem dano extra ao jogador; a pressão é só a de perder tempo de jogo, não uma punição dupla). A Ação Bônus continua disponível normalmente. No protótipo CLI (sem interface gráfica), o timeout de input é simulado via `input()` com limite de tempo; se o terminal não suportar isso de forma confiável, o próprio script sinaliza o tempo restante a cada decisão em vez de bloquear.
- **Fases:** o guardião verdadeiro desta fatia tem **1 fase única** (mini-chefe, não o "chefe completo" de fim de Ato) — deliberadamente mais simples que os chefes multifásicos de missões futuras (ex.: Astherion em M5), para isolar a variável "cronômetro + habilidade especial" sem também introduzir troca de fase no mesmo teste.

## O que esta spec NÃO resolve (fora de escopo)

- Baralhos iniciais de Kayron, Sylas Malafa e Maelor (ficam para depois que o protótipo com Durvall for jogado pelo menos uma vez).
- Modelo de posicionamento "corredor vs. arena" — **proposta deliberada de adiamento**: todos os combates desta fatia tratam os inimigos como um único alvo direto (sem posicionamento), para não misturar essa variável de design com o teste do loop principal. Revisitar somente se/quando uma Missão precisar de múltiplos inimigos simultâneos em cena.
- Loja, ouro farmável e desbloqueio de personagens adicionais (Seção 04 do design original) — irrelevante para uma fatia de uma única tentativa.
- Arte de carta e a convenção visual de `SIS-002` (ainda em draft) — esta spec descreve efeito mecânico, não o texto/diagramação final da carta.

## Verificação proposta

1. Implementar um protótipo em texto/CLI (Python) com as 12 cartas de Durvall, os 4 inimigos, o mapa de 6 salas e a fórmula de dano completa (item 3, camadas 1 e 2) — `games/card-game/prototype/`.
2. Jogar a fatia interativamente pelo terminal, do início ao fim, medindo a duração real da tentativa.
3. Registrar em `.atena/evidence/` (arquivo `EVID-001`, a criar após o playtest): duração real vs. meta de 15-30 min, se houve morte/reinício, se a fórmula de dano gerou números que "pareceram certos" jogando, e qualquer regra que precisou ser inventada/corrigida na hora (sinal de lacuna não coberta por esta spec — como já aconteceu com a Corrente de Classe, corrigida acima).
4. Com base nisso, ajustar os números aqui antes de estender a mesma spec para Kayron/Sylas/Maelor, para M2, ou para migrar a lógica para um motor gráfico.

## Próxima decisão solicitada

Revisar os números propostos (PV, baralho, inimigos, fórmula de dano) e aprovar para um primeiro playtest físico, ou apontar ajustes antes de montar as cartas.

## Review record

- Proposed by: Claude, a partir da solicitação do responsável pelo projeto em 2026-09-15, respondendo às 7 decisões em aberto da Seção 05 de `build_design_pdf.py`.
- Reviewed by: responsável pelo projeto, em 2026-09-15.
- Approval decision: aprovada — Durvall confirmado como personagem da fatia; 20 PV, baralho de 12 cartas e mão máxima 5 confirmados; fórmula de dano explicada e aprovada.
- Correção de 2026-09-15 (pós-aprovação): jogo é PC, referência Vampire Crawlers; combo permanece sem sistema de mana; verificação passa a ser protótipo CLI em Python, não cartas físicas; fórmula de dano corrigida para incluir a Corrente de Classe e o bônus de passiva do Durvall, que faltavam na primeira versão.
