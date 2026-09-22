---
id: "SPEC-107"
type: "spec"
title: "Escolha de pergaminho: carta com a face limpa"
status: "draft"
created: "2026-09-21"
relations:
  - "[[SPEC-039]]"
sources:
  - "Responsável, 2026-09-21: na escolha da carta temporária as cartas não devem aparecer do jeito que são; jeito padrão, completando o layout da página. Escolhido: carta padrão, só a face"
---

# Face limpa na escolha de pergaminho

Problema: `draw_card_scaled` desenha a carta com `note=True`, então na escolha de pergaminho a arte fica coberta pela nota (cortada com "…") e
pelas etiquetas PERGAMINHO / USO ÚNICO, e o efeito aparece de novo abaixo da moldura.

- `draw_card_scaled` ganha `note: bool = True` (padrão igual ao de hoje: mão, baralho e catálogo não mudam).
- Com `note=False`, `_draw_card` não desenha a faixa de nota nem as etiquetas PERGAMINHO/USO ÚNICO sobre a arte.
- `ChooseCardScreen`, na oferta de pergaminho (`card.scroll`), desenha a face com `note=False`. Pacote e chefe seguem como estão.
- Abaixo da moldura: linha de etiquetas "Pergaminho · Uso único" no lugar da raridade, e o efeito por inteiro (sem cortar).
- Todo efeito de pergaminho cabe acima dos botões (`notes_bottom`); o cartão não fica desalinhado dos outros.
- Nenhuma regra na UI.

## Testes
`tests/ui/`: a face do pergaminho é desenhada sem nota; todos os pergaminhos cabem na área de texto; `notes_bottom` acima dos botões; pacote e chefe
inalterados.
