# EVID-009 — M6: Willie, o Amálgama Abissal

Data: 2026-09-23  
Spec: `SPEC-009`  
Intenção: `M6-001`

## Entrega integrada

- M6 exige M5 e percorre Docas sem voz, Armazém inundado e Píer do Amálgama.
- A luta final tem seis slots independentes: Willie e cinco Tentáculos de
  Willie. Não há segunda fase, ritual de fechamento ou ordem de alvo.
- A `Aura de névoa verde` atinge a área e causa 6 de dano ao Willie uma única
  vez ao preparar cada especial; o dano não pode eliminá-lo sozinho.
- A vitória salva `oleo_willie` e `pocao_sopro_de_fogo`. O texto final deixa
  apenas o gancho da “coleção” para o Interlúdio D.

## Assets P0

| Entrega | Arquivos no projeto |
|---|---|
| Docas | `assets/rooms/m6_sala_1_docas/{bg,fg}.png` |
| Armazém | `assets/rooms/m6_sala_2_armazem/{bg,fg}.png` |
| Píer | `assets/rooms/m6_sala_3_pier/{bg,fg}.png` |
| Inimigo | `assets/enemies/tentaculo_willie.png` (corpo de Willie já importado) |
| Props | `assets/world/props/{rede_apodrecida,oleo_willie,pocao_sopro_de_fogo}.png` |
| Recompensas | `assets/items/{oleo_willie,pocao_sopro_de_fogo}.png` |

Os oito recursos originais foram gerados com referência de estilo em pintura
dark fantasy: docas abandonadas com névoa verde, armazém inundado, píer de
chefe, moldura de redes/cordas, tentáculo abissal, rede, frasco de óleo e
poção de chama. O lote é de arte customizada; não foi necessário fallback.

## Verificações

| Verificação | Resultado |
|---|---|
| Reimportação Godot de 12 recursos | passou |
| `test_compile.gd` | 1 teste, 0 falhas |
| `test_m6.gd` (contrato, aura e persistência) | 3 testes, 0 falhas |
| `test_ui_smoke.gd` (M1, M3, M4, M5 e M6) | 5 testes, 0 falhas |
| `test_m3.gd` + `test_m4.gd` + `test_m5.gd` | 7 testes, 0 falhas |
| `test_enemies.gd` | 3 testes, 0 falhas |
| `tools/audit_assets.gd` | 113 referências de dados, 10 HQs, 0 faltas |
| Regressão completa | 49 testes; 47 passaram e 2 falharam por restrição externa |
| `git diff --check` | passou; sem erro de whitespace |

As duas falhas da regressão geral são os round-trips de disco em
`test_persistence.gd`. O sandbox bloqueia a escrita em `user://`; os testes de
salvamento em memória, incluindo a persistência das recompensas de M6,
passaram. Os avisos de `AppData` e recursos remanescentes no encerramento do
Godot seguem a mesma limitação externa e não afetaram a importação nem os
contratos acima.
