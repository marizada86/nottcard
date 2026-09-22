---
id: "SPEC-083"
type: "spec"
title: "Minimapa da exploração com seta de posição e direção"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-015-observacoes-v0.11.0-strafe-minimapa-dano-abas-2026-09-20]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
sources:
  - "Responsável, 2026-09-20: minimapa no canto esquerdo inferior, versão simplificada e estilizada do mapa do M, com uma seta para a posição e a direção. Decisões D2 e D3 do PLAN-015 pelas recomendações"
---

# Minimapa da exploração

## O que é
Painel de 152x104 px (`game/ui/minimap.py`) no canto inferior esquerdo da caminhada, em x 12–164 e y 604–708: fora dos seis botões (que começam em x 165) e da legenda.

- **Janela local** de 19x13 células a 8 px, **centrada no jogador** (o mapa inteiro tem 51x24 e ficaria ilegível a 4 px). Rola suave por baixo da seta, usando a posição animada (`vis_pos`).
- **Só o já visto:** `revealed_cells` do automapa (células pisadas e vizinhas); o resto é a cor de "desconhecido". Paredes só onde tocam o chão conhecido.
- **Estilo:** fundo escuro translúcido de cantos arredondados, moldura do painel, paleta do automapa (chão, visitado, porta âmbar, sala atual mais quente) com a parede mais clara para se separar do desconhecido, rótulo "M".
- **Seta:** triângulo âmbar com contorno e halo, no centro, apontando para onde a câmera olha (`vis_angle`); gira e desliza junto com a câmera. Norte para cima, sem "N" fixo.
- **Marcador de evento** (D3): losango rosa nas células de evento já reveladas.
- Só na caminhada (o modo clássico de portas e o mapa de nós não têm). Com "reduzir movimento" a posição e o ângulo já saltam, sem interpolar.

## Correções encontradas ao verificar o quadro real
- A **Bolsa** (SPEC-073) cobria o botão Mochila: os botões Mochila e Mapa da caminhada desceram para y 56 e 104.
- A **faixa de lore** (SPEC-078) cobria o subtítulo "Virado para…": passou de y 56 para y 96.
- A legenda de teclas mostrava quadrados no lugar das setas (a fonte padrão não as tem): agora diz "setas".

## Testes
`tests/ui/test_minimap.py`: posição fora dos botões, janela centrada, seta em cada direção e em giro contínuo, só células vistas, desenho nos cantos do mapa, com eventos e sem histórico, a seta muda com a direção, e o HUD sem as sobreposições acima.
