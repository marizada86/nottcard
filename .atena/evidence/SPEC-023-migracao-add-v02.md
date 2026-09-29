---
id: "EVID-014"
spec: "SPEC-023"
title: "Migracao do workspace ADD para v0.2"
created: "2026-09-28"
source_revision: "fa62b122e8b4bcee1f0a0fd9c9711d59f0f6c60b"
---

# Evidencia — SPEC-023

## Origem

- Repositorio oficial: `https://github.com/guimariz/atena-driven-development`.
- Revisao verificada: `fa62b122e8b4bcee1f0a0fd9c9711d59f0f6c60b`.
- Contrato aplicado: ADD v0.2.

## Escopo executado

- `add.yaml` atualizado de v0.1 para v0.2.
- Adicionados os blocos oficiais de interacao, especificacao, bootstrap,
  habilidades e grafo.
- Preservadas as politicas locais mais restritivas: `review-before-remote` e
  aprovacao explicita para commits, merge e publicacao.
- Criado `vault/research/` para material nao-canonico.
- Preservados sem alteracao os 22 arquivos planos `SPEC-001` a `SPEC-022`.

## RTK

- `rtk --version` identificou a versao 0.48.0.
- `rtk gain` nao concluiu porque este host negou a criacao do banco global de
  historico. Nenhuma configuracao global foi alterada; RTK nao e requisito de
  validade do ADD.

## Verificacao

- A inspecao confirmou `add_version: "0.2"` e todos os campos v0.2 previstos
  por esta migracao.
- `vault/research/.gitkeep` esta presente.
- O inventario encontrou 22 specs historicas planas; `git diff --
  .atena/specs` nao encontrou alteracoes rastreadas nelas.
- `git diff --check` foi aprovado.
