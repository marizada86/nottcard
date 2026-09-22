---
id: "SPEC-101"
type: "spec"
title: "Tela Baralho: detalhes da carta ao passar o mouse"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
sources:
  - "Responsável, 2026-09-21: mostrar detalhes ao passar o mouse nas cartas de 'Baralho' no menu inicial"
---

# Hover no Baralho

- Em `deck_screen.py` (aberta pelo menu inicial, pela Loja e pelo resultado), passar o mouse numa carta da lista do baralho ou da coleção mostra a **carta
  ampliada**, com o desenho de `cards_widget` usado no combate: nome, cor, raridade, dados, nota completa e ícones de ação/reação/uso único.
- Posição ao lado do cursor, sem sair da janela; some ao tirar o mouse. Não altera os cliques (adicionar/remover/trocar seguem iguais).
- Cartas do núcleo (travadas) também mostram, com o selo "núcleo".
- Reaproveitar o widget de hover do combate; nenhuma regra na UI.

## Testes
`tests/ui/test_deck_screen.py`: hover sobre uma carta define a carta em destaque; o desenho não falha com nenhuma carta do catálogo; sair do item limpa o destaque.
