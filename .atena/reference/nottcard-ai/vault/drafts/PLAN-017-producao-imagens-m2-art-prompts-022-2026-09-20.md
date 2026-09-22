---
id: "PLAN-017"
type: "plano"
title: "Produção e validação das imagens de M2 (ART-PROMPTS-022)"
status: "draft"
created: "2026-09-20"
relations:
  - "[[ART-PROMPTS-022-m2-praca-da-loucura-2026-09-20]]"
  - "[[PLAN-016-m2-praca-da-loucura-2026-09-20]]"
  - "[[SPEC-082-inimigos-de-corpo-inteiro]]"
  - "[[SPEC-054-arte-em-camadas-primeira-pessoa-fp4]]"
  - "[[SPEC-058-texturas-do-mundo]]"
sources:
  - "Responsável, 2026-09-20: plano para fazer as imagens dos prompts em ART-PROMPTS-022"
---

# Produção das imagens de M2

> Rascunho de produção. O `ART-PROMPTS-022` define os pedidos de imagem; este plano define a ordem, as portas de qualidade e o que só pode ser feito depois de a SPEC de M2 congelar os ids. Não gerar nem aprovar arte final para substituir o fallback antes da aprovação da SPEC correspondente.

## Resultado esperado

Entregar o lote completo de M2 com imagens consistentes, processadas e aprovadas no jogo: 51 gerações únicas, que produzem 54 arquivos finais quando o céu compartilhado é copiado para os quatro ambientes externos. A entrega não é “imagens bonitas em uma pasta”: cada asset precisa encaixar no tamanho, cromia, camada e uso de jogo previstos.

| Lote | Gerações únicas | Saída final | Prioridade |
|---|---:|---:|---|
| Inimigos | 5 | 5 sprites de corpo inteiro | 1 |
| Cenas de combate/exploração | 12 | 6 fundos + 6 frentes | 1 |
| Porta e adereços | 6 | 1 porta + 5 cartazes | 2 |
| Texturas do mundo | 15 | 18 arquivos (céu único copiado para 4 ambientes) | 2 |
| Retratos e itens | 6 | 6 imagens | 3 |
| HQs e tela de missão | 7 | 7 imagens | 4 |
| **Total** | **51** | **54** | |

## Portas antes de gerar

1. **SPEC de campanha/M2:** congelar os seis espaços, os ids de sala, as portas e o uso de cada item. Enquanto forem provisórios, só o piloto técnico é permitido.
2. **Integração de arte:** confirmar que o catálogo de missões já consegue resolver os assets de M2, em vez de os módulos que hoje apontam apenas para `rooms.py`, `world_art.py` e `dungeon_m1.py` usarem os dados de M1.
3. **Narrativa:** confirmar a aparência inventada de Arlindo antes do retrato; manter garoto, Brook e Durvall dentro dos limites de spoiler de `ART-PROMPTS-022`.
4. **HQs:** congelar ids (`hq_002`, `hq_003`) e texto/UI antes de gerar os seis quadros. Não criar arte narrativa que o fluxo ainda não sabe mostrar.
5. **Contrato técnico:** verificar, com uma amostra por tipo, o processamento de fundo verde, magenta exato, cenas em camadas, porta, textura ladrilhável e inimigo vertical. A categoria `enemies` precisa estar na via da SPEC-082 antes de receber o lote.

## Fase 0 — piloto técnico (5 imagens)

Gerar no máximo três candidatas por imagem e aprovar uma só depois de processar e ver no jogo.

| Imagem piloto | Valida |
|---|---|
| `cultista_adaga` | Magenta #FF00FF removido sem comer roxos; corpo inteiro, pés a 94%, escala 320×480 no combate e na caminhada. |
| `m2_sala_1_entrada/bg` | Corte 16:9, paleta indexada, espaço para inimigos/cartas e leitura da primeira pessoa. |
| `m2_sala_1_entrada/fg` | Verde removido, centro transparente, alinhamento estável sobre o fundo. |
| `porta_igreja` | Chroma, recorte ao conteúdo, proporção vertical e leitura a 64 px. |
| `world/dagruve_entrada/wall` | Textura repetida em grade 3×3 sem emenda, vinheta ou objeto repetitivo óbvio. |

Se uma classe de asset falhar, corrigir o bloco técnico de `ART-PROMPTS-022` antes de continuar. Após duas correções infrutíferas, abrir conversa nova com o bloco-base completo; não aceitar “quase transparente”, composição cortada ou textura com emenda para ganhar velocidade.

## Fase 1 — inimigos e cenas que sustentam o jogo

### 1A. Família do culto (5)

1. Gerar e aprovar `cultista_adaga`; ele vira a referência visual obrigatória.
2. Anexar a referência aprovada para `cultista_cajado`, `cultista_arqueiro` e `sacerdote_mente_derretida`, nesta ordem. O zumbi pode ser produzido em paralelo, mas só é aprovado ao lado do sacerdote.
3. Revisar juntos os cinco sprites: alturas relativas, silhueta, motivo de olho escorrendo, ausência de névoa e nenhum magenta dentro da figura.
4. Testar cultistas em trio, sacerdote mais quatro zumbis e todos como cartazes da caminhada; confirmar que o sacerdote continua legível no espaço do chefe.

### 1B. Cenas em camadas (12)

