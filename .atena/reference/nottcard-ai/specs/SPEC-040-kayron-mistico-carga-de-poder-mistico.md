---
id: "SPEC-040"
type: "spec"
title: "Kayron (Místico): Carga de Poder Místico, cartas psíquicas/celestiais e progressão"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[PERS-kayron]]"
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[SIS-005-progressao-de-nivel-maestria]]"
  - "[[SPEC-009-habilidade-de-classe-hc]]"
  - "[[SPEC-011-personagem-como-dado-characterdef]]"
  - "[[SPEC-019-destaque-da-corrente-de-classe]]"
  - "[[SPEC-024-cartas-e-passivas-por-nivel]]"
  - "[[SPEC-038-sylas-malafa-clerigo-das-sombras]]"
sources:
  - "PERS-kayron-ficha-jogavel (Místico, aasimar elfo, Roxo/Universal, FOR 12 INT 12 CON 12 CAR 14; passiva Carga de Poder Místico aprovada em 2026-09-14)"
  - "Lore pública do vault: aasimar ligado a Shar, lê inscrições abissais, dano radiante e psíquico em área, sangue celestial, forma estrelada"
  - "Referência de habilidades: classe Mystic (Unearthed Arcana, D&D 5e): Pontos de Psi, disciplinas, foco psíquico; traços de aasimar (mãos curativas, resistência celestial, revelação)"
---

# Kayron (Místico)

> **Aprovada em 2026-09-19** (responsável do projeto; pendências resolvidas pelas recomendações da spec). Números são valores
> iniciais de playtest. **Nenhum texto de carta usa cânone reservado ao mestre**: quem é a voz na
> estrela, o treinamento aos dez anos e o evento de 1688 ficam de fora (ver "Notas de designer" da
> ficha). Nada de texto dizendo que Kayron "sabe" quem ela é.

Contraste com os outros: cor da classe **Roxo (Universal)**, o baralho quase inteiro é da cor da
classe e a Corrente quase nunca quebra, **mas ela não multiplica dano**. Em vez disso, ela **carrega**
uma reserva (a Carga de Poder Místico, PPM) que os ataques "com Poder Místico" gastam. Durvall
multiplica na hora, Maelor amplia tudo, Sylas protege com a cópia; Kayron **guarda e descarrega**.

## Referência de design: o que um Místico faz

A classe Mystic (UA) roda em Pontos de Psi, com disciplinas e um "foco" que dá bônus enquanto
sustentado. Traços de aasimar: mãos curativas, resistência celestial e uma revelação (asas, aura).

| Referência | Vira |
|---|---|
| Pontos de Psi (recurso acumulado e gasto) | a **Carga de Poder Místico** (a passiva) |
| Disciplina de ataque mental / lâmina psíquica | **Lança Mística**, **Lâmina Psíquica** |
| Pulso/explosão psíquica em área | **Pulso Psíquico**, **Descarga Estelar** |
| Foco/meditação | **Foco Psiônico** |
| Mãos curativas (aasimar) | **Mãos Celestiais** |
| Sangue celestial como custo (lore) | **Sangue Celestial** |
| Mente vazia / defesa mental | **Mente Vazia** |
| Perturbar a mente em área (lore: psíquico em área com debuff) | **Ruído Mental** |
| Lê inscrições abissais (lore) | **Leitura Abissal** (nível 2) |
| Asas negras (arte aprovada) | **Asas Negras** (nível 3) |

## Decisões já aprovadas (ficha, 2026-09-14)

1. Classe **Místico**, raça **Aasimar (elfo)**, cor de classe **Roxo (Universal)**.
2. Atributos **FOR 12 · INT 12 · CON 12 · CAR 14** → CA 11, **CAM 11**; bônus de cor: Roxo **+40%**,
   Vermelho/Amarelo/Azul +20% cada.
3. **Passiva:** as Correntes de Classe de Kayron **não aplicam dano imediato**. Ele acumula Pontos de
   Poder Místico, e alguns ataques gastam esse acúmulo para atacar "com Poder Místico".

## Passiva: Carga de Poder Místico (`passive_name`)

Texto de cartão: *"A Corrente não multiplica: ela carrega. Cada carta em Corrente gera Poder Místico, e os
ataques místicos o gastam para bater mais forte."* Valores propostos (pontas soltas em "Pendências"):

