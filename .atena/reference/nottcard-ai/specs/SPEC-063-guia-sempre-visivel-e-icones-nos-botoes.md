---
id: "SPEC-063"
type: "spec"
title: "Guia sempre visível e ícones de Ação e Ação Bônus"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
  - "[[SPEC-050-modo-playtester-boas-vindas-e-bloco-de-notas]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
sources:
  - "Higor, v0.9.1 (H13, H14)"
---

# Guia sempre visível e ícones de Ação e Ação Bônus

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Decisões de origem já aprovadas em 2026-09-20 (D1, D2 do PLAN-007).
> Números marcados como provisórios são calibrados no simulador e confirmados pelo Higor.

## 1. Guia global
- Botão **"Guia"** no topo (à esquerda do botão de velocidade), em todas as telas menos login e boas-vindas; só com `PLAYTEST_BUILD` e jogador identificado.
- Abre uma sobreposição `GuideOverlay` (padrão do tutorial/bloco de notas): pausa a tela de baixo e o cronômetro do chefe, registra no log dev e retoma ao fechar (Esc, "Voltar" ou novo clique). Nada da luta se perde.
- Atalho `F2`. O desenho do painel é extraído de `playtest_guide.py`; sai o botão do menu.

## 2. Ícones nos botões
- "Comprar 1 carta" + a gema da ação no lugar do parêntese: losango laranja (Ação), estrela azul (Ação Bônus), de `assets/hud/ind_acao.png` e `ind_bonus.png`. `draw_button(..., icon=)` em `hud.py`.
- Dica ao passar o mouse: "Gasta a sua Ação Bônus". Usado: "Ação Bônus usada" com o ícone apagado.
- Sem o arquivo, texto de reserva "(Ação Bônus)". Tutorial passa a dizer "Ação Bônus" e legenda as gemas. O rótulo "Bônus" do trilho fica.

## 3. Testes
Botão em combate, menu e caminhada; clique no combate abre, pausa e bloqueia a mão; fechar retoma; ausente no login e sem `PLAYTEST_BUILD`; botões com ícone e texto de reserva.
