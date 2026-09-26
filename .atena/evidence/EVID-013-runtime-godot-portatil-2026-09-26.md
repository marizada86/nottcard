# EVID-013 — Runtime portátil Godot 4.7.2

Data: 2026-09-26  
Spec: `SPEC-016-runtime-godot-portatil.md`

## Artefatos publicados

Release: <https://github.com/marizada86/nottcard/releases/tag/godot-v4.7.2-win64>

| Arquivo | SHA-256 | Tamanho |
| --- | --- | ---: |
| `Godot_v4.7.2-stable_win64.exe` | `ab1824f85bfd8e0e4128182c000c4003a3e042245b2967848d089b2a04b22424` | 180.858.888 bytes |
| `Godot_v4.7.2-stable_win64_console.exe` | `c8f0a6bc45a19b33541501e57f6f7cd972ab18453743266339d495cbbe846643` | 198.152 bytes |
| `godot-v4.7.2-stable-win64.zip` | `ac1eddfaa82b4375e31fe383cbc114159aca503ec71bd874831effc7a29a6829` | 86.239.930 bytes |

O ZIP foi extraído em diretório limpo e contém os executáveis gráfico e de
console. A API da release confirmou o upload dos dois anexos e o digest SHA-256
do ZIP publicado.

## Verificação funcional

- Executável de console: `4.7.2.stable.official.ed1daf0bf`.
- Importação headless concluída com o runtime extraído.
- `tests/run_all.gd`: 69 testes executados, 0 falhas.

## Observações

No sandbox restrito, os testes de persistência não conseguem escrever no
diretório padrão de dados do Windows. A validação final foi executada fora desse
isolamento, usando o mesmo runtime extraído, e passou integralmente. O Godot
reportou avisos de recursos ainda em uso ao encerrar, sem falhas na suíte.
