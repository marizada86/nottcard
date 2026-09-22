---
id: "LOG-2026-09-20"
type: "devlog"
title: "Devlog 2026-09-20: do combate de lado à primeira pessoa, e o que os playtesters disseram"
status: "draft"
created: "2026-09-20"
---

# 20/09/2026: entrei na masmorra, e os playtesters me trouxeram de volta

Para publicar no marizverso.com. Data do trabalho: **20 de setembro de 2026**.

Hoje foi o dia mais cheio do Nottcard AI até agora. Comecei o dia com um jogo de cartas com mapa de nós e terminei com uma masmorra
que dá para caminhar em primeira pessoa, com mouse controlando a câmera, texturas nas paredes e dados com rosto.

## Primeiro, o jogo virou "de frente"

Eu queria que o combate deixasse de parecer uma tela de menu. Extraí a parte de desenho do combate para um módulo próprio, conferindo
que o resultado saía pixel a pixel igual ao anterior, e só então redesenhei: mão em leque, livros de baralho e descarte, um orbe de PV,
gemas para as ações e as orbes do grupo. A intenção do inimigo agora aparece revelada, e a câmera acompanha o mouse com um leve
parallax (com opção de reduzir movimento no perfil, para quem enjoa).

A exploração ganhou portas em vez de só nós num mapa, com arte em camadas por sala: 27 imagens entre fundo, primeiro plano, portas e HUD.

## Depois, andei dentro dela

A parte que mais me divertiu: um mapa em grade, um caminhante no núcleo do jogo (sem pygame, como manda a arquitetura) e um raycaster
por cima, à moda dos jogos antigos. Ganhei um automapa, encontros no caminho e mantive o modo clássico de portas como opção no perfil.
Fechei isso na v0.9.0, com 1284 testes. Na v0.9.1 entrou a quinta personagem, Brook Franca, uma Paladina com Guarda e Desonra, e na
v0.9.2 as texturas do mundo (7 salas e 8 props), as faces dos dados e um bloco de notas editável (F5) que agora entrega o pacote da
sessão em `.zip` ao lado do executável.

## Aí veio o playtest

O Higor rodou a v0.9.1 com o Daniel e o Hiago e o relatório voltou cheio de coisa boa. Registrei tudo como feedback (FB-004) e escrevi um
plano (PLAN-008), respeitando a regra de que a nota do Higor tem prioridade:

- **Os inimigos acertam demais.** Os dois playtesters disseram, e o Kayron foi o mais citado. Como cada ponto de CA tira 5 pontos
  percentuais da chance do inimigo, medi no simulador antes de mexer em qualquer número. O ajuste virou defesa base e PV por nível para
  todos os personagens (SPEC-060).
- **A Corrente quebrava antes do dado.** O resultado aparecia antes da revelação. Agora recursos só mudam quando o dado é revelado
  (SPEC-061).
- **Carta de cor diferente da classe** (dano ×0,5) passava despercebida. Vai ganhar destaque na carta, no detalhe e no número de dano
  (SPEC-062).
- **W A S D não era óbvio.** Q/E passam a virar e A/D andam de lado, com a tela virando junto, mais legenda e ajuda no "?" (SPEC-064).
- **Guia sempre visível e ícones nos botões de Ação e Ação Bônus** (SPEC-063) e a **Mão Maior**, um upgrade de loja liberado pela
  conquista Fechadura Aberta (SPEC-065).
- **Um log de combate no estilo do Baldur's Gate 3** (Ctrl+F12): modificadores, tipo de dano, o que cada dado tirou, quem rolou. O F12
  continua como está (SPEC-066).

As sete specs (060 a 066) estão aprovadas. A implementação já começou pelos números de defesa e PV, e o resto vem em seguida. Ainda falta
playtestar a caminhada em primeira pessoa e as texturas.

## O que aprendi hoje

Mostrar o sistema para quem não o escreveu é a melhor auditoria que existe. Eu achava a Corrente clara, e o Daniel encontrou o momento
exato em que ela contava a resposta antes do dado.
