---
id: "PLAN-021"
type: "plano"
title: "Vantagem/desvantagem, balanceamento do baralho base e correções do playtest do Higor (v0.14.0)"
status: "canon"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-020-roteiro-geral-de-implementacao-2026-09-20]]"
sources:
  - "Responsável, 2026-09-21: pedido de Vantagem/Desvantagem e ajuste do baralho básico; 'aceito recomendações e propostas'"
  - ".atena/evidence/novas evidencias/EV-higor-20260921-*.zip (4 pacotes, 13 notas, v0.14.0)"
---

# Plano

> Objetivo do responsável: jogo mais dinâmico e menos frustrante; decisões rápidas fora do combate; **um baralho base que funcione com todos os
> personagens** (hoje Kayron sobra em Poder Místico sem carta roxa de dano e Brook tem pouco dano). Regra da casa para o que vem: **novas cartas
> ou reajustes não repetem efeito** — cada carta traz uma variedade real.
> Tudo abaixo espera aprovação (`execution_approval: per-spec`); as SPECs 098 a 103 são escritas depois do OK.

## 1. Ponto de partida (o que o código já tem)

- Baralho comum do jogador = **núcleo travado** `CORE_DECK` (`collection.py`): Golpe×2, Chama Menor×2, **Toque Curativo×2, Poção×2** (8 cartas) + 6 comuns sorteadas
  (`starting_extras`). Regras de validade: ≥2 de cada cor, ≥1 cura, ≥2 ataque. A **Poção é Roxa e é o que hoje garante as 2 Roxas** — tirar 1 Poção exige uma Roxa nova.
- O d20 é rolado por `_d20()` em `combat.py` (acerto do jogador, teste de atordoamento, ataque inimigo), em `exploration.py`/`items.py`/`death_saves.py`.
  `HitResult`/`StunCheck` guardam um único `d20`; `dice_widget.py` mostra um dado só.
- Reações já têm janela ("Reagir?") entre o d20 do inimigo e o dano (`PendingEnemyAttack`), com `reacts_to`.
- Durvall já tem só 2 Golpe Perfurante no baralho fixo; o excesso vem do **sorteio de comuns** (pool `COMMON_NAMES`).

## 2. Blocos de trabalho

### Bloco A — Vantagem e desvantagem (SPEC-098) · mecânica-base, vem primeiro
- `dice.roll_d20(state)` com `state ∈ {normal, vantagem, desvantagem}`: rola 2d20, fica o maior/menor; **vantagem + desvantagem se anulam** (regra D&D 5e).
  O crítico e a falha crítica valem no dado que ficou (`crit`/`fumble` leem o d20 mantido).
- `HitResult`/`StunCheck`/testes de exploração passam a guardar `d20`, `d20_descartado` e `estado`.
- **Onde se aplica** (recomendação): ataque do jogador, ataque do inimigo, teste de atordoamento, testes de exploração/situações. Testes de morte ficam fora (regra própria).
- **Fontes iniciais** (pra a mecânica já nascer usada, sem repetir efeito):
  - *Desvantagem* no próximo ataque inimigo: carta **Esquiva** (Bloco B).
  - *Vantagem* no acerto: alvo atordoado/marcado (Localizar Criatura, Visão Verdadeira…) troca o "+2/+3 no acerto" por vantagem? **Recomendo manter o bônus e adicionar vantagem só no Golpe Furtivo e na furtividade (SPEC-047)** para não desfazer o que foi balanceado.
  - *Vantagem* inimiga contra o jogador exposto (Ataque Imprudente troca "acerta sem teste" por vantagem do inimigo — mais lido e menos punitivo).
- **UI:** `dice_widget` desenha 2 dados d20; o descartado fica apagado; texto no log ("Vantagem: 17 e 4 → 17"); selo "VANT."/"DESV." no HUD. Cobre a nota do Higor de contraste (§4, item U1).
- Testes: distribuição (média de vantagem > normal > desvantagem com semente fixa), anulação, crítico só no dado mantido, UI desenha os dois dados.

