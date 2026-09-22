---
id: "PLAN-022"
type: "plano"
title: "Pendências fora do playtest e do Discord: arte, textos, documentação e higiene do repositório"
status: "canon"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
  - "[[PLAN-020-roteiro-geral-de-implementacao-2026-09-20]]"
  - "[[ART-PROMPTS-023-cartas-novas-e-faltantes-2026-09-21]]"
  - "[[ART-PROMPTS-022-m2-praca-da-loucura-2026-09-20]]"
sources:
  - "Responsável, 2026-09-21: 'ignore o playtest e o discord, faça um plano para arrumar o resto... faça recomendações dos faltantes'"
---

# Pendências (o que sobra além das SPECs 098 a 103)

> Fora de escopo por decisão do responsável: **playtest** (TASK-001..017 e o ajuste de números por playtest) e **Discord**. A lista do núcleo do baralho já vale
> como a definida na SPEC-099. O código das SPECs 098 a 103 está no `PLAN-021`; este plano cobre o que **não é** implementar essas SPECs.

## 1. O que sobra

| # | Pendência | Tamanho |
|---|---|---|
| P1 | **Arte**: 51 imagens (10 novas em `ART-PROMPTS-023` + 41 de M2 já com prompt em `ART-PROMPTS-022`) | grande (geração), pequeno (integração) |
| P2 | **Ligar a arte no jogo**: processar, conferir dentro do jogo e checar o fallback quando faltar | pequeno |
| P3 | **Textos do jogo**: tutorial e "Como jogar" (vantagem/desvantagem, Esquiva, Ataque Imprudente, poção por missão, equipamento único, proficiência) | pequeno |
| P4 | **Perguntas em aberto** de `ART-PROMPTS-022` §4 (topologia, Arlindo, névoa, repetição de inimigos, ids das HQs) | decisão |
| P5 | **Auditoria de assets automática**: hoje é feita à mão e refeita a cada rodada (cartas, salas, texturas, itens) | pequeno |
| P6 | **Documentos derivados e vault**: `CLAUDE.md` (marco atual), `README`, `ASSETS-PENDENTES-001` e `ART-PROMPTS-014` (velhos), log do projeto | pequeno |
| P7 | **Higiene do repositório**: arquivos soltos e commits por SPEC | pequeno |
| P8 | **Versão e empacotamento**: 0.15.0, 0.15.1 e 0.16.0, exe renomeado, CI | pequeno |
| P9 | **Promoção de drafts** (`PLAN-021` e `PLAN-022`) e conferência das SPECs 098 a 103 | decisão |

## 2. Recomendações por pendência

### P1/P2 — Arte
- **Ordem** (também em `ART-PROMPTS-023` §6): primeiro as cartas que aparecem em todo combate (Esquiva, Estocada Mística, Pancada de Escudo) e as 4 raras do
  sacerdote; depois `bg`/`fg` das salas 5 e 6; depois texturas, adereços, retratos e itens; por último HQ e tela de missão. Nada disso bloqueia código (fallback).
- **Texturas de M2:** dos 17 arquivos que faltam, os céus dos 4 ambientes externos são o **mesmo arquivo** (regra da triagem de `ART-PROMPTS-022`): gerar 1 e copiar, o que tira cerca de 3 gerações.
- **Cartas do Cajado e do Cetro (4.4 e 4.5):** só gerar depois que a simulação da SPEC-100 fixar o efeito das duas; os prompts descrevem o efeito, e mudar o
  efeito muda a imagem.
- **Olhar Fixo:** a carta agora é Roxa; o prompt já não pinta a arte de roxo (a cor vive na moldura).
- **Regra de aceite:** cada imagem abre **dentro do jogo** (combate e Baralho) antes de ser aprovada; reduzir a 150 px e a 64 px para o teste de silhueta.
- **Integração:** `python scripts/process_art.py cards|rooms|world|items|portraits|hq|screens` por categoria; conferir alfa/chroma dos adereços verdes; commit dos
  finais em `assets/` (o bruto em `_raw/` fica fora do git).

### P3 — Textos
Alterar `tutorial_content.py` e o guia (SPEC-102 dá a rolagem):
1. "Vantagem e desvantagem": 2 dados, o melhor ou o pior; anulam-se.
2. Esquiva na lista de reações; Ataque Imprudente agora dá vantagem aos inimigos.
3. "Uma Poção por missão; ache mais em eventos ou compre do mercador."
4. Equipamento: cada unidade vale 1 personagem; proficiência bloqueia com o motivo.
5. Conquistas novas (Veterano de Durvall, Golpe Devastador) na descrição da tela.
Teste: o tutorial não cita "Toque Curativo x2" nem "acerta sem teste" (busca de texto proibido).

