---
id: "SPEC-052"
type: "spec"
title: "Primeira pessoa, passo FP-1: combate de frente (extração do combat_view e layout da referência)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-002-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-049-camera-com-o-mouse-primeira-pessoa-fp0]]"
  - "[[SPEC-016-layout-do-jogador-trilho-direito]]"
  - "[[SPEC-037-grupo-mais-de-um-personagem-em-cena]]"
  - "[[SPEC-044-ajustes-do-playtest-v0.6.0]]"
sources:
  - "Referências de primeira pessoa (Shroom and Gloom), enviadas em 2026-09-20 pelo responsável"
  - "Responsável, 2026-09-20: intenção do inimigo só nas cartas (decisão 1 do PLAN-002)"
---

# Combate de frente (FP-1)

> **Aprovada pelo responsável em 2026-09-20**, começando pela etapa A. O responsável dispensou esperar o playtest das
> TASK-001..007. As SPEC-045/046/047 já estão implementadas (o HUD final está definido). Não muda regra de combate nem `core`.

## 1. Objetivo
Reorganizar a tela de combate como a referência: inimigos de frente, mão em leque, pilhas como livros nos cantos, PV em orbe.

## 2. Etapa A: extração sem mudar pixel (obrigatória, antes da B)
- `CombateScreen` (`game/app.py`, ~1450 linhas) delega todo o **desenho** para `game/ui/combat_view.py` (novo), que recebe o
  estado do combate e a `Camera`; input e regras continuam na tela.
- **Aceite da etapa A:** testes existentes verdes; print antes/depois idêntico pixel a pixel nas telas de referência (1
  inimigo, grupo, mão cheia, chefe, pausa). Commit próprio.

## 3. Etapa B: layout novo
1. **Fileira de inimigos:** no fundo da sala, centralizados (SPEC-027 mantida), com câmera (SPEC-049).
   - **PV e status abaixo** de cada inimigo (barra e ícones de atordoamento, CA corroída, marca de trovão).
   - **Intenção acima**, **só quando uma carta a revela** (Localizar Criatura, Visão Verdadeira); sem revelação, nada.
2. **Mão em leque** na borda inferior: arco calculado a partir de N cartas (ângulo total limitado, sobreposição adaptativa
   para mão cheia, SPEC-020); hover eleva e endireita a carta; duplo clique e descarte por escolha como hoje (SPEC-018/020).
3. **Livros nos cantos:** baralho (esquerda) e descarte (direita) com a contagem, clicáveis para abrir o `pile_overlay` do H3
   (SPEC-044). Só muda posição e desenho.
4. **Orbe de PV** do personagem ativo e **indicadores de Ação / Bônus / Reação** onde a referência põe a energia.
5. **Grupo (SPEC-037):** os outros personagens viram orbes pequenos empilhados com retrato e PV; o ativo em destaque; clicar
   troca como hoje.
6. **Corrente de Classe, Guarda, Sorte, equipamento e PV do inimigo** mantêm o que as SPEC anteriores exigem, reposicionados;
   nenhum elemento some.
7. Tudo legível em 1280×720 e em tela cheia (mesma escala `SCALED`).

## 4. Aceite
- Etapa A: os três pontos acima. Etapa B: jogar o M1 completo com 1, 2 e 3 personagens sem elemento ilegível ou sobreposto;
  task de playtest nova.
- Nenhuma regra alterada: os testes de `combat` e `turn` nem são tocados.

## 5. Riscos
- Maior risco de regressão do plano (arquivo grande): por isso a etapa A separada e com print idêntico.
- O layout depende do HUD das F1–F3; começar antes dessas fases retrabalha o desenho.

## 6. Fora do escopo
Corredor e portas (SPEC-053), arte nova (SPEC-054), mudança de regra ou de valores.

## 7. Implementação (2026-09-20)

**Etapa A:** `game/ui/combat_view.py` (desenho) extraído de `CombateScreen`; 13 capturas idênticas pixel a pixel antes e depois.

**Etapa B**, com a arte que o responsável já gerou (`ART-PROMPTS-013`):
- **Inimigos:** nome, barra de PV e CA/CAM (e atordoado/marcado) **abaixo** da arte; `EnemySlot.intent` guarda o próximo ataque
  revelado por Localizar Criatura e a linha "Próximo: Golpe 1d8" aparece **acima** dele até ele atacar (só a carta revela).
- **Mão em leque:** `CardSlot.angle`; as pontas descem 14 px e giram até 5°; a carta sob o mouse ou selecionada fica reta.
  O clique continua sobre o retângulo da carta.
- **Livros:** `livro_baralho` e `livro_descarte` no lugar dos ícones, clicáveis como as pilhas do H3.
  **Desvio:** ficaram na coluna direita, não nos cantos: os cantos inferiores são do orbe de PV e dos botões, e o superior
  esquerdo, da Corrente.
- **Orbe de PV:** moldura `orbe_pv` com o líquido desenhado dentro do vidro (sem a arte, o círculo de antes).
- **Indicadores:** gemas `ind_acao`, `ind_bonus` e `ind_reacao` (escurecidas quando gastas), na coluna direita.
- **Grupo:** orbes de retrato de 64 px empilhados à direita, sob os botões do topo, com barra de PV curta e o número.
- Testes novos em `tests/ui/test_combat_layout.py`; 1201 testes.
