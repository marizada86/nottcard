---
id: "SPEC-015"
titulo: "Dado 3D nativo, legível e com peso visual"
status: "aprovada — em execução"
criado: "2026-09-23"
relacoes:
  - "SPEC-014-paridade-visual-e-cadencia-do-combate"
referencias:
  - "D:/dev/nottgard/games/IA/nottcard-ai/game/ui/dice_mesh.py"
  - "D:/dev/nottgard/games/IA/nottcard-ai/game/ui/dice_widget.py"
  - "D:/dev/nottgard/games/IA/nottcard-ai/.atena/specs/SPEC-002-animacao-dado-d20-procedural-3d.md"
---

# SPEC-015 — Dado 3D nativo, legível e com peso visual

## Intenção

Substituir o renderer provisório de dado 2D por um dado 3D real do Godot. O
objetivo é recuperar a sensação de volume, giro, desaceleração e pouso do jogo
original sem criar um quadrado/face sobreposta no final da animação.

## Diagnóstico

O componente atual em `ui/dice_roll_view.gd` usa textura 2D, rotação plana e
uma face desenhada por cima ao assentar. Isso não representa profundidade e
produz uma transição visual artificial. Este renderer deve ser removido após a
substituição estar validada; não será incrementado como solução definitiva.

## Escopo

- Criar um renderer 3D isolado, composto por `SubViewport`, câmera, luzes e
  malha do dado, exibido sobre a tela 2D de combate.
- Implementar **d20 primeiro**, com malha icosaédrica, uma face mapeada para
  cada valor, material verde, arestas luminosas e numerais/ilustrações dos
  assets existentes.
- A rotação inicial é apenas decorativa; a orientação final usa a face que
  corresponde exatamente ao valor já resolvido pelo core.
- Animar em três fases: entrada/giro, desaceleração/assentamento e retenção
  legível. O painel de combate recebe scrim discreto durante a rolagem.
- Após validar d20, generalizar a infraestrutura para d4, d6, d8, d10 e d12,
  incluindo múltiplos dados, críticos, área e vantagem/desvantagem.
- Manter um fallback 2D mínimo somente quando um asset ou malha não existir.

## Invariantes

- O valor vem de `CombatSession`/`Dice` antes da animação. O renderer não usa
  RNG de regra nem recalcula acerto/dano.
- A face vista no repouso é sempre o valor decidido; não basta desenhar um
  numeral por cima da malha.
- A sequência de combate continua bloqueando input durante a rolagem, como
  definido na SPEC-014.
- Não haverá dependência externa, plugin, asset comprado ou alteração de
  balanceamento.

## Direção visual

1. O dado entra pelo canto, menor e em giro rápido, com trajetória curta.
2. Durante o giro, luz e faces criam sensação de volume; motion blur vem de
   poucas cópias 3D transparentes ou pós-processamento leve, se o desempenho
   permitir.
3. Ele desacelera no centro do painel e a câmera mantém uma perspectiva clara.
4. A orientação faz slerp até a face sorteada; ela fica legível por pelo menos
   0,5 s antes de a sequência avançar.
5. A composição tem fundo escurecido discreto, sem esconder inimigo, PV ou
   número de dano no momento do impacto.

## Arquitetura proposta

| Área | Responsabilidade |
|---|---|
| `ui/dice_3d_view.gd` | ciclo de vida do `SubViewport`, cena 3D e textura entregue ao combate |
| `ui/dice_mesh_3d.gd` | dados declarativos: vértices, faces, UVs, número de cada face e orientação-alvo |
| `ui/dice_roll_view.gd` | fachada de apresentação; delega para 3D e conserva fallback mínimo |
| `ui/screens/combat_screen.gd` | posiciona a apresentação, compõe o scrim e consome `finished` sem conhecer geometria |
| `tests/cases/test_dice_3d_presentation.gd` | face final, duração, fallback e múltiplos dados |

Cada face terá vértices próprios no `ArrayMesh`, para receber UV/material
correto. A orientação-alvo é calculada a partir da normal da face e da câmera;
o dado deve terminar na mesma posição independente da rotação decorativa
inicial.

## Plano de voo

1. Instalar/localizar um executável Godot compatível e capturar referência do
   dado provisório e do original para comparação visual.
2. Construir a malha/UV/orientações do d20 e testes sem animação.
3. Criar o `SubViewport` e validar luz, câmera, materiais e face final para os
   20 valores.
4. Implementar entrada, desaceleração, slerp, retenção e motion blur leve;
   compor no `CombatScreen` sem afetar regras.
5. Fazer playtest de acerto, crítico, vantagem e dano; ajustar timing e
   enquadramento com evidências F6/F7.
6. Portar os demais dados e casos de múltiplos dados/área.
7. Remover o renderer 2D provisório, mantendo apenas fallback seguro; revisar
   FPS, testes e evidências antes de concluir.

## Critérios de aceitação

- [ ] d20 possui volume e faces reais; não há textura/foto plana sobreposta no
      pouso.
- [ ] Os 20 valores terminam na face correta, com teste automatizado.
- [ ] O valor pode ser lido por ao menos 0,5 s; entrada, giro e assentamento
      parecem uma única ação contínua.
- [ ] Acerto, crítico, vantagem/desvantagem e dados de dano seguem mostrando o
      resultado já resolvido pelo core.
- [ ] Múltiplos dados são organizados e legíveis, sem ocultar o impacto.
- [ ] O combate continua bloqueando input corretamente durante os beats.
- [ ] Não há queda perceptível abaixo de 60 FPS no cenário de combate padrão.
- [ ] Há evidência comparativa de runtime e captura F6/F7 após a validação.

## Fora de escopo

- Física de colisão real, som de dado, partículas cinematográficas ou câmera
  livre.
- Mudança de fórmula, RNG, cartas, inimigos ou regras do combate.
- Recriar recursos de arte que já existem apenas para mascarar problema de
  renderização.
