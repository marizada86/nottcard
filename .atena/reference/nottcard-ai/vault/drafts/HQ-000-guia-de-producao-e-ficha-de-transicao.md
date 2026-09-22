---
id: "HQ-000"
type: "proposta-de-conteudo"
title: "Guia de produção e ficha de HQ de transição"
status: "draft"
created: "2026-09-19"
relations:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
  - "[[MUNDO-001-tarn-cupula-de-nottgard]]"
---

# Guia de produção e ficha de HQ de transição

## Objetivo

Padronizar HQs curtas que conectam Missões e Interlúdios sem interromper o
ritmo do jogo. Cada HQ deve explicar uma única mudança de estado: uma ameaça
foi resolvida, uma consequência surgiu ou uma próxima direção foi dada.

Este é um guia de produção; não altera missões, mecânicas ou cânone.

## Formato aprovado para o piloto

| Item | Padrão |
|---|---|
| Duração | 8–12 segundos de leitura; sempre pulável |
| Estrutura | 1 página horizontal com 4 quadros, lida da esquerda para a direita |
| Área de arte | 1920 x 1080 px, PNG opaco, sem texto incorporado |
| Texto | Balões, legenda e botão de avançar compostos pela UI do jogo |
| Estilo | Pixel art denso e sombrio; paleta e linguagem visual de `SIS-004` |
| Continuidade | Uma referência visual de personagem por figura recorrente e uma referência de cenário por local |
| Aprovação | Storyboard em cinza -> arte sem texto -> texto/UI -> teste no jogo |

Não pedir texto, balões, logo, moldura de página ou marca-d'água à ferramenta
de imagem. Isso reduz erros tipográficos e torna localização e revisão de
diálogo independentes da ilustração.

## Fluxo no StanleyAI

1. Criar uma coleção/projeto `Nottgard / HQs de transição`.
2. Carregar a ficha de identidade visual e as referências indicadas na ficha
   da HQ. Se a ferramenta permitir referências persistentes, salvar cada
   personagem e cenário com seus identificadores; caso contrário, anexá-los
   em cada geração.
3. Gerar primeiro o **storyboard** por quadro, com baixa prioridade para
   acabamento. Aprovar ordem, emoção, leitura e continuidade antes de gerar
   arte final.
4. Gerar cada quadro final separadamente, usando o mesmo estilo e as mesmas
   referências. Regenerar somente o quadro que falhar.
5. Exportar os quatro PNGs sem texto e registrar versão, prompt e referências
   usadas nesta ficha.
6. Montar a página e aplicar os textos no jogo; nunca rasterizar diálogo na
   arte base.

## Regras de linguagem visual

- A Tarn é uma barreira energética azul: nunca vidro, cristal ou céu solar.
- Névoa de corrupção é esverdeada; efeitos arcanos de corrupção são roxos.
- Luz quente é âmbar discreto; vermelho seco é acento de perigo.
- Personagens precisam ser reconhecíveis pela silhueta antes de detalhes.
- Em um quadro de fala, privilegiar plano médio ou fechado; em um quadro de
  mundo, privilegiar plano aberto. Evitar quatro enquadramentos iguais.
- Toda HQ precisa encerrar com um destino visual claro, não apenas exposição.

## Modelo de ficha por transição

Copiar esta seção para cada nova HQ.

### Identificação

| Campo | Preencher |
|---|---|
| ID / título | `HQ-### — ...` |
| Entre | Missão/Interlúdio de origem -> destino |
| Estado que fecha | Fato que o jogador acabou de resolver |
| Estado que abre | Objetivo, ameaça ou promessa seguinte |
| Spoilers proibidos | Informações que não podem aparecer |
| Referências | Assets e documentos canônicos aplicáveis |

### Roteiro de quadros

| Quadro | Função | Direção visual | Texto na UI | Saída emocional |
|---|---|---|---|---|
| 1 | Recapitular | ... | ... | ... |
| 2 | Virar | ... | ... | ... |
| 3 | Apresentar | ... | ... | ... |
| 4 | Dar gancho | ... | ... | ... |

### Prompt por quadro

Cada prompt deve conter: bloco de estilo, formato, sujeitos/referências,
ação visível, enquadramento, iluminação, restrições e área de respiro para
eventual UI. Anotar referência e versão usados logo abaixo do prompt.

### Controle de qualidade

- [ ] A HQ cabe no tempo-alvo de leitura.
- [ ] A consequência da origem e o próximo destino são compreensíveis sem
  texto extra.
- [ ] Nenhum spoiler proibido foi incluído.
- [ ] Cabelo, pele, roupa, arma e silhueta dos personagens batem com as
  referências.
- [ ] A Tarn, cores e iluminação obedecem à direção de arte.
- [ ] Não há texto, balões, moldura, logotipo ou marca-d'água na arte.
- [ ] Há espaço seguro para texto/UI e nenhum elemento relevante foi cortado.
- [ ] A leitura no tamanho real do jogo continua clara.

## Decisões pendentes para aprovação do responsável

1. Confirmar a página horizontal de quatro quadros como linguagem padrão, ou
   preferir uma sequência de quadros em tela cheia.
2. Definir se as HQs entram antes da tela de recompensa, depois dela, ou são
   acessíveis também pelo diário de campanha.
3. Validar o piloto `HQ-001` antes de replicar este formato para as demais
   transições.

