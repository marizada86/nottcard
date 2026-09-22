# Estado do porte (2026-09-21) — nottcard-ai v0.18.0 → Godot 4.7.2

Regra: nada é "portado" sem teste. Legenda: OK = portado e testado; PARCIAL = existe mas simplificado; FALTA = não iniciado.

| Área | Estado | Como foi provado |
|---|---|---|
| RNG (Mersenne Twister do CPython) | OK | golden vs Python, 7 sementes |
| Dados, atributos, cartas, personagens, inimigos, turno, testes de morte | OK | golden |
| Combate (Corrente, acerto, dano, reações, Cópia, Guarda, Poder Místico, pergaminhos) | OK | 69 lutas passo a passo idênticas ao Python |
| Player, grupo, coleção/baralho, upgrades, economia, progresso, save (SaveState), equipamento, pergaminhos, mochila | OK | golden |
| Exploração (d20), eventos, plano de eventos, mapa, grade, caminhada, portão, missões M1/M2 | OK | golden (180 testes, 5 caminhadas, 39x6 eventos) |
| Loja, conquistas, layouts por mortes, elenco | OK | golden |
| Save/perfil em disco | OK | ida e volta + arquivo corrompido |
| RunSession / CombatSession (orquestração do App) | OK (sem par no Python: testada por bots) | test_run_flow |
| Menu, seleção, missões, caminhada em 1ª pessoa, situação/eventos, combate, oferta, resultado | PARCIAL | smoke + capturas; sem dados 3D, sem animação por batidas, sem dano flutuante rico |
| Loja, Baralho, Cartas/Conquistas, Equipamento, Mochila, Layout das cartas (telas) | FALTA (a lógica existe) | — |
| Login, boas-vindas, tutorial, pausa, diário/HQ, mapa (automapa), log F12/detalhado | FALTA | — |
| Dados 3D procedurais (dice_mesh/dice_widget), câmera com paralaxe, efeitos (damage_fx), sequenciador de batidas | FALTA | — |
| Ferramentas de playtest (evidência .zip, Discord, guia) | adiado (PLAN-001) | — |
| Export do executável Windows | FALTA (precisa dos export templates do Godot 4.7.2) | — |

Origem: a árvore de trabalho já tem a SPEC-110/111 (Dupla pela HQ, 2º baralho, personagens a 100 moedas, Minhas Cartas) fora do baseline; entram por spec de sincronização depois.
