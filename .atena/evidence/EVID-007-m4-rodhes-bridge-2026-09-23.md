# EVID-007 — M4: O Resgate em Rodhe's Bridge

Data: 2026-09-23  
Spec: `SPEC-007`  
Intenção: `M4-001`

## Entrega integrada

- M4 requer M3 e percorre estrada sob chuva, ponte em perseguição e
  carroça-prisão.
- A perseguição é uma situação de atributo local; os confrontos têm dois e
  três rebeldes, sem sistema de corrida ou reputação.
- A vitória salva `cadernos_magicos`; o lore limita a revelação a Bella chamar
  Kein de Elias, sem explicar a origem da memória apagada.

## Assets P0

| Entrega | Arquivos no projeto |
|---|---|
| Estrada | `assets/rooms/m4_sala_1_estrada/{bg,fg}.png` |
| Ponte | `assets/rooms/m4_sala_2_ponte/{bg,fg}.png` |
| Carroça-prisão | `assets/rooms/m4_sala_3_carroca/{bg,fg}.png` |
| Prop | `assets/world/props/grade_carroca_prisao.png` |
| Reuso | `m4_ponte_perseguicao.png`, `rebelde_ponte.png`, retratos de Bella/Kein e `cadernos_magicos.png` |

## Verificações

| Verificação | Resultado |
|---|---|
| Reimportação Godot de 7 novos recursos | passou |
| `test_compile.gd` | 1 teste, 0 falhas |
| `test_m4.gd` (contrato + cadernos persistidos) | 2 testes, 0 falhas |
| `test_ui_smoke.gd` (M1, M3 e M4 em telas reais) | 3 testes, 0 falhas |
| `test_m3.gd` | 2 testes, 0 falhas |
| `test_run_flow.gd` (regressão M1/M2) | 2 testes, 0 falhas |
| `test_world.gd` | 7 testes, 0 falhas |
| `tools/audit_assets.gd` | 113 referências de dados, 10 HQs, 0 faltas |
| Regressão completa | 41 testes; 39 passaram e 2 falharam por restrição de escrita externa |

O executável headless continua sem poder escrever preferências e logs globais
em `AppData` e relata recursos remanescentes no encerramento. Esses avisos não
impediram a importação nem os testes acima.

As duas falhas da regressão completa são os round-trips de disco em
`test_persistence.gd`: o sandbox bloqueia `user://` fora do projeto. As
validações de save em memória, da vitória de M4 e da UI real passaram.
