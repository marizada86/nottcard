---
id: "SPEC-097"
type: "spec"
title: "M2 — inimigos, sacerdote da Mente Derretida e reforços"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-096-m2-praca-da-loucura-mapa-exploracao-e-narrativa]]"
  - "[[SPEC-082-inimigos-de-corpo-inteiro]]"
  - "[[SPEC-043-cartas-raras-de-chefe]]"
  - "[[PLAN-018-implementacao-de-m2-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: o sacerdote morre sem invocar; gatilho em 50% dos PV; 4 zumbis dos cadáveres; 'tudo aprovado'"
---

# M2 — inimigos, sacerdote e reforços

- **Inimigos** (dado declarativo em `enemies.py`, números iniciais a ajustar no playtest): Cultista (11 PV, CA 11), Cultista de cajado (10 PV, golpe mágico a cada
  2 turnos), Arqueiro cultista (8 PV, ataque 1d8, CA 9; inimigo normal, sem cobertura), Zumbi (14 PV, CA 9). 10 cultistas nas salas 2, 3 e 5 (com arqueiros).
- **Sacerdote da Mente Derretida** (34 PV, CA 12, CAM 14, Turíbulo de cera em área contra a CAM, atordoamento com imunidade): chefe da sala 6.
- **`EncounterScript`** (mecânica nova, mínima): o portador invoca reforços **uma vez** quando cai a 50% dos PV **e ainda está vivo**; se um golpe o leva direto a
  0 PV ele **morre sem invocar**. O estado `fired` mora na instância do inimigo (recarregar a tela, trocar de alvo ou reabrir o combate não dispara de novo). Sem
  IA geral, fases nem cinemática; reaproveitável por outros chefes.
- **Combate:** depois de qualquer dano (turno do jogador ou contra-ataque) a tela checa os roteiros; `add_reinforcements` acrescenta os 4 zumbis à fileira (5 cabem na
  tela), reposiciona e reetiqueta todos ("Zumbi A" a "D"), avisa "Os mortos se levantam!" e registra no log. Os zumbis agem a partir do próximo turno inimigo. A
  vitória exige o sacerdote **e** todos os zumbis derrotados (XP e abates normais).
- **Recompensa do chefe:** `BOSS_POOLS["sacerdote_mente_derretida"]` com 4 raras novas (Cera Fervente, Vela Sagrada, Olhar Fixo, Estola de Cera; mecânicas que o jogo já
  tem), e a oferta "escolha 1 de 3" usa o pool da missão ativa. XP de conclusão 30; ouro e pergaminho do chefe como em M1.
- **Arte:** os 5 sprites de corpo inteiro (SPEC-082) já estão no jogo.

## Testes
`tests/core/test_roster.py` (roteiro: gatilho, uma vez, sem invocar se cai de uma vez), `tests/ui/test_m2_flow.py` (5 slots cabem e desenham, os zumbis entram uma vez,
vitória exige todos, recompensa do sacerdote).
