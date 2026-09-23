---
id: "SPEC-014"
titulo: "Paridade visual e cadência do combate"
status: "aprovada — em execução"
criado: "2026-09-23"
referencias:
  - "D:/dev/nottgard/games/IA/nottcard-ai/game/ui/dice_widget.py"
  - "D:/dev/nottgard/games/IA/nottcard-ai/game/ui/damage_fx.py"
  - "D:/dev/nottgard/games/IA/nottcard-ai/game/ui/sequence.py"
  - "D:/dev/nottgard/games/IA/nottcard-ai/.atena/specs/SPEC-002-animacao-dado-d20-procedural-3d.md"
  - "D:/dev/nottgard/games/IA/nottcard-ai/.atena/specs/SPEC-003-dano-flutuante-e-eliminacao.md"
  - "D:/dev/nottgard/games/IA/nottcard-ai/.atena/specs/SPEC-004-cadencia-do-combate.md"
---

# SPEC-014 — Paridade visual e cadência do combate

## Intenção

Restaurar no porte Godot os sinais visuais e a cadência do combate do jogo
original: indicadores de Ação/Ação Bônus/Reação, dados que revelam o resultado
já decidido, impacto legível, PV animado e uma sequência que mostre uma coisa
por vez.

## Escopo

- Desenhar as gemas existentes `ind_acao`, `ind_bonus` e `ind_reacao` no trilho
  e nos botões, coloridas quando disponíveis e escurecidas quando gastas.
- Criar uma fila de batidas visuais reutilizável e testável.
- Portar o dado procedural de apresentação, usando os assets já presentes para
  d4, d6, d8, d10, d12 e d20; múltiplos dados, vantagem/desvantagem, crítico e
  área são apresentados sem alterar o resultado.
- Apresentar o turno em anúncio, acerto quando aplicável, dados, pausa,
  impacto/PV, modificadores, respiro e morte/continuação.
- Animar PV mostrado somente na batida de impacto, com tremor, números
  flutuantes, cura, bloqueio, redução, bônus e aviso de eliminação.
- Cobrir ataques do jogador e inimigo, reações, área, contra-ataque, trovão e
  morte de grupos sem duplicar regras do core.

## Invariantes

- `Combat` e `Dice` continuam sendo a autoridade de regras e RNG. A UI nunca
  re-rola, recalcula dano ou muda o vencedor.
- `CombatSession` pode expor eventos aditivos de apresentação, mas os cálculos
  e mutações de regra permanecem idênticos.
- Durante batidas, o input de combate fica bloqueado; uma janela de reação é
  liberada explicitamente quando necessária.
- O resultado exibido ao final de cada dado é exatamente o resultado resolvido.

## Cadência inicial

| Batida | Duração inicial |
|---|---:|
| anúncio/telégrafo | 0,4–0,6 s |
| d20 de acerto | 1,7 s |
| dados de dano | 2,1 s |
| pausa | 0,25 s |
| impacto | 1,5–1,6 s |
| respiro | 0,5 s |

Os valores são pontos de partida do original e serão calibrados no playtest.
Não há atalho de pular nesta spec.

## Arquitetura proposta

| Arquivo | Responsabilidade |
|---|---|
| `ui/combat_sequence.gd` | fila `CombatBeat`, ordem, tempo remanescente, estado ocupado e progresso |
| `ui/dice_mesh.gd` | geometria, orientação e projeção declarativas do dado |
| `ui/dice_roll_view.gd` | animação/revelação e desenho dos dados já resolvidos |
| `ui/combat_fx.gd` | PV exibido animado, tremor, números flutuantes e banner de eliminação |
| `core/combat_session.gd` | eventos imutáveis e aditivos de apresentação, produzidos junto aos resultados existentes |
| `ui/screens/combat_screen.gd` | orquestração da sequência, desenho e bloqueio de input |

Não serão adicionadas dependências ou assets externos.

## Plano de voo

1. Registrar a spec e consolidar a matriz de paridade a partir do código e dos
   testes do jogo original.
2. Criar os componentes de sequência e efeitos, com testes determinísticos.
3. Conectar as gemas de turno e a apresentação de PV/efeitos à tela atual.
4. Portar o renderer e a animação dos dados, começando pelo d20 e cobrindo os
   dados usados pelas cartas.
5. Emitir eventos de apresentação para todas as ações do `CombatSession` e
   enfileirar jogador, inimigo, reações e mortes.
6. Executar testes unitários/UI, playtests pelos cenários QA e capturar F6/F7;
   ajustar tempos somente após observar o fluxo real.
7. Reconciliar esta spec com evidências, critérios e limitações de runtime.

## Critérios de aceitação

- [ ] Ação, Ação Bônus e Reação usam suas gemas e comunicam estado disponível,
      gasto e ação extra.
- [ ] O valor final de todo dado mostrado é o resultado do core; não há segundo
      sorteio de lógica.
- [ ] As batidas nunca ocorrem simultaneamente e input não cria ações duplicadas.
- [ ] PV só começa a mudar no impacto, depois dos dados pertinentes.
- [ ] Dano, cura, redução, bloqueio, bônus, erro e eliminação continuam legíveis
      por tempo suficiente e têm a ordem correta.
- [ ] Um inimigo eliminado recebe fade e banner antes de o combate avançar.
- [ ] Testes cobrem sequência, dados, valores animados, bloqueio de input e um
      ciclo de ataque/morte; evidência de runtime é anexada quando o executável
      Godot estiver disponível.

## Fora de escopo

- Alterar fórmulas, balanceamento, RNG ou conteúdo de missões.
- Som, câmera cinematográfica, vídeo de captura ou modo de pular animações.
- Reescrever telas fora do combate.
