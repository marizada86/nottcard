# PLAN-025 — Revisão de UX dos menus + "Minhas Cartas" com baralho Solo e Grupo

Status: **draft** (aguarda aprovação do responsável). Nenhum código foi alterado. Cada parte vira uma SPEC própria antes de implementar
(`execution_approval: per-spec`).

## Parte A — Análise de UX/UI dos menus (v0.18.0)

### O que existe hoje
- **Menu principal** (`MenuScreen`, `game/app.py:307`): até 9 botões em 2 fileiras (Continuar, Novo jogo, Cartas, Conquistas, Layout das cartas,
  Loja, Baralho, Equipamento, Diário) **mais** 5 botões de configuração soltos no canto superior esquerdo (Câmera, Modo playtester, FPS,
  Tremulação, Movimento suave) e "Trocar jogador" no canto superior direito. O subtítulo fixo diz "M1 … (solo)" — desatualizado (há M2 e grupo).
- **Interlúdio** repete Loja/Baralho/Layout/Menu; **Seleção de personagem** tem Layout e "Baralho N" (só existia com o 2º baralho).
- **Baralho** (`deck_screen.py`): lista de linhas de texto (3 colunas) com [−]/[+]; a arte da carta só aparece ao passar o mouse.
- **Cartas** (`ui/collection.py`): catálogo por personagem + Conquistas, em sobreposição. Nome quase igual a "Baralho" → confunde.

### Problemas (por gravidade)
1. **Nomes e fronteiras confusos:** "Cartas" (catálogo do que existe) × "Baralho" (o que tenho e o que uso) × "Layout das cartas" (cosmético) são três
   entradas para a mesma ideia. O jogador não sabe onde ver "as minhas cartas".
2. **Menu superlotado e sem hierarquia:** 9 botões de peso igual; a ação principal (Continuar) não se destaca; ações de progresso
   (Loja/Baralho/Equipamento) misturadas com cosméticos (Layout) e metajogo (Conquistas/Diário).
3. **Opções soltas:** 5 toggles técnicos (FPS, tremulação, câmera…) e o "Modo playtester" ocupam o canto do menu com o mesmo peso visual dos botões
   principais; o modo playtester é ferramenta de teste, não opção de jogador.
4. **Deckbuilding sem rosto:** a coleção é uma lista de texto; cartas são o produto do jogo e ficam invisíveis. Sem filtro (cor, tipo, raridade),
   sem ordenação, sem busca; o teto de 20 só aparece depois de bater nele.
5. **Feedback de erro tardio e textual:** "Baralho inválido: … Ajuste em Baralho." aparece como toast na hora de começar; o botão "Começar" já
   deveria avisar antes (ícone/estado) e levar direto ao baralho certo.
6. **Navegação inconsistente:** cada tela tem o próprio "Voltar" (posição e largura diferentes), Esc nem sempre funciona igual, e algumas telas são
   sobreposição (Cartas) e outras trocam de tela (Baralho, Loja).
7. **Estados de bloqueio pouco claros:** personagem bloqueado mostra "Bloqueado" + dica, ok, mas o mesmo padrão (véu + motivo + como liberar) não
   vale para cartas, missões e layouts.
8. **Texto de ajuda espalhado** em legendas de 16–18 px em cinza, baixo contraste sobre fundo escuro.

### Recomendações
- **R1 — Menu em 3 grupos:** (a) *Jogar*: Continuar/Iniciar (botão grande, destacado) + Novo jogo; (b) *Meu grupo*: Minhas Cartas, Equipamento,
  Loja; (c) *Mais*: Conquistas, Diário, Catálogo, Opções. Layout de coluna central em vez de grade 5×2.
- **R2 — Tela "Opções" única:** Câmera, FPS, Tremulação, Movimento suave, Layout das cartas, Trocar jogador. "Modo playtester" fica dentro dela, sob
  "Avançado". Libera o canto do menu e sobra um menu limpo.
- **R3 — Renomear e unificar cartas:** "Minhas Cartas" (o que tenho + baralhos) e "Catálogo" (o que existe, com silhuetas do que falta). Ver Parte B.
- **R4 — Cartas com rosto:** grade de cartas reais (com contador ×N e marca de "no baralho"), filtros por cor/tipo/raridade e ordenação; a lista
  textual vira uma opção compacta.
