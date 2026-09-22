---
id: "SPEC-108"
type: "spec"
title: "Retirar o modo clássico (portas): só a caminhada em primeira pessoa"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[SPEC-057]]"
  - "[[SPEC-053]]"
sources:
  - "Responsável, 2026-09-21: retirar o modo clássico; deixar apenas o modo padrão do jogo, com o first person"
---

# Só a caminhada

- Some a opção "Exploração: caminhada/portas" do menu, `App.explore_mode`, `toggle_explore_mode` e `profile.exploration`/`set_exploration`.
  Um `perfil.json` antigo com `"exploracao": "classica"` é lido sem erro e a chave é ignorada (e não é mais gravada).
- `MapaScreen` (exploração por portas) é removida; `open_exploration` abre sempre a `WalkScreen`.
- Eventos pendentes da sala não abrem na entrada: são marcadores na sala (comportamento da caminhada).
- Fica o mapa de nós (`NodeMapScreen`, visão de orientação) e `move_to_node`, usado pela caminhada ao cruzar a soleira.
- Os testes que dirigiam o fluxo pelas portas passam a usar `move_to_node` e a `WalkScreen`.

## Testes
Perfil antigo com `exploracao: classica` abre a caminhada; o menu não tem o botão; `open_exploration` sempre devolve `WalkScreen`.
