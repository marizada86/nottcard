---
id: "SPEC-025"
type: "spec"
title: "Corrente quebra ao errar; sem Passar a Ação; psiônico do Durvall 1d4..4d4; Chama Sagrada e Luz Reveladora"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-021-rebalanceamento-chama-nevoa-e-golpe-contundente]]"
  - "[[SPEC-020-mao-cheia-descarte-por-escolha-e-acao-compra-2]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
sources:
  - "Playtest do Higor, 2026-09-19 (pedido direto do responsável)"
---

# Ajustes do playtest do Higor

Números são valores iniciais de playtest, ajustáveis sem nova spec.

## Regras

1. **Corrente quebra no erro.** Ataque que erra o teste de acerto quebra a Corrente (streak = 0).
   Carta de área só quebra se errar **todos** os alvos. Golpe Contundente que acerta mas **falha no
   teste de atordoamento** também quebra a Corrente. (Antes: errar avançava a Corrente.)
2. **Sem "Passar a Ação (0)".** Botão, tecla e `_pass_action` saem do combate. "Comprar 2 cartas
   (Ação)" e "Encerrar turno" cobrem o caso.
3. **Psiônico do Durvall:** toda carta que conta na Corrente soma dados psiônicos d4 pelo multiplicador:
   1x = 1d4 | 2x = 2d4 | 3x = 3d4 | 4x = 4d4 (antes: 2x=1d6, 3x=2d6, 4x=3d6). Não vale pra cartas
   fora da Corrente. Crítico dobra a quantidade de dados, como antes.
4. **Maelor:**
   - Chama Sagrada: 1d4, fogo + radiante, **não ignora mais CAM** (`ignores_cam` removido da carta).
   - Nova carta Azul **Luz Reveladora** (Ação, 1 cópia, alvo único): CA e CAM do alvo −2 até o fim do
     combate, acumulando até −4 cada. Baralho do Maelor: 13 cartas.

## Critérios de aceite

- [x] Erro de ataque e falha no teste de atordoamento quebram a Corrente.
- [x] Sem botão/tecla de passar a Ação.
- [x] Psiônico 1d4×mult do Durvall.
- [x] Chama Sagrada sem `ignores_cam`; Luz Reveladora no baralho do Maelor.
- [ ] Playtest.
