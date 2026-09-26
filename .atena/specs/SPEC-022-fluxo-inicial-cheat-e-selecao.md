---
id: "SPEC-022"
titulo: "Inicio de partida, persistencia do cheat QA e selecao de personagem"
status: "validada em testes — captura visual manual pendente"
criado: "2026-09-26"
aprovacao: "Plano aprovado pelo Guilherme em 2026-09-26"
relacoes:
  - "SPEC-017-f5-e-cheat-qa"
  - "SPEC-021-ux-ui-menus-e-hud"
  - "SPEC-014-paridade-visual-e-cadencia-do-combate"
evidencia:
  - "EV-tester-20260926 150048.zip"
  - "EV-tester-20260926 152223.zip"
---

# SPEC-022 — Inicio de partida, persistencia do cheat QA e selecao de personagem

## Intencao

Restaurar um inicio de partida confiavel para qualquer personagem elegivel,
fazer o cheat QA persistir e tornar a selecao de personagem legivel com os
cinco personagens exibidos.

## Escopo

- Tornar observaveis as etapas de validacao e inicio de uma partida.
- Impedir que falhas de escrita do save parecam sucesso para o playtester.
- Validar o cheat apos reabrir o save, incluindo personagens, progressao,
  conquistas, itens, layouts e colecao.
- Reorganizar a selecao para nao comprimir informacoes de cinco personagens em
  cartoes completos simultaneos.
- Comparar os indicadores de Corrente e apresentacao de dados/dano com o
  baseline, sem alterar regras de combate nesta spec.

## Fora de escopo

- Alterar regras, RNG, missoes, balanceamento ou conteudo narrativo.
- Reescrever a HUD de combate; apenas registrar desvios para trabalho posterior.
- Mudar o formato publico do save sem necessidade de correcao de persistencia.

## Criterios de aceite

- [ ] Um personagem elegivel selecionado inicia a primeira sala; uma recusa
      mostra seu motivo preciso na tela e no log.
- [ ] Durvall e Kayron passam pelo fluxo de inicio em save isolado.
- [ ] O cheat QA continua completo apos criar uma nova instancia de SaveStore.
- [ ] Erros de leitura ou escrita do save sao comunicados e nao geram mensagem
      falsa de sucesso.
- [ ] A selecao de cinco personagens nao possui texto nem controles sobrepostos
      em 1280x720.
- [ ] Os testes cobrem persistencia real e os caminhos positivo e negativo do
      inicio; a validacao visual em runtime fica registrada como pendencia se o
      executavel Godot nao estiver disponivel.

## Plano de voo

1. Reproduzir em save isolado e criar testes de regressao para o inicio e o
   cheat apos releitura do disco.
2. Corrigir a escrita atomica para verificar substituicao, preservar backup e
   propagar erro ao chamador.
3. Exibir e registrar as validacoes que antecedem RunSession.start.
4. Substituir os cartoes completos comprimidos por seletores compactos e um
   painel detalhado do personagem selecionado.
5. Executar a suite, revisar os criterios e registrar evidencia de runtime
   quando houver uma build Godot disponivel.

## Reconciliacao

- SPEC-017 passa a exigir persistencia apos reinicio, nao somente estado em
  memoria.
- SPEC-021 recebe a matriz da selecao de cinco personagens.
- Desvios de Corrente, dados ou dano encontrados na comparacao com o baseline
  ficam em uma spec propria de paridade de combate.
- Godot 4.7.2 executou a suite local em 2026-09-26: 77 testes, 0 falhas.
  Os testes especificos cobrem 100 seeds de save novo, inicio de M1 com
  Durvall e Kayron, e releitura do cheat em disco.
- A captura automatica da selecao continua pendente: o renderizador headless
  usado neste host nao disponibiliza a textura do viewport. A confirmacao
  visual deve ser feita em uma execucao com janela antes de encerrar a spec.
