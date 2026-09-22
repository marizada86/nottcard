---
id: "SIS-004"
type: "sistema-mecanico"
title: "Direção de arte — pixel art denso e sombrio"
status: "canon"
created: "2026-09-16"
relations:
  - "[[SIS-002-destaque-visual-de-mecanica-em-carta]]"
  - "[[SIS-003-fileira-de-inimigos-exploracao-com-cartas-hud]]"
  - "[[VSN-002-fichas-jogaveis-elenco]]"
sources:
  - "Entrevista com o responsável do projeto em 2026-09-16 (decisão de estilo pra migração do protótipo CLI para UI gráfica em Godot)"
  - "4 imagens de referência de personagem em C:/Users/gui-m/Desktop/nottgard (Durvall_Gellad.png, kayron.png, Maelor.png, sylas_malafa.png) — usadas como referência de CONTEÚDO (silhueta, cor temática, elementos icônicos de cada personagem), não de estilo; nenhuma delas é pixel art e não seguem estilo entre si"
---

# Direção de arte — pixel art denso e sombrio

## Decisão

O jogo (versão gráfica em Godot, ver `game/`) adota **pixel art denso e sombrio**,
na linha de Blasphemous / Dead Cells / Hyper Light Drifter: mais detalhe e
dithering pesado que pixel art retrô clássico (16-bit), não o estilo "limpo"
de Moonlighter/Enter the Gungeon.

- **Enquadramento de personagens e inimigos em combate:** retrato/busto
  frontal (da altura do peito pra cima, olhando de frente), não sprite de
  corpo inteiro de perfil. O jogador não vê o próprio personagem em combate
  (só a mão de cartas); os inimigos aparecem como retratos frontais — mesma
  leitura da imagem de referência de Vampire Crawlers já citada em
  `SPEC-001`.
- **Cor de família de carta (Vermelho/Amarelo/Azul/Roxo, `VSN-002`) fica
  só na moldura/UI da carta, nunca pintada na ilustração em si.** A
  ilustração usa sempre a paleta sombria/neutra do jogo (ver abaixo),
  independente da família da carta. A moldura colorida por família é
  desenhada em código no Godot (`ColorRect`/`StyleBox`), não precisa ser
  gerada como imagem.
- **Geração avulsa, sem seed/imagem-âncora entre gerações** — cada prompt
  precisa ser autocontido e repetir o bloco de estilo por completo (ver
  `ART-PROMPTS-001` em `.atena/generated/`), já que o nano banana não vai
  manter contexto entre uma geração e outra.

## Paleta sombria do jogo (independente de cor de família)

Usar em toda ilustração de personagem/inimigo/cenário, como identidade
visual do mundo de Nottgard — não confundir com a cor de família da carta:

- Névoa/base: cinza-azulado profundo, quase monocromático
- Corrupção: roxo escuro/violeta sujo
- Sangue/perigo: vermelho seco (oxblood), nunca vermelho vivo
- Única luz quente: âmbar fraco (tochas, brasas) — usado com moderação,
  como contraste pontual, não como cor dominante

## Referências de conteúdo por personagem (não de estilo)

A partir das 4 imagens de referência do responsável do projeto — usadas só
pra herdar silhueta/elementos icônicos, redesenhados do zero em pixel art:

- **Durvall:** drow, cabelo branco longo, armadura escura ornamentada,
  energia psiônica branco-azulada nas mãos/arma (coerente com a passiva de
  dano psiônico bônus já canônica em `PERS-durvall`).
- **Kayron:** asas grandes preto-e-vermelho, olhos vermelhos, cabelo
  branco/claro, tema de energia mística vermelha nas mãos (coerente com
  "Carga de Poder Místico").
- **Maelor:** armadura dourada/branca ornamentada, chama azul-branca na
  mão (coerente com Clérigo da Luz).
- **Sylas Malafa:** máscara com chifres, capa escura, marcações
  roxo-rosadas brilhantes (coerente com tema Shadow Cleric).

## Especificações técnicas por tipo de asset

| Tipo | Canvas sugerido | Notas |
|---|---|---|
| Retrato de personagem/inimigo | Quadrado, gerar em alta resolução (ex.: 1024×1024) com estética de pixel art | Se o nano banana não sair com pixel bem definido, aplicar downscale + nearest-neighbor depois (Aseprite ou similar) pra um grid real |
| Ilustração de carta | Quadrado, mesma família de estilo, um pouco menos denso que retrato (elemento menor na tela) | Sem moldura, sem texto — a UI do Godot desenha por cima |
| Cenário de sala | Retangular widescreen (16:9) | Cena mais ampla, pode ter mais elementos de composição que os retratos |
| Ícone de HUD | Quadrado, simples, alto contraste | Exceção à densidade: ícone precisa ler bem pequeno (24–32px in-game), então menos detalhe que personagens/cartas |

## O que esta decisão NÃO resolve

- Paleta de cor exata em hex — descrita por nome aqui, não codificada; fica
  pra quando os primeiros assets gerados definirem os tons finais.
- Animação/frames de sprite — este documento cobre só imagem estática.

## Review record

- Proposed by: Claude, a partir de entrevista com o responsável do projeto em 2026-09-16.
- Reviewed by: responsável do projeto, em 2026-09-16.
- Approval decision: aprovado — estilo (pixel art denso e sombrio), enquadramento (retrato frontal) e regra de cor de família só na UI confirmados nesta mesma conversa.