- **A Corrente de Kayron não multiplica** dano, cura nem controle: para ele o multiplicador vale sempre 1x
  (`chain_mode="carga"` em `CharacterDef`). A Corrente segue existindo (mesmas regras de avanço e quebra, indicador
  da SPEC-019 mostrando 1x a 4x).
- **Ganho:** cada carta que **avança** a Corrente gera PPM igual ao nível da Corrente que ela atingiu
  (**+1, +2, +3 ou +4**). Quebrar a Corrente **não** zera a reserva.
- **Reserva:** começa em **0** em cada combate e **não passa de 8** (teto; sobe pelo nível 5).
- **Gasto:** uma carta "com Poder Místico" (`spends_mystic = N`) gasta **até N PPM** (o que houver) e
  causa **+1 de dano por PPM gasto**, somado depois da conta normal, sem passar por compat ou por bônus de
  cor. Em crítico só os dados da carta dobram; o bônus de PPM não. Errar o teste de acerto **não gasta** PPM.
- **Cores:** como quase tudo é Roxo (a cor da classe), quase todas as cartas mantêm a Corrente. A Poção Roxa
  também. Cartas de outra cor causam 50% de dano, mas o baralho inicial não tem nenhuma.
- A UI mostra a **reserva** (barra ou pips) ao lado da Corrente, com preview de "+X dano" ao mirar uma carta
  com Poder Místico.

## Modificador de acerto

Cartas de ataque Roxas hoje **não rolam acerto** (`hit_attribute` só cobre Vermelho e Amarelo). Para Kayron,
proponho que **ataques Roxos rolam d20 + Carisma contra a CAM** do alvo, coerente com `COLOR_ATTRIBUTE`
(Roxo → Carisma). Vale só para personagens com ataque Roxo; Durvall e Maelor não mudam.

## Cartas do baralho inicial (13)

| Carta | Qtd | Cor | Tipo | Efeito | Custo |
|---|---|---|---|---|---|
| **Lança Mística** | 3 | Roxo | ataque | 1d6 psíquico; **gasta até 4 PPM** (+1 por PPM) | Ação |
| **Lâmina Psíquica** | 2 | Roxo | ataque | 1d4 psíquico, sem gasto de PPM | Ação Bônus |
| **Pulso Psíquico** (HC) | 1 | Roxo | ataque em **área** | 2d4 em todos; **gasta até 4 PPM** (+1 por PPM em cada alvo) | Ação |
| **Foco Psiônico** | 2 | Roxo | canalizar | **+2 PPM** | Ação Bônus |
| **Sangue Celestial** (HC) | 1 | Roxo | canalizar | perde **2 PV** e ganha **+5 PPM** | Ação Bônus |
| **Mãos Celestiais** (HC) | 1 | Roxo | cura | 1d6 + Carisma | Ação Bônus |
| **Ruído Mental** | 1 | Roxo | controle, **área** | 1d4: reduz o próximo ataque de todos os inimigos | Ação |
| **Mente Vazia** | 1 | Roxo | reação | reação a ataque **mágico**: reduz o dano em 1d8 + Carisma | Reação |
| **Poção de Cura** | 1 | Roxo | cura | uso único: 1d4 + Constituição (a mesma dos outros) | Ação Bônus |

Total: 3+2+1+2+1+1+1+1+1 = **13**. As três HC (Pulso Psíquico, Sangue Celestial, Mãos Celestiais) seguem a
SPEC-009: 1 cópia, saem até o fim do combate, voltam no próximo, etiqueta "· HC". **Segundo Fôlego, Surto de
Ação, Atordoar e Chama Sagrada não entram** (são de outros personagens).

Notas de balanceamento:
- Sem multiplicador, o dano por carta é **baixo** (1d6 × 1,4 ≈ 5); o ganho está em juntar PPM e gastar
  em Lança Mística (até +4) e Pulso Psíquico (até +4 em **cada** alvo).
- **Foco Psiônico e Sangue Celestial** trocam Ação Bônus por reserva. O Sangue custa PV, o que faz sentido
  para um personagem que "fornece sangue celestial" nos rituais do grupo.
- A cura é modesta (só Mãos Celestiais e a Poção); ele compensa com a Mente Vazia e o Ruído Mental.

## Cartas por nível (uma cópia cada, entram na run seguinte; SPEC-024)

