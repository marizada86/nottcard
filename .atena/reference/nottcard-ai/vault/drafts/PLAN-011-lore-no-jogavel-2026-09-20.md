---
id: "PLAN-011"
type: "plano"
title: "Lore no jogável: sabor na M1, eventos de história e Interlúdio A"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[MUNDO-001-tarn-cupula-de-nottgard]]"
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[HQ-000-guia-de-producao-e-ficha-de-transicao]]"
  - "[[HQ-001-piloto-m1-para-interludio-a]]"
  - "[[SPEC-077-eventos-de-historia]]"
  - "[[PLAN-010-ouro-carisma-e-eventos-aleatorios-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: plano de mais lore no jogável; texto em 3ª pessoa; códice adiado; ordem 1 → 2 → 4; revisão dos textos em lote em drafts"
---

# Lore no jogável

Rascunho: nada aqui é regra nem entra no jogo até cada spec ser aprovada (`execution_approval: per-spec`). Textos só vão
ao código depois da revisão do responsável (seção 4). Commit, merge e publicação seguem exigindo aprovação explícita.

## 1. Decisões já tomadas (2026-09-20)

| # | Decisão |
|---|---|
| L1 | Voz do texto: **3ª pessoa**, no tom das HQs ("O grupo...", "Durvall..."), não "Você...". |
| L2 | **Códice/diário adiado.** Entra quando houver mais de uma missão jogável. |
| L3 | Ordem: **Camada 1 → Camada 2 → Camada 4** (sabor na M1, eventos de história, Interlúdio A jogável). |
| L4 | Revisão em lote: os textos ficam num draft em `.atena/vault/drafts/` e o responsável revisa **antes** de qualquer código. |

Fronteira de spoiler (vale para tudo): nada da identidade/traição do Durvall, nada de Astherion/Kein/Adam, Brook só aparece
no Interlúdio A na apresentação formal. Só lore observável e ambíguo, como já fixado em `VSN-003` e `VSN-004`.

## 2. Camadas

### Camada 1 — Sabor na M1 (só dado, sem mecânica)
- **Texto de entrada por sala** (7 salas de `game/core/rooms.py`), 1 a 2 frases, 3ª pessoa, alinhado a `MUNDO-001`
  (Tarn azul, névoa verde só na rachadura e depois dela, âmbar como único calor).
- **Inscrição "Seremos um só"** na rachadura e no ritual (motivo recorrente de `VSN-004`).
- **Ficha curta dos inimigos** (criatura corrompida, guardião alado, slime): uma linha de sabor cada.
- **Frases de vitória e derrota** da tentativa (hoje só mecânica).
- **Conversão das situações existentes** (`exploration.py`, salas 1 e 3) para a 3ª pessoa, mantendo os efeitos.
- Onde vive: dado declarativo novo (ex.: `game/core/lore_m1.py`), lido pela UI. Sem regra de jogo na UI.

### Camada 2 — Eventos de história (SPEC-077, já aprovada)
- Altar de Sendrinah/Lliira, Viajante ferido, Fenda de névoa; depois o banco de ideias (apostador, oficina abandonada,
  emboscada na névoa, cofre da taverna).
- Depende do motor de eventos (SPEC-074) e do baú/loja (SPEC-075/076).
- O texto desses eventos também passa pela revisão em lote da seção 4.

### Camada 4 — Interlúdio A jogável
- Hub em Castle Rodhe depois da M1: recepção (Cassandra), reconhecimento (Helion), missão paralela de Kayron (Zynara),
  entrega dos quatro broches, gancho para M2 (Dagruve).
- Estende a HQ-001 (já no jogo) em vez de substituí-la; a ficha de transição segue o `HQ-000`.
- Precisa de: cenas de diálogo curtas (dado declarativo, não script imperativo), arte nova (sala do Conselho e retratos),
  e uma spec própria. **Só depois do playtest** (TASK-015 a 017), porque só existe uma missão jogável.