- **R5 — Validação visível:** medidor "14/20" com faixa, checklist do baralho (2 por cor, 1 cura, 2 ataque) com ✓/✗ ao vivo, e o botão
  "Começar" da seleção mostra o aviso e um atalho "Ajustar baralho".
- **R6 — Barra de navegação padrão:** título à esquerda, "Voltar (Esc)" sempre no mesmo canto inferior esquerdo, mesma altura/largura, em todas as
  telas; Esc sempre volta um nível.
- **R7 — Padrão de bloqueio único:** véu + cadeado + "Como liberar", reaproveitando o que a seleção de personagem já faz.
- **R8 — Contraste e tamanho:** ajudas em ≥18 px com `TEXT_COLOR` atenuado, não cinza-escuro; subtítulo do menu passa a refletir a última missão.
- **R9 — Menu de pausa/Interlúdio:** o Interlúdio mostra o mesmo grupo "Meu grupo" (Minhas Cartas, Equipamento, Loja) e "Próxima missão" destacada.

## Parte B — Minhas Cartas + 2º baralho (Solo × Grupo)

### Estado atual (relevante)
- **Uma coleção** (`SaveState.collection`, nomes com repetição) e **uma lista de baralhos** (`SaveState.decks`, `active_deck`); o SaveState e o
  `Deck` **já aceitam N baralhos** e `ensure_core` já percorre todos.
- `collection.MAX_DECKS = 1` desde a SPEC-045; `shop.migrate_removed_items` **apaga `decks[1:]`** (`shop.py:176`); a UI (`DeckScreen`,
  `CharacterSelectScreen`, `App.cycle_deck`) ainda tem as abas e o botão "Baralho N" — código dormente que dá para reaproveitar.
- `start_run` usa `decks[active_deck]` para **todos** os personagens (o baralho é do jogador, cada um soma a sua assinatura).
- Elenco: `roster.unlocked_characters` (começa com 1 inicial); grupo = 1/2/3 por conquista (`party_limit`).

### Regras propostas (decisões marcadas como D-x para aprovar)
- **D1 — Dois baralhos com papel fixo:** *Solo* (usado quando a missão vai com 1 personagem) e *Grupo* (usado com 2 ou 3). Não há escolha manual de
  qual baralho entra: é derivado do tamanho do grupo ao iniciar. (Mais simples e à prova de erro que "Baralho 1/2".)
- **D2 — Liberação:** o baralho Grupo nasce **quando o jogador libera o 2º personagem** (`len(unlocked_characters) >= 2`, na compra em
  `roster.unlock`). Nasce como cópia do Solo (para o jogador já começar jogável) e passa a ser independente.
  *Mesmo se o jogador tiver 2 personagens mas só tiver "Dupla" depois:* o baralho aparece já com o 2º personagem; o jogo usa o Grupo só em grupo.
- **D3 — Coleção única, cópias por baralho:** as cartas são as mesmas e a mesma carta pode estar nos dois baralhos (cada baralho respeita
  as cópias que o jogador tem e `MAX_COPIES`; não há "reserva" entre baralhos). Alternativa mais rígida (cópia só num baralho) rejeitada: pune
  quem só compra 1 cópia e exige mais tela.
- **D4 — Mesmas regras de validade nos dois:** núcleo travado (`CORE_DECK`), teto 20, 2 por cor / 1 cura / 2 ataque, Poção 1. Sem exceções por
  modo, para o `deck_problems` seguir único.
- **D5 — Ganhos vão para os dois:** carta ganha (chefe, pergaminho, loja) entra na coleção e, com espaço, no baralho **do modo que está em uso**; o
  outro só ganha se o jogador for lá — ou (recomendado) entra em ambos com espaço, evitando "ganhei e não apareceu no Grupo". *(Recomendo: ambos.)*
- **D6 — Validação no início:** a seleção valida o baralho do modo (Solo ou Grupo) e o aviso leva a "Minhas Cartas" já na aba certa.
- **D7 — Migração de save:** `MAX_DECKS = 2`; `migrate_removed_items` passa a **manter** `decks[1:]` (ou criar o Grupo se já há ≥2 personagens); saves
  atuais com 1 baralho e 1 personagem ficam como estão; com ≥2 personagens ganham o Grupo como cópia do Solo. `active_deck` deixa de ser
  necessário (mantido por compatibilidade de leitura, ignorado). `grant_cards` e `cycle_deck` deixam de depender dele.

