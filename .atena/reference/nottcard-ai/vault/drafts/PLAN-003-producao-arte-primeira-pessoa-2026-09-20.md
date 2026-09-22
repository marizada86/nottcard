---
id: "PLAN-003"
type: "plano"
title: "Plano de produção e validação da arte da primeira pessoa"
status: "draft"
created: "2026-09-20"
relations:
  - "[[ART-PROMPTS-013-primeira-pessoa-2026-09-20]]"
  - "[[PLAN-002-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-052-combate-de-frente-layout-primeira-pessoa-fp1]]"
  - "[[SPEC-053-corredor-portas-e-recompensas-primeira-pessoa-fp2-fp3]]"
  - "[[SPEC-054-arte-em-camadas-primeira-pessoa-fp4]]"
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
sources:
  - "ART-PROMPTS-013, 2026-09-20"
  - "PLAN-002, seções 2, 4 e 5"
  - "Responsável, 2026-09-20: fazer plano para ART-PROMPTS-013"
---

# Plano de produção da arte da primeira pessoa

> Rascunho operacional. A geração começa somente após a aprovação das specs de primeira pessoa
> pertinentes; este plano não autoriza implementação, promoção a cânone, commit ou publicação.
> A arte é incremental: a ausência de qualquer arquivo preserva o fallback existente e não bloqueia
> FP-0, FP-1, FP-2 ou FP-3.

## 1. Resultado e ordem de prioridade

Entregar os 27 arquivos descritos em `ART-PROMPTS-013`, prontos para o jogo em 1280×720 nas cenas
e nos tamanhos de interface definidos pela spec. O lote deve manter o mesmo enquadramento, paleta e
legibilidade ao ser reduzido e aplicado em movimento; não basta aprovar a imagem isolada.

| Onda | Objetivo | Entregáveis | Decisão para avançar |
|---|---|---|---|
| 0. Preparar | Tornar o pipeline e a ficha de revisão capazes de receber o lote | contrato técnico, referências e checklist | processar fundo e alfa sem ambiguidade |
| 1. Calibrar | Fixar estilo, enquadramento e par `bg`/`fg` | sala 1 completa | funciona no jogo e é aprovada visualmente |
| 2. Cenários | Cobrir a rota M1 com camadas coerentes | salas 2 a 7, 12 imagens | cada par passa na revisão em contexto |
| 3. Navegação | Tornar o corredor clicável e legível | 4 portas e cadeado | comporta 1, 2 e 3 portas sem conflito |
| 4. Combate | Substituir os símbolos provisórios do layout FP-1 | livros, orbe e 3 indicadores | silhuetas claras nos tamanhos reais |
| 5. Recompensa | Finalizar a apresentação FP-3 | fundo e moldura | cartas continuam sendo o foco |
| 6. Fechar | Verificar o lote no jogo e no executável | evidência visual e checklist concluído | fallback, performance e empacotamento aprovados |

Essa ordem preserva a dependência de código: a sala 1 é a amostra de risco, portas dependem dos
slots de `scenes_data`, os ícones dependem do layout FP-1 e a recompensa pode entrar por último sem
impedir a navegação.

## 2. Onda 0 — contrato antes de gerar

1. Aprovar `SPEC-052`, `SPEC-053` e `SPEC-054`, ou registrar explicitamente quais delas ainda não
   são necessárias para começar a geração. `ART-PROMPTS-013` é derivado e deve ser regenerado se uma
   delas mudar.
2. Registrar numa ficha curta por asset: prompt usado, data, imagem de referência anexada, tentativa
   escolhida, caminho bruto, resultado da revisão e motivo de rejeições. A ficha mantém a reprodução
   possível sem tornar `assets/_raw/` versionado.
3. Preparar as referências: para cada sala, anexar o respectivo `assets/rooms/<sala>.png`; para os
   assets de HUD, anexar `assets/hud/pv_icon.png` e `assets/hud/deck_icon.png`. Não misturar referências
   de composição com o prompt — elas servem só para estilo e acabamento.
4. Fechar o contrato do processamento **antes do lote**. Hoje `process_art.py` só trata chroma-key para
   `hud` e `dice`; FP-4 exige suporte explícito a `rooms/<sala>/fg.png` e `mid.png` com alfa, enquanto
   `rooms/<sala>/bg.png` continua opaco e indexado. Também devem ficar definidos o chroma-key, recorte,
   tamanho final e formato das novas categorias `doors` e `hud` que não sejam quadradas. Cobrir esses
   casos por testes de processamento.
5. Confirmar em uma imagem-teste que o carregador procura as subcamadas e cai no `assets/rooms/<sala>.png`
   atual. A geração não deve começar supondo que o fallback já foi implementado.

## 3. Onda 1 — sala de calibração

Gerar **uma imagem por vez**, começando por `sala_1_docas/bg.png`, depois
`sala_1_docas/fg.png`. Avaliar a primeira antes de pedir a segunda.

| Verificação | Fundo (`bg`) | Frente (`fg`) |
|---|---|---|
| Composição | parede central entre 20–80% e 30–68% livre para portas; chão central livre para inimigos; terço inferior discreto para a mão | centro entre 22–78% e 15–78% inteiramente verde e borda inferior quase livre |
| Formato | 16:9, opaco, sem conteúdo crítico que o recorte central possa perder | verde `#00FF00` uniforme, sem verde nos objetos |
| Continuidade | luz alto-esquerda, paleta e escala correspondem à sala atual | mesmos materiais, luz e escala do `bg`, mas objetos mais próximos e escuros |
| Jogo | câmera, inimigos e porta de teste não se sobrepõem de modo confuso | paralaxe mostra profundidade sem cobrir inimigos, portas ou mão |

