---
id: "SPEC-021"
titulo: "Contencao de texto e hierarquia da UI em menus e HUD"
status: "aprovada - em execucao"
criado: "2026-09-26"
aprovacao: "Plano aprovado pelo Guilherme em 2026-09-26"
relacoes:
  - "SPEC-004-f4-f6-interface-e-fluxo-jogavel"
  - "SPEC-013-ferramentas-de-playtest-e-navegador-qa"
  - "SPEC-014-paridade-visual-e-cadencia-do-combate"
---

# SPEC-021 - Contencao de texto e hierarquia da UI em menus e HUD

## Intencao

Eliminar textos que ultrapassam molduras, controles sobrepostos e conteudo
importante oculto em toda a interface 2D: menus, sobreposicoes e HUD de
exploracao e combate. A correcao deve continuar legivel em portugues e
preservar regras, atalhos e dados exibidos.

## Escopo

- Criar primitivas de layout em `ui/gfx.gd` para medir, quebrar, limitar e
  desenhar texto dentro de um retangulo de conteudo.
- Tornar botoes resistentes a rotulos longos, por meio de quebra, altura
  calculada ou uma abreviacao explicita; texto significativo nunca some em
  silencio.
- Revisar `menu_screen`, `mission_select_screen`, `character_select_screen`,
  `hq_screen`, `offer_screen`, `result_screen` e `situation_screen`.
- Revisar a HUD de `walk_screen` e `combat_screen`: status, comandos,
  recursos, notificacoes, cartas, mensagens e atalhos.
- Revisar sobreposicoes: console, guia de playtest, bloco de evidencias e
  navegador de QA.
- Cobrir conteudo curto e longo, grupos de um a tres personagens, listas de
  missoes e recompensas extensas, estados de combate e mensagens de erro.

## Invariantes

- A resolucao logica continua 1280x720 e a tela cheia usa o mesmo canvas.
- Regras, RNG, dados, recompensas, missoes e atalhos nao mudam.
- Descricoes e narrativas longas usam quebra e area paginada/rolavel quando
  necessario; nao sao truncadas.
- O retangulo de clique de cada controle permanece coerente com o elemento
  visivel e nao se sobrepoe a outro controle ativo.

## Plano de voo

1. Consolidar tokens de margem, padding e espacamento, e adicionar helpers de
   texto contido e botao com rotulo adaptativo.
2. Migrar paineis e listas dinamicas para alturas e posicoes medidas, em vez
   de coordenadas verticais fixas.
3. Corrigir menus e telas de fluxo, priorizando listas de missoes, detalhes de
   personagens, narrativas do QG e escolhas de eventos.
4. Corrigir HUD de exploracao e combate, incluindo trilhos, cartas, comandos,
   avisos e dicas de teclado.
5. Corrigir as sobreposicoes de desenvolvimento e playtest que possuem linhas
   de log, instrucoes ou atalhos extensos.
6. Criar testes de geometria dos helpers e ampliar o smoke test de UI para
   estados de conteudo limite.
7. Executar o suite local e, com o runtime Godot disponivel, registrar
   capturas de 1280x720 e tela cheia para a matriz de telas.

## Criterios de aceite

- [ ] Todo texto pertence ao retangulo interno de sua moldura, ou usa
      explicitamente quebra, pagina ou rolagem.
- [ ] Nenhum botao, atalho, contador, barra de status ou area clicavel se
      sobrepoe a outro elemento visivel e ativo.
- [ ] Textos em portugues permanecem compreensiveis: rotulos abreviados sao
      intencionais e descricoes completas continuam acessiveis.
- [ ] Menus, HUD de exploracao, HUD de combate e sobreposicoes passam pela
      matriz de estados extremos sem vazamento visivel.
- [ ] Testes de layout e o smoke test de UI passam; evidencias de runtime sao
      registradas assim que o executavel Godot estiver acessivel.

## Fora de escopo

- Nova identidade visual, nova arte ou alteracao de mecanicas.
- Adaptacao para uma resolucao logica menor que 1280x720.
- Alterar conteudo narrativo, balanceamento ou a localizacao alem de ajustes
  minimos de rotulos para caberem em controles.

## Evidencias e reconciliacao

- Testes deterministas dos calculos de retangulo e dos estados de UI.
- Capturas de runtime da matriz de telas quando houver executavel Godot.
- Atualizacao desta spec com resultado, excecoes e arquivos afetados.
