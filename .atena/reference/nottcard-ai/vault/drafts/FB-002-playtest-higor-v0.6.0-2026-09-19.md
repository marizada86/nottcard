---
id: "FB-002"
type: "feedback"
title: "Notas de playtest do Higor (Higurino), build v0.6.0, 2026-09-19"
status: "draft"
created: "2026-09-20"
relations:
  - "[[FB-001-feedback-playtest-higor-caio-2026-09-19]]"
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
sources:
  - "Higor (Higurino), game designer, notas de 2026-09-19, playtest iniciado às 04:19, build v0.6.0"
---

# Notas do Higor sobre a v0.6.0 (2026-09-19)

Regra do responsável: **as notas do Higor têm prioridade**. O que ele pede para mudar entra primeiro no plano.
Este arquivo guarda as notas como chegaram (seção 2), cada uma com um id (`H1`..) para as specs e o
`PLAN-001` apontarem. O que o código faz hoje e a proposta de cada item estão no `PLAN-001`.

Condições do teste: todos os personagens no **nível 5**, **sem alterar o baralho**.

## 1. Índice

| Id | Tipo | Resumo |
|---|---|---|
| H1 | bug de interface | A linha sob o "?" do nome cobre "CA / CAM" |
| H2 | regra (fórmula) | O atributo entra duas vezes no dano (percentual e flat); deve ser só o modificador flat |
| H3 | interface | Pilhas de compra e descarte clicáveis, mostrando as cartas (sem a ordem) |
| H4 | regra (loja) | Tirar o pacote de cartas; loja de upgrades (estilo Vampire Crawlers / Survivors) |
| H5 | regra (baralho) | Menos liberdade para trocar cartas; algumas obrigatórias |
| H6 | regra (exploração) | Punição mais pesada no 1 natural (falha crítica) em eventos |
| H7 | regra (exploração) | Habilidade "Sorte": rerrolar um d20 ruim, 1 por missão (sobe com nível ou upgrade) |
| H8 | regra (equipamento) | Armas e armaduras (D&D), menu de equipar por personagem, conquistas liberam melhores |
| H9 | balanceamento | Durvall com dano muito alto: a Corrente não deve multiplicar o 1d4 psiônico |
| H10 | balanceamento | Sylas muito forte (combo infinito, cópia imortal): aceita propostas |
| H11 | observação | Kayron equilibrado, com trabalho contra o grupo de slimes e o chefe; bom para a diversidade |
| H12 | próximo teste | Jogar com 2 e depois com 3 personagens |

## 2. As notas, como enviadas

**Sobre a jogabilidade:**

1. (H1) Durante o combate a "?" à direita do nome dos personagens tem uma linha que está sobrepondo a "CA" e a
   "CAM" abaixo do nome do personagem, dificultando a visibilidade. Consertar.
2. (H2) Algo está errado com a fórmula de dano. Ex.: Durvall tirou 6 base x 1 da Corrente + 3 de Força; o dano
   seria 9 + 1 de dano psiônico da passiva = 10. Mas no teste apresentado ele fez o seguinte cálculo:
   `(6 x 1x x compat 1.0 x (1 + 0,60 Força)) = ceil(9.60) = 10 + 1 psiônico = 11`. Esse "0,60" vindo da Força não
   deveria existir, porque da Força foi tirado o "modificador +3" que acrescenta 3 de dano; dessa forma o atributo
   contribuía com 3,60 de dano, e isso está errado.
3. (H3) Onde fica o ícone do baralho indicando quantas cartas tem: se clicar no baralho, ou no ícone debaixo de
   cartas descartadas, nada acontece. Seria interessante se esses ícones fossem clicáveis e mostrassem as cartas
   presentes; claro, não mostrar na ordem de compra, mas sim quais cartas ainda podem ser compradas e quais foram
   descartadas.
4. (H4) A loja como está deixa muita brecha para quebrar o jogo. Vamos remover o pacote de comprar cartas e
   trabalhar com upgrades: comprar aumento de % de dano base, aumento do número de cartas na mão, vida,
   rerrolagem de recompensas etc. (estilo de loja dos jogos "Vampire Crawlers" e "Vampire Survivors").
5. (H5) Deixar menos liberdade para trocar as cartas do baralho: algumas cartas devem ser obrigatórias no baralho.
   O objetivo aqui é evitar que o jogador abuse de mecânicas para "quebrar" o jogo e eliminar todo desafio que
   poderia ser proposto.
6. (H6) Adicionar punição mais pesada ao interagir em eventos e tirar 1 no dado (falha crítica).
7. (H7) Analisar para futuramente adicionar cartas e/ou habilidades que ajudem as interações, por exemplo
   "luck/sorte", que permite rerrolar um dado malsucedido, podendo reverter uma falha crítica em uma tentativa.
   Recomendo limitar o uso por missão a 1, podendo aumentar de acordo com os níveis ou upgrades em loja.
8. (H8) Definir os equipamentos, baseando-se em equipamentos do D&D e seus benefícios/malefícios: uma armadura
   "full plate" possui uma CA alta, mas em compensação deve ter uma CAM baixa e/ou desvantagens em eventos que
   envolvam furtividade. Criar um menu onde possa equipar os personagens um a um; pode ser na tela de escolha de
   personagens e/ou no menu principal. Os itens serão inicialmente somente arma e armadura, tendo todas as opções
   básicas na loja; para equipamentos melhores, devem existir conquistas que os desbloqueiam para comprar na loja.
   Inicialmente 3 armaduras básicas e 3 armas básicas. A ideia é que as armas venham com a sua própria carta, ou
   que alterem o efeito das cartas vermelhas: o que achar mais interessante e de melhor aplicação.

**Primeiro playtest com Kayron (H11):** Kayron aparenta estar equilibrado; teve um certo trabalho contra o grupo
de slimes e o último chefe, mas consegui me adaptar. Kayron é uma forma diferente de se jogar e pode levar um
tempo para se acostumar; muito bom para criar mais diversidade de jogabilidade.

**Conferindo Durvall (H9):** o dano do Durvall está MUITO alto. Sugestão inicial: ao causar uma Corrente, não
multiplicar o 1d4 de dano psiônico; somente o dano da carta será multiplicado.

**Primeiro playtest do Sylas (H10):** muito forte e muito divertido; precisa ser equilibrado de alguma forma que não
perca a parte divertida. O dano está muito alto; talvez o excesso de cartas sombrias facilite fazer um combo
infinito e uma cópia imortal. Aceito recomendações e propostas de balanceamento.

**Próximo playtest (H12):** pretendo analisar o jogo sendo jogado com 2 e depois 3 personagens. Isso foi tudo que
consegui pensar até o momento.