### Tela "Minhas Cartas"
Substitui "Baralho" (e o botão do menu/Interlúdio). Uma tela, três áreas:
1. **Abas superiores:** `Coleção` · `Baralho Solo` · `Baralho Grupo` (esta última com cadeado e "Libere o 2º personagem" até liberar).
2. **Coleção:** grade de cartas reais (`draw_card_scaled`), contador ×N, selo "no Solo/no Grupo", filtros (cor, tipo, raridade), ordenação
   (raridade padrão), rolagem. Clique = ampliar; botões +/− contextuais quando uma aba de baralho está aberta.
3. **Baralho (Solo/Grupo):** à esquerda a lista do baralho (agrupada por cor, núcleo com cadeado), à direita a coleção filtrável para adicionar; topo
   com medidor N/20 e checklist de validade; "Sugerir baralho" (já existe) e "Copiar do outro baralho".
- Sem baralho Grupo, a aba mostra o texto de como liberar (padrão de bloqueio R7).
- "Catálogo" (hoje "Cartas") continua como sobreposição separada, agora só para o que existe/está bloqueado, e linka "Ver em Minhas Cartas".

### Impacto técnico (esboço)
| Área | Mudança |
|---|---|
| `core/collection.py` | `MAX_DECKS = 2`; `DECK_SOLO=0`, `DECK_GROUP=1`; `deck_for_party(state, n)`; `ensure_group_deck(state)`; `grant_cards` nos dois; `copy_deck` |
| `core/shop.py` | `migrate_removed_items` mantém o 2º baralho; testes da SPEC-045 mudam |
| `core/roster.py` | `unlock` chama `ensure_group_deck` |
| `core/progress.py` | sem mudança de formato (`decks` já é lista); `active_deck` só compatibilidade |
| `game/app.py` | `start_run` escolhe o baralho pelo tamanho do grupo; `cycle_deck` e o botão "Baralho N" da seleção saem; o aviso leva à aba certa |
| `ui/deck_screen.py` → `ui/my_cards_screen.py` | grade com cartas, abas, filtros, medidor e checklist (só desenho e input) |
| Testes | baralho por modo, liberação com o 2º personagem, migração, ganho de carta nos dois, validação por modo |

### Ordem de implementação (cada item = 1 SPEC, testável e revisável)
1. **SPEC-110 — Núcleo do 2º baralho (core):** regras D1–D7, migração e testes. Sem UI nova; a UI atual já mostra as abas.
2. **SPEC-111 — Minhas Cartas (UI):** grade, abas Coleção/Solo/Grupo, filtros, medidor e checklist; renomeia entradas no menu e no Interlúdio.
3. **SPEC-112 — Menu principal e Opções (R1, R2, R8):** menu em 3 grupos, tela Opções, subtítulo dinâmico.
4. **SPEC-113 — Navegação e bloqueios (R6, R7, R5 na seleção):** barra padrão, padrão de bloqueio, "Começar" com aviso e atalho.

## Riscos
- Coleção pequena no início (14 cartas: núcleo 8 + 6 comuns) → dois baralhos válidos ficam quase idênticos; aceitar, o incentivo é a loja/chefes.
- Tela nova com grade de cartas é a peça mais cara (desenho + rolagem + filtros); dá para entregar primeiro com a lista atual em abas (SPEC-110)
  e só depois trocar por cartas (SPEC-111).
- Reverte parte da SPEC-045 (2º baralho removido); registrar a mudança de decisão no vault.

## Decisões pendentes para o responsável
1. D1: baralho por **tamanho do grupo** (recomendado) ou por escolha manual?
2. D2: o Grupo nasce com o 2º personagem (recomendado) ou só quando houver "Dupla"?
3. D3/D5: mesma carta em ambos os baralhos e ganhos nos dois (recomendado)?
4. Parte A: aprovar R1–R9 inteiras ou em quais fatias (recomendo a ordem 110 → 111 → 112 → 113)?
5. O "Catálogo" (hoje "Cartas") mantém o nome ou vira "Enciclopédia"?
