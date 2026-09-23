---
id: "M7-001"
type: "ficha-de-producao"
title: "M7 — Ficha de produção de O Espeto de Pau"
status: "promoted"
created: "2026-09-23"
sources:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[PERS-korrak-ficha-jogavel]]"
  - "[[PERS-leoric-ficha-jogavel]]"
  - "[[PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21]]"
---

# M7 — O Espeto de Pau

## Leitura confirmada

Depois de M6, o comício de Dagruve e a pista de Willie apontam para o Martelo
de Bromnor. M7 é a dungeon-puzzle na ferraria abandonada Espeto de Pau: o
grupo atravessa portais gêmeos, encontra o diário de Bromnor e conhece Korrak
e Leoric. O mímico é o único combate obrigatório definido para o recorte.

Leoric surge assustado de um portal carregando uma semente desconhecida; sua
amnésia deve permanecer um mistério. Korrak entra como aliado associado a
Leoric. As revelações posteriores sobre a semente, a Árvore Sagrada e a Tarn
permanecem fora da missão.

## Situação atual do projeto

| Item | Situação |
|---|---|
| Mímico | Já existe como inimigo e tem arte importada. |
| Korrak e Leoric — retratos | Já existem em `assets/portraits/`. |
| Korrak e Leoric — personagens jogáveis | Ainda não existem em `data/core/characters.json`; não há baralhos, passivas ou desbloqueio no save. |
| Ferraria, portais, diário e salas M7 | Ainda não existem. |
| Sistema de portais | A caminhada não possui teletransporte/puzzle de conexão. |

## Fluxo proposto — precisa de aprovação

1. **Pátio da ferraria:** situação de investigação; o grupo encontra a entrada
   do Espeto de Pau e a primeira marca de Bromnor.
2. **Fornalhas apagadas:** situação de puzzle; três fornalhas fornecem a pista
   visual para escolher o portal correto.
3. **Porão dos portais gêmeos:** segunda situação curta; a escolha correta
   conduz ao portal de Leoric, a errada cobra custo e retorna à mesma sala.
4. **Oficina do mímico:** um único combate de chefe contra um mímico de maior
   porte; a vitória libera o diário de Bromnor e registra a chegada de Korrak
   e Leoric.

Para preservar a base atual, os portais serão situações encadeadas e não uma
nova regra global de teletransporte na caminhada. A escolha errada não cria
rotas duplicadas nem salas extras; aplica dano/XP reduzido e mantém a sala
atual até a resolução correta.

## Decisão de elenco necessária

As fichas canônicas de Korrak (Bárbaro, Vermelho, Satanaxe) e Leoric (Druida,
Azul, Modo de Constelação) estão aprovadas como referência, mas o jogo ainda
não tem suas definições mecânicas completas. Para não inventar baralhos e
valores no mesmo passo da dungeon, proponho dois marcos:

1. **M7-A — chegada narrativa:** M7 persiste `korrak_recrutado` e
   `leoric_recrutado`, mostra seus retratos e deixa ambos prontos para seleção
   futura; eles ainda não entram como escolha de jogador nesta missão.
2. **M7-B — elenco jogável:** uma especificação própria traduz as fichas já
   aprovadas em atributos, baralhos, cartas de assinatura, passivas, progresso
   e desbloqueio na seleção. Só então eles entram no catálogo jogável.

Essa separação preserva o fato narrativo de que ambos chegam em M7 sem escolher
agora números de combate que as fontes não definem.

## Backlog P0 de M7-A

| Entrega | Quantidade | Decisão |
|---|---:|---|
| Salas em camadas | 4 pares `bg`/`fg` | Pátio, fornalhas, portais e oficina. |
| Props | 4 | Bigorna/ferramentas, brasas apagadas, dois portais e diário de Bromnor. |
| Inimigo | 0 novos | Reuso validado do mímico, com variante de chefe em dados. |
| Retratos | 0 novos | Reuso de Korrak e Leoric já importados. |
| Dados | 1 missão + mapa + lore + 2 situações | M7 exige M6. |
| Recompensas narrativas | 3 chaves | Diário de Bromnor, chegada de Korrak e chegada de Leoric. |

## Não objetivos

- Não criar sistema global de portais, teletransporte, labirinto ramificado ou
  persistência de estado de puzzle para outras missões.
- Não inventar as cartas, números de combate ou passivas executáveis de Korrak
  e Leoric dentro de M7-A.
- Não revelar o significado futuro da semente de Leoric, sua amnésia, a Árvore
  Sagrada ou o destino da Tarn.
- Não antecipar Vila das Sombras, Erik ou os chefes de M8/M9.

## Aceite proposto

- M7 exige M6 e tem quatro salas, um combate obrigatório e duas etapas de
  puzzle de portal.
- O mímico é o único inimigo novo em dados; sua arte é reusada sem fallback.
- Erro de portal é observável, seguro e não cria uma regra global.
- Vitória persiste diário e as duas chegadas narrativas.
- M1–M6 preservam regressão e a UI real percorre M7.

## Decisão aprovada

O usuário aprovou a M7-A com os portais modelados como situações encadeadas e
a chegada narrativa de Korrak/Leoric. A M7-B, para torná-los integrantes
selecionáveis do elenco, permanece uma especificação posterior e independente.
