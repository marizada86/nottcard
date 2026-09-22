---
id: "SPEC-044"
type: "spec"
title: "Ajustes do playtest v0.6.0: fórmula do atributo, psiônico fixo, Sylas, pilhas clicáveis e linha do nome"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SPEC-008-ajustes-pos-playtest-evid-003]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-022-passiva-de-classe-em-destaque]]"
  - "[[SPEC-025-corrente-quebra-no-erro-e-ajustes-durvall-maelor]]"
  - "[[SPEC-038-sylas-malafa-clerigo-das-sombras]]"
sources:
  - "Higor (game designer), 2026-09-19, playtest da v0.6.0: H1, H2, H3, H9 e H10 (FB-002). As notas do Higor têm prioridade"
---

# Ajustes do playtest v0.6.0

> **Aprovada pelo responsável em 2026-09-20** (`execution_approval: per-spec`). É a "SPEC-008 desta rodada":
> só corrige o que o Higor viu no playtest, sem trazer mecânica nova. Os números são o primeiro palpite e
> **fecham depois do simulador** (seção 7). Cada item vem com o id da nota do Higor (H1...).

## 1. Escopo

**Entra:** H1 (linha do "?" sobre CA/CAM), H2 (o atributo vira modificador flat), H9 (o psiônico do Durvall fixo em
1d4), H3 (pilhas de compra e descarte clicáveis), H10 (Sylas: Corrente e Cópia), e o simulador de combate para
medir tudo isso.
**Fica de fora:** loja de upgrades e regras de baralho (`SPEC-045`), falha crítica e Sorte (`SPEC-046`),
equipamento (`SPEC-047`), tasks (`SPEC-048`), primeira pessoa (`SPEC-049`). Kayron não muda (H11).

## 2. H1: a linha do "?" cobre "CA · CAM"

- **Causa:** `name_hint` (`game/ui/passive_card.py`) desenha um sublinhado de 2 px em `name_rect.bottom + 1`, e o
  `draw_player_panel` (`game/ui/hud.py`) põe "CA x · CAM y" em `y + ORB_RADIUS + 34`, quase no mesmo ponto. O
  sublinhado passa por cima do texto.
- **Correção:** tirar o sublinhado (o "?" em círculo já diz que o nome é clicável; o nome acende quando o mouse
  está em cima) e descer "CA · CAM" e "Nível" 8 px. Nada de regra.