| Nível | Carta | Cor / custo | Regra inicial |
|---|---|---|---|
| 2 | **Leitura Abissal** | Roxo, Ação Bônus | Tipo `localizar`: revela nome e dado do próximo ataque do alvo (`peek_action`), **+2 no acerto** do próximo ataque de Kayron e **+2 PPM**. |
| 3 | **Asas Negras** | Roxo, Reação | Reação a ataque **físico**: reduz o dano em **2d4** e gera **+2 PPM**. |
| 4 | **Descarga Estelar** (HC) | Roxo, Ação | Ataque em **área**, 1d6 em todos; **gasta toda a reserva** (até 8): +1 por PPM em cada alvo. |
| 5 | **Passiva: Forma Estrelada** | — | O teto da reserva sobe de **8 para 10**. **+2 Carisma** (14→16, teto 18). |

O baralho cresce 13→16 até o nível 4, como Durvall e Sylas.

## Regras novas no `core`

- **Elementos** em `Card.elements`: `psíquico` (ataques, controle) e `radiante` (Descarga Estelar,
  Mãos Celestiais). Só etiqueta (SIS-002); sem regra por elemento.
- **`CharacterDef`:** `chain_mode: str = "multiplicador"` (`"carga"` para o Kayron) e
  `charge_cap: int = 8`. O nível 5 sobe o teto por gancho (`charge_cap_plus2`).
- **`Card`:** `spends_mystic: int = 0` (máximo de PPM gasto), `grants_mystic: int = 0` (PPM fixo
  ao jogar), `self_damage: int = 0` (custo em PV do Sangue Celestial) e o tipo novo `canalizar`
  (só ganha PPM e avança a Corrente; não tem alvo).
- **`ComboTracker`:** `multiplier_for` devolve 1 se `chain_mode == "carga"`; um `mystic_power` novo
  soma o ganho ao avançar e nunca é zerado pela quebra. O gasto é um método à parte (`spend_mystic(n)`),
  chamado por `resolve_attack`/`resolve_area_attack` **só quando acertam**.
- **`_attack_outcome`:** soma `bonus_mistico` depois de `dano_carta` (novo campo em `AttackResult`, exibido no
  log dev e na UI).
- **`hit_attribute`:** Roxo devolve `"carisma"`; teste contra a CAM.
- **Reação** com PPM (`Asas Negras`, `Mente Vazia` no nível 1 sem PPM): usa `grants_mystic` no ponto onde a
  reação já é resolvida em `combat.py`.

## Interação com SPEC-037 (grupo) e SPEC-038

A reserva é **por personagem**, como a Corrente. Nada aqui muda a Cópia Sombria do Sylas; as duas
passivas são independentes e o `combat.py` só ganha o `chain_mode` e o gasto de PPM.

## Interface e arte

- `game/ui/`: barra/pips da **Carga de Poder Místico** junto à Corrente (SPEC-019), preview de dano extra na
  mira, dano flutuante com o bônus separado, cor da passiva em `passive_card.py` (violeta-prata).
- **Texto do tutorial** e cartão de seleção entram pelo `CHARACTERS` (SPEC-011).
- **Arte** (fallback de retângulo com nome enquanto não existir): retrato `assets/portraits/kayron.png`
  (do conceito `assets/concepts/characters/kayron_fullbody.png`), emblema `assets/hud/passiva_kayron.png`,
  ícone da carga `assets/hud/carga_icon.png`, 8 cartas novas do baralho (a Poção reaproveita a existente) + 3 de
  nível. Prompts em `.atena/generated/ART-PROMPTS-008-kayron-2026-09-19.md`. `asset_id` explícito
  (o `slugify` não trata acentos): `lanca_mistica`, `lamina_psiquica`, `pulso_psiquico`, `foco_psiquico`,
  `sangue_celestial`, `maos_celestiais`, `ruido_mental`, `mente_vazia`, `leitura_abissal`, `asas_negras`,
  `descarga_estelar`.

## Mudanças por camada

