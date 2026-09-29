# Plan of flight — SPEC-023

## Plan mode

- Origin: `planned`
- Reconstruction: `false`

## Recommended approach

Aplicar somente a migracao de contrato que a v0.2 define de forma clara:
configuracao, pasta de pesquisa e registro da propria migracao. Manter as
specs v0.1 como historico imutavel ate que exista uma regra de conversao
oficial ou uma necessidade concreta do projeto.

## Reuse

- Reutilizar a identidade e as politicas existentes em `.atena/add.yaml`.
- Reutilizar os valores padrao do `CONTRACT.md` v0.2 para os novos blocos.
- Reutilizar a estrutura atual de `.atena/`, sem criar um segundo workspace.

## Implementation sequence

1. Atualizar o `add.yaml` com os campos v0.2 e preservar as escolhas locais.
2. Criar `vault/research/.gitkeep`.
3. Finalizar os quatro artefatos desta spec e registrar a evidencia da
   migracao, incluindo a revisao de origem e as verificacoes.
4. Verificar a estrutura resultante, a preservacao do historico e a higiene
   do diff.

## Expected changes

- `.atena/add.yaml` — contrato operacional v0.2.
- `.atena/vault/research/.gitkeep` — pasta exigida pelo contrato.
- `.atena/specs/SPEC-023-migracao-add-v02/*` — registro v0.2 da migracao.
- `.atena/evidence/SPEC-023-migracao-add-v02.md` — evidencia de origem e
  verificacao.

## Validation

- Inspecao estruturada de `add.yaml` e das pastas obrigatorias — todos os
  campos e diretorios previstos presentes.
- Contagem e verificacao de hash dos 22 arquivos `SPEC-001` a `SPEC-022` —
  nenhum arquivo historico alterado.
- `git diff --check` — sem espacos ou marcadores de conflito invalidos.

## Limits

- Max retries: 3
- Changed-file budget: 7
- Cost/time constraints: nenhum servico pago ou instalacao global.

## Recovery

Reverter somente os arquivos desta spec, `add.yaml`, a nova pasta de pesquisa
e a evidencia por meio do controle de versao local; nenhum dado historico sera
migrado nem apagado.

## Mandatory gates

- Migracao material de metadados do workspace ADD: requer aprovacao explicita
  deste plano antes da execucao.

## Approval record

```yaml
status: approved
approved_at: "2026-09-28"
approved_by: "user (explicit approval in this conversation)"
scope_revision: 1
```
