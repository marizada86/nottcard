---
id: "SPEC-072"
type: "spec"
title: "Correções pequenas: F5 sobre sobreposições, texto das cartas, Ação usada, log"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-009-evidencias-do-daniel-v0.9.1-recomendacoes-2026-09-20]]"
  - "[[SPEC-063-guia-sempre-visivel-e-icones-nos-botoes]]"
sources:
  - "Daniel (jogador DNA), evidências da v0.9.1, notas 2, 4, 5 e 9"
---

# Correções pequenas: F5 sobre sobreposições, texto das cartas, Ação usada, log

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem aprovadas em 2026-09-20 (PLAN-009, D15 a D18).

## 1. F5 sobre qualquer sobreposição
O bloco de notas abre **por cima** de tutorial, pausa, catálogo, layout, mochila, pilhas, passiva e guia. Ao fechar, só retoma a tela de
baixo se nenhuma outra sobreposição continuar aberta; o print da nota sai com a sobreposição atrás.

## 2. Texto das cartas cabe
A nota da carta tenta as fontes 18, 16, 14 e 13 até caber na altura útil; se ainda estourar, corta com reticências (o texto completo está no
painel de detalhe). Um teste mede **todas** as cartas (incluindo os 18 pergaminhos) nos **10 layouts**.

## 3. Ajustes da SPEC-063
- O botão "Comprar 1 carta" da Ação vira **"Ação usada"** quando não resta Ação, com a gema apagada.
- A dica do Bônus diz "Gasta a sua Ação Bônus (não é uma carta grátis)".
- Guia e tutorial citam **Ctrl+F12**; novo botão **"Log"** ao lado do "Guia" (só na build de playtest); o aviso do primeiro combate ganha "· Ctrl+F12 log".

## 4. Descarte explicado (D15)
Uma linha no tutorial e na dica das pilhas: "o descarte só volta quando o baralho acaba, e vale a missão inteira".

## 5. Botão "Sugerir baralho" (D16)
Na tela do Baralho, "Sugerir baralho para [personagem]" preenche as vagas livres com cartas da cor da classe da coleção, respeitando o
núcleo, as 3 cópias e as regras de validade.

## 6. Regressão do suspense
Um teste percorre as batidas de um turno (alvo único, área, cada tipo de carta) e falha se qualquer texto, número, HUD ou log aparecer antes da
batida de revelação. Correção: a fixture de testes aponta a pasta de evidência para uma pasta temporária (fim dos `EV-*.zip` na raiz).

## 7. Testes
F5 sobre cada sobreposição; largura e altura de todas as cartas; "Ação usada"; o botão e o texto do Log; a sugestão de baralho válida para os 5 personagens.
