---
id: "SPEC-085"
type: "spec"
title: "Abas que deslizam: catálogo e conquistas sem estourar a tela"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-015-observacoes-v0.11.0-strafe-minimapa-dano-abas-2026-09-20]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
sources:
  - "Responsável, 2026-09-20: 'crie as specs fazendo as mudanças' (item 4 do PLAN-015: as abas passam da tela; slide de clicar e arrastar). Decisão D6 pela recomendação"
---

# Abas que deslizam

## Problema
A fileira do "Catálogo e conquistas" tinha 6 abas x (200 + 12 px) = 1272 px num painel de 1180 px: a última, "Conquistas", saía do painel e da tela.

## O que muda
Componente novo `game/ui/tab_strip.py` (`TabStrip`), usado pelo catálogo:
- A fileira é recortada na largura do painel (1132 px) e **desliza** por **arraste** (clicar e arrastar), **roda do mouse** e **setas ‹ ›**.
- Um clique curto (até 6 px de movimento) troca a aba, **na soltura do botão**; um arraste não troca.
- As setas e um esmaecido só aparecem nas pontas onde há mais abas escondidas; com poucas abas nada desliza.
- A aba ativa entra sempre na área visível (ao abrir, ao clicar e ao trocar por teclado).
- Teclado no catálogo: ←/→ (ou Q/E) e Tab trocam de aba, com volta.
- Só o catálogo usa por enquanto. A loja (2 abas) e o menu Equipamento (5) cabem; o Equipamento passa a precisar dele com mais personagens.

## Fora
Inércia do arraste; rolagem do painel de conquistas (linhas fixas, precisa da mesma lógica quando passar de 4 conquistas); arrastar em telas de toque.

## Testes
`tests/ui/test_tab_strip.py`: sem estouro nada desliza; as 6 abas do catálogo passam do painel e a fileira fica dentro dele; clique x arraste (limiar); limites do arraste;
roda e setas; setas só onde há mais; a aba ativa fica visível; passo com volta; desenho recortado que restaura o clip; catálogo alcança a última aba por clique, arraste e teclado.