Processar o par, inspecionar o PNG final e fazer uma captura em 1280×720. Só após aprovação desse
par, congelar a fórmula de prompt comum e prosseguir. Se houver deriva de estilo, iniciar uma conversa
nova de geração usando o par aprovado como única referência de acabamento.

## 4. Ondas 2 a 5 — produção em lotes pequenos

### 4.1 Cenários (12 imagens)

Produzir um par por vez, na sequência narrativa abaixo. O `bg` precisa ser aprovado antes do `fg` da
mesma sala; cada par entra no jogo antes do próximo.

1. Sala 2, Cais atacado — valida continuidade com a sala 1 e a parede com três portas.
2. Sala 3, Rachadura na Tarn — valida a primeira bifurcação e a leitura de dois ambientes.
3. Sala 4, Porão entrada — calibra a escala subterrânea e as duas portas.
4. Sala 5, Porão sala de livros — confirma que detalhes de estantes não invadem os slots.
5. Sala 6, Porão corredor — confirma o enquadramento de frente, substituindo a composição anterior que
   não tinha esse ponto de vista.
6. Sala 7, Ritual — fecha a progressão visual do chefe sem colocar entidades, nomes ou símbolos de lore
   que revelem a trama.

Após cada par: conferir dimensões, opacidade/alfa, faixa de portas, área dos inimigos, terço da mão e
paralaxe. Rejeitar imediatamente texto, marca d'água, personagens, porta desenhada no fundo ou verde
fora do chroma do primeiro plano.

### 4.2 Portas e cadeado (5 imagens)

Produzir na ordem madeira, pedra, escada, ritual e cadeado. Usar uma cena aprovada para testar cada
porta centralizada e depois em todos os slots (uma, duas e três portas). O código é responsável por
hover, estado limpo e escurecimento; a arte não deve embutir texto ou estados alternativos. O cadeado
precisa ser revisado a ~64 px antes de ser aceito.

### 4.3 HUD de combate (6 imagens)

Produzir livros antes dos demais, pois eles substituem as pilhas no layout FP-1; seguir com orbe de PV e
indicadores de Ação, Bônus e Reação. Aprovar os três indicadores juntos para garantir que sejam uma
família, mas avaliar um por mensagem. Todos devem manter o fundo verde recortável e leitura inequívoca
em 32 px (indicadores), 64 px (orbe) e ~128 px (livros). O interior verde do orbe e da moldura é uma
janela funcional para desenho pelo código, não área decorativa.

### 4.4 Tela de recompensa (2 imagens)

Gerar primeiro `screens/recompensa.png`, conferir a área central calma com três cartas de teste e só
então gerar `hud/moldura_recompensa.png`. A moldura deve receber carta real por trás e pela frente sem
ocultar a informação de raridade, custo ou efeito.

## 5. Controle de qualidade e aceite

Cada arquivo só é marcado no checklist de `ART-PROMPTS-013` quando atender a todos estes pontos:

- o nome, a pasta bruta e a pasta final correspondem exatamente ao `asset_id` e à convenção da spec;
- não há texto, número, marca d'água, transparência falsa ou verde fora das áreas cromadas;
- processamento entrega dimensão prevista, alfa onde solicitado e paleta indexada apenas nas cenas opacas;
- a imagem final é testada no contexto da tela relevante, em 1280×720 e tela cheia;
- a câmera com movimento normal e com “Reduzir movimento” não prejudica clique, hover, intenção, mão ou HUD;
- a imagem continua legível nas dimensões reais de uso e não cria contraste que esconda cartas, inimigos ou portas.

Ao fim de cada onda, registrar uma captura antes/depois e os caminhos dos assets aceitos. Na onda 6,
percorrer as sete salas, a bifurcação e a recompensa; repetir sem nenhuma camada nova para confirmar o
fallback; por fim, testar o executável empacotado para garantir que as subpastas de `assets/` foram incluídas.

## 6. Replanejamento e riscos

| Sinal | Ação |
|---|---|
| A sala 1 não casa com câmera, portas ou inimigos | parar o lote, corrigir o prompt-base ou slots e repetir apenas a amostra |
| Gerador deriva de estilo | iniciar conversa nova e usar somente a amostra aprovada como referência |
| Fundo verde entra no objeto ou no centro do `fg` | rejeitar antes do processamento; não corrigir manualmente sem registrar exceção |
| A camada frente prejudica cartas ou alvos | reduzir ou mover o elemento no prompt; `fg` não é obrigatório para o jogo funcionar |
| Pipeline não preserva alfa ou redimensiona incorretamente | bloquear a promoção daquele asset e concluir primeiro a alteração prevista na SPEC-054 |
| O volume de 27 imagens atrasa FP-1–FP-3 | manter apenas os assets já aceitos; os fundos e formas desenhadas por código seguem como fallback |

## 7. Definição de pronto

O plano estará concluído quando os 27 itens estiverem marcados no checklist de `ART-PROMPTS-013`, cada
um tiver revisão em contexto registrada, os testes do pipeline e do fallback estiverem verdes, e o lote
funcionar no executável. A promoção de specs, commits e publicação continua dependente da aprovação
explícita do responsável.
