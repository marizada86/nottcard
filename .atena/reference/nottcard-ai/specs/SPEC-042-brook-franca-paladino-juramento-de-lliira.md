---
id: "SPEC-042"
type: "spec"
title: "Brook França (Paladino): Juramento de Lliira, Guarda e Desonra, cartas sagradas e progressão"
status: "approved"
created: "2026-09-19"
reviewed: "2026-09-20"
relations:
  - "[[PERS-brook-franca]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SIS-005-progressao-de-nivel-maestria]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-011-personagem-como-dado-characterdef]]"
  - "[[SPEC-012-maelor-clerigo-da-luz]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
  - "[[SPEC-025-corrente-quebra-no-erro-e-ajustes-durvall-maelor]]"
  - "[[SPEC-038-sylas-malafa-clerigo-das-sombras]]"
  - "[[SPEC-040-kayron-mistico-carga-de-poder-mistico]]"
  - "[[SPEC-044-ajustes-do-playtest-v0.6.0]]"
  - "[[SPEC-047-equipamento-armas-e-armaduras]]"
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
sources:
  - "PERS-brook-franca-ficha-jogavel (Paladino, anão, Azul/Suporte, FOR 12 INT 10 CON 16 CAR 14; passiva Juramento Quebrado aprovada em 2026-09-16)"
  - "Lore pública do vault: afilhado de Bromnor Martelo da Luz, Paladino de Lliira, Martelo da Glória, Redenção Divina, voz pública contra a névoa"
  - "Referência de habilidades: Paladino (D&D 5e): Mãos Consagradas, Punição Divina, Aura de Proteção, Sentido Divino, Juramento"
---

# Brook França (Paladino)

> **Aprovada em 2026-09-20** (`execution_approval: per-spec`). Números são valores
> iniciais de playtest. A ficha não tem cânone reservado ao mestre; ainda assim nenhum texto de carta
> deve antecipar a investigação da morte de Bromnor além do que a ficha já diz.

Contraste com os outros quatro: Durvall multiplica, Maelor amplia, Sylas protege com a cópia, Kayron
carrega. Brook **jura**: a Corrente o cobre de **Guarda** (escudo que absorve dano), mas quebrar a
Corrente de propósito o põe **Em Desonra**, e só a **Redenção Divina** limpa isso. É o personagem que
premia disciplina e pune improviso.

## Referência de design: o que um Paladino faz

| Referência | Vira |
|---|---|
| Golpe com arma + Punição Divina | **Martelo da Glória**, **Punição Divina** |
| Mãos Consagradas (cura por toque) | **Mãos Consagradas** (HC) |
| Aura de Proteção | **Aura de Proteção** (Guarda para si, ver abaixo) |
| Escudo da Fé / resistência | **Escudo da Fé** (reação) |
| Voto de inimizade / desafio | **Desafio Divino** |
| Detectar o Mal e o Bem | **Sentido Divino** (nível 2) |
| Redenção Divina (assinatura, mesa) | **Redenção Divina** (HC; limpa a Desonra) |

## Decisões já aprovadas (ficha, 2026-09-15/16)

1. Classe **Paladino**, raça **Anão**, cor de classe **Azul** (Suporte).
2. Atributos **FOR 12 · INT 10 · CON 16 · CAR 14** → CA 11, **CAM 10**; modificador flat por cor (SPEC-044):
   Azul **+3**, Roxo **+2**, Vermelho **+1**, Amarelo **0**.
3. **Passiva Juramento Quebrado:** em "Desonra", cartas de cura/buff rendem **−50%**; uma carta de
   **Redenção** remove o status na hora.

## Passiva: Juramento de Lliira (`passive_name`)

A ficha liga a Desonra a uma **condição de missão**. Como a fatia atual não tem essa camada, a spec a
traduz para o combate (a ligação com missões fica para a SPEC-034/exploração; ver "Pendências").

Texto de cartão: *"A Corrente de Classe o cobre de Guarda. Quebrar o juramento o deixa Em Desonra: curas e
Guarda rendem metade até jogar Redenção."*

- **Guarda:** reserva de dano absorvido, **teto 6**. Todo dano recebido reduz a Guarda antes dos PV
  (sem transbordo especial: o excedente passa para os PV). Não some entre turnos; zera ao fim do combate.
