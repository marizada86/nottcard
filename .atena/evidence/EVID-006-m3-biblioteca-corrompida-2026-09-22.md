# EVID-006 — M3: Biblioteca Corrompida

Data: 2026-09-22  
Spec: `SPEC-006`  
Intenção: `M3-001`

## Entrega integrada

- M3 é desbloqueada somente após `m2` e contém três salas: Vestíbulo selado,
  Acervo do silêncio e Arquivo da estrela.
- Há dois combates de três gárgulas corrompidas; as demais estátuas continuam
  como ameaça ambiental, conforme o cânone aprovado.
- O vestíbulo usa uma situação declarativa do enigma do silêncio, com Livrinho
  e o diário das gárgulas, sem regra global nova.
- A vitória registra `ampulheta_silencio_eterno` em `story_items`.
- Aila é mencionada apenas como voz distante no arquivo final.

## Assets P0

| Entrega | Arquivos no projeto |
|---|---|
| Salas | `assets/rooms/m3_sala_{1_entrada,2_acervo,3_arquivo}/{bg,fg}.png` |
| Props novos | `assets/world/props/diario_gargulas.png`, `assets/world/props/recorte_aluris.png` |
| Reuso | `livrinho.png`, `ampulheta_silencio_eterno.png`, `gargula_corrompida.png`, `aila.png` |

## Verificações

| Verificação | Resultado |
|---|---|
| Reimportação Godot dos três `fg.png` | passou |
| `test_m3.gd` (contrato + persistência da Ampulheta) | 2 testes, 0 falhas |
| `test_ui_smoke.gd` (M1 e M3 em telas reais) | 2 testes, 0 falhas |
| `test_compile.gd` | 1 teste, 0 falhas |
| `test_run_flow.gd` (regressão M1/M2) | 2 testes, 0 falhas |
| Regressão completa | 38 testes; 36 passaram e 2 falharam por restrição de escrita externa |
| `tools/audit_assets.gd` | 113 referências de dados, 10 HQs, 0 faltas |

O executável headless informa, no encerramento, recursos e objetos ainda em
uso, além de não poder escrever preferências/logs globais em `AppData`. As
verificações de M3 e a auditoria retornaram código zero; os avisos não
impediram importação, execução ou verificação dos assets do projeto.

Na regressão completa, as duas falhas são os round-trips em disco de
`test_persistence.gd`. Eles escrevem em `user://`, que resolve para diretórios
globais bloqueados neste ambiente. As validações que usam o save em memória e
as telas reais da M3 passaram; não houve alteração de persistência fora do
registro da Ampulheta.