- **Aceite:** o retângulo do nome, o da dica e o de "CA · CAM" não se cruzam, para nomes curtos e longos ("Sylas
  Malafa"), com e sem "Nível".

## 3. H2: o atributo entra como modificador flat

**Hoje** (`combat._attack_outcome`, `resolve_control`): `ceil(dado × Corrente × compat × (1 + 0,2 × modificador))`. O
atributo entra como **percentual**, que cresce com a Corrente. O exemplo do Higor (6 de dado x1, +3 de Força,
+1d4 = 10; o jogo deu 11) só bate se o atributo for **flat**.

**Nova regra (ataque):**

```
dano_carta = ceil(dado_base × Corrente × compat) + modificador
```

- `modificador` = o modificador do atributo da cor da carta (`COLOR_ATTRIBUTE`: Força para Vermelho, Inteligência
  para Amarelo, Constituição para Azul, Carisma para Roxo), **uma vez por carta** e **fora da Corrente**.
- **Fora da cor** (`compat = 0,5`): só o dado é cortado; o modificador entra **inteiro**.
- **Crítico** (20 natural): dobra a quantidade de **dados**; o modificador **não** dobra.
- **Modificador negativo:** soma como negativo, e um ataque que acerta causa **no mínimo 1** de dano.
- **Errar** não causa dano (nada muda).
- Depois vêm o dado psiônico (seção 4), o bônus místico do Kayron e o multiplicador de pergaminho (que continua
  sem bônus de atributo: `card.scroll` ignora o modificador, como hoje ignora o percentual).

**Controle** (Névoa Fria, Escuridão, Ruído Mental...): `reducao = ceil(dado × Corrente × compat × fator_de_area) +
modificador`, mínimo 1. **Cura** não muda (já usa `modifier_attr` flat, fora da Corrente).

**Efeito esperado** (Força +3, `Golpe` 1d8, média 4,5, cor da classe): Corrente x1 ~7,2 → ~7,5; x2 ~14,4 → ~12;
x3 ~21,6 → ~16,5; x4 ~28,8 → ~21. O corte cresce com a Corrente, que é onde o Higor sentiu o dano alto.

**Dados que mudam:**
- `AttackResult.attr_bonus` (float) vira `attr_flat` (int). `ControlResult.attr_bonus` idem.
- `CharacterDef.color_bonus` (percentual) sai; entra `CharacterDef.color_modifier(color)` (o modificador flat).
- O log dev (F12) e a legenda de dano passam a mostrar `ceil(dado × Corrente × cor) + atributo`, com o valor de
  cada parte (por exemplo, `ceil(6 × 1 × 1,0) + 3 Força = 9`).
- **Canon:** `SIS-001` diz "+20% por ponto"; a cópia local recebe uma nota datada da mudança e o nome do Higor. A
  eficiência de cor (cartas fora da cor valem 50%) **não muda**.

## 4. H9: o psiônico do Durvall fica em 1d4

- **Hoje:** `PSIONIC_DICE_BY_MULT = {1: 1d4, 2: 2d4, 3: 3d4, 4: 4d4}`, então o dado psiônico cresce com a Corrente.
- **Novo:** `1d4` em todos os níveis da Corrente (o mapa fica `{1: "1d4", 2: "1d4", 3: "1d4", 4: "1d4"}`, sem mexer
  no mecanismo `chain_bonus_dice`). Só o dado da carta é multiplicado. O crítico continua dobrando esse dado.
- O texto da passiva (cartão e tutorial) troca "1x = 1d4 | 2x = 2d4 | 3x = 3d4 | 4x = 4d4" por "cartas vermelhas
  na Corrente ganham +1d4 de dano psiônico". Os testes e o `tutorial_content` acompanham.
- **Efeito esperado:** Golpe em Corrente x4 cai de ~39 (28,8 + 4d4) para ~23,5 (18 + 3 + 1d4), somando o H2.

## 5. H3: pilhas de compra e descarte clicáveis

- **O que abre:** clicar no ícone do baralho (e no número) abre a lista **do que ainda pode ser comprado**; clicar
  no ícone do descarte abre a lista **do que foi descartado**. Só o personagem ativo (SPEC-037).
- **Ordem:** **nunca a ordem de compra.** As cartas aparecem **agrupadas por nome, com a quantidade** ("Golpe ×3"),
  em ordem alfabética. A carta do topo não é revelada (a Comunhão com Sendrinah continua sendo a única forma de olhar).
- **Seções:** "Baralho (N)" e "Descarte (N)"; em separado, "Gastas neste combate" (uso único e pergaminhos usados)
  e "Habilidades de classe usadas" (HC fora do baralho até o fim do combate), para o jogador entender por que a
  carta não volta.
- **Comportamento:** sobreposição no padrão do catálogo (`CollectionOverlay`): pausa o combate e o cronômetro do
  chefe, `Esc`, clique fora ou "Fechar" fecham; o mouse sobre uma linha mostra a carta ampliada (`draw_card_scaled`).
  Não abre durante a janela de reação nem no modo descarte (o clique é ignorado).
- **Onde ficam os cliques:** o retângulo do ícone mais o número (`draw_pile_counter` passa a devolver o `Rect`, para
  a tela e o teste usarem o mesmo).
- **Dados (core, sem pygame):** `Player.pile_view()` devolve `PileView(compra, descarte, gastas, hc)`, cada lista
  como `[(nome, quantidade)]`, ordenada por nome. É a única fonte da tela.

## 6. H10: Sylas, Corrente e Cópia

**Causas** (`characters.SYLAS`, `state.Player`):
1. `chain_elements=("sombra",)` mais a cor Amarelo faz **quase todas** as cartas contarem na Corrente (Raio, Lâmina,
   Toque e Farpa; Escuridão, Cegueira, Imagem Espelhada e Dominar Pessoa pelo elemento). Só a Poção quebra; a
   Corrente vive em x4.
2. Cada carta que avança a Corrente de x2 em diante cura a Cópia em +2, +3 ou +4 (`_on_chain_advance`), então a
   Cópia (10 PV) se recupera sozinha, e a Imagem Espelhada e a Sombra Persistente a trazem de volta.

**Mudanças (nesta ordem; a 6.3 só entra se a medição pedir):**

1. **Tag de elemento só no dano.** `CharacterDef.chain_element_kinds: tuple[str, ...] = ()` (novo): se preenchido,
   `counts_for_chain` só aceita o elemento em cartas desses tipos. Sylas: `("ataque",)`. Escuridão, Cegueira,
   Imagem Espelhada e Dominar Pessoa continuam funcionando, mas **quebram** a Corrente se jogadas no meio dela
   (a mesma regra de qualquer carta fora da cor). A Farpa Psiônica, Visão Verdadeira e Raio Enfraquecedor
   continuam contando (são Amarelas). Mantém "encadear sombra" sem a Corrente eterna.
2. **Cura da Cópia pela Corrente:** uma vez por turno, e só ao atingir **x3 ou x4** (cura de +3 ou +4). O flag
   `Player.clone_chain_healed` zera em `start_turn`. Imagem Espelhada e Toque Vampírico não mudam.
3. **(Condicional)** `CharacterDef.chain_cap` (novo, padrão 3 = x4): o Sylas pode ganhar 2 (= x3) se a medição
   ainda mostrar excesso. O campo existe desde já, mas nenhum personagem muda dele.

- O texto da passiva do Sylas troca "cartas de sombra também ativam a Corrente" por "cartas de dano de sombra
  também ativam a Corrente". `SPEC-038` recebe a nota da mudança.

## 7. Simulador de combate (`scripts/simulate.py`)

Para ajustar com número, não por palpite.
- **O que faz:** roda N combates (padrão 500) por personagem e nível (1 e 5) contra os inimigos do M1 (criatura,
  slime, guardião cópia, grupo do corredor e chefe), só com `game/core/` e sem janela. Política simples e fixa: joga a
  carta que mantém a Corrente, depois a de maior dano esperado, usa cura abaixo de 40% de PV e reage quando pode.
  Sementes fixas: o mesmo comando repete o mesmo resultado.
- **Saída** (tabela em markdown): turnos para vencer, dano por turno, PV perdidos, taxa de vitória, maior Corrente
  e, para o Sylas, a fração dos turnos com a Cópia viva.
- **Limite honesto:** é uma aproximação do laço do `App` (que é ligado à UI), então serve para **comparar antes e
  depois**, não como verdade absoluta. O playtest do Higor continua sendo o critério final.
- **Uso na spec:** rodar **antes** de mexer (baseline, guardado em `.atena/generated/SIM-baseline-2026-09-20.md`),
  depois de cada item e no fim.

## 8. Arquivos

| Arquivo | Mudança |
|---|---|
| `game/ui/passive_card.py`, `game/ui/hud.py` | H1: sem sublinhado; CA/CAM e Nível descem 8 px; `draw_pile_counter` devolve o `Rect` |
| `game/core/combat.py` | H2/H9: fórmula flat de ataque e controle; `attr_flat`; passiva do Durvall |
| `game/core/characters.py` | `color_modifier`, `chain_element_kinds`, `chain_cap`; `PSIONIC_DICE_BY_MULT`; texto das passivas |
| `game/core/state.py` | `pile_view()`; cura da Cópia uma vez por turno em x3/x4 |
| `game/ui/pile_overlay.py` (novo) | H3: sobreposição das pilhas |
| `game/ui/devlog.py`, `game/ui/tutorial_content.py` | contas e textos novos |
| `game/app.py` | cliques nos ícones das pilhas; pausa/retomada como a passiva |
| `scripts/simulate.py` (novo) | simulador |
| `.atena/vault/canon/nottcard/regras/SIS-001-...md` | nota datada do H2 |
| `tests/` | ver seção 9 |

## 9. Testes

- **Fórmula (tabela):** dado fixo × Corrente 1..4 × cor (dentro e fora) × modificador (−1, 0, +3) → o dano esperado;
  o crítico dobra só os dados; o mínimo de 1 ao acertar; o pergaminho continua sem modificador.
- **Exemplo do Higor:** 6 de dado, x1, Força +3, psiônico 1 → 9 + 1 (o teste fixa o dado e confere 10).
- **Psiônico:** 1d4 em x1..x4 para o Durvall; ninguém mais ganha psiônico.
- **Controle:** a redução usa o flat e o fator de área, com o mínimo de 1.
- **Sylas:** Escuridão/Cegueira/Imagem quebram uma Corrente em x2; a Farpa e o Raio a mantêm; a Cópia cura uma vez por
  turno e só em x3/x4; o flag zera no turno seguinte; os outros personagens não mudam (`chain_element_kinds` vazio).
- **Pilhas:** `pile_view` agrupado e em ordem alfabética, nunca na ordem da compra (embaralhar não muda a saída);
  pergaminhos, uso único e HC nas seções certas; o clique no ícone abre e pausa; o `Esc` fecha e retoma; ignorado em
  reação e descarte.
- **H1:** os retângulos do nome, da dica e de CA/CAM não se cruzam (nomes curtos e longos).
- **Simulador:** roda com semente fixa em poucos segundos e repete o resultado; smoke por personagem.
- Os testes existentes que citam `attr_bonus`, o percentual ou "2d4/3d4/4d4" mudam junto (esperado, não regressão).

## 10. Decisões pendentes (com a recomendação)

1. **Flat uma vez por carta e inteiro fora da cor** (recomendo sim). Alternativa: uma vez por dado.
2. **Modificador negativo** soma como negativo, com o mínimo de 1 ao acertar (recomendo sim).
3. **Sylas:** aplicar 6.1 e 6.2, medir e só então 6.3 (recomendo sim). Higor prefere começar por outra?
4. **Texto da passiva do Durvall** "+1d4 psiônico" (recomendo sim).
5. **Faixas-alvo do simulador** (por exemplo, "Sylas vence o chefe em X a Y turnos"): Higor fixa depois do baseline; até
   lá o aceite é "o Sylas deixa de ser o mais forte por larga margem e a Cópia não fica viva o combate todo".

## 11. Critérios de aceite

- [x] O exemplo do Higor (6 x 1 + 3 Força + 1d4) dá o resultado esperado e o log mostra a conta nova.
- [x] O atributo entra flat, uma vez por carta, fora da Corrente e sem dobrar no crítico; o pergaminho o ignora.
- [x] O psiônico do Durvall é 1d4 fixo em todas as Correntes; o texto da passiva foi atualizado.
- [x] O nome, o "?" e "CA · CAM" ficam legíveis, sem sobreposição.
- [x] Os ícones das pilhas abrem a lista agrupada e em ordem alfabética, sem a ordem de compra, e pausam o combate.
- [x] No Sylas, só cartas de dano de sombra mantêm a Corrente e a Cópia cura uma vez por turno em x3/x4.
- [x] O simulador roda com semente fixa; baseline e resultado final guardados em `.atena/generated/`.
- [x] `core` sem pygame; todos os testes passam (os que citam a fórmula antiga foram atualizados).
- [ ] (aguarda o playtest) Números registrados em EVID/task após o playtest do Higor (T-001 a T-005 da `SPEC-048`).

## 12. Ordem de execução

1. Simulador e baseline. 2. H1. 3. H2 (fórmula e log). 4. H9. 5. Medir. 6. H10 (6.1 e 6.2), medir. 7. H3. 8. Nota do canon,
tutorial e textos. 9. Playtest.

## Registro da implementação (2026-09-20)

- Feito conforme a spec. Simulador: baseline em `.atena/generated/SIM-baseline-2026-09-20.md` (código do commit 40b7a77) e resultado em
  `SIM-depois-2026-09-20.md` (500 combates por linha, semente fixa). Leitura: a política do simulador só joga ataque e cura, então
  ele quase não enxerga o efeito de H10 (a Cópia continua viva em 52 a 95% dos turnos; PV perdidos mudam pouco). **6.3 (`chain_cap`)
  não foi aplicado**: o campo existe, ninguém mudou dele. Decisão para o playtest do Higor.
- Sem palpite de faixa-alvo (decisão 5): aguarda o Higor.

## Review record

- Proposed by: Claude, a pedido do responsável em 2026-09-20 (notas do Higor de 2026-09-19).
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20 (sem alterações; decisões pendentes ficam com as recomendações).