Produzir cada sala como par `bg` → `fg`, nunca como lote cego. A sala anterior aprovada é a referência de acabamento da seguinte: Entrada → Praça → Beco e Adro; Adro → Nave; Nave → Altar. Para cada par, verificar primeiro o fundo isolado, depois a sobreposição e por fim combate com um e três inimigos.

Não desenhar portas nos fundos. A faixa central exigida pelo prompt é um contrato de UI: nela entram portas renderizadas, inimigos e efeitos, portanto não pode receber altar, vitral, chafariz, textos ou detalhes essenciais.

## Fase 2 — exploração em caminhada

1. Gerar a porta da igreja e os cinco adereços após as salas que lhes dão contexto visual. Conferir silhueta a 64 px, croma verde exclusivo do fundo e margem de 15% após o recorte.
2. Gerar as seis paredes e seis pisos por ambiente. Para cada ambiente, aprovar `wall` antes de `floor`, usando a cena correspondente somente como referência de paleta, não de perspectiva.
3. Gerar três tetos únicos: céu encoberto compartilhado, teto da nave e teto do altar. Copiar o céu aprovado para os quatro ambientes externos; não gerar quatro céus quase iguais.
4. Fazer o teste de costura 3×3 em parede, piso e teto antes de processar o ambiente seguinte. Depois, caminhar por uma sala no raycaster e confirmar que não há mosaico visível, textura invertida ou cache antigo.

## Fase 3 — conteúdo secundário

1. **Retratos:** gerar primeiro o garoto, cuja aparência está definida. Arlindo só entra após a aprovação de sua aparência; até lá a UI fica no fallback.
2. **Itens:** gerar poção, gema e mapa quando as recompensas já existirem como dados de M2. O mapa continua sem palavras: os três destinos são pontos visuais, não texto embutido.
3. Testar os retratos em diálogo e os itens nos painéis reais a tamanho final. Não aprovar detalhes que só funcionam no original de 1024 px.

## Fase 4 — narrativa e briefing

Gerar `hq_002`, `hq_003` e `screens/missao` por último. Cada quadro é aprovado no contexto de sequência, não isoladamente: continuidade de paleta, número de silhuetas, Brook introduzido só no quadro previsto e área de legenda livre. A tela de missão precisa ser testada com texto e botões reais, para que o centro continue legível.

## Fluxo por imagem

1. Abrir uma conversa nova conforme o grupo indicado no `ART-PROMPTS-022`; colar o bloco de estilo e esperar a confirmação.
2. Enviar o pedido de uma imagem, anexando somente as referências aprovadas que ele pede.
3. Salvar candidatas brutas versionadas em `assets/_raw/<categoria>/.../<nome>_v01.png`, `_v02.png`, `_v03.png`.
4. Fazer a triagem do contrato visual antes de processar. A candidata escolhida vira o bruto sem sufixo; variações permanecem só como material de decisão.
5. Processar a categoria, abrir o arquivo final e testar no contexto do jogo. Registrar a versão aprovada na tabela de `ART-PROMPTS-022`.
6. Se falhar, fazer uma correção curta e objetiva, mantendo o prompt original. Não mascarar erros de geração alterando manualmente a arte final, exceto o processamento padronizado já previsto no projeto.

## Critérios de aceite

- Nenhuma arte contém texto, marca d’água, runa legível, símbolo sagrado, spoiler do garoto ou indício da identidade do Durvall.
- Inimigos: fundo magenta integral, nenhum corte, pés na mesma linha, escala relativa correta e transparência limpa no combate e no mundo.
- `bg`: opaco e sem portas; `fg`: somente bordas, centro livre após chroma; os pares se alinham em 16:9.
- Porta e adereços: fundo verde integral, nenhum verde residual no objeto, leitura a 64 px e proporção correta depois do recorte.
- Texturas: cada lado emenda consigo mesmo em 3×3; o céu externo é idêntico nas quatro salas que o usam.
- Retratos e HQs respeitam referências e têm espaço seguro para o texto composto pela UI.
- Cada asset aprovado está em `assets/` na rota exata que o dado de missão usa, é carregado pela build e possui entrada de versão/observação em `ART-PROMPTS-022`.

## Ordem de execução e dependências

`SPEC M2 congelada` → `piloto técnico` → `{inimigos + cenas}` → `{porta + adereços + texturas}` → `{retratos + itens}` → `{HQs + briefing}` → `playtest visual da missão inteira`.

Inimigos e cenas podem ser produzidos em paralelo somente depois de o piloto dos respectivos formatos passar. Texturas dependem das cenas para consistência estética, mas não de código final; HQs dependem das decisões de campanha e não devem bloquear o jogo.

## Riscos e proteção de escopo

| Risco | Proteção |
|---|---|
| Os ids/topologia de M2 mudam | Manter brutos versionados e só promover finais depois da SPEC; regenerar/renomear antes da integração. |
| Geração ignora o chroma ou corta a figura | Piloto obrigatório e rejeição antes do processamento. |
| Estilo deriva entre salas e cultistas | Referência aprovada encadeada e revisão conjunta por família. |
| Arte bonita esconde UI ou inimigos | Teste no tamanho final, em combate e na caminhada, não apenas no arquivo aberto. |
| 51 pedidos viram retrabalho caro | Lotes pequenos, no máximo três candidatas, portas de aceite por formato. |
| HQ antecipa revelações | Produção por último, após ids, texto e revisão narrativa. |
