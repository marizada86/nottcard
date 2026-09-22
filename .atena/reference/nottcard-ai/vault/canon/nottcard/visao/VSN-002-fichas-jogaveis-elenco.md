---
id: "VSN-002"
type: "vision"
title: "Fichas de referência jogável do elenco principal"
status: "canon"
created: "2026-09-11"
reviewed: "2026-09-15"
relations:
  - "[[VSN-001-visao-inicial]]"
sources:
  - "Vault local de Nottgard: D:/dev/nottgard/Vault/nottgard (02_Personagens e 03_NPCs)"
  - "Nottgard Card Game/tmp/pdfs/build_design_pdf.py (secao 05 - Elenco e proximos recortes)"
---

# Fichas de referência jogável do elenco principal

## Declaração proposta

Criar uma ficha de referência por personagem principal (8 no total), separada da lore narrativa do vault, reunindo apenas o que é útil para desenhar cartas: classe confirmada em mesa, sugestão de passiva ligada à lore, afinidade de cor de carta e ganchos jogáveis (itens, relações, missões). Cada ficha cita suas fontes e isola qualquer segredo de mestre num campo próprio, não usável em texto de carta.

## Recorte do vault usado como contexto

Esta é a primeira leitura do vault autorizada para o Card Game, respondendo à pergunta em aberto da VSN-001 ("quais recortes do vault podem ser usados como contexto"). Política aplicada nesta leva:

- **Personagens cobertos (8):** Brook, Maelor, Sylas, Kayron, Korrak, Leoric, Durvall e Erik Blackthorn — o elenco citado na seção "05 - Elenco" do documento de design atual.
- **Conteúdo usado:** seções "Em poucas palavras", "Situação ao fim da Sessão 09", "Relações conhecidas em mesa", "Histórico essencial", "Objetos relacionados" e as seções de sessões posteriores já marcadas como reveladas em mesa (ex.: "Revelações posteriores", "Sessões 10-24").
- **Conteúdo explicitamente excluído do texto de carta:** qualquer coisa sob `## Cânone reservado ao mestre` ou equivalente (histórico pessoal não revelado, identidades ocultas, parentescos secretos). Quando um desses fatos é relevante para o design, ele aparece isolado em "Notas de designer" na ficha do personagem, nunca nas seções voltadas ao jogador.
- **Nada do vault é copiado integralmente.** Cada ficha é um resumo curto com citação da fonte, não uma cópia da dossiê.

## Inconsistência observada no vault (apenas relato, não corrigida aqui)

Para 3 dos 8 personagens, o vault divide o conteúdo de forma inconsistente entre `02_Personagens/` e `03_NPCs/`: um arquivo tem a ficha completa e o outro guarda só um resquício de notas de sessões posteriores nunca incorporadas.

| Personagem | Ficha completa | Resquício |
|---|---|---|
| Brook França | `02_Personagens/Brook França.md` | `03_NPCs/Brook França.md` |
| Sylas Malafaia | `02_Personagens/Sylas Malafaia.md` | `03_NPCs/Sylas Malafaia.md` |
| Korrak | `03_NPCs/Korrak.md` | `02_Personagens/Korrak.md` |
| Leoric | `03_NPCs/Leoric.md` | `02_Personagens/Leoric.md` |

As fichas desta leva leem os dois arquivos onde há resquício. A correção do vault em si fica fora do escopo deste repositório.

## Conflitos de classe entre o documento de design e a mesa

O documento de design (seção "05 - Elenco") atribuiu classes por suposição inicial, sem checagem contra o vault. Ao cruzar com a mesa, um conflito claro apareceu:

- **Maelor** — o documento listava **Cleric**; a mesa confirma explicitamente **Druida** a partir da Sessão 16 ("Druida / devoto de Sendrinah"; "Forma Selvagem", etc.). Esta leva adota a classe confirmada em mesa e mantém a original do documento apenas como nota histórica na ficha.

Os demais (Brook = Paladino, Korrak = Bárbaro, Leoric = Druida, Durvall = Psi-warrior) batem com o que a mesa confirma explicitamente. Kayron (Mystic), Sylas (Shadow Cleric) e Erik Blackthorn (Fighter) não têm uma classe mecânica explicitamente nomeada em nenhuma sessão lida — o documento de design é a única fonte para eles; isso é sinalizado como suposição não confirmada em cada ficha, não como conflito.

