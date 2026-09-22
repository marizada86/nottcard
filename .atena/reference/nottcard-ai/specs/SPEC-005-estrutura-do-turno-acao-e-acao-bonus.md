---
id: "SPEC-005"
type: "spec"
title: "Estrutura do turno: Ação, Ação Bônus, Surto de Ação e cartas de uso único"
status: "approved"
created: "2026-09-18"
reviewed: "2026-09-18"
relations:
  - "[[SPEC-001-porte-m1-solo-pygame]]"
  - "[[SPEC-004-cadencia-do-combate]]"
  - "[[EVID-002-playtest-dados-3d-e-cadencia]]"
  - "[[PERS-durvall-ficha-jogavel]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
sources:
  - "Pedido do responsável em 2026-09-18: cartas de Ação Bônus; encerrar o turno ao usar a Ação atrapalha a ordem de execução"
  - "Decisões do responsável em 2026-09-18 (ver §1): Bônus disputado, fim automático, Corrente conta Bônus, e as 3 cartas (Surto de Ação, Segundo Fôlego, poção de uso único)"
  - ".atena/specs/nottcard/SPEC-001-vertical-slice-m1-solo.md (Ação Bônus opcional; chefe perde a Ação por timeout, o Bônus continua; baralho inicial de 12 cartas)"
  - ".atena/vault/canon/nottcard/personagens/PERS-durvall-ficha-jogavel.md (Constituição 12, mod +1)"
  - "game/app.py (hoje: jogar qualquer carta chama o turno do inimigo na hora)"
---

# Estrutura do turno: Ação, Ação Bônus, Surto de Ação e cartas de uso único

## Problema

Hoje jogar uma carta (ou "Passar a Ação") **encerra o turno na hora** e
dispara o inimigo. A "Ação Bônus" existe só como botão que compra 1 carta,
sem relação com cartas. Com cartas de Ação Bônus isso quebra: o jogador não
consegue escolher a **ordem** (Bônus → Ação ou Ação → Bônus), e a ordem
importa porque cada carta jogada avança a Corrente de Classe.

## Declaração proposta

O turno tem **uma Ação e uma Ação Bônus**, gastas **em qualquer ordem**. O
turno passa pro inimigo **sozinho quando os dois espaços foram gastos**, ou
quando o jogador clica em **"Encerrar turno"**. Referência de design: a
economia de ações do D&D ("uma homenagem ao DnD", playtester Higor).

## 1. Decisões já tomadas (responsável do projeto, 2026-09-18)

1. **O Bônus é um espaço único**, disputado entre **"comprar 1 carta"** e
   **uma carta de Ação Bônus** — só um dos dois por turno.
2. **O turno passa sozinho** quando os dois espaços foram gastos.
3. **A Corrente de Classe conta as cartas de Bônus** na ordem real de jogo.
4. **Três cartas** (ver §3).
5. **Surto de Ação é ROXO** (Vermelho facilitaria demais os combos: a Corrente é de cartas Vermelhas seguidas, e uma carta Roxa **quebra** a Corrente — então usar Bônus roxo antes dos ataques vermelhos é uma escolha de ordem com custo).
6. **Baralho inicial: 12 → 14 cartas** (1 Surto de Ação + 1 Poção), para testar a mecânica. Muda a base canônica de 12 cartas; como obter como raridade/recompensa fica para depois.
7. **Poção:** 1d4 **fixo** + **modificador de Constituição do personagem** (Durvall: +1). Uso único: **descartada para sempre** naquela tentativa; só volta ao **conquistar outra numa sala** ou ao **iniciar uma nova tentativa**.
8. **Cartas equipáveis** (Ação ou Bônus): fica para depois.

## 2. Regras do turno

1. **Uma Ação por turno**: toda carta que não é de Ação Bônus consome a Ação.
2. **Uma Ação Bônus por turno**: consumida por uma carta de Ação Bônus **ou** por "comprar 1 carta".
3. **Qualquer ordem** entre Ação e Bônus.
4. **Fim do turno**: automático quando **Ação e Bônus** estão gastos; manual pelo botão **"Encerrar turno"** a qualquer momento. **"Passar a Ação"** gasta só a Ação (não encerra).
5. **Ação extra (Surto de Ação)**: uma carta pode **conceder +1 Ação neste turno**. A Ação extra pode ser usada mesmo se a Ação normal já foi gasta. O turno só passa sozinho quando **não resta Ação (normal ou extra) e o Bônus está gasto**.
6. **Corrente de Classe** avança pela ordem real de jogo (Ação e Bônus).
7. **Cronômetro do chefe (45 s)** vale só pra decisão da Ação; se esgotar, perde a Ação e o Bônus segue livre (canon `SPEC-001` nottcard §8).
8. **Mão/compra** inalterados (compra 1 no início do turno, máximo 5, excedente descartado **ao fim do turno**).
9. **Turno do inimigo** só começa depois do fim do turno; a sequência de batidas (SPEC-004) não muda.

## 3. As três cartas

