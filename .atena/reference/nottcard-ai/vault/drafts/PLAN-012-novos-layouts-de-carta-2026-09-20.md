---
id: "PLAN-012"
type: "plano"
title: "Novos layouts de carta: remover os dez atuais e criar molduras ilustradas a partir de referências"
status: "draft"
created: "2026-09-20"
relations:
  - "[[SPEC-030-pacotes-de-arte-de-carta-selecao-livre]]"
  - "[[ART-001-pacotes-de-arte-de-carta-e-titulos]]"
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
sources:
  - "Responsável, 2026-09-20: não gostou de nenhum dos dez layouts atuais; pede apagar todos e planejar novos, com duas imagens de referência de cartas colecionáveis"
---

# Novos layouts de carta

Rascunho: nada aqui é regra até a spec ser aprovada (`execution_approval: per-spec`). Onde há **[decisão]**, a recomendação vem
primeiro. Commit, merge e publicação seguem exigindo aprovação explícita.

> Leitura do pedido: "pode ditar todos" foi entendido como **deletar** os dez layouts atuais. A remoção entra na spec (fase 0) e só
> roda depois de aprovada; até lá os dez continuam no jogo.

## 1. O que as referências mostram

Duas pranchas com 16 cartas de coleção. O que elas têm em comum e o jogo hoje não tem:

| Traço | Referências | Layouts atuais |
|---|---|---|
| **Moldura ilustrada** | Cada carta tem uma moldura desenhada com tema (madeira e café, laço de presente, papel de mangá com caneta, videira e flores, gótico dourado, holográfico, metal e ferro). A moldura **invade** a arte, com objetos sobrepondo a borda (laços, folhas, croissant, caneta, xícara). | Retângulo desenhado por código: cor de fundo, linha, cantos e brilho. Ninguém diz "ilustrado". |
| **Arte em destaque** | A ilustração ocupa 60 a 75% da carta, quase sangrando até a moldura. | Arte de 92 px numa carta de 210 px (cerca de 44%), com o resto para nome e texto. |
| **Nome numa placa** | Placa/faixa no topo, com material do tema (madeira, fita, pergaminho), fonte grande e decorativa. | Nome em texto solto abaixo da arte. |
| **Rodapé de série** | Segunda placa embaixo com a origem ("Honkai Impact 3rd"); etiqueta pequena com código no canto superior esquerdo; número de tiragem no canto inferior direito. | Rótulo "Ataque · 1d8" em texto solto. |
| **Tema, não classe** | A moldura conta a história do personagem, não uma categoria. | A cor da classe pinta o fundo inteiro. |
| **Efeitos** | Brilho e partículas nas raras; versão P&B (a "Haru") para variar. | Brilho simples em dois layouts. |

**Conclusão de design:** os layouts novos não são um ajuste dos parâmetros de `CardLayout`. São **molduras ilustradas** (imagens com
janela transparente), placas de nome e rodapé, etiquetas de canto e ornamentos que sobrepõem a arte. Isso muda a técnica.

## 2. Decisões

### D1. Técnica (a decisão que muda o resto)
| Opção | Como | Prós | Contras |
|---|---|---|---|
| **A. Moldura em PNG (recomendada)** | Uma imagem por tema, com janela da arte transparente, gerada no nano banana e processada por `scripts/process_art.py`. Em runtime: arte por baixo, moldura por cima, texto por cima de tudo. | É exatamente o que as referências fazem. 1 imagem por tema serve as 79 cartas. Ornamentos que sobrepõem a arte vêm de graça. | Depende de geração de arte e de revisão visual por tema. |
| B. Só código | Melhorar o desenho procedural | Sem arte nova | Não chega ao nível das referências; é o que já não agradou. |
| C. Híbrido | Moldura PNG + sobreposições por código (brilho de rara, tinta da classe, seleção) | Cobre estados de jogo sem gerar arte para cada um | Um pouco mais de código |

