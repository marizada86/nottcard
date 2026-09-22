---
id: "SPEC-030"
type: "spec"
title: "Layouts de carta: dez layouts de teste, escolha opcional"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[ART-001-pacotes-de-arte-de-carta-e-titulos]]"
  - "[[SPEC-017-arte-final-no-jogo]]"
sources:
  - "Responsável, 2026-09-19: layout opcional, salvo para as tentativas seguintes; 10 layouts para teste; temas à escolha da IA"
---

# Layouts de carta

Um **layout** é o corpo da carta: fundo, moldura, ornamentos e cor do texto. Nome, atributos, dano e texto da
carta não mudam. A cor da classe continua mandando no fundo; cada layout só a reinterpreta.

## Escopo

**Entra:** dez layouts de teste, todos liberados; seletor opcional na tela de seleção de personagem;
escolha que vale para as tentativas seguintes.
**Fica de fora (fase da loja):** moeda, preço, títulos, compra e bloqueio de layouts.

## Os dez layouts

Clássico (o de sempre, padrão), Pergaminho, Obsidiana, Vitral, Ferro Rúnico, Néon, Papel Recortado, Bosque,
Brasa, Gelo. Cada um é um dado (`CardLayout`) em `game/ui/card_layouts.py`: mistura/degradê do fundo, borda,
moldura interna, cantos, brilho, janela da arte e cores do texto.

## Regras

- O layout muda só o desenho. Seleção, descarte e escurecimento seguem legíveis em qualquer layout: a borda
  de seleção/descarte sobrepõe a do layout.
- Vale na mão, no painel de detalhe e na escolha da Comunhão (mesmo desenho). O catálogo mostra as cartas com
  o layout escolhido; a silhueta de carta bloqueada não muda.
- **Escolha opcional:** o painel abre pelo botão "Layout das cartas" no menu principal, na seleção de
  personagem e na tela de resultado; sem mexer nele, vale o Clássico. O painel mostra os dez numa carta de exemplo; clicar escolhe (o painel fica aberto pra
  comparar), Esc ou "Fechar" fecham.
- **Persistência:** a escolha fica no `App` e sobrevive a novas tentativas e a "Novo jogo" (é gosto, não
  progresso). Como o save (SPEC-023), some ao fechar o `.exe`.
- Id de layout desconhecido cai no Clássico.
- **Arte por layout (opcional):** se existir `assets/cards/<layout>/<id>.png`, a carta usa essa ilustração
  naquele layout; senão a padrão; senão o retângulo com o nome. Nenhum layout traz arte própria ainda.

### Ponto de troca para a loja

Hoje todos os layouts estão liberados. A fase da loja restringe o que o seletor oferece e o que
`set_card_layout` aceita; o desenho não muda.

## Arquivos

| Arquivo | Mudança |
|---|---|
| `game/ui/card_layouts.py` (novo) | `CardLayout`, os dez layouts, layout ativo, `draw_frame`, `draw_art_frame`. |
| `game/ui/layout_picker.py` (novo) | Painel do seletor. |
| `game/ui/cards_widget.py` | `_draw_card`, `draw_card_detail` e `draw_card_scaled` usam o layout (`draw_card_scaled` aceita `layout=` para o seletor). |
| `game/ui/assets.py` | `load_image(..., pack="")` com fallback pacote → padrão → retângulo; o cache inclui o pacote. |
| `game/app.py` | `App.card_layout`, `set_card_layout`, `open_layout_picker`; painel como sobreposição do `App`; botões no menu, na seleção e no resultado. |
| `tests/ui/test_card_layouts.py` | Dez layouts, fallback, todos os estados de desenho, borda de seleção, arte por pacote, seletor, persistência. |

## Critérios de aceite

- [x] Dez layouts distintos, o Clássico igual ao desenho anterior.
- [x] Escolha opcional, mantida entre tentativas e após "Novo jogo".
- [x] Seleção, descarte e escurecimento legíveis em todos os layouts (teste dos estados).
- [x] `core` sem mudança e sem import de pygame.
- [x] 555 testes passam.
- [x] Aprovação do responsável em 2026-09-19 (implementada antes da aprovação formal, a pedido direto).
- [ ] Playtest: legibilidade dos layouts claros (Pergaminho, Papel Recortado, Gelo) e dos escuros em combate.
- [ ] Build do `.exe` conferido.