| Carta | Tipo de ação | Efeito | Observações |
|---|---|---|---|
| **Surto de Ação** (rara) | Ação Bônus | Concede **1 Ação extra** no turno. Não causa dano nem cura por si. | **Roxa.** 1 cópia no baralho inicial (teste). Como vira recompensa rara: depois. |
| **Segundo Fôlego** (já existe, Roxo, cura 1d4, 2 no baralho) | **passa de Ação para Ação Bônus** | Mesmo efeito de hoje: cura 1d4. | Só muda o `action_type`. |
| **Poção** (nova, **uso único**) | Ação Bônus | Cura **1d4 (fixo) + modificador de Constituição do personagem** (Durvall: Constituição 12 → mod **+1**, valor do canon `PERS-durvall`). | **Roxa.** Depois de usada é **removida para sempre** naquela tentativa (não vai pro descarte nem volta ao embaralhar); volta ao conquistar outra numa sala (recompensa de sala: fora do escopo desta spec) ou ao iniciar nova tentativa. Nome provisório: "Poção de Cura". |

Notas:
- A poção soma o modificador **fixo**, não o bônus de eficiência de cor (`SIS-001` aplica eficiência às cartas *da cor do atributo*; a poção é Roxa e o efeito é explicitamente "1d4 + Constituição").
- O modificador vem do canon (Constituição 12 → +1); o core guarda os atributos do personagem (`Player.attributes`) e calcula `piso((valor − 10) / 2)`, como `SIS-001`.
- **O dado mostrado na rolagem é só o 1d4**; o modificador soma depois e aparece como número separado.
- **Mecânica "uso único"** (`exhaust`): carta marcada é movida pra uma pilha `exhausted` do jogador e nunca mais é comprada naquela tentativa.

## 4. Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/cards.py` | `Card` ganha `action_type: "acao" \| "bonus"` (padrão `"acao"`), `single_use: bool = False` e um efeito de `grants_action: int = 0`. Novas cartas Surto de Ação e Poção; Segundo Fôlego passa a `action_type="bonus"`. **Mudança de core — precisa da sua aprovação.** |
| `game/core/state.py` | Pilha `exhausted`; estado de turno (`action_used`, `bonus_used`, `extra_actions`); `can_play(card)`; `should_end()`. Lógica pura, sem pygame. |
| `game/core/combat.py` | `resolve_heal` estendido pra somar o modificador (poção); leitura do modificador de Constituição do personagem. |
| `game/app.py` | Jogar carta **não** chama mais o inimigo se o turno não terminou; botão **"Encerrar turno"**; "Ação Bônus: comprar" passa a gastar o espaço de Bônus; cartas de uso único vão pra `exhausted`. |
| `game/ui/hud.py` | **Indicadores de Ação e Ação Bônus** (ícone redondo verde → vermelho quando gasto); mostrar Ação extra concedida. Pedido do playtester, agora essencial. |
| `assets/cards/` | Arte de Surto de Ação e da Poção (prompts a gerar, como nos outros). Sem arte, cai no retângulo de fallback. |
| Testes | Ordem livre; auto-fim com os dois gastos; "Encerrar turno"; "Passar a Ação" não encerra; Surto de Ação concede Ação mesmo já gasta; poção cura 1d4+1 e é removida do baralho; Segundo Fôlego consome o Bônus; Corrente na ordem real; chefe com timeout ainda permite Bônus. |

## 5. Decisões pendentes

Nenhuma para implementar. Fora do escopo por decisão do responsável: cartas equipáveis (Ação ou Bônus), raridade/loot e como conquistar outra Poção numa sala.

## 6. Fora do escopo

Reações, mais de uma Ação por turno **exceto pela Ação extra do Surto de Ação**, sistema de raridade/loot e recompensa de sala (repor a Poção), mana/custo, arte final das cartas, cartas equipáveis.

## 7. Critérios de aceite

- [x] Depois de gastar a Ação, o jogo **não** passa pro inimigo se o Bônus está livre.
- [x] Bônus → Ação e Ação → Bônus funcionam; a Corrente segue a ordem real de jogo.
- [x] O turno passa sozinho quando Ação (normal e extra) e Bônus estão gastos; "Encerrar turno" funciona a qualquer momento.
- [x] "Passar a Ação" gasta só a Ação.
- [x] Surto de Ação (Bônus) concede 1 Ação extra, inclusive quando a Ação normal já foi gasta.
- [x] Segundo Fôlego gasta o Bônus (não a Ação); "comprar 1 carta" e carta de Bônus são mutuamente exclusivos no turno.
- [x] Poção cura 1d4 + mod. de Constituição do personagem (+1 pro Durvall) e sai do baralho para sempre depois de usada; uma nova tentativa a restaura.
- [ ] Indicadores de Ação/Bônus refletem o estado; input segue bloqueado durante as batidas.
- [x] Timeout do chefe perde só a Ação.
- [x] Cartas atuais mantêm o comportamento (`action_type` padrão `"acao"`), exceto o Segundo Fôlego, que agora é Bônus.

## 8. Ordem de execução (após aprovação)

1. Estado de turno + pilha `exhausted` + novas cartas em `core`, com testes.
2. Ligar `CombateScreen` (não encerrar turno ao jogar; "Encerrar turno"; Bônus como espaço único).
3. Indicadores de Ação/Bônus no HUD.
4. Prompts de arte pras 2 cartas novas.
5. Playtest de ordem (Bônus antes/depois da Ação, combo, Surto de Ação) e registro em `EVID-00X`.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Aberto: indicadores de Ação/Bônus (só visual, sem teste).
