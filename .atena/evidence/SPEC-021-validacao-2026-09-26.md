# Evidencia - SPEC-021

Data: 2026-09-26

## Verificacoes concluidas

- `test_ui_layout`: 3 testes aprovados para padding, reducao de corpo e quebra
  de paragrafos.
- `git diff --check` nao encontrou espacos em branco invalidos nos arquivos da
  spec.
- O carregamento do editor reconheceu os scripts de UI alterados, incluindo
  `Gfx`, telas de missao, QG, situacao, caminhada e combate.

## Limitacao registrada

O suite integral ainda para antes dos testes de fluxo por um erro preexistente
em `core/run_session.gd:136`: inferencia de tipo a partir de `Variant`, tratada
como erro pelo projeto. A mesma falha impede abrir o jogo para a revisao visual
manual e nao foi alterada por esta spec.

## Proxima evidencia

Depois de corrigido o erro de compilacao preexistente, capturar a matriz de
menus, sobreposicoes, HUD de caminhada e HUD de combate em 1280x720 e tela
cheia, conforme os criterios da SPEC-021.
