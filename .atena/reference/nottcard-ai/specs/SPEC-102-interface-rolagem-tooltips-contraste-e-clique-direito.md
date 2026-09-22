---
id: "SPEC-102"
type: "spec"
title: "Interface: rolagem, tooltips da loja, contraste do dado e clique direito"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[SPEC-098-vantagem-e-desvantagem]]"
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
sources:
  - "Playtest do Higor, 2026-09-21 (v0.14.0): EV-020302..032545, notas de dado, resultado, catálogo/conquistas, loja, 'Como jogar' e clique direito"
---

# Ajustes de interface

1. **Rolagem reutilizável** (`game/ui/scroll.py`, `ScrollArea`): roda do mouse, arrastar a barra, PgUp/PgDn/setas quando focada, recorte da área e barra visível só se o
   conteúdo passa da altura. Sem regra de jogo.
2. **Missão concluída** (`result_panel.py`): "XP da tentativa" e "Estatísticas" (com os detalhes dos inimigos) numa `ScrollArea` cada; **Total, Nível, barra e
   Moedas fixos** abaixo, fora da lista; a lista nunca sobrepõe o que está fixo; botões sempre visíveis.
3. **Catálogo e Conquistas** (`hq_screen.py`, `tab_strip.py`, `collection.py`): rolagem vertical em cada aba. **Auditoria de estouro:** um teste desenha toda tela em
   1280×720 e 1024×576 e falha se algum texto sai do retângulo do seu painel ou se dois blocos de texto se sobrepõem.
4. **"Como jogar"/tutorial** (`tutorial.py`, `playtest_guide.py`): rolagem; o texto nunca cobre a interface.
5. **Loja** (`shop_screen.py`): toda linha com texto cortado ("…") mostra o **texto completo num tooltip** ao passar o mouse; todo item (upgrades, equipamentos,
   personagens) mostra também "o que faz" (nota, dados, requisitos, bônus).
6. **Contraste dos números do dado** (`dice_widget.py`): cor do número por luminância da face (claro em face escura, escuro em face clara) e contorno de 1–2 px; teste
   com todas as cores de dado (razão de contraste ≥ 4,5:1).
7. **Clique direito no combate** (`app.py`, `combat_view.py`): botão 3 cancela a carta selecionada e a mira; sem carta selecionada não faz nada.

## Testes
`tests/ui/test_scroll.py` (recorte, limites, roda), `tests/ui/test_layout_audit.py` (auditoria nas duas resoluções), `tests/ui/test_shop_tooltip.py`, `tests/ui/test_dice_contrast.py`, `tests/ui/test_combat_right_click.py`.
