---
id: "SPEC-020"
titulo: "Dados legíveis, ambientes e recuo seguro na exploração"
status: "aprovada — aguardando validação no runtime Godot"
criado: "2026-09-26"
aprovacao: "Plano aprovado pelo Guilherme em 2026-09-26"
relacoes:
  - "SPEC-014-paridade-visual-e-cadencia-do-combate"
  - "SPEC-015-dado-3d-nativo-e-legivel"
---

# SPEC-020 — Dados legíveis, ambientes e recuo seguro na exploração

## Escopo

- O d20 usa as texturas de face existentes, sem `Label3D` atravessando a malha.
- A auditoria verifica pisos e tetos de todos os ambientes antes de criar arte
  adicional.
- Recuar permite voltar a uma sala visitada sem abrir combate; só o avanço para
  uma sala nova e não resolvida inicia o encontro.

## Critérios de aceite

- [ ] Os vinte valores do d20 ficam na face correspondente e são legíveis.
- [ ] Cada ambiente usado por M1–M9 encontra piso e teto válidos.
- [ ] Avanço, recuo, porta e bifurcação preservam o bloqueio de combate correto.
