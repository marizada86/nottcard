---
id: "SPEC-023"
title: "Migracao do workspace ADD para v0.2"
status: "verified"
origin: "planned"
implementation_preceded_spec: false
created: "2026-09-28"
canonical_refs: []
---

# Migracao do workspace ADD para v0.2

## Objective

Atualizar o contrato operacional do workspace `.atena/` de ADD v0.1 para
v0.2, preservando a identidade, as politicas mais restritivas e todo o
historico existente do projeto.

## Context and evidence

- O projeto usa `.atena/add.yaml` com `add_version: "0.1"`.
- A revisao oficial verificada e `fa62b122e8b4bcee1f0a0fd9c9711d59f0f6c60b`,
  cujo `CONTRACT.md` declara ADD v0.2.
- A raiz ja e `.atena/`; nao existe a raiz legada `atena/` a renomear.
- `vault/research/` ainda nao existe.
- Ha 22 specs planas, `SPEC-001` a `SPEC-022`, produzidas no formato v0.1.
- `rtk --version` funciona, mas `rtk gain` nao pode criar seu banco global
  neste host. RTK continua opcional e nao determina a validade do ADD.

## Scope

- Atualizar `.atena/add.yaml` para o contrato v0.2, preservando a identidade
  do projeto, `review-before-remote` e as aprovacoes locais de Git atuais.
- Adotar os padroes v0.2 de interacao direta, Atena guiada, especificacao e
  bootstrap sem instalar nem configurar ferramentas globais.
- Criar `vault/research/` como pasta vazia rastreavel.
- Registrar esta migracao no formato de spec v0.2 e em evidencia local.
- Manter `SPEC-001` a `SPEC-022` sem mover, reescrever ou alterar seus
  metadados.

## Non-goals

- Alterar intencao canonica, regras do jogo, arquitetura do jogo ou lore.
- Converter retroativamente os 22 registros historicos ao formato v0.2.
- Instalar, configurar globalmente ou corrigir permissao do RTK.
- Criar commit, publicar, enviar ou mesclar alteracoes.

## Decisions

| Decision | Choice | Evidence / rationale | Status |
| --- | --- | --- | --- |
| Raiz do workspace | Manter `.atena/` | Ja atende ao contrato v0.2; nao ha raiz legada concorrente. | decided |
| Historico de specs | Preservar planos v0.1 intactos | A v0.2 nao fornece conversao prescrita; mover ou dividir perderia fidelidade historica. | decided |
| Politicas locais | Preservar restricoes mais fortes | `review-before-remote` e commits locais com aprovacao ja protegem o projeto. | decided |
| Interacao v0.2 | Usar padroes oficiais | A atualizacao solicitada deve adotar o protocolo v0.2 sem customizar seu significado. | decided |

## Gaps

### BLOCKING

- None.

### RESOLVABLE

- Politicas novas de interacao e bootstrap: adotar os valores padrao v0.2,
  pois sao o contrato da revisao oficial e nao enfraquecem as politicas locais.

### DEFERRED

- Conversao dos registros `SPEC-001` a `SPEC-022` para diretorios v0.2: fora
  do escopo para preservar documentos ja validados e por nao haver migrador
  oficial.
- Configuracao do banco global do RTK: fora do escopo; o RTK e opcional.

## Acceptance criteria

- [ ] `add.yaml` declara `add_version: "0.2"` e mantem a identidade e as
      politicas locais existentes.
- [ ] A configuracao v0.2 de interacao, especificacao e bootstrap esta
      presente com os valores oficiais.
- [ ] `vault/research/` existe e pode receber pesquisa nao-canonica.
- [ ] Os 22 arquivos historicos de spec permanecem inalterados.
- [ ] A migracao possui plano, tarefas, criterios e evidencia locais no
      formato v0.2.
- [ ] A verificacao de estrutura e `git diff --check` passam.

## Impact

### Expected files/systems

- `.atena/add.yaml`
- `.atena/vault/research/.gitkeep`
- `.atena/specs/SPEC-023-migracao-add-v02/`
- `.atena/evidence/SPEC-023-migracao-add-v02.md`

### Canonical impact

- None expected.

## Risks

- Ferramentas futuras podem exigir conversao formal das specs planas v0.1.
  Mitigacao: preservar o historico e manter essa conversao explicitamente
  adiada, em vez de produzir uma migracao sem regra oficial.

## Post-hoc disclosure

Not applicable.
