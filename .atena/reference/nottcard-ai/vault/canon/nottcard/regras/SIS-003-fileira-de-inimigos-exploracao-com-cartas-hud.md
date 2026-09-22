---
id: "SIS-003"
type: "sistema-mecanico"
title: "Combate em fileira, testes de d20 no modo exploração e HUD de PV"
status: "canon"
created: "2026-09-16"
relations:
  - "[[SPEC-001-vertical-slice-m1-solo]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SIS-002-destaque-visual-de-mecanica-em-carta]]"
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
sources:
  - "Screenshot de referência enviado pelo responsável do projeto em 2026-09-16 (tela de combate de um deckbuilder roguelike em primeira pessoa, mesmo gênero de Vampire Crawlers já citado em SPEC-001)"
  - "tmp/pdfs/build_design_pdf.py, Seção 02 (loop Explorar/Confrontar) e Seção 05"
---

# Combate em fileira, testes de d20 no modo exploração e HUD de PV

## Declaração proposta

Três pontos levantados a partir da imagem de referência de 2026-09-16, propostos aqui como plano de adoção — nenhum deles se aplica retroativamente à fatia M1 já validada em `SPEC-001` (que segue como está até o playtest humano pendente). Servem para **M2 em diante**, salvo decisão em contrário.

## 1. Combate com múltiplos inimigos em fileira

`SPEC-001` deliberadamente adiou isso ("todos os combates desta fatia tratam os inimigos como um único alvo direto... revisitar somente se/quando uma Missão precisar de múltiplos inimigos simultâneos"). A imagem de referência mostra o padrão do gênero: inimigos lado a lado, cada um com sua própria barra de PV e ícones de status empilhados embaixo.

**Recomendação:**

- Uma Sala de Combate pode declarar 2–3 inimigos simultâneos (cap em 3 para não estourar a legibilidade num protótipo de texto/CLI nem numa tela pequena).
- **Seleção de alvo:** ao jogar uma carta de ataque de alvo único, o jogo pergunta contra qual inimigo (por número/posição), igual à escolha de carta hoje.
- **Cartas de área** passam a fazer sentido como categoria própria — e já há um gancho pronto: a passiva de Erik Blackthorn (`PERS-erik-blackthorn`, aprovada hoje) já menciona "cartas de Erik com efeito de área", hoje sem nenhuma carta de área existir no jogo. Esta é a peça que destrava essa passiva.
- **Turnos dos inimigos:** cada inimigo mantém seu próprio contador de habilidade especial (o código de `Enemy.turns_taken` já é por-instância — não muda), e age em sequência (esquerda pra direita), não simultaneamente, pra manter o log/HUD legível.
- **Corrente de Classe:** continua sendo um recurso do jogador, não por-inimigo — nenhuma mudança na fórmula de `SPEC-001` seção 3, só no motivo de descartar o "alvo único" implícito.

**Não resolvido aqui (fica para quando M2 definir os encontros):** quantos e quais inimigos por sala, se cartas de área causam dano total ou reduzido contra múltiplos alvos.

## 2. Modo exploração resolvido por teste de d20 (não por cartas)

**Decisão do responsável do projeto (2026-09-16), substituindo a proposta original de Claude:** o modo exploração **não** usa cartas — nem um baralho separado, nem gastar carta do baralho de combate. Situações de exploração se resolvem por **teste de d20 + modificador do atributo pedido pela situação**, no espírito direto de D&D 2024, de onde o jogo já herda o sistema de atributos (`SIS-001`).

**Como funciona:**

