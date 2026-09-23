# EVID-005 — Auditoria de assets importados

Data: 2026-09-22  
Spec: `SPEC-005`

## Reimportação

O Godot 4.7.2 reimportou os 27 arquivos finais que ainda não tinham sido
reconhecidos pelo projeto: 10 inimigos, 6 quadros de HQ, 3 itens, 6 retratos,
uma sala de M4 e um prop. A operação foi concluída com código de saída zero.

O ambiente bloqueou apenas os diretórios globais de preferências e logs do
Godot (`AppData`); o cache e a importação do projeto foram concluídos. Esses
erros não afetaram assets nem testes.

## Auditoria

Comando: `Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/audit_assets.gd`

Resultado:

- 113 `asset_id` declarados;
- 10 imagens de HQ declaradas;
- inicialmente, uma referência sem arquivo: `res://assets/hq/hq_002_q4.png`.

As seis salas M2 com `bg.png` e `fg.png` foram reconhecidas como presentes.

## Regressão

| Verificação | Resultado |
|---|---|
| `test_compile.gd.test_all_scripts_compile` | passou |
| `test_ui_smoke.gd.test_bot_drives_the_real_screens` | passou |

O runner em modo headless relatou recursos remanescentes ao encerrar o smoke
test. É um aviso de encerramento já fora do fluxo testado; o teste retornou
zero falhas.

## Resolução de HQ_002

`hq_002_q4` não tinha arte na origem congelada nem em `assets/_raw/`. Após a
aprovação, foi gerada uma nova ilustração para o texto aprovado: a estrada
leva a Dagruve e o grupo observa, de longe, o culto preparando um ritual na
praça. O arquivo final está em `assets/hq/hq_002_q4.png` e foi reimportado.

A auditoria foi executada novamente: 113 `asset_id`, 10 imagens de HQ e
**zero faltas**. O smoke test de UI também passou após a inclusão.

`hq_003_q3.png` continua disponível e importada, mas sem referência. Nenhum
arquivo existente foi renomeado, apagado ou reutilizado.