| Camada | Mudança |
|---|---|
| `game/core/attributes.py` | `KAYRON_ATTRIBUTES`. |
| `game/core/cards.py` | 11 cartas novas, `build_kayron_deck`, campos `spends_mystic`, `grants_mystic`, `self_damage`, tipo `canalizar`. **Mudança de core.** |
| `game/core/combat.py` | `chain_mode`, `mystic_power`, ganho e gasto de PPM, `bonus_mistico`, acerto Roxo por Carisma, `self_damage`. |
| `game/core/characters.py` | `KAYRON` (com `chain_mode="carga"`, `level_rewards`, gancho `charge_cap_plus2`), registro em `CHARACTERS`. |
| `game/ui/` | Reserva de PPM, preview de bônus, etiquetas de elemento, passiva, tutorial. |
| Testes | Ver abaixo. |

### Testes

- Baralho de 13 (16 no nível 4), só cartas Roxas; HC saem e voltam no combate seguinte.
- Corrente de Kayron **não** multiplica dano, cura nem controle (1x sempre) e o indicador ainda avança.
- Ganho de PPM = nível da Corrente atingido; quebrar a Corrente não zera; teto 8 (10 no nível 5); zera no
  novo combate.
- Carta com Poder Místico gasta `min(N, reserva)`, soma +1 por PPM, **não** dobra no crítico e **não** gasta
  no erro.
- Pulso Psíquico e Descarga Estelar somam o bônus por alvo acertado; Descarga gasta toda a reserva.
- Foco Psiônico dá +2, Sangue Celestial custa 2 PV e dá +5 (e não mata: teto em 1 PV? ver Pendências).
- Acerto Roxo usa Carisma contra CAM; Durvall e Maelor continuam idênticos.
- Asas Negras reduz dano físico e gera PPM; Mente Vazia só reage a ataque mágico.
- Nível 5: teto 10 e Carisma 16 (teto 18).

## Pendências (decisões do responsável)

1. **Ganho de PPM:** "igual ao nível da Corrente" (1 a 4) foi a leitura mais fiel de "as Correntes acumulam".
   Alternativa mais lenta: +1 fixo por carta, +1 extra a partir de 3x.
2. **Persistência:** a reserva sobrevive à quebra da Corrente (proposto) e **zera a cada combate**. Alternativa:
   valer só dentro da Corrente, perdendo tudo quando ela quebra. Fica mais punitivo, mais fiel a "Corrente".
3. **Teto 8:** confere com o custo das cartas (4 + 4)? Sobe para 10 no nível 5.
4. **Acerto Roxo por Carisma vs CAM:** aprovar a extensão de `COLOR_ATTRIBUTE` também para o acerto, ou os ataques
   de Kayron não rolam (sempre acertam)? Recomendo rolar.
5. **Sangue Celestial:** pode deixar Kayron em 1 PV, mas nunca a 0 (proposto). Ou só joga se PV > 2?
6. **PV do Kayron:** 20 como os outros?
7. **"Forma Estrelada" no nível 5:** o nome vem de "forma estrelada" (Sessão 11+) na ficha, fora das
   "Notas de designer". Confirmar que pode aparecer em texto de jogo; senão trocar por "Céu Aberto".
8. **Lore de Shar:** a ficha liga Kayron a Shar. As cartas evitam o nome dela; confirmar se algum texto
   de sabor pode citá-la ("Por Shar" é fala do sacrifício, cena sensível).

## Fora do escopo

Missões além da M1; outros personagens; o Broche Celestial como item (SPEC-036); a "forma estrelada" como
transformação visual completa; balanceamento fino (playtest).

## Critérios de aceite

- [x] Kayron aparece na seleção de personagem, com passiva, PV e baralho de 13 cartas.
- [x] A Corrente dele carrega a reserva sem multiplicar; o gasto por carta segue a regra, sem alterar Durvall,
      Maelor e Sylas.
- [x] As 13 cartas (8 novas) e as 3 de nível funcionam, com etiquetas de elemento e "· HC".
- [x] Nível 5 libera Forma Estrelada e o bônus de atributo.
- [x] `core` sem pygame; todos os testes existentes continuam passando.
- [ ] Números registrados em EVID após playtest.

## Ordem de execução

1. Atributos, `KAYRON`, `chain_mode` e a reserva (só Lança Mística e Foco Psiônico jogáveis).
2. Acerto Roxo por Carisma e o gasto de PPM. 3. Restante do baralho (área, HC, reação, controle).
4. Cartas por nível e nível 5. 5. UI da reserva. 6. Prompts e arte. 7. Playtest.