### Bloco B — Baralho base (SPEC-099)
| Pedido | Como fica |
|---|---|
| 3 Toques Curativos → 1 | `CORE_DECK`: Toque Curativo×1; `COPY_CAP_BY_NAME["Toque Curativo"] = 1`; o sorteio inicial nunca acrescenta outro (as demais cópias só por compra/evento). |
| 1 Palavra Curativa no baralho base | `CORE_DECK` ganha **Palavra Curativa×1** (Azul, bônus, 1d4). Cap 1. Maelor tem uma como HC de assinatura — deixar a dele como está e checar duplicidade na simulação. |
| Só 1 Poção por missão (era 2) | `CORE_DECK` Poção×1, `COPY_CAP_BY_NAME["Poção de Cura"] = 1`. **Poções extras vêm de eventos aleatórios** (Bloco D) e da loja do mercador (`events.py`, `POTION_PRICE`). Migração: saves com 2 Poções no núcleo perdem 1 do baralho e ficam com ela na coleção (sem tirar nada do jogador). |
| Carta roxa **Esquiva** (reação) | Nova comum, **Roxa**, `action_type="reacao"`, `reacts_to="qualquer"`, campo novo `forces_disadvantage`: ao jogar na janela "Reagir?", o ataque inimigo é **rolado de novo com desvantagem** (o d20 original + um novo, fica o menor). Só faz sentido se o golpe ia acertar → a janela só oferece a Esquiva quando acertou. Entra no núcleo (repõe a 2ª Roxa que a Poção deixou). |
| Reduzir Golpe Perfurante para 2 | Cap por nome no sorteio (`COPY_CAP_BY_NAME["Golpe Perfurante"] = 2`); o baralho fixo do Durvall já tem 2. |
| **Golpe permanente** por conquista | Nova conquista "Durvall no nível 4" → +1 **Golpe** na coleção (`achievements.py` ganha benefício `grant_card`). O sorteio inicial passa a limitar Golpe a 2 (o núcleo) para essa cópia ser de fato ganha. |

**Núcleo resultante (8 cartas, mesmo tamanho):** Golpe×2, Chama Menor×2, Toque Curativo, Palavra Curativa, Poção de Cura, Esquiva → 2 de cada cor, 2 ataques, 3 curas: continua válido.

### Bloco C — Corrigir Kayron e Brook + variedade (SPEC-100) · **propostas para aprovação**
Diagnóstico: o núcleo só tem ataque Vermelho e Amarelo; o Kayron (tudo Roxo, Poder Místico sobrando) e o Brook (Vermelho/Azul, poucos ataques) dependem das cartas de assinatura. Propostas (cada uma com efeito distinto, nada de "mais um golpe 1d6"):
1. **Estocada Mística** (Roxa, ataque, comum): 1d6 + gasta até 3 Poder Místico (+1 dano cada, `spends_mystic`). Para os outros personagens vale como ataque Roxo simples, o que também aumenta o dano disponível a todos e liga o Poder que sobra do Kayron.
2. **Golpe Pesado** (Vermelha, comum): 1d10, mas é Ação e **quebra a Corrente** de quem não é Vermelho? — descartado por repetir "dano maior". **Alternativa:** *Pancada de Escudo* (Vermelha, comum): 1d4 + próximo ataque inimigo −2 (mistura dano e controle) — dá dano ao Brook sem virar clone de Golpe.
3. **Olhar Fixo: Amarelo → Roxo** (pedido do Higor, nota 13): trocar a cor no cartão e nos pools; vira uma segunda fonte Roxa de controle para o Kayron.
4. Rebalancear **Chama Sagrada / Farpa Psiônica / Lâmina Psíquica** só se a simulação mostrar sobra; `scripts/simulate.py` roda por personagem antes/depois (critério: os 4 personagens dentro de ±15% de vitória/PV perdidos).
Regra de variedade: cada carta nova ou reajustada precisa mudar **um eixo** (alvo, timing, recurso, estado aplicado); uma tabela "carta × eixo" entra na SPEC para provar isso.

### Bloco D — Eventos e loja (parte da SPEC-099)
- Evento aleatório "**achar uma Poção**" (`event_data.py`, motor SPEC-074) com peso próprio, e 1 evento que troque poção por outra coisa útil.
- Mercador continua vendendo Poção (preço `POTION_PRICE`), mas com estoque 1 por visita.

### Bloco E — Tela "Baralho" com detalhes ao passar o mouse (SPEC-101, pequena)
- Em `deck_screen.py` reaproveitar o card grande do combate (hover, SPEC-018): ao passar o mouse numa carta da lista/coleção, mostra a carta ampliada com nota, dados, cor e raridade. Cobre também a coleção do menu.

## 3. Correções que vieram das evidências (SPEC-102 — interface; SPEC-103 — jogo)

