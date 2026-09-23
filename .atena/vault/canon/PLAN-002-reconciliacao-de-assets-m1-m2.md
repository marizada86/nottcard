---
id: "PLAN-002"
type: "plano"
title: "Reconciliação de assets importados e fechamento visual de M1–M2"
status: "executed"
created: "2026-09-22"
approved: "2026-09-22"
relations:
  - "[[PLAN-001-porte-nottcard-ai-para-godot]]"
  - "[[SPEC-005-auditoria-e-reconciliacao-de-assets]]"
---

# Reconciliação de assets importados e fechamento visual de M1–M2

## Foto confirmada

- Os 363 arquivos finais elegíveis de `nottcard-ai/assets/`, excluídos `_raw/`
  e `concepts/`, existem em `assets/` e têm hash idêntico.
- Há 27 arquivos finais adicionais no Godot para conteúdo futuro; eles ainda
  precisam passar pela importação do Godot e validação em cena.
- M1 e M2 têm os 13 pares `bg`/`fg`, os ambientes, inimigos, props, itens,
  cartas, fontes, HUD, dados e portas exigidos pela fatia atual.
- `hq_002_q4` foi criada, importada e satisfaz a referência de
  `data/core/hq.json`. `hq_003_q3.png` continua sem referência e não foi
  renomeada nem reaproveitada.

## Escopo aprovado

1. Reimportar e verificar as 27 artes adicionais.
2. Adicionar uma auditoria reproduzível das referências de asset declaradas no
   Godot, com saída legível e falha para ausência real.
3. Validar compilação e o fluxo jogável existente após a reimportação.
4. Registrar evidência e separar a pendência narrativa `hq_002_q4`.

## Fora de escopo

- Gerar ou alterar arte, inclusive `hq_002_q4`.
- Renomear `hq_003_q3` ou mudar o texto/ordem de HQ.
- Criar conteúdo, encontros, rotas ou regras de M3–M9.

## Critérios de aceite

- Todos os arquivos adicionais são importáveis pelo Godot.
- A auditoria identifica `hq_002_q4` e não reporta falsos positivos para as
  salas em camadas M1/M2.
- O teste de compilação e o smoke test de UI terminam sem falhas.
- A evidência informa, por categoria, o que está pronto, integrado e pendente.

## Próximo gate

`hq_003_q3` fica preservado como arte não integrada até que uma futura HQ ou
uma ficha narrativa a referencie explicitamente.
