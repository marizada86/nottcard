---
id: "SPEC-087"
type: "spec"
title: "Frequência dos eventos com garantia na 3ª missão e a conquista \"O infeliz\""
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-074-motor-de-eventos-aleatorios]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-046-falha-critica-e-sorte]]"
sources:
  - "Higor, playtest da v0.11.0 (Hiago), 2026-09-20: itens 3 e 4"
  - "Responsável, 2026-09-20: item 4 conta só os testes de d20"
---

# Frequência dos eventos e "O infeliz"

> Aprovada pelo responsável em 2026-09-20 (`execution_approval: per-spec`). Altera números e a regra da SPEC-074 §1.

## 1. Chance de evento (item 3)
Números novos em `event_data.py` (o arquivo de ajuste do Higor):

| Constante | Hoje | Passa a ser |
|---|---|---|
| `BASE_CHANCE` | 0,25 | **0,30** |
| `PITY_STEP` | 0,10 | 0,10 |
| `CHANCE_CAP` | 0,75 | 0,75 (vale só até a garantia) |
| `PITY_GUARANTEE` (novo) | — | **2** |

**Garantia:** com `event_pity >= 2` (duas missões seguidas sem evento) a chance da próxima é **100%**. Ou seja: 30% na 1ª, 40% na 2ª e **obrigatório na 3ª**. Média estimada: 1 evento a cada ~2,1 missões (hoje ~2,4). A chance de um 2º evento (10%) não muda.

## 2. Só conta o evento que o jogador viu
`next_pity` hoje zera com `bool(event_plan)`: um evento sorteado e nunca alcançado (morte antes da sala, desistência) também zera a proteção, o que derrubava o ritmo real.
**Passa a ser:** `event_pity` zera só se **pelo menos um evento foi aberto** na missão (`events_resolved` não vazio, ou evento aberto e interrompido por derrota). Senão sobe. A garantia da §1 usa esse mesmo contador.

## 3. Devlog e simulador
- O devlog registra "chance 1,00 (garantia)" quando a garantia vale.
- `scripts/simulate_events.py` passa a simular também a fração de eventos **vistos** (parâmetro `--reach` = chance de o jogador chegar à sala do evento, padrão 0,8) e imprime o intervalo médio entre eventos vistos.

## 4. Conquista "O infeliz" (item 4)
- **Condição:** tirar **3 naturais "1"** (`natural == "1"`) em testes de **d20 de exploração/eventos** (`resolve_check`) numa mesma missão. Combate **não conta** (decisão do responsável). Vale o d20 mantido (`natural`), não o descartado da desvantagem.
- **Benefício permanente:** **+1 uso de Sorte por missão** para **todos** os personagens (`Player.luck`, `state.py`), pela mesma via dos benefícios: `benefit_key = EXTRA_LUCK` em `achievements.py`, lido por `has_benefit` e somado em `Player.for_character` junto de `LUCK_BASE`, dos níveis e do upgrade Sorte.
- **Contagem:** novo campo `RunStats.natural_ones` (soma em `resolve_check`/`reroll_with_luck` quando o resultado válido é 1 natural). A regra de "a mesma missão" reinicia em cada tentativa como `crits`.
- Nome: **"O infeliz"**. Descrição: "Tire 3 dados '1' em testes de d20 na mesma missão." Benefício: "+1 uso de Sorte por missão, para todos os personagens."
- Entra no catálogo de conquistas, no `unlock_all` do cheat (Ctrl+O+P) e no guia do playtester. O save antigo carrega (conquista simplesmente ausente).

## 5. Testes
- `roll_plan`/`chance`: 0,30, 0,40 e 1,00 nas três primeiras missões sem evento; segundo evento a 10%; frequência média em 100 mil missões entre 0,44 e 0,52.
- `next_pity`: evento aberto zera; sorteado e não visto sobe; garantia só cai quando um evento é visto.
- "O infeliz": 3 naturais 1 em testes de exploração conquistam; 2 não; 1 natural no combate não conta; +1 Sorte em todos os personagens na missão seguinte; não acumula em duplicidade; o save antigo carrega.

## Fora do escopo
A Sorte puxando a chance do evento (segue adiada na SPEC-074). Novos tipos de evento e visibilidade do sorteio (assunto do plano de eventos, separado).