### Fora deste plano
Códice (L2), M2 em diante, Sessão 22, Shendilavri, arco do Durvall após M20.

## 3. Sequência de entrega

1. Este plano aprovado → 2. draft de textos da Camada 1 revisado (seção 4) → 3. SPEC-078 (Camada 1) → 4. implementação →
5. textos da Camada 2 revisados junto da SPEC-077 → 6. depois do playtest, spec do Interlúdio A.

A Camada 1 não bloqueia nem é bloqueada pela fila das SPEC-067 a 077.

## 4. Textos propostos da Camada 1 (para revisão)

Marque cada linha com ✔, ✎ (ajustar) ou ✘. Nada abaixo foi ao jogo.

### Entrada das salas
| Sala | Texto proposto |
|---|---|
| 1. As Docas | A névoa se arrasta pelo cais, fina e fria. Acima das docas, a Tarn brilha em azul, calma demais para uma noite como esta. |
| 2. O cais atacado | Caixotes tombados e cordas rasgadas marcam o caminho. Algo que já foi gente ainda se move entre as sombras. |
| 3. A rachadura na Tarn | Uma fenda pequena, quase cirúrgica, corta a parede de energia. Só névoa esverdeada escapa por ela, e as pedras ao redor estão cobertas de símbolos e de uma frase repetida: "Seremos um só". |
| 4. O porão — entrada | Degraus úmidos descem para um porão que ninguém deveria conhecer. O ar cheira a metal corroído. |
| 5. O porão — sala de livros | Estantes tortas guardam livros que ninguém teve coragem de queimar. Uma sombra alada se levanta entre elas. |
| 6. O porão — o corredor | O corredor é estreito e escorre. O que vive nele já ouviu o grupo chegar. |
| 7. O ritual | Ossos alinhados, um círculo escrito em alfabeto abissal e, no centro, um vazio à espera. Na parede, a mesma frase, várias vezes: "Seremos um só". |

### Inimigos (uma linha)
| Inimigo | Texto proposto |
|---|---|
| Criatura corrompida | A névoa a torceu por dentro; nada nela lembra o que era antes. |
| Slime corrosivo | Escorre pelas frestas e corrói o metal por onde passa. |
| Guardião alado (cópia) | Uma imitação bem-feita, mas sem sangue de verdade. |
| Guardião alado (verdadeiro) | Guarda o ritual com asas negras e sangue escuro. Não recua. |

### Fim da tentativa
| Momento | Texto proposto |
|---|---|
| Vitória | O ritual foi desfeito. A névoa recua e a fenda na Tarn volta a ser só luz azul. |
| Derrota | A névoa se fecha sobre o grupo. Nottgard ainda não ficou a salvo. |
| Desistência | O grupo recua para a superfície. O que ficou no porão continua esperando. |

### Respostas da revisão (2026-09-20)
1. Tom: **sombrio** (como acima).
2. "Seremos um só" **já pode aparecer na sala 3** (texto ajustado acima) e segue na sala 7.
3. A linha do guardião **não entrega demais** (o nome do inimigo já diz "cópia"); mantida.

Todos os textos acima: **aprovados**.

## 5. Testes previstos (para a spec futura)
Toda sala e inimigo da M1 tem texto; nenhum texto usa 2ª pessoa; nenhum texto contém os termos proibidos (Astherion, Kein,
Adam, Ghaunadaur, receptáculo, Brook antes do Interlúdio A); texto longo cabe na caixa sem estourar; sem texto o jogo
continua funcionando (regra do projeto: não bloquear lógica por conteúdo faltante).

## Review record
- Proposed by: Claude, 2026-09-20, com as decisões L1 a L4 do responsável.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: plano (L1 a L4, camadas e ordem) e textos da Camada 1 aprovados. Próximo: SPEC-078 para aprovação.
