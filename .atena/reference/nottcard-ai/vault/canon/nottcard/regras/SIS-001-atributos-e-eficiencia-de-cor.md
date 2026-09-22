---
id: "SIS-001"
type: "sistema-mecanico"
title: "Atributos de personagem e escala de eficiência por cor"
status: "canon"
created: "2026-09-14"
relations:
  - "[[VSN-002-fichas-jogaveis-elenco]]"
sources:
  - "Declaração do responsável pelo projeto em 2026-09-14"
---

# Atributos de personagem e escala de eficiência por cor

## Regra

Todo personagem jogável tem 4 atributos, um por família/cor de carta:

| Atributo | Família de carta | Cor |
|---|---|---|
| Força | Dano Físico | Vermelho |
| Inteligência | Dano Mágico | Amarelo |
| Constituição | Suporte | Azul |
| Carisma | Universal | Roxo |

O bônus é calculado sobre o **modificador do atributo, no padrão D&D 2024** (`modificador = piso((valor - 10) / 2)`), não sobre o valor bruto. Cada ponto de modificador dá +20% de eficiência das cartas daquela cor quando usadas por esse personagem.

| Valor do atributo | Modificador | Bônus de eficiência |
|---|---|---|
| 10-11 | +0 | +0% |
| 12-13 | +1 | +20% |
| 14-15 | +2 | +40% |
| 16-17 | +3 | +60% |
| 18-19 | +4 | +80% |
| 20 | +5 | +100% |

Confirmado pelo responsável do projeto em 2026-09-14 — escala de modificador, não de valor bruto.

## Atributos do elenco aprovado

| Personagem | Força | Inteligência | Constituição | Carisma | Cor de carta (atributo principal) |
|---|---|---|---|---|---|
| Kayron | 12 (+20%) | 12 (+20%) | 12 (+20%) | **14 (+40%)** | Roxo — Universal |
| Durvall | **16 (+60%)** | 14 (+40%) | 12 (+20%) | 10 (+0%) | Vermelho — Dano Físico |
| Sylas Malafa | 10 (+0%) | **16 (+60%)** | 14 (+40%) | 12 (+20%) | Amarelo — Dano Mágico |
| Maelor Menezes | 10 (+0%) | 13 (+20%) | **16 (+60%)** | 12 (+20%) | Azul — Suporte |

Kayron foi definido diretamente pelo responsável do projeto em 2026-09-14. Durvall, Sylas e Maelor foram propostos por Claude a partir da lore de cada um (força física/estudo psiônico do Durvall, intelecto/controle do Sylas, devoção/suporte do Maelor), mantendo o atributo principal alinhado à cor de carta já aprovada de cada personagem — pendentes de ajuste do responsável do projeto.

## Pendências

- Interação desta regra com a "Regra de compatibilidade" (carta sem classe compatível opera a 50%) e com a "Corrente de classe" (combo 2x/3x/4x) ainda não está formalizada — presume-se que os efeitos se acumulam, mas a ordem de aplicação não foi definida.
- Teto de atributo (D&D 2024 usa 20 como máximo padrão) não foi confirmado para este jogo.
- Atributos abaixo de 10 (modificador negativo) ainda não foram usados nem decididos — todos os valores propostos até agora ficam em 10 ou acima para evitar assumir se a eficiência pode ficar negativa.

## Nota de 2026-09-20 (SPEC-044, H2): o atributo virou modificador flat

No playtest da v0.6.0, o Higor (game designer) mostrou que o exemplo dele (dado 6, x1, +3 de Força, +1d4 = 10) só bate se o
atributo for **flat**. A regra "+20% por ponto" acima passa a valer assim no jogo: `dano_carta = ceil(dado × Corrente × compat) +
modificador`, uma vez por carta, **fora** da Corrente, **inteiro** fora da cor (só o dado é cortado pela compatibilidade), sem
dobrar no crítico (que dobra os dados), com mínimo de 1 ao acertar. A eficiência de cor (cartas fora da cor valem 50%) **não muda**.
As colunas "+X%" das tabelas acima são o histórico do desenho antigo; o valor que vale é a coluna do modificador.