### P4 — Decisões pendentes de `ART-PROMPTS-022` (recomendação)
| Pergunta | Recomendação |
|---|---|
| Topologia e ids das salas | **Manter os 6 ids atuais**: as `bg` 1 a 4 já existem com esses nomes. |
| Aparência do Arlindo | **Aprovar o prompt como está** (canon não descreve; corrigir só se o Higor discordar) e marcar `arlindo` como "aparência provisória". |
| Névoa em M2 | **Sem névoa**, como está; o chão do combate segue como hoje. |
| Repetição de inimigos | **Sem variantes agora**; pedir variantes só se o playtest reclamar. |
| Ids das HQs (`hq_002`, `hq_003`) | **Confirmar** com o catálogo de HQs (`game/core/hq.py`); conferir na SPEC-096 antes de gerar. |

### P5 — Auditoria de assets automática (recomendação nova)
`scripts/audit_assets.py`: lê todos os `asset_id` de cartas, cenas, texturas, adereços, retratos, itens, HQ e telas referenciados no código e lista o que não existe
(o cruzamento que hoje é refeito a mão). Saída em Markdown para `.atena/generated/`. Um teste em `tests/` garante que o **fallback** de cada tipo continua
funcionando (sem arquivo, não levanta exceção). Evita a repetição de `ASSETS-PENDENTES` e das auditorias das ART-PROMPTS 017 e 019.

### P6 — Documentos
- **`CLAUDE.md`**: o parágrafo "Marco atual" ficou um diário de versões; **recomendo trocá-lo por um resumo curto** (versão, o que é jogável, pendências) e mover o
  histórico para `.atena/vault/canon/` ou para o log do projeto. Atualizar depois de cada versão.
- **`README`**: comandos, teclas e versão.
- **Ficheiros velhos**: marcar `ASSETS-PENDENTES-001.md` e `ART-PROMPTS-014` como "superseded" (as 3 cartas de arma foram geradas) apontando para o `ART-PROMPTS-023`.
- **Log do projeto (marizverso.com)**: entrada datada por versão, mais a descrição viva (dois documentos separados, como no fluxo combinado).

### P7 — Higiene do repositório
Hoje há arquivos soltos e sem commit:
- `.atena/generated/MODIFICACOES-apos-v0.11.0-2026-09-20.pdf` — **recomendo commitar** (evidência do que mudou) ou apagar se ficou obsoleto.
- `tmp/m2_wall_repeat.png` — **apagar**: é imagem de teste; conferir se `tmp/` está no `.gitignore` (recomendo incluir).
- `.atena/evidence/novas evidencias/` — **renomear** para `.atena/evidence/playtest-higor-2026-09-21/` (sem espaço nem acento) e commitar os 4 zips.
- Cada SPEC (098–103) e cada bloco de código em **um commit próprio**, mensagem no padrão do repositório; nenhum commit sem aprovação do responsável (`add.yaml`).

### P8 — Versões e empacotamento
- 0.15.0 = SPEC-098/099/100; 0.15.1 = SPEC-101/102; 0.16.0 = SPEC-103 (a, depois b). Atualizar a string de versão e o log do projeto.
- Depois de cada versão: build local e **renomear o exe** para `nottcard-ai-<versão>.exe` em `dist/` (regra da memória do projeto); o CI publica a cada push em `main`.
- Confirmar que os saves da 0.14.0 abrem na 0.15.x (migração da SPEC-099) com um save real do Higor, guardado como fixture.

### P9 — Aprovações
- Promover `PLAN-021` e `PLAN-022` de `drafts/` para `canon/` só com aprovação do responsável.
- As SPECs 098–103 já estão em `.atena/specs/` como `approved`; conferir antes de implementar **a matriz de proficiências** (SPEC-103). A dúvida das Poções de assinatura foi medida e
  descartada (SPEC-099 corrigida).

## 3. Ordem de execução

| Fase | O quê | Depende de |
|---|---|---|
| A | P7 (higiene) e P6 (marcar velhos) | — |
| B | P5 (auditoria automática) — mostra a lista real antes da geração | A |
| C | Gerar as imagens (P1) em paralelo à implementação das SPECs 098–103 | `ART-PROMPTS-023`; B |
| D | P2 (processar e conferir no jogo), a cada lote gerado | C |
| E | P3 (textos), junto de cada SPEC implementada | SPECs 098–103 |
| F | P8 (versão, exe, log) ao fim de cada versão | E |
| G | P9 (promoções) | tudo acima |

**Gates:** suíte verde a cada fase; nenhum commit ou promoção sem aprovação; o `CLAUDE.md` só se atualiza no fim de cada versão.
