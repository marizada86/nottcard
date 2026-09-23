---
id: "M8-001"
tipo: "ficha-de-producao"
titulo: "M8 — A Vila das Sombras"
status: "promoted"
created: "2026-09-23"
sources:
  - "VSN-003-estrutura-de-missoes-arco-01"
  - "PERS-erik-blackthorn-ficha-jogavel"
  - "PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21"
---

# M8 — A Vila das Sombras

## Recorte canônico

Após o Espeto de Pau, o grupo chega à Vila das Sombras. A missão deve conter a
pousada-armadilha com o demônio sedutor, a Igreja das Sombras e os artefatos de
Bromnor; Erik Blackthorn é encontrado como o guia dos Greenholders.

Não serão revelados o destino posterior da Tarn, a descida ao Reino Abissal, a
Lâmina da Digestão ou detalhes futuros da origem de Erik.

## Decisão de implementação proposta

Como a base ainda só disponibiliza os cinco personagens iniciais, M8-A mantém
o elenco jogável atual e registra `erik_recrutado` como chegada narrativa. A
definição jogável de Erik, assim como a de Korrak e Leoric, fica para um marco
de elenco separado.

Rota linear proposta:

1. **Entrada da Vila** — situação de exploração sob a névoa e pista de Erik.
2. **Pousada Vazia** — situação que descobre a armadilha.
3. **Salão da Pousada** — combate obrigatório contra o Demônio Sedutor.
4. **Igreja das Sombras** — investigação final, artefatos de Bromnor e chegada
   de Erik.

## Conteúdo técnico

- Reutilizar `demonio_sedutor.png` e `erik.png`, ambos já importados.
- Criar uma variante de chefe do demônio sedutor, quatro pares de cenas e os
  props de pousada, igreja, névoa e relicário.
- Criar dungeon/lore/situações M8, ligar M8 após M7 e persistir apenas as
  chaves narrativas `artefatos_bromnor` e `erik_recrutado` na vitória.
- Reutilizar o ambiente 3D de igreja/corredor em vez de introduzir texturas
  novas sem o conjunto completo de parede, piso e teto.

## Critérios de aceite

- M8 exige M7; o percurso atravessa as quatro salas e o combate do demônio.
- A vitória persiste as duas chaves narrativas e não desbloqueia Erik no elenco
  ainda.
- As quatro cenas e quatro props carregam em telas reais, sem asset ausente.
- Contrato M8, fluxo automatizado, fumaça de UI, auditoria e regressão passam.

## Não objetivos

- Implementar os três novos personagens do elenco.
- Criar um sistema de imunidade permanente à névoa.
- Nomear ou explicar além do necessário os artefatos de Bromnor.
- Antecipar M9, a queda da Tarn ou o Reino Abissal.

## Decisão aprovada

O usuário aprovou a M8-A: rota linear de quatro salas, demônio sedutor como
único confronto obrigatório e Erik somente como recrutamento narrativo. A
entrega seguirá com assets, dados, testes e evidência.
