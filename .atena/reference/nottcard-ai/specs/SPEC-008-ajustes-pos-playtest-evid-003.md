---
id: "SPEC-008"
type: "spec"
title: "Ajustes pós-playtest EVID-003: d20 mais lento, dano grande, limite de Segundo Fôlego, orbe de vida"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-004-cadencia-do-combate]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
  - "[[EVID-003-playtest-turno-acerto-e-log-dev]]"
sources:
  - "EVID-003 §6 (ajustes pedidos pelo playtester/responsável em 2026-09-19)"
  - "Decisões do responsável em 2026-09-19: máx. 1 Segundo Fôlego na mão; barra de vida vira coração/orbe"
---

# Ajustes pós-playtest EVID-003

## Problema

O playtest do EVID-003 validou dificuldade, CA/CAM, tamanho/posição do log e
tamanho geral dos números. Pediu cinco ajustes pontuais, listados abaixo.
**Não muda balanceamento de CA/CAM nem chance de acerto.**

## 1. Decisões (responsável do projeto)

1. **d20 de acerto 0,4 s mais lento**, crítico continua mais demorado que o acerto normal:
   - acerto normal: 1,3 s → **1,7 s**
   - 20 natural (crítico): 1,8 s → **2,2 s**
   *(altera o §4 da SPEC-006; o dado de dano de 2,1 s não muda)*
2. **(Substituída pela SPEC-009: agora 1 cópia no baralho, HC.)** ~~Segundo Fôlego: no máximo 1 na mão.~~ O baralho continua com 2 cópias.
   Se uma cópia for comprada com outra já na mão, ela volta ao **fundo do
   baralho** e compra-se a próxima carta no lugar.
3. **Fonte do número de dano cresce com o valor:**
   - dano ≤ 9: tamanho atual
   - dano 10–19: fonte maior
   - dano ≥ 20: fonte maior ainda
   Vale para o número flutuante (SPEC-003). Cura e "Errou" não mudam.
4. **Barra de vida do Durvall vira coração/orbe estilo RPG**, menor, no canto
   inferior esquerdo perto da mão, com **PV atual/máx. em número legível dentro
   ou ao lado**. CA/CAM ficam junto dele.
5. Todo o resto do EVID-003 (log, CA/CAM dos inimigos, chance de acerto) fica como está.

## 2. Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/state.py` | Regra de compra: ao comprar Segundo Fôlego com outro já na mão, devolve ao fundo do baralho e compra outra (se só restar Segundo Fôlego, compra normal). **Mudança de core — precisa da sua aprovação.** |
| Cadência (`app.py`/`ui`) | Duração do d20 de acerto: 1,7 s / 2,2 s (constantes nomeadas, não números soltos). |
| `game/ui/` | Número flutuante escala por faixa (≤9, 10–19, ≥20). Orbe de vida no lugar da barra do Durvall; barra dos inimigos não muda. |
| `assets/` | Orbe/coração: fallback desenhado em código (círculo preenchido pela fração de PV) até existir arte; prompt de arte depois, se aprovado. |
| Testes | Nunca 2 Segundo Fôlego na mão; devolvido vai pro fundo; baralho só com Segundo Fôlego não trava; faixa de fonte por dano (9→normal, 10→maior, 19→maior, 20→maior ainda); constantes de duração. |

## 3. Decisões pendentes

- Fatores exatos da fonte (ex.: ×1,25 e ×1,5) — proposta inicial, ajustar no playtest.
- Orbe: enche de baixo pra cima com o líquido descendo conforme o PV cai (proposta), ou só cor por faixa de PV.

## 4. Fora do escopo

Mudar CA/CAM, bônus de ataque, PV de inimigo, layout do log, novas mecânicas (Vantagem/Desvantagem, testes de morte etc. — spec própria).

## 5. Critérios de aceite

- [x] d20 normal dura ~1,7 s e crítico ~2,2 s.
- [ ] Nunca há dois Segundo Fôlego na mão ao mesmo tempo.
- [x] Dano 10–19 e ≥20 aparecem em fontes progressivamente maiores.
- [ ] O PV do Durvall aparece num orbe perto da mão, com o número legível.
- [ ] Nada mais muda no comportamento dos combates.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Abertos: nunca dois Segundo Fôlego na mão (sem teste); o orbe de PV foi substituído pelo trilho direito (SPEC-016); "nada mais muda" não é verificável hoje.
