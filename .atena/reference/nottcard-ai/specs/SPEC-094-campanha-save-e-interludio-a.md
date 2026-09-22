---
id: "SPEC-094"
type: "spec"
title: "Campanha: missões concluídas no save, tela de Missão e Interlúdio A"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-093-catalogo-de-missoes-e-m1-portada]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
  - "[[PLAN-018-implementacao-de-m2-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'tudo aprovado' (PLAN-018, etapa 2a)"
---

# Campanha, save e Interlúdio A

- `SaveState.missions_completed` (ids das missões concluídas) e `story_items` (itens narrativos: o mapa de Dagruve, que abre a M3). Entram em
  `to_dict`/`from_dict` no padrão do arquivo, **sem subir `SAVE_VERSION`**. Migração: `hq_001` em `hqs_seen` ⇒ `m1` concluída.
- `finish_run(VITORIA)` registra a missão ativa (e o mapa, na M2) **antes** de avaliar as conquistas e de gravar; o mesmo `save` grava o resultado e a
  oferta do chefe, então fechar o jogo no meio não perde o desbloqueio.
- **Tela de Missão** (`MissionSelectScreen`): lista M1 ("rejogar" se concluída) e M2 (liberada com a M1 concluída), mostra o briefing e leva à seleção.
  Com uma só missão liberada, o caminho de sempre (direto para a seleção). O botão "Próxima missão" do Interlúdio e "Continuar" do menu passam por ela.
- **Interlúdio A:** ao abrir a M2 pela 1ª vez toca a `hq_002` (Castle Rodhe, os broches, a apresentação formal do Brook) antes da seleção. A vitória da M2
  toca a `hq_003` (o mapa de Dagruve). Sem a arte, as HQs caem no fundo escuro com o texto (fallback existente).

## Testes
`tests/core/test_roster.py` (migração e campos do save), `tests/ui/test_m2_flow.py` (tela de Missão, HQ da 1ª vez, vitória grava, derrota não).