- **Ganho pela Corrente:** cada carta que **continua** a Corrente (atinge 2x, 3x, 4x) dá **+1 / +2 / +3 de
  Guarda** (o multiplicador menos 1).
- **Corrente e elemento:** cartas `sagrado` também contam para a Corrente (padrão de `chain_elements` do
  Maelor com fogo). O Martelo é **Vermelho** (usa FOR no acerto), então precisa disso para não quebrá-la.
- **Desonra:** ativa quando a Corrente **quebra por escolha do jogador**, isto é, ao jogar uma carta que
  não conta para ela com uma Corrente de 2x ou mais em andamento (Poção Roxa, por exemplo). **Errar o
  acerto não desonra** (SPEC-025 já pune com a quebra; aqui seria dupla punição).
- **Efeito da Desonra:** cura de cartas **−50%** (arredonda para baixo, mínimo 1), ganho de Guarda **−50%**.
  Não afeta dano. A UI mostra o status "Em Desonra" no cartão da passiva.
- **Redenção:** qualquer carta com `redeems=True` (Redenção Divina) remove a Desonra **antes** de resolver
  seu efeito, então a própria cura sai inteira.
- A Desonra **não persiste** entre combates na v1 (nasce limpa); persistir por missão fica para depois.

## Modificador de acerto

Martelo da Glória e Punição Divina são **Vermelhos**: usam **Força** (+1) no acerto, contra a CA do alvo. Sem
`hit_attr_by_element`. Dano pela fórmula da SPEC-044: `ceil(dado × Corrente × compat) + modificador`, com o
modificador de Força (**+1**) uma vez por carta, fora da Corrente, sem dobrar no crítico. O ponto fraco do Brook
é justamente esse: só **+1** de dano flat nas cartas Vermelhas (contra +3 de um Durvall). Cartas Azuis
(cura/controle/reação) não rolam acerto; a cura soma Constituição (**+3**) flat, e o controle (Desafio Divino)
soma o mesmo +3 à redução (mínimo 1), o que o torna o melhor controlador de dano por carta do elenco.

## Cartas do baralho inicial (13)

| Carta | Qtd | Cor | Tipo | Efeito | Elementos | Custo |
|---|---|---|---|---|---|---|
| **Martelo da Glória** | 3 | Vermelho | ataque | 1d8, dano contundente | sagrado | Ação |
| **Punição Divina** | 2 | Vermelho | ataque | 1d4, dano radiante | sagrado, radiante | Ação Bônus |
| **Mãos Consagradas** (HC) | 1 | Azul | cura | 1d8 + Constituição | sagrado | Ação |
| **Escudo da Fé** | 2 | Azul | reação | reação a ataque **físico**: reduz o dano em 1d6 e dá **+1 de Guarda** | sagrado | Reação |
| **Desafio Divino** | 2 | Azul | controle, alvo único | 1d6: reduz o próximo ataque do alvo | sagrado | Ação |
| **Aura de Proteção** | 1 | Azul | proteção | ganha **+3 de Guarda** (sujeito à Desonra) | sagrado | Ação Bônus |
| **Redenção Divina** (HC) | 1 | Azul | cura | remove a Desonra; cura 1d4 + Constituição | sagrado | Ação Bônus |
| **Poção de Cura** | 1 | Roxo | cura | uso único: 1d4 + Constituição (igual aos outros) | — | Ação Bônus |

Total: 3+2+1+2+2+1+1+1 = **13**. Azuis: 7 (Corrente); Vermelhas: 5 (Corrente por `sagrado`); a Poção Roxa
quebra a Corrente e, com 2x+, **desonra**: é a armadilha do baralho.

Notas de balanceamento:
- HC (Mãos Consagradas, Redenção Divina; e, por nível, Sentença de Lliira) seguem a SPEC-009: 1 cópia, saem
  até o fim do combate, voltam no próximo, etiqueta "· HC".
- Segundo Fôlego e Surto de Ação **não** entram no baralho.
- Brook tem o **maior PV efetivo** do elenco em combates longos (Guarda + cura com +3 flat) e o **menor dano**
  (só +1 flat nas cartas Vermelhas). Espera-se combate mais lento e seguro. Ajustar no playtest.

## Cartas por nível (uma cópia cada, entram na run seguinte; SPEC-024)