**Recomendo A com toques de C:** moldura PNG por tema; seleção, descarte, escurecimento, selo "×0,5" e "USO ÚNICO" continuam por código
por cima (o estado de jogo se lê igual em qualquer tema, regra da SPEC-030).

### D2. Estilo da moldura: pixel art ou ilustração pintada?
As referências são ilustração lisa e detalhada; o jogo é pixel art (`SIS-004`). **Recomendo pixel art** (mesma direção do resto,
moldura desenhada na resolução da carta e reduzida com nearest-neighbor), com o **vocabulário** das referências: placa de nome,
rodapé, ornamentos sobrepondo a borda, etiqueta de canto. Alternativa: pintada, e a carta destoaria do mundo.

### D3. Estrutura da carta (para todos os temas)
Carta continua **154x210** na mão (`CARD_SIZE`) e o painel de detalhe (340 de largura) reaproveita a mesma composição em escala maior.

```text
+------------------------+
| [custo]      [gema]    |   etiqueta de custo (Ação/Bônus/Reação) no canto sup. esquerdo;
|  +------------------+  |   gema da cor da classe no canto sup. direito
|  |  PLACA DO NOME   |  |   placa no topo (material do tema)
|  +------------------+  |
|                        |
|        A R T E         |   arte grande, quase toda a carta (~62%)
|     (com ornamentos    |
|      sobre a borda)    |
|                        |
|  +------------------+  |
|  | Ataque · 1d8     |  |   placa do rodapé: tipo e dado (+ "bônus", "HC")
|  +------------------+  |
+------------------------+
```

- **Texto da nota:** hoje a carta mostra a nota inteira (`NOTE_TOP = 160`). Com a arte maior não cabe. **[decisão D3]** recomendo a
  nota sair da carta na mão e ficar **só no painel de detalhe** (hover e duplo clique, já existente na SPEC-018), com um **ícone de
  tipo** na placa do rodapé. Alternativa: nota curta (1 linha) sobre um degradê escuro no pé da arte.
- **Cor da classe:** sai do fundo inteiro e vira **gema + tinta leve na placa do nome** (Vermelho/Amarelo/Azul/Roxo seguem legíveis
  em forma e cor, como pede a acessibilidade da SPEC-062).
- **Raridade** (SPEC-041): pode virar brilho/partículas por código nas raras, sem moldura extra. **[decisão D4]** entra já ou depois.

### D5. Temas (rascunho, do mundo de Nottgard e das referências)
Cada um vira uma moldura. Todos spoiler-safe.

| # | Tema | Vocabulário visual | Referência |
|---|---|---|---|
| 1 | **Guardiões** (padrão) | Metal claro com veios azuis da Tarn, broche celestial no canto | Mio, Vanilla |
| 2 | **Docas** | Madeira molhada, cordas, nós, lanterna âmbar | Yu Mei-ren (madeira) |
| 3 | **Tarn** | Energia azul, cristais de luz, brilho | Bloody Reina, Ai Hoshino |
| 4 | **Névoa** | Pedra com musgo e fumaça verde nos cantos, névoa | Kei Karuizawa |
| 5 | **Ritual** | Ossos e alfabeto abissal, ferro escuro, vela | Naoko Kirino |
| 6 | **Diário** | Papel de HQ/manuscrito, tinta, pena, P&B | Haru |
| 7 | **Bosque** | Videira, flores e folhas envolvendo a arte | Felis, Satori |
| 8 | **Inverno/Presente** | Fita e laços prateados (cosmético sazonal) | Ninym, Kana Arima |

**[decisão D5]** quantos e quais. Recomendo **onda 1 com 3 temas (Guardiões, Docas, Tarn)** para validar a técnica e o pipeline; as
outras cinco entram em ondas seguintes, sem mexer no código.

