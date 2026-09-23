# EVID-008 — M5: O Santuário de Astherion

Data: 2026-09-23  
Spec: `SPEC-008`  
Intenção: `M5-001`

## Entrega integrada

- M5 exige M4 e percorre cemitério partido, limiar dimensional e Santuário de
  Astherion.
- Dois Notívagos protegem o limiar. Astherion troca uma única vez da fase 1
  para a fase 2 ao chegar a 50% de PV, mantendo o mesmo slot de combate.
- A vitória salva `colar_visao_verdadeira` e `tarn_dagruve_selada`.
- A reação excepcional de Astherion a Durvall fica observável, mas sem
  explicação narrativa ou mecânica adicional.

## Assets P0

| Entrega | Arquivos no projeto |
|---|---|
| Cemitério | `assets/rooms/m5_sala_1_cemiterio/{bg,fg}.png` |
| Limiar | `assets/rooms/m5_sala_2_limiar/{bg,fg}.png` |
| Santuário | `assets/rooms/m5_sala_3_santuario/{bg,fg}.png` |
| Props | `lapide_fraturada.png`, `bacia_nevoa.png`, `circulo_fogo_azul.png` |
| Reuso | `notivago.png`, `astherion_fase_1.png`, `astherion_fase_2.png`, `colar_visao_verdadeira.png` |

## Verificações

| Verificação | Resultado |
|---|---|
| Reimportação Godot de 9 novos recursos | passou |
| `test_compile.gd` | 1 teste, 0 falhas |
| `test_m5.gd` (contrato, troca de fase e persistência) | 3 testes, 0 falhas |
| `test_ui_smoke.gd` (M1, M3, M4 e M5) | 4 testes, 0 falhas |
| `test_enemies.gd` (invocação M2 preservada) | 3 testes, 0 falhas |
| `test_m3.gd` + `test_m4.gd` | 4 testes, 0 falhas |
| `test_run_flow.gd` (regressão M1/M2) | 2 testes, 0 falhas |
| `tools/audit_assets.gd` | 113 referências de dados, 10 HQs, 0 faltas |
| Regressão completa | 45 testes; 43 passaram e 2 falharam por restrição de escrita externa |

O Godot headless não pode escrever preferências/logs globais em `AppData` e
relata recursos remanescentes ao encerrar. Esses avisos não impediram a
importação nem os testes listados.

As duas falhas da regressão completa são os round-trips de disco em
`test_persistence.gd`, pois o sandbox bloqueia a gravação em `user://` fora do
projeto. A persistência em memória e as recompensas da M5 passaram.