| Nível | Carta | Cor / custo | Regra inicial |
|---|---|---|---|
| 2 | **Sentido Divino** | Azul, Ação Bônus | Tipo `localizar`: revela nome e dado do próximo ataque do alvo e dá **+3 no acerto** do próximo ataque de Brook contra ele. |
| 3 | **Marca da Retidão** | Azul, Ação | Tipo `enfraquecer`: **CA e CAM do alvo −2** até o fim do combate (acumula, como Luz Reveladora). |
| 4 | **Sentença de Lliira** (HC) | Vermelho, Ação | Ataque em **área** 2d6 radiante, `sagrado`; se Brook estiver com Guarda cheia (6), +1d6. |
| 5 | **Passiva: Voz Contra a Névoa** | — | **1 vez por combate**, a primeira Desonra é **ignorada**. **+2 Carisma** (14→16, teto 18). |

O baralho cresce 13→16 até o nível 4, como os demais.

## Regras novas no `core`

- **Estado do jogador:** `guard` e `guard_cap` (0 em quem não tem a passiva), `dishonored: bool`,
  `dishonor_ignored_used` (gancho do nível 5), no padrão de `last_stand_used`.
- **Campos novos em `Card`:** `grants_guard: int` (Guarda fixa ao jogar, Aura de Proteção e o +1 do Escudo da
  Fé) e `redeems: bool` (Redenção). Reação com redução de dano reaproveita `counter_dice`/`reacts_to` se
  couber; senão um campo `reduces_dice: str`.
- **`CharacterDef`:** `guard_cap: int = 0` (0 = sem Guarda) e `chain_elements=("sagrado",)`.
- **Dano ao jogador:** passa por `apply_damage_to_player` (a mesma função planejada na SPEC-038, único ponto
  que decide Guarda, cópia, ganchos). Se a SPEC-038 já a criou, Brook só adiciona o passo da Guarda antes
  dos PV; se não, esta spec cria o ponto único e a SPEC-038 herda.
- **Corrente:** onde o multiplicador atinge 2x+, `player.gain_guard(mult - 1)`. Onde a Corrente quebra por
  carta de fora com streak ≥ 2, `player.dishonor()` (respeitando o gancho do nível 5).
- **Cura:** um único helper aplica o −50% da Desonra (toda cura de carta passa por ele), sobre o total já com o
  modificador flat de Constituição (ex.: 1d8 + 3, média 7,5 → 3 com Desonra).
- **Atributos:** `BROOK_ATTRIBUTES` segue o padrão de `CharacterDef.color_modifier` (SPEC-044); nada de
  `color_bonus` percentual.
- **Equipamento (SPEC-047):** armadura e arma equipadas entram como nos demais personagens; a Guarda é um
  escudo à parte da CA, sem interação. Sem cartas de arma próprias do Brook na v1.

## Interação com SPEC-037 (grupo)

A Guarda e a Desonra são **por personagem**. Nada de Guarda compartilhada na v1. O Redenção Divina é
sempre em si mesmo.

## Interface e arte

- `game/ui/`: barra/ícone de Guarda junto do retrato (escudo com número), status "Em Desonra" no cartão da
  passiva (`passive_card.py`, cor azul-aço, tom apagado quando Desonrado), aviso "Desonrado!" e "Redenção!".
