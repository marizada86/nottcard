---
id: "SPEC-006"
type: "spec"
title: "Classe de Armadura (CA), Classe de Armadura Mágica (CAM) e teste de acerto"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-19"
relations:
  - "[[SPEC-001-porte-m1-solo-pygame]]"
  - "[[SPEC-004-cadencia-do-combate]]"
  - "[[SPEC-005-estrutura-do-turno-acao-e-acao-bonus]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[PERS-durvall-ficha-jogavel]]"
sources:
  - "Decisões do responsável em 2026-09-19 (ver §1)"
  - ".atena/specs/nottcard/SPEC-001-vertical-slice-m1-solo.md (Golpe Perfurante: 'ignora 1 ponto de redução de armadura'; inimigos: PV, ataque e habilidade, sem armadura)"
  - ".atena/vault/canon/nottcard/regras/SIS-001-atributos-e-eficiencia-de-cor.md (atributos e modificadores D&D 2024)"
---

# Classe de Armadura (CA), Classe de Armadura Mágica (CAM) e teste de acerto

## Problema

Hoje **não existe armadura** no jogo. A carta Golpe Perfurante diz "ignora 1 de
redução de armadura do alvo", mas é só texto: nenhum inimigo tem armadura, e
todo ataque sempre acerta. O único abatimento de dano é a Névoa Fria (efeito
temporário de carta). O responsável pediu um modelo à D&D: o ataque precisa
**acertar**.

## Declaração proposta

Ataques passam a exigir um **teste de acerto** (d20) contra a defesa do alvo:
**CA** (armadura física) ou **CAM** (armadura mágica). Errar causa 0 de dano.
Isso resolve o Golpe Perfurante (passa a ignorar 1 ponto de CA). A fórmula de
dano (Camadas 1 e 2 do canon) **não muda**: só passa a valer se o ataque acertar.

## 1. Decisões já tomadas (responsável do projeto, 2026-09-19)

1. **Modelo D&D**: CA e CAM; o ataque precisa acertar (não é redução fixa por golpe).
2. **Fórmulas padrão do personagem:**
   - **CA = 10 + modificador de Força**
   - **CAM = 10 + modificador de Inteligência**
3. **O gatilho é o Golpe Perfurante** ("ignora 1 de armadura") e vale resolver isso agora.

4. **Alterações na aprovação (2026-09-19):**
   - **"Action Surge" passa a se chamar "Surto de Ação"** (a carta da SPEC-005 e todos os textos do jogo).
   - **O d20 de acerto dura 1,3 s, mas em 20 natural (crítico) dura 1,8 s** — a rolagem demora mais no momento de maior tensão.
   - **Crítico dobra a QUANTIDADE de dados de dano** (1d8 → 2d8), e o resultado segue a fórmula normal (Corrente, compatibilidade de cor, atributo). **Não é "2× o dano final".**
5. Todas as demais propostas das §2 e §3 foram aprovadas como estão (ver §6).

Aplicado ao Durvall (`PERS-durvall`): Força 16 (+3) → **CA 13**; Inteligência 14 (+2) → **CAM 12**.

## 2. Regras propostas (a confirmar — ver "Decisões pendentes")

### 2.1 Qual defesa cada ataque enfrenta
- Carta de ataque **Vermelha** (dano físico) → **CA** do alvo.
- Carta de ataque **Amarela** (dano mágico, ex.: Chama Menor) → **CAM** do alvo.
- Cartas de **controle, cura, surto e equipáveis** não têm teste de acerto (Névoa Fria, Segundo Fôlego, Poção, Action Surge continuam funcionando como hoje).
- Ataque do **inimigo** contra o Durvall: físico → **CA** dele; o especial de natureza abissal (Grito Abissal) → **CAM**. *(proposta)*

### 2.2 Teste de acerto
- **Jogador:** `d20 + modificador do atributo da cor da carta` (Vermelho → Força; Amarelo → Inteligência) contra CA/CAM do alvo. **Acerta se o total ≥ defesa.** *(proposta: usa o mesmo atributo da fórmula da defesa, o que dá simetria)*
- **Inimigo:** `d20 + bônus de ataque do inimigo` contra a CA/CAM do Durvall. *(bônus por inimigo, ver §3)*
- **20 natural:** acerta sempre e é **crítico**. **1 natural:** erra sempre. *(proposta)*
- **Crítico:** dobra a **quantidade de dados de dano** (1d8 → 2d8, como no D&D 2024); a soma dos dados entra na fórmula de dano normal. Os dados do **bônus psiônico** também são dados de dano e dobram (1d6 → 2d6). Cada dado aparece rolando na tela.
- **Golpe Perfurante:** ignora **1 ponto de CA** do alvo (a CA efetiva contra ele é 1 menor).

### 2.3 Efeitos do erro
- **Erro = 0 de dano** e nenhum número de dano. Aparece **"Errou"** com o total do teste vs. defesa.
- **A Corrente de Classe avança mesmo errando** (a carta foi jogada). *(proposta)*
- **O bônus psiônico da passiva só entra se acertar** (é dano). *(proposta)*
- **A carta é gasta** (vai pro descarte) mesmo errando; o slot de Ação também.

## 3. Valores dos inimigos da M1 (**propostos por Claude, pendentes de aprovação e de balanceamento**)

O canon não define CA/CAM nem bônus de ataque dos inimigos. Ponto de partida testável:

| Inimigo | Sala | CA | CAM | Bônus de ataque |
|---|---|---|---|---|
| Criatura corrompida pela névoa (tutorial) | 2 | 10 | 10 | +2 |
| Slime corrosivo | 4 (opcional) | 9 | 11 | +1 |
| Guardião alado (cópia) | 5 | 12 | 10 | +3 |
| Guardião alado (verdadeiro, mini-chefe) | 6 | 13 | 12 | +4 |

