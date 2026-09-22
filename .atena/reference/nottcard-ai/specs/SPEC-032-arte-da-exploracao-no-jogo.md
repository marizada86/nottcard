---
id: "SPEC-032"
type: "spec"
title: "Arte da exploração no jogo (mapa, nós, atributos e selos)"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-031-modo-exploracao-mapa-de-nos-e-testes-de-d20]]"
  - "[[SPEC-017-arte-final-no-jogo]]"
  - "[[ART-PROMPTS-006-exploracao-2026-09-19]]"
sources:
  - "Responsável, 2026-09-19: arte de exploração gerada (ART-PROMPTS-006); integrar ao jogo"
---

# Arte da exploração no jogo

## Problema

A SPEC-031 desenha o mapa com círculos e a situação de d20 com uma miniatura de 320×200. A arte de
`ART-PROMPTS-006` já está em `assets/` (fundo do mapa, 6 ícones de nó, 4 de atributo e 2 selos), mas nenhum
código a usa. Sem mudar nenhuma regra, esta spec só troca o desenho.

## Regras

Toda arte tem **fallback**: se o arquivo não existe, vale o desenho da SPEC-031 (círculo com número, fundo liso,
botão sem ícone). Nada bloqueia a lógica.

### Mapa (`game/ui/map_view.py`)

- Fundo: `assets/screens/mapa.png`, em tela cheia (sem ele, o fundo liso de hoje).
- Ícone do nó, sobre o círculo de estado: `node_exploracao` (exploração), `node_evento` (evento), `node_combate`
  (combate), `node_chefe` (chefe), 72 px. O círculo continua dando o estado (visitado, resolvido, vizinho) e
  o brilho do mouse.
- Com o ícone, o **número da sala some** (o ícone já identifica o tipo); sem o ícone, volta o número.
- `node_atual` (peão) sobre o nó atual, 52 px, no lugar do texto "você está aqui"; o anel dourado fica.
- `node_limpo` (selo) no canto inferior direito de todo nó resolvido, 34 px; o ícone do nó escurece.

### Situação de d20 (`SituacaoScreen`)

- Fundo: a cena da sala (`assets/rooms/*.png`, já 1280×720) em **tela cheia**, com uma faixa escura atrás de
  cada bloco de texto para manter a leitura. Sem a cena, o fundo liso de hoje.
- Botão de opção: ícone do atributo (`attr_forca`, `attr_inteligencia`, `attr_constituicao`, `attr_carisma`,
  32 px) ao lado do rótulo; a opção de combate não tem ícone.
- Resultado: selo `check_sucesso` ou `check_falha` (64 px) ao lado da primeira linha (`d20 + mod = total vs DC`).

## Fora de escopo

Animação dos ícones, som, arte de itens e de pergaminhos, e as HQs.

## Critérios de aceite

- [x] O mapa usa o fundo, o ícone de cada tipo de nó, o peão no nó atual e o selo nos resolvidos.
- [x] Sem cada arte, o mapa e a situação desenham como na SPEC-031 (teste com os arquivos ausentes).
- [x] A situação usa a cena em tela cheia, o ícone de atributo nas opções e o selo no resultado.
- [x] Nenhuma regra muda; os testes de fluxo da SPEC-031 seguem passando.
- [ ] Playtest: os ícones são reconhecíveis no tamanho real e o texto se lê sobre todas as cenas.
