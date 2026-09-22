---
id: "SPEC-015"
type: "spec"
title: "Atordoamento (estado do inimigo), Atordoar do Maelor e Onda Psiônica do Durvall"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-014-combate-com-multiplos-inimigos]]"
sources:
  - "Pedido do responsável em 2026-09-19: completar o baralho do Maelor com Golpe Contundente e uma carta de atordoamento; recomendação de ataque em área para o Durvall (escolhidas: Atordoar sem teste, HC; Onda Psiônica)"
---

# Atordoamento e Onda Psiônica

## Atordoamento (novo estado do inimigo)

- `Enemy.stunned`: o inimigo **perde o próximo ataque**. O estado é **consumido** no
  turno dele (uma vez), então dura exatamente um ataque.
- Um inimigo atordoado **não gasta turno**: `turns_taken` (ciclo do ataque especial) não avança.
- No turno inimigo, o atordoado mostra "X está atordoado e perde o ataque" e passa a vez;
  os demais atacam normalmente (SPEC-014). Vale igual contra o chefe.
- Sem teste de acerto. A carta avança a Corrente como qualquer outra jogada.
- UI: etiqueta "ATORDOADO" sob o inimigo; flutuante "Atordoado!" ao aplicar; linha no log F12.

## Atordoar (Maelor)

Azul · `kind="atordoamento"` (alvo único, linha de mira) · Ação · **HC** (1 cópia, 1 uso por
combate, SPEC-009) · "o alvo perde o próximo ataque". Mantém a Corrente Azul.

## Golpe Contundente (Maelor)

Vermelho · ataque · 1d4 · Ação · 1 cópia. Acerto com Força contra a CA. A Força já escala o
dano via SIS-001 (+20% por ponto de modificador); com FOR 10 o Maelor tem +0%, e Vermelho é
fora da cor da classe (50%) e **quebra a Corrente** Azul/fogo — é uma jogada de emergência.

## Onda Psiônica (Durvall)

Amarelo · ataque em **área** · 2d6 · Ação · **HC** (1 cópia, 1 uso por combate). Um d20 por
inimigo vivo contra a CAM com INT; 50% de dano (fora da cor Vermelha); **quebra a Corrente
vermelha**. Baralho do Durvall de 15 para **16** cartas.

## Baralho do Maelor: 13 cartas

Chama Sagrada ×4, Chama Menor ×2, Toque Curativo (HC), Névoa Fria, Golpe Contundente,
Atordoar (HC), Bola de Fogo (HC), Palavra Curativa (HC), Poção de Cura.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | Cartas novas; `kind="atordoamento"` é de alvo único; baralhos de 16 e 13. **Mudança de core.** |
| `game/core/enemies.py` | `Enemy.stunned`. |
| `game/core/combat.py` | `resolve_stun`. |
| `game/app.py` / `game/ui/` | Aplicar o atordoamento, pular o ataque, etiqueta "ATORDOADO", log F12. |
| Testes | Atordoado pula 1 ataque e o ciclo especial não avança; Onda Psiônica em área, CAM/INT, quebra a Corrente; deck do Durvall com 16 e do Maelor com 13. |

## Fora do escopo

Arte das cartas novas; atordoamento por teste, com duração maior ou empilhável; resistência do chefe.