- Cada situação de exploração (examinar algo, evitar um perigo, notar uma pista, forçar uma passagem, impressionar/negociar) pede o atributo mais coerente com a ficção do momento — não há uma tabela fixa de "sala tipo X sempre pede atributo Y"; é decidido pela narrativa da situação, igual perícia em D&D.
- **Mapeamento de atributo** reaproveita o já definido em `SIS-001`/`VSN-002` (cor de carta ↔ atributo ↔ tema): Força (físico/atlética), Inteligência (investigar/notar/deduzir), Constituição (resistir/aguentar), Carisma (persuadir/impressionar/enganar).
- **Resolução:** `1d20 + modificador do atributo` (modificador padrão D&D: `(valor do atributo − 10) ÷ 2`, arredondado para baixo) contra uma Dificuldade (DC) definida pela situação. Este modificador é o **modificador bruto de D&D**, não o bônus percentual de `SIS-001` (que é específico do dano/efeito de carta em combate) — os dois nascem do mesmo atributo mas se aplicam em contextos diferentes, e não devem ser confundidos.
- **Faixas de DC sugeridas** (proposta de Claude, pendente de números finais): Fácil = 10, Médio = 15, Difícil = 20 — os mesmos patamares comuns em D&D 2024.
- **Falha não deve travar a Missão:** consistente com o espírito da Sala 1 de `SPEC-001` ("eco da névoa", consequência leve, nunca devastadora), uma falha de teste de exploração deve custar algo pequeno (perder uma pista, um recurso menor, um leve dano), nunca reiniciar a tentativa por si só.

**Não resolvido aqui:** a tabela final de DCs por tipo de situação e qual personagem específico faz o teste quando há mais de um personagem em cena (fora do escopo solo de M1) — fica para quando uma spec de M2 definir as salas reais.

## 3. PV do jogador em destaque (HUD)

Menos uma mecânica nova, mais uma lacuna de apresentação: hoje o PV de Durvall só aparece embutido em frases de log ("Durvall em 13/20 PV"), sem um elemento fixo e sempre visível — a referência mostra PV do jogador com destaque grande, fixo num canto, sempre visível independente do que mais está acontecendo na tela.

**Recomendação:**

- **No protótipo CLI (curto prazo):** imprimir uma linha de status fixa (PV / mão / baralho restante / descarte) antes de cada prompt de escolha de carta, não só depois de tomar dano — mesma informação que já existe na "Ficha de acompanhamento" de `PLAYTEST-KIT-001`, mas automática em vez de anotada à mão. Mudança pequena e contida em `player_turn`/`show_hand`.
- **Numa futura UI gráfica:** PV do jogador como elemento fixo de canto (não rolagem, não dentro do log de combate), seguindo a convenção de cor já aprovada em `SIS-002` — não há cor de família associada a PV do jogador, então recomendo neutro/vermelho-sangue fixo, dedicado, para diferenciar de números de dano (que usam a cor da família da carta).

## O que esta proposta NÃO resolve (fora de escopo)

- Números concretos de inimigos/encontros de M2 (isso é conteúdo de uma spec futura, não deste sistema).
- A tabela final de DCs por tipo de situação de exploração (item 2) — só o esqueleto da regra (d20 + modificador de atributo, faixas de DC sugeridas).
- Qualquer coisa de engine gráfico — os itens 1 e 3 descrevem o modelo lógico; a implementação visual real só faz sentido quando o projeto migrar do protótipo CLI.

## Verificação proposta

1. Aplicar o teste de d20 do item 2 e o HUD do item 3 no próprio `prototype/durvall_m1_solo.py`, já que são mudanças pequenas e testáveis sem esperar M2.
2. Deixar o item 1 (fileira de inimigos) para quando uma spec de M2 definir os primeiros encontros com múltiplos inimigos — não há sala na fatia M1 que precise disso agora.

## Review record

- Proposed by: Claude, a partir da imagem de referência enviada pelo responsável do projeto em 2026-09-16.
- Reviewed by: responsável do projeto, em 2026-09-16.
- Approval decision: aprovado integralmente em 2026-09-16, com uma correção do responsável do projeto ao item 2: exploração resolvida por teste de d20 + modificador de atributo (não por cartas) — texto do item 2 já reflete a decisão final, não a proposta original de Claude. Promovido de `.atena/vault/drafts/` para `.atena/vault/canon/regras/`.
