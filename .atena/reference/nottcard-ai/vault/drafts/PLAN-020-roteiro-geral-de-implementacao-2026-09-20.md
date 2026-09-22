---
id: "PLAN-020"
type: "plano"
title: "Roteiro geral: das SPECs em aguardo até M2 jogável"
status: "draft"
created: "2026-09-20"
relations:
  - "[[PLAN-019-implementar-specs-em-aguardo-2026-09-20]]"
  - "[[PLAN-018-implementacao-de-m2-2026-09-20]]"
  - "[[PLAN-016-m2-praca-da-loucura-2026-09-20]]"
  - "[[PLAN-017-producao-imagens-m2-art-prompts-022-2026-09-20]]"
  - "[[ART-PROMPTS-022-m2-praca-da-loucura-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'faça um plano para implementar as specs. tudo aprovado com suas recomendações'"
---

# Roteiro geral

> Junta os três planos numa fila única, com portas de saída. O **quê e o como** de cada bloco continuam nos planos de origem: `PLAN-019` (as SPECs em
> aguardo), `PLAN-018` (M2) e `PLAN-017` (produção das imagens). Aqui ficam só a **ordem, os gates, as versões e o que falta escrever**. Todas as
> decisões abertas dos planos anteriores foram **aprovadas com as recomendações** (registro na seção 7 do `PLAN-018`).

## 1. Fila

| Fase | O quê | SPECs | Versão sugerida | Tamanho |
|---|---|---|---|---|
| **0** | Fechar o working tree: suíte, conferir combate com 1 e 3 inimigos, commits por SPEC | 081 a 085, 090 (já com código) | — | pequeno |
| **1** | Eventos e "O infeliz"; mercador com as moedas do perfil | 087, 089 | 0.11.1 | pequeno |
| **2** | Colisão, portas travadas, falha inicia a luta, alvo aleatório | 086 | 0.11.1 | médio |
| **3** | Lote de interface: sugerir baralho, resultado enxuto, x2, Esc na exploração, layouts | 088 | 0.11.1 | médio |
| **4** | Testes de morte e cura de aliados | 092, depois 091 | 0.12.0 | grande |
| **5** | Catálogo de missões, M1 portada, teste dourado | **093** (a escrever) | 0.12.1 | grande (18 arquivos) |
| **6** | Campanha, save e Interlúdio A | **094** (a escrever) | 0.13.0 | médio |
| **7** | Elenco: escolha inicial, grupo por conquista, compra de personagem | **095** (a escrever) | 0.13.0 | médio-grande |
| **8** | M2: mapa, exploração, narrativa | **096** (a escrever) | 0.14.0 | médio |
| **9** | M2: inimigos, sacerdote, invocação | **097** (a escrever) | 0.14.0 | médio |
| **10** | Arte de M2 (`ART-PROMPTS-022`, 50 imagens) e ligação | `PLAN-017` | 0.14.x | pequeno de código, grande de geração |
| **11** | Simulação, regressão, playtest e evidência | — | 0.14.x | pequeno |

A arte (fase 10) **não bloqueia** nada: começa quando o fluxo da fase 8 existir e pode andar em paralelo às fases 9 e 11, com o fallback de retângulo.

## 2. Por que essa ordem

- **Fases 1 a 4 antes de M2:** são melhorias que já estão aprovadas e afetam o que a migração de missões vai carregar (`walk_screen`, `Party`, conquistas).
  A 086 entra no teste dourado da fase 5; a 087 estende o catálogo de conquistas que a fase 7 usa; a 092 e a 091 fecham as regras de combate em grupo antes
  de o sacerdote e os 4 zumbis entrarem no mesmo combate.
- **Fase 5 (93) antes de qualquer conteúdo de M2:** só porta M1 para o catálogo, com regressão obrigatória; sem ela, M2 vira cópia de M1.
- **Fases 6 e 7 separadas:** o save e a tela de Missão (094) são a base do elenco (095); e a 095 é a maior regra nova de progressão (conquistas, compra,
  limite de grupo, migração de todos os saves). Separar dá dois pontos de commit e de playtest.
