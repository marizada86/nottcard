---
id: "SIS-002"
type: "sistema-mecanico"
title: "Convenção de destaque visual de mecânica em texto de carta"
status: "canon"
created: "2026-09-14"
relations:
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
sources:
  - "Declaração do responsável pelo projeto em 2026-09-14: mecânica de jogo, em carta ou no próprio jogo, deve ficar destacada de acordo com sua estrutura."
---

# Convenção de destaque visual de mecânica em texto de carta

## Regra proposta

Toda vez que uma carta (ou peça de UI do jogo) mostra uma mecânica — não só sabor/lore — o destaque visual segue a estrutura do próprio dado, não é aleatório. Proposta inicial, com 4 categorias:

| Tipo de conteúdo | Tratamento visual | Exemplo |
|---|---|---|
| **Nome de mecânica/palavra-chave** (ex.: "Corrente de Classe", "Carga de Poder Místico") | Negrito, dourado (#F2BE52), funciona como termo fixo reconhecível | **Carga de Poder Místico** |
| **Valor numérico ligado a uma família/cor** (dano, bônus %, dados) | Cor da família a que pertence (Vermelho=Físico, Amarelo=Mágico, Azul=Suporte, Roxo=Universal) | "+40%" em roxo, por ser bônus de Carisma/Universal |
| **Condição/gatilho** ("se", "quando", "ao invés de") | Texto normal, mas com um pequeno ícone antes indicando o tipo de gatilho (ex.: ícone de corrente para combo, ampulheta para efeito ao longo do tempo) | ⛓ Ao encadear 3 cartas da mesma classe... |
| **Texto de sabor/lore** | Itálico, cor neutra clara/creme, separado do texto mecânico por uma linha fina ou caixa própria — nunca compartilha linha com número ou palavra-chave | *"Memórias fragmentadas voltam a cada golpe."* |

## Por que isso importa

Sem essa separação, um jogador não consegue escanear a carta rapidamente para achar "o que ela faz" vs. "o que ela conta de história" — problema comum em jogos que misturam os dois num único bloco de texto corrido.

## Aplicação nos prompts de carta

A partir desta regra, todo prompt de imagem de carta deve pedir explicitamente esse tratamento diferenciado (cor por família nos números, negrito dourado nas palavras-chave, itálico neutro no sabor), em vez de um bloco de texto único.

## Pendências

- Ícones de gatilho (corrente, ampulheta, etc.) são só uma sugestão de exemplo; nenhum conjunto de ícones foi definido para o jogo.
- Ainda não aplicada retroativamente às fichas já promovidas a canon (Kayron, Durvall, Sylas, Maelor) — elas descrevem a mecânica em prosa corrida, sem essa separação.

## Review record

- Proposed by: Claude, a partir da declaração do responsável do projeto em 2026-09-14.
- Reviewed by: responsável do projeto, em 2026-09-16.
- Approval decision: aprovado — princípio geral e as 4 categorias de tratamento visual confirmados. Ícones de gatilho e aplicação retroativa às fichas já canônicas ficam como pendências de execução, não bloqueiam o status canon desta regra. Promovido de `.atena/vault/drafts/` para `.atena/vault/canon/regras/`.