- **Tutorial** (`tutorial_content.py`): parágrafo de Brook com Guarda e Desonra.
- **Seleção de personagem** entra pelo `CHARACTERS` (SPEC-011), sem mexer na tela.
- **Arte**, com fallback de retângulo com nome: retrato `assets/portraits/brook.png`, emblema
  `assets/hud/passiva_brook.png`, ícone `assets/hud/guarda_icon.png`, 7 cartas novas + 3 de nível. Prompts em
  `.atena/generated/ART-PROMPTS-009-brook-franca-2026-09-19.md` (gerados só após a aprovação), seguindo
  `SIS-004`. `asset_id` explícito: `martelo_da_gloria`, `punicao_divina`, `maos_consagradas`,
  `escudo_da_fe`, `desafio_divino`, `aura_de_protecao`, `redencao_divina`, `sentido_divino`,
  `marca_da_retidao`, `sentenca_de_lliira`.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/attributes.py` | `BROOK_ATTRIBUTES`. |
| `game/core/cards.py` | 10 cartas novas, `build_brook_deck`, campos `grants_guard`, `redeems`. **Mudança de core.** |
| `game/core/state.py` | `guard`, `dishonored`, `dishonor_ignored_used`, `gain_guard`, `dishonor`, `redeem`. |
| `game/core/combat.py` | Guarda antes dos PV, Desonra na quebra por escolha, helper de cura com −50%, Redenção. |
| `game/core/characters.py` | `BROOK` (`chain_elements=("sagrado",)`, `guard_cap=6`, `level_rewards`, gancho `dishonor_ward`) e registro em `CHARACTERS`. |
| `game/ui/` | Guarda, status de Desonra, etiquetas, passiva, tutorial. |

### Testes

- Baralho de 13 (16 no nível 4), sem Segundo Fôlego/Surto; HC saem e voltam no combate seguinte.
- Corrente 2x/3x/4x dá +1/+2/+3 de Guarda, com teto 6; dano consome a Guarda antes dos PV.
- Martelo (Vermelho, `sagrado`) mantém a Corrente; Poção Roxa com streak ≥ 2 desonra; com streak < 2 não.
- Errar o acerto quebra a Corrente e **não** desonra.
- Desonra: cura e Guarda pela metade (mínimo 1), dano intacto; Redenção remove antes de curar e cura inteira.
- Escudo da Fé reduz ataque físico (+1 Guarda) e não reage a mágico.
- Nível 5: a primeira Desonra do combate é ignorada; CAR 16, teto 18.
- Fórmula flat: Martelo 1d8 na Corrente x1 soma +1 (Força); Mãos Consagradas soma +3 (Constituição); Desafio
  Divino soma +3 à redução; o crítico dobra só os dados; a Desonra corta a cura já somada.
- Durvall, Maelor, Sylas e Kayron continuam idênticos (`guard_cap == 0`).

## Pendências (decisões do responsável)

> Revisada em 2026-09-20 para o modificador flat (SPEC-044). Cada item traz a recomendação; aprovar a spec
> aprova todas, salvo o que for marcado como diferente. Retrato do anão idoso já decidido (PLAN-001).

1. **Gatilho da Desonra:** recomendo **quebrar a Corrente por escolha** (proposto). Alternativas: qualquer
   carta Roxa, ou só por condição de missão (como na ficha), deixando a passiva inerte até existirem missões.
2. **Guarda × cópia do Sylas:** irrelevante enquanto não há grupo; na SPEC-037, a ordem seria Guarda, depois
   Cópia, depois PV.
3. **Teto da Guarda:** 6 (proposto). Com 20 PV, é 30% da vida; pode ser 4 se ficar forte.
4. **Desonra entre combates:** proposto **não persistir**. Persistir por missão precisa da SPEC-034.
5. **Sentença de Lliira** como Vermelha (proposto, mantém a Corrente via `sagrado`) ou Azul.
6. **Nível 5:** +2 Carisma (proposto, reforça o "voz pública") ou +2 Constituição.
7. **Cor da classe Azul repete a do Maelor:** aceito pela ficha; a diferenciação é pela Guarda, não pela cor.

## Fora do escopo

Missões além da M1; Desonra ligada a condições de missão; Martelo da Glória como item equipável (SPEC-036);
Bromnor, Gilly e Arlindo como diálogo; balanceamento fino (playtest).

## Critérios de aceite

- [ ] Brook aparece na seleção de personagem, com passiva, PV e baralho de 13 cartas.
- [ ] Guarda, Desonra e Redenção funcionam como especificado, sem alterar os outros quatro personagens.
- [ ] As 13 cartas do baralho (7 novas) e as 3 de nível funcionam, com etiquetas e "· HC".
- [ ] Nível 5 libera Voz Contra a Névoa e o bônus de atributo.
- [ ] `core` sem pygame; todos os testes existentes continuam passando.
- [ ] Números registrados em EVID após playtest.

## Ordem de execução

1. Atributos e `BROOK` sem a passiva (só cartas de dano/cura). 2. Guarda e ganho pela Corrente.
3. Desonra, Redenção e helper de cura. 4. Reação e proteção. 5. Cartas por nível e nível 5. 6. UI.
7. Prompts de arte. 8. Playtest.

## Review record

- Proposed by: Claude, a pedido do responsável em 2026-09-19 ("vamos criar o próximo personagem"; escolha: Brook França).
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20, com as recomendações das pendências e o modificador flat da SPEC-044.