Chance de acerto resultante (só pra dimensionar):
- Durvall com Vermelho (+3): vs CA 10 → **70%**, vs CA 12 → 60%, vs CA 13 → **55%**. Golpe Perfurante soma +5 pontos percentuais.
- Durvall com Amarelo (+2) vs CAM 10 → **65%**.
- Inimigos vs CA 13 do Durvall: bônus +2 → 50%, +3 → 55%, +4 → **60%**.

**Consequência esperada:** o dano médio do Durvall cai uns 30–45%. O jogo fica mais duro; o playtest pode pedir rebalanceamento (PV, valores acima). Por isso os números ficam em dado declarativo, fáceis de ajustar.

## 4. Cadência (SPEC-004) e tela

- **O d20 finalmente entra em jogo.** A sequência do ataque vira: anúncio → **d20 de acerto** → (se acertou) dado de dano → impacto.
- O d20 de acerto usa uma **versão mais curta** da animação 3D: **1,3 s** (2,1 s é o dado de dano), e **1,8 s quando sai 20 natural**. A rodada sobe uns 2–3 s.
- **Vários dados de dano** (crítico, bônus psiônico 2x+) rolam **lado a lado**, um dado por resultado, cada um mostrando o seu número.
- Legenda do teste, ~1,5 s: **"14 + 3 = 17 vs CA 13 — Acertou!"** ou **"Errou"** (cinza, sem tremor no alvo). Crítico: destaque dourado.
- O **inimigo também rola** o d20 de acerto no turno dele; errar mostra **"Errou"** sobre o Durvall e a barra não muda.
- **HUD:** mostrar **CA e CAM** ao lado do nome do inimigo e do Durvall (o jogador precisa saber contra o que está rolando).

## 5. Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/attributes.py` | `armor_class(attributes)` = 10 + mod(Força); `magic_armor_class(attributes)` = 10 + mod(Inteligência). |
| `game/core/combat.py` | `roll_to_hit(bonus, defense)` → `HitResult(d20, bonus, total, defense, hit, crit, fumble)`; `resolve_attack` recebe defesa e aplica acerto/crítico/ignora-CA. `AttackResult` ganha o `HitResult` e `hit`. **Mudança de core — precisa da sua aprovação.** |
| `game/core/enemies.py` | `Enemy` ganha `ca`, `cam`, `attack_bonus` (dado declarativo) e o tipo de defesa de cada golpe especial. |
| `game/core/cards.py` | `Card` ganha `ignores_ca: int = 0`; Golpe Perfurante → `1`. |
| `game/core/state.py` | `Player.ca` e `Player.cam` derivados dos atributos. |
| `game/app.py`, `game/ui/` | Batidas do d20 de acerto (jogador e inimigo), legenda, "Errou"/crítico, CA/CAM no HUD; versão curta da rolagem 3D. |
| Testes | Acerta/erra no limite (total = defesa acerta); 20 natural acerta mesmo abaixo da CA; 1 natural erra mesmo acima; crítico dobra o dado; Golpe Perfurante −1 CA; Vermelho→CA, Amarelo→CAM; erro não causa dano nem passiva mas avança a Corrente; controle/cura/surto não rolam acerto; inimigo erra/acerta; CA 13/CAM 12 do Durvall. |

## 6. Decisões

Todas resolvidas em 2026-09-19: itens 1–8 aprovados como recomendados, com as alterações do §1 (nome "Surto de Ação", d20 crítico de 1,8 s, crítico dobra a quantidade de dados). Kayron/Sylas/Maelor usam as mesmas fórmulas quando entrarem.

## 7. Fora do escopo

Armadura por equipamento (bônus de item), bônus de proficiência, vantagem/desvantagem, resistências/imunidades, testes de resistência (saving throws), reações, ataques em área, arma equipada do Durvall como carta.

## 8. Critérios de aceite

- [x] Um ataque só causa dano se `d20 + bônus ≥ defesa` (ou 20 natural); errar não causa dano nem bônus psiônico e avança a Corrente.
- [x] Vermelho enfrenta a CA e Amarelo a CAM; controle/cura/surto não rolam acerto.
- [x] Golpe Perfurante ignora 1 ponto de CA.
- [x] Crítico dobra a **quantidade** de dados de dano (carta e bônus psiônico), cada um visível na tela, e o total segue a fórmula normal; 1 natural sempre erra.
- [ ] O d20 de acerto dura 1,3 s e 1,8 s em 20 natural.
- [x] Rolagem com vários dados (ex.: bônus psiônico 2d6) nunca falha, nem mostra valor fora das faces.
- [x] O inimigo também rola pra acertar o Durvall (CA 13 / CAM 12).
- [x] A tela mostra o d20 de acerto, o resultado ("Acertou"/"Errou"/crítico) e CA/CAM dos dois lados.
- [x] `game/core/` sem pygame; valores de CA/CAM/bônus em dado declarativo.
- [x] Nenhuma mudança na fórmula de dano do canon.

## 9. Ordem de execução (após aprovação)

1. `core`: CA/CAM, `roll_to_hit`, ajustes em `resolve_attack`/`Enemy`/`Card`, com testes.
2. Ligar o turno do jogador (d20 de acerto → dano → impacto) e do inimigo.
3. Versão curta da rolagem 3D; legenda do teste; "Errou"/crítico.
4. CA/CAM no HUD.
5. Playtest de balanceamento (taxa de acerto e dificuldade) e registro em `EVID-00X`.

Conferido em 2026-09-19 contra os testes e o código: marquei só os itens com teste ou implementação correspondente. Aberto: as durações do d20 (1,3 s e 1,8 s) foram trocadas por 1,7 s e 2,2 s na SPEC-008.