## Limites desta proposta

Esta leva não define números de carta (custo, dano, mana), o restante do sistema de combo de cor, nem cartas de itens/inimigos derivadas. Ela também não corrige as inconsistências do vault nem promove nada automaticamente — as 8 fichas ficam em `.atena/vault/drafts/` até revisão.

## Próxima decisão solicitada

Revisar as 8 fichas anexas (`PERS-*-ficha-jogavel.md`) e esta nota. Após aprovação, promover os arquivos aprovados para `.atena/vault/canon/personagens/` e registrar a decisão abaixo.

## Decisão adicional — aprovação parcial (2026-09-14)

O responsável do projeto revisou e aprovou as 4 fichas ligadas à primeira Missão (Kayron, Durvall, Sylas Malafaia, Maelor), acrescentando uma camada mecânica que esta leva original não cobria: classe no jogo (podendo divergir da classe de mesa), raça, cor de carta e passiva com efeito preciso. Detalhes em cada ficha, seção "Definição mecânica aprovada". As outras 4 fichas (Brook, Korrak, Leoric, Erik Blackthorn) seguem como estavam, sem essa camada.

**Esquema de cor por família de carta (nova decisão, vale para todo o jogo, não só estes 4):**

| Cor | Família |
|---|---|
| Vermelho | Dano Físico |
| Amarelo | Dano Mágico |
| Azul | Suporte |
| Roxo | Universal |

**Pendências abertas por essa aprovação parcial (histórico — ver resoluções abaixo):**

- **Sylas Malafaia:** nome de exibição precisa trocar antes de qualquer publicação (coincide com pessoa pública real). Ficha mantida com o nome do vault só como referência interna.
- **Durvall:** a passiva de carta está definida, mas o problema estrutural do arco de chefe final (VSN-003) continua sem solução de design.

## Decisão adicional — aprovação integral (2026-09-15)

O responsável do projeto aprovou integralmente esta visão, resolvendo as pendências acima e autorizando a criação da camada mecânica para as 4 fichas restantes (Brook, Korrak, Leoric, Erik Blackthorn) no mesmo padrão das primeiras 4:

- **Sylas Malafaia → resolvido:** nome de exibição definido como **"Sylas Malafa"**. Ver `PERS-sylas-malafaia-ficha-jogavel.md` (campo `nome_jogo`) — desbloqueado para publicação.
- **Durvall → resolvido em VSN-003:** sem medidor de corrupção ou mecânica de estado bloqueado; a traição acontece narrativamente no momento da história em que ela ocorre em mesa (M21). Ver a "Decisão adicional" em `VSN-003-estrutura-de-missoes-arco-01`.
- **Brook, Korrak, Leoric, Erik Blackthorn:** camada mecânica sendo adicionada nas respectivas fichas em `.atena/vault/drafts/`; cada uma segue seu próprio ciclo de revisão antes de promoção a `.atena/vault/canon/personagens/`.

**Correção de 2026-09-14 (pós-aprovação):** Maelor não diverge entre mesa e jogo. O vault trazia "Druida" por erro numa linha de resumo das Sessões 16-24; a classe confirmada em mesa sempre foi **Clérigo da Luz**, igual à do jogo. `Vault/nottgard/02_Personagens/Maelor.md` e a ficha canônica do Maelor foram corrigidos.

## Review record

- Proposed by: Claude, a partir da solicitação do responsável pelo projeto em 2026-09-11.
- Reviewed by: responsável pelo projeto, em 2026-09-14 (parcial: 4 de 8 fichas); aprovação integral em 2026-09-15.
- Approval decision: aprovado integralmente em 2026-09-15 (ver "Decisão adicional — aprovação integral" acima). Histórico: aprovação parcial em 2026-09-14 cobriu Kayron, Durvall, Sylas Malafaia e Maelor com camada mecânica completa; Brook, Korrak, Leoric e Erik Blackthorn seguiram pendentes até esta data.
