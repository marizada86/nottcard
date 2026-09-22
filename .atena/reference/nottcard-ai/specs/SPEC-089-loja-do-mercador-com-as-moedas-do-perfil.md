---
id: "SPEC-089"
type: "spec"
title: "Loja do mercador gasta as moedas do menu"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-074-motor-de-eventos-aleatorios]]"
  - "[[SPEC-035-loja-e-titulos]]"
  - "[[SPEC-073-ouro-e-carisma]]"
sources:
  - "Higor, playtest da v0.11.0 (Hiago), 2026-09-20: item 9 (chegou ao mercador sem ouro)"
  - "Responsável, 2026-09-20: gasto livre (sem teto por visita)"
---

# Loja do mercador com as moedas do perfil

> Aprovada pelo responsável em 2026-09-20 (`execution_approval: per-spec`). Mexe na economia: ver §3.

## 1. O problema
O Mercador (SPEC-074, `_shop` em `events.py`) só aceita o **ouro da missão** (`ledger.mission_gold`, "só aceita o ouro que você achou por aqui"). Quem chega a ele antes de achar ouro (Hiago) não pode comprar nada.

## 2. Como fica
O mercador passa a aceitar **também as moedas do perfil** (`SaveState.coins`, as do Menu e da loja da SPEC-035), **sem teto por visita** (decisão do responsável).
- **Saldo disponível** no mercador = `ouro da missão + moedas do perfil`. Cada opção mostra o preço em "ouro"; a tela mostra as duas bolsas ("Ouro da missão: 12 · Moedas: 118").
- **Ordem de gasto:** primeiro o ouro da missão; o que faltar sai das moedas do perfil. O gasto é feito na hora (a compra não desfaz se a missão terminar mal).
- **Opções desabilitadas** ("Faltam N") passam a considerar o saldo somado. `Option.cost_gold` continua sendo o preço; quem debita é uma função nova (`spend_gold(ledger, save, price)`) em `core`, sem pygame.
- O acerto de fim de missão (`settle_coins`) não muda: o ouro da missão que sobrar segue virando moedas; as moedas gastas já saíram do perfil.
- "Trocar a oferta" (`SHOP_REROLL_COST`) usa a mesma regra.

## 3. Consequências a conferir
- **Economia:** quem tem moedas no perfil passa a poder trocá-las por itens/cartas **temporários** da missão. Como o mercador é evento raro (~1 a cada 2 missões, SPEC-087) e os itens são temporários, o impacto é limitado; se o playtest mostrar que esvazia a loja do Menu, o teto por visita volta como ajuste em `event_data.py` (não entra agora).
- **Save:** o débito acontece em `SaveState.coins` e é persistido pelo `save_store.save` no momento da compra, para não voltar se o jogo fechar.
- **Outros eventos** que cobram ouro (`cost_gold`, baú trancado etc.) **não mudam**: só o mercador ganha o saldo do perfil.

## 4. Testes
- Comprar com ouro da missão suficiente: debita só dele.
- Ouro da missão insuficiente: o restante sai das moedas; saldo total insuficiente: opção desabilitada com "Faltam N".
- Ordem de gasto (missão primeiro); moedas nunca ficam negativas; o débito é salvo.
- Trocar a oferta segue a mesma regra; o acerto de fim de missão não é afetado.
- Save antigo sem mudança de formato carrega.
