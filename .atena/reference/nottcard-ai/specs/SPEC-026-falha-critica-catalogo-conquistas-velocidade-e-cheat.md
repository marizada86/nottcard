---
id: "SPEC-026"
type: "spec"
title: "Falha crítica, catálogo de cartas, conquistas, velocidade 2x, poção descartável, mortes simultâneas e cheat"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-025-corrente-quebra-no-erro-e-ajustes-durvall-maelor]]"
  - "[[SPEC-023-progresso-save-e-resultado-da-tentativa]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
  - "[[SPEC-018-pausa-e-interacao-de-cartas]]"
  - "[[SPEC-006-classe-de-armadura-e-teste-de-acerto]]"
sources:
  - "Playtest do Higor, segunda rodada, 2026-09-19 (pedido direto do responsável)"
---

# Sete ajustes do playtest

Números e listas são valores iniciais de playtest, ajustáveis sem nova spec.

## 1. Falha crítica (d20 natural = 1)

- **Jogador:** uma carta de ataque cujo(s) d20 de acerto saíram todos 1 (com um alvo só, é o 1 natural)
  é **falha crítica**: o turno **termina na hora** (a Ação e o Bônus que sobravam se perdem) e o jogador
  **não tem Reação** no turno inimigo que vem em seguida. A carta já se gastou, e a Corrente já quebra por errar (SPEC-025).
- **Inimigo:** o 1 natural do inimigo é falha crítica: o ataque erra, o turno dele acaba ali (sem golpes
  extras) e ele **não tem Reação**. Hoje cada inimigo tem uma ação por turno e nenhum tem Reação, então o efeito
  mecânico é só o aviso "Falha crítica!" na tela; a regra fica escrita pra quando houver ataques múltiplos.
- Só vale para o teste de acerto. O teste de atordoamento (d20 + Força) não muda.

## 2. Catálogo de cartas

- Sobreposição "Cartas" aberta pelo **menu principal** (botão "Cartas") e pelo **menu de pausa** (botão
  "Catálogo de cartas"; ao fechar, volta à pausa).
- Abas: Durvall, Maelor e Conquistas (item 3). Cada aba de personagem lista cada carta uma vez.
- **Liberada** = a carta está no baralho do nível salvo do personagem (`deck_at`). **Bloqueada** aparece como
  **silhueta** (sem arte, nome, nota ou dado) com "Nível N".
- Fonte: `CharacterDef.catalog()` (carta, nível que a libera).

## 3. Conquistas

- Núcleo puro `game/core/achievements.py`: cada conquista tem condição, descrição e um **benefício** que
  o jogo lê. São checadas no fim de cada tentativa e ficam no `SaveState` (em memória, junto do nível: "Novo
  jogo" as apaga; o save em arquivo segue fora do escopo).
- Lista inicial:

| Conquista | Condição | Benefício |
|---|---|---|
| Dois Veteranos | Os dois personagens no nível 5 | **Trocar a mão inicial** de um combate: botão no 1º turno, 1 uso por tentativa |
| Fechadura Aberta | Concluir a missão (vitória) | +2 PV máximo em toda tentativa |
| Sorte de Sendrinah | 3 críticos (20 natural) numa mesma tentativa | Falha crítica não tira a Reação (só encerra o turno) |

- Aba **Conquistas** do catálogo (também no menu principal) lista todas, com condição e benefício; as
  desbloqueadas aparecem marcadas. A tela de resultado mostra as conquistas novas da tentativa.

## 4. Botão de velocidade 2x

- Botão redondo "1x"/"2x" no topo (ao lado de "?" e "II") durante o combate. Em 2x o `dt` das batidas,
  dados e números flutuantes dobra. **O cronômetro de decisão do chefe não acelera** (usa relógio real).
- Vale para a sessão, não para o save. O tempo de tentativa nas estatísticas segue em segundos reais.

## 5. Poção descartável

- Carta de uso único (`single_use`) ganha uma etiqueta **"USO ÚNICO"** sobre a arte, na mão, no catálogo e
  na escolha da Comunhão. O painel de detalhes já descrevia a regra.

## 6. Mortes simultâneas

- Vários inimigos eliminados pela mesma ação (carta de área, contra-ataque) somem juntos: **um** fade e **um**
  aviso ("N inimigos foram eliminados"), em vez de um de cada vez.

## 7. Cheat code

- **Ctrl + O + P** (a qualquer momento): todos os personagens vão ao **nível 5** (XP no teto), **todas as
  conquistas** são liberadas e o catálogo abre inteiro. Aviso na tela e no log. A tentativa em andamento não
  muda: vale na próxima. É ferramenta de playtest, sem aviso ao jogador no tutorial.

## Critérios de aceite

- [x] 1 natural do jogador encerra o turno e tira a Reação; do inimigo, aviso.
- [x] Catálogo no menu e na pausa, com silhuetas nas cartas ainda não liberadas.
- [x] Conquistas no core, no save, no menu e no resultado; benefícios funcionam.
- [x] Botão 2x acelera as batidas e não o cronômetro do chefe.
- [x] Etiqueta "USO ÚNICO" nas cartas de uso único.
- [x] Inimigos eliminados juntos morrem juntos.
- [x] Ctrl+O+P leva tudo ao nível 5 e libera as conquistas.
- [ ] Playtest.