### D6. Loja e save
Hoje os layouts são vendidos na loja (100 e 200 moedas, três presos a títulos) e o save guarda `card_layout` e os comprados.
Recomendo **manter o mecanismo** (loja, seletor, título) trocando o catálogo: o tema padrão é grátis e sempre disponível; os demais
custam moedas (simples 100, elaborados 200) e os presos a título mantêm a regra. Quem já tinha layout antigo comprado: **reembolso
das moedas** de cada um (poucas dezenas), e `card_layout` desconhecido cai no padrão (já é o comportamento de `card_layouts.get`).
Alternativa: tudo liberado enquanto não há playtest.

## 3. Fases

| Fase | O que | Depende de |
|---|---|---|
| **0. Remover** | Apagar os 10 `CardLayout` e o desenho procedural; tema padrão provisório (o "Clássico" atual simplificado) para o jogo continuar rodando. Tirar os itens antigos da loja e migrar o save (reembolso). Ajustar/remover testes de layout. | Spec aprovada |
| **1. Composição** | Novo módulo com: carregar moldura PNG, encaixar arte, placas, etiqueta de custo, gema da classe. Mão, painel de detalhe, Comunhão, catálogo e pacotes usam o mesmo desenho. | Fase 0 |
| **2. Arte da onda 1** | Prompts em `ART-PROMPTS-020` (moldura por tema, PNG com alfa, 154x210 e 340x~470), geração, `process_art.py`, revisão de cada uma no jogo. | D2, D5 |
| **3. Seletor e loja** | Atualizar o seletor (cartas de exemplo com as novas molduras), a loja e os títulos. | Fase 2 |
| **4. Ondas seguintes** | Temas 4 a 8 e efeitos de rara, só arte e dado. | Playtest |

Sem a moldura, a carta cai num retângulo simples (regra do projeto: não bloquear lógica esperando arte).

## 4. Impacto no código (o que a fase 0 e 1 tocam)
- `game/ui/card_layouts.py` (reescrito), `game/ui/layout_picker.py`, `game/ui/cards_widget.py` (`_draw_card`, painel de detalhe,
  `draw_card_silhouette`), `game/ui/assets.py` (`pack=layout.id` deixa de existir; não há pastas de pacote em `assets/cards/`).
- `game/core/shop.py` (`LAYOUT_ITEMS`, `owned_layouts`), `game/core/progress.py` (migração de `card_layout` e `owned`), `game/app.py`
  (botões "Layout das cartas", `card_layout`, cheat).
- Testes: `tests/ui/test_card_layouts.py`, `test_shop_flow.py`, `test_save_flow.py`, `test_collection_flow.py`, `test_spec072.py`,
  `tests/core/test_shop.py` e `test_save_file.py`.
- Sem mudança de regra de jogo: cartas, dano e Corrente não mudam.

## 5. Testes previstos
Todo tema tem moldura e o desenho cai no retângulo simples quando o arquivo falta; a janela da arte fica sempre dentro da carta;
nome longo cabe na placa (fonte reduz até o mínimo); a etiqueta de custo e a gema mostram forma e cor da classe; seleção, descarte
e escurecimento aparecem em qualquer tema; save antigo com id de layout removido carrega no padrão; reembolso de layouts antigos
uma única vez; painel de detalhe mostra a nota que saiu da carta; nenhum teste depende da lista antiga de layouts.

## 6. Perguntas para você
1. **D1/D2:** moldura em PNG, em pixel art? (recomendado) Ou pintada como as referências?
2. **D3:** a nota da carta sai da mão e fica só no detalhe? Ou nota curta sobre a arte?
3. **D5:** onda 1 com 3 temas (Guardiões, Docas, Tarn)? Quer trocar algum tema?
4. **D6:** manter a loja de layouts com reembolso, ou liberar tudo por enquanto?
5. **D4:** brilho por raridade agora ou depois?

## Review record
- Proposed by: Claude, 2026-09-20, a partir do pedido do responsável e das duas imagens de referência.
- Reviewed by: pendente.