| # | Nota (arquivo) | Ação | Onde |
|---|---|---|---|
| U1 | Números do dado na mesma cor do dado (022510 #1) | Cor de contraste calculada pela luminância da face + contorno; testar com todas as cores de dado | `dice_widget.py` |
| U2 | Tela "Missão concluída" sobrepõe texto; precisa rolar (022510 #4) | Painel "XP da tentativa" e "Estatísticas" com **rolagem** (roda do mouse + barra); Total/Nível/Moedas fora da lista rolável; botões fixos | `result_panel.py` |
| U3 | Catálogo e Conquistas não cabem (022510 #6) | Rolagem vertical; varredura de textos que estouram (auditoria de todas as telas em 1280×720 e 1024×576) | `hq_screen.py`, `tab_strip.py`, `collection.py` |
| U4 | "..." na Loja (Upgrades, Equipamentos, Personagens) (025838 #2, #5, #10) | Tooltip completo ao passar o mouse **em toda a loja** + detalhes do item (o que faz) | `shop_screen.py` |
| U5 | "Como jogar" sobrepõe a interface (025838 #16) | Rolagem no guia/tutorial | `tutorial.py`, `playtest_guide.py` |
| U6 | Clique direito cancela a carta selecionada (032545 #1) | `MOUSEBUTTONDOWN` botão 3 limpa a seleção/alvo | `app.py`, `combat_view.py` |
| G1 | Sylas forte demais: a Cópia deve poder ser alvo (022510 #2) | **A Cópia Sombria entra na lista de alvos do inimigo** (escolha uniforme entre Sylas, Cópia e aliados); dano na Cópia não passa ao Sylas | `combat.py`, `enemies.py`, HUD |
| G2 | Equipamento único por compra (025838 #9) | Cada armadura/arma comprada é **1 unidade**; equipar em 2 personagens exige 2 compras. Migração: o save atual mantém quem já usa e vira 1 unidade por equipado | `equipment.py`, `shop.py`, `save_file.py` |
| G3 | Proficiência e compatibilidade (025838 #11) | `EquipmentDef.allowed_classes`/proficiências (Brook: armadura pesada, sem adaga; Maelor: maça/cajado; Kayron: leve/cajado…) — a UI mostra o motivo do bloqueio | `equipment.py`, tela de equipamento |
| G4 | Novos itens: Robes (CAM), Cajado e Cetro (cartas roxa e amarela) (025838 #10) | 1 Robe (CAM +), Cajado (carta Roxa própria) e Cetro (carta Amarela própria), cada um com carta de arma no padrão SPEC-047, **cartas com efeito distinto** das armas atuais | `equipment.py`, `cards.py`, arte via `ART-PROMPTS` |
| G5 | Transferir itens entre personagens na exploração (020302 #1) | Ação "Passar item" no menu Equipamento/Mochila durante a exploração (respeita G3) | `backpack.py`, `equipment_screen.py` |
| G6 | **BUG** câmera gira sozinha e o jogador é teleportado para a luta (025838 #12) | Reproduzir (evento de tecla `Q/E` repetido ao voltar da pausa/foco da janela?), limpar estado de teclas ao perder foco/entrar em combate, teste de regressão | `walk_screen.py`, `camera.py`, `walker.py` |
| G7 | Conquista: 30+ de dano em um ataque → +10% de dano permanente a todos (032545 #2) | Nova conquista com benefício; **recomendo +10% no dano base (arredondado para cima, mínimo +1) e teto de 1 vez**; entra em `achievements.py` e no cálculo de dano | `achievements.py`, `combat.py` |

(#3 do Higor 022510 = "Sylas forte demais" → G1. Notas numeradas sem texto nos zips (#3, #7, #8, #14, #15) não têm conteúdo; se o Higor tinha algo ali, ele reenvia.)

## 4. Ordem, versões e gates

| Fase | O quê | SPEC | Versão |
|---|---|---|---|
| 0 | Reproduzir G6 (bug de câmera) e travar com teste; rodar `simulate.py` para a **linha de base** dos 4 personagens | — | — |
| 1 | Vantagem/desvantagem (motor + UI + testes) | 098 | 0.15.0 |
| 2 | Núcleo novo, Esquiva, caps, conquista do Golpe, eventos de poção, migração de saves | 099 | 0.15.0 |
| 3 | Estocada Mística, Pancada de Escudo, Olhar Fixo Roxo + simulação comparativa | 100 | 0.15.0 |
| 4 | Hover no Baralho | 101 | 0.15.1 |
| 5 | Interface: contraste do dado, rolagens, tooltips da loja, clique direito | 102 | 0.15.1 |
| 6 | Cópia como alvo, equipamento único, proficiências, itens novos, transferência, conquista de 30 de dano | 103 (pode dividir em 103a/103b) | 0.16.0 |
| 7 | Arte das cartas/itens novos (fallback: retângulo com o nome) e playtest | — | 0.16.x |

Gates: suíte inteira verde (hoje 1284+ testes) a cada fase; nenhum commit sem sua aprovação (`add.yaml`); depois de cada versão, renomear o exe para `nottcard-ai-<versão>.exe` em `dist/`.

## 5. Decisões que peço (recomendação em negrito)

1. Vantagem em testes de exploração além do combate: **sim**. Nos testes de morte: **não**.
2. Ataque Imprudente troca "acerta sem teste" por vantagem do inimigo: **sim** (alternativa: manter como está).
3. Esquiva só aparece na janela se o golpe acertou: **sim**.
4. Cartas novas do Bloco C (Estocada Mística, Pancada de Escudo): **aprovar como comuns**; nomes e números ajustáveis.
5. Golpe por conquista: 4º nível do Durvall dá **+1 Golpe** na coleção; o sorteio inicial limita Golpe a 2.
6. Conquista de 30 de dano: **+10% de dano, uma vez, aplicada a todos**.
7. Equipamento único: **migrar o save atual sem tirar nada de quem já equipou**.