- **M2 depois do elenco:** M2 só faz sentido com Brook comprável e o grupo de 2 possível.

## 3. As SPECs a escrever (numeração a reservar na hora, porque outras frentes criam SPECs)

Cada uma sai do `PLAN-018` e nasce **aprovada** pelo OK das recomendações (o texto vai para você revisar junto com a entrega, como nas SPECs anteriores).

| Nº provisório | Título | Conteúdo (do `PLAN-018`) |
|---|---|---|
| 093 | Catálogo de missões e M1 portada | `core/missions.py` (`MissionDef`, `DungeonDef`), fim dos globais de M1 (23 usos em `app.py` e ~17 arquivos), `start_run(mission_id, party)`, teste dourado de M1 |
| 094 | Campanha, save e Interlúdio A | `missions_completed` (migração por `hq_001`), conclusão gravada junto do resultado e da oferta do chefe, tela de Missão, `hq_002` e `hq_003` |
| 095 | Elenco e compra | `unlocked_characters`, escolha de 1 inicial (todos os saves), `party_limit` por "Dupla"/"Trio", conquistas e 3 vagas de compra, item `PERSONAGEM` na loja (300 moedas), Brook após M2, `can_play`, migração, ajuste de "Dois Veteranos" |
| 096 | M2: mapa, exploração e narrativa | 6 salas lineares, grade de portas e caminhada, situações (Arlindo, porta da igreja), lore, eventos filtrados, `story_items` (mapa de Dagruve, que abre M3), sem névoa |
| 097 | M2: inimigos, sacerdote e reforços | 5 inimigos, `EncounterScript` (invoca 4 zumbis a 50% dos PV, morre sem invocar), pool de raras do chefe, números iniciais |

## 4. Gates (vale para todas as fases)

Uma fase só termina quando:
1. **Suíte completa verde** (base: 1677) e nenhum teste antigo removido, salvo os que a SPEC manda reescrever (086: "menor CA"; 088: texto da narração).
2. **Conferido no jogo** o que é interface: rodar o app (skill `run`) e ver a tela, com 1, 2 e 3 personagens quando o grupo importar.
3. **README, tutorial e guia do playtester** atualizados onde a SPEC pede.
4. **Evidência curta** em `.atena/evidence/` (o que foi conferido e a contagem de testes).
5. **OK do responsável para o commit** (`add.yaml`: commit exige aprovação). Peço **um OK por fase** com a mensagem e a versão propostas; nunca commit por conta própria.

## 5. Riscos que atravessam as fases

| Risco | Contenção |
|---|---|
| Várias frentes editando os mesmos arquivos (`app.py`, `hud.py`, SPECs) | Fase 0 primeiro; `git add` seletivo; reservar o número da SPEC na hora de escrever; reler o arquivo antes de editar |
| Migração de **todos** os saves para "1 inicial" (095) pode surpreender quem já joga com vários | Tela explica que o progresso dos outros fica guardado e volta na compra; nada é apagado; testar com saves reais de playtest |
| `app.py` com 3.500+ linhas concentra 086, 088, 091, 092, 093 e 094 | Uma SPEC por vez; suíte entre elas; sem refatorar `app.py` fora da fase 5 |
| Balanceamento (preço de personagem 300, PV e XP de M2, gatilho a 50%) sem playtest | Números marcados "a ajustar"; qualquer mudança vai para evidência antes |
| Trio exige os 5 personagens no nível 3 (muito grind) | Playtest da fase 11 mede; o número (3) e a regra ficam em constantes |

## 6. Próximo passo

Começar pela **fase 0**: rodar a suíte, conferir o combate com 1 e 3 inimigos e propor os commits por SPEC para o seu OK. Em seguida, fases 1 a 4 na ordem
do `PLAN-019` (087, 089, 086, 088, 092, 091).
