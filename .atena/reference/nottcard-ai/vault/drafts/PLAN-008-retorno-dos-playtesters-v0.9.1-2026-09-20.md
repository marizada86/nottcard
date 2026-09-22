---
id: "PLAN-008"
type: "plano"
title: "Retorno dos playtesters na v0.9.1: cor da carta, teclas da caminhada, log detalhado e defesa base"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[FB-004-playtest-higor-daniel-hiago-v0.9.1-2026-09-20]]"
  - "[[PLAN-007-ajustes-do-higor-v0.9.1-2026-09-20]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
  - "[[SPEC-007-log-dev-f12]]"
  - "[[SPEC-044-ajustes-do-playtest-v0.6.0]]"
sources:
  - "Responsável, 2026-09-20: plano para o relatório do Higor com o Daniel e o Hiago (FB-004)"
---

# Retorno dos playtesters na v0.9.1

Rascunho: nada aqui é regra até cada spec ser aprovada (`execution_approval: per-spec`). Onde há **[decisão]**, a recomendação vem
primeiro. Este plano complementa o `PLAN-007`; **os dois entram no mesmo build, `v0.9.2`**. Commit, merge e publicação seguem exigindo
aprovação explícita.

## 1. Resumo e ordem

| Ordem | Spec (nova) | Nota | O que entra | Porte |
|---|---|---|---|---|
| 1 | `SPEC-065` Defesa base por personagem | H20 | CA e CAM base como dado de cada personagem; o Kayron sobe primeiro, medido no simulador | P |
| 2 | `SPEC-062` Cor diferente da classe, em destaque | H17 | Selo na carta, linha no detalhe, marca no número de dano e no tutorial | P/M |
| 3 | `SPEC-063` Teclas da caminhada | H18 | Q/E viram, A/D andam de lado (e a tela vira), ajuda no "?" e legenda na tela | M |
| 4 | `SPEC-064` Log de combate detalhado (Ctrl+F12) | H19 | Painel novo no estilo do BG3, sem spoiler, que entra no pacote da evidência | G |

Motivo da ordem: o H20 foi reportado pelos **dois** playtesters e é só número (dado + simulador), então vai primeiro e barato. O H17 e o
H18 são interface. O H19 é o maior (muitos pontos de chamada e dados novos) e depende de o `PLAN-007` (`SPEC-059`) já ter separado o
"estado real" do "estado mostrado", para o log novo não estragar o suspense dos dados.

## 2. H20: os inimigos acertam demais

**Hoje.** A CA é `10 + modificador de Força` e a CAM é `10 + modificador de Inteligência` (`attributes.py:56-63`), lidas em `Player.ca`/`cam`
(`state.py:237-242`), mais armadura equipada. Os inimigos do M1 têm bônus de ataque de +1 a +4 (`enemies.py`), e o teste é `d20 + bônus`
contra a defesa, então **cada ponto de CA ou CAM tira 5 pontos percentuais da chance de o inimigo acertar**.

| Personagem | CA | CAM | Cartas de cura | Chance de um inimigo de +2 acertar (CA / CAM) |
|---|---:|---:|---:|---|
| Durvall | 13 | 12 | 2 | 50% / 55% |
| Sylas | 10 | 13 | 2 (+ Cópia Sombria) | 65% / 50% |
| **Kayron** | **11** | **11** | **2** | **60% / 60%** |
| Maelor | 10 | 11 | 3 | 65% / 60% |
| Brook | 11 | 10 | 3 | 60% / 65% |

**Medição no simulador** (`scripts/simulate.py` do projeto, 300 combates por linha, nível 5; um experimento em memória, **nada foi gravado no
código**). É uma aproximação: não joga Reação, Guarda nem controle. Vitória / PV perdidos:

| Kayron, defesa extra | Porão, livros | Porão, corredor | O ritual (chefe) |
|---|---|---|---|
| +0 (hoje) | 75% / 14,3 | 57% / 17,6 | 41% / 21,5 |
| **+1** | 79% / 13,7 | 65% / 16,6 | 47% / 21,3 |
| **+2** | 81% / 13,3 | 66% / 16,5 | 54% / 20,5 |
| **+3** | 85% / 11,8 | 73% / 16,2 | 55% / 19,9 |
| *Durvall hoje, para comparar* | 90% / 7,9 | 76% / 13,5 | 74% / 13,7 |

Leitura: o Higor e os testadores têm razão (o Kayron perde 17 a 21 PV nas salas difíceis contra 13 do Durvall). Cada ponto ajuda de forma
modesta e a defesa **sozinha não iguala** o Kayron ao Durvall no chefe (55% contra 74% com +3), então o número final é uma calibragem do
Higor, não uma conta fechada. O mesmo experimento mostrou o **Maelor** e o **Brook** em situação pior que o Kayron no simulador
(Brook: 15% no ritual e 30% no corredor), mas eles têm 3 curas e a Guarda/Reação, que o simulador não joga; por isso não os mexo sem
evidência de playtest.

**Proposta.**
- Um campo `defense_bonus` em `CharacterDef` (dado declarativo, como manda a arquitetura), somado à CA e à CAM em `Player.ca`/`cam`. A
  fórmula `10 + modificador` não muda; o bônus é "treino de defesa" do personagem.
- Valor inicial do **Kayron: +2 de CA e +2 de CAM** (11 para 13). Os demais ficam em 0 até haver evidência.
- Rodar o simulador antes e depois e guardar a tabela na evidência; o Higor ajusta com o playtest (o bônus é um número em um arquivo).
- O HUD (nome do personagem: CA e CAM) e o painel de seleção já leem `Player.ca`/`cam`; conferir os textos fixos que citam CA/CAM
  (tutorial de personagens, cópia canônica `SIS-001`, que diz "CA = 10 + modificador"; a divergência é permitida desde 2026-09-18, mas a
  promoção no vault canon precisa da sua aprovação).

**Testes.** O bônus soma à CA e à CAM só do personagem certo; `Player.ca` continua igual sem bônus; o teste de acerto do inimigo usa o novo
valor; o Kayron tem CA e CAM 13 no nível 1; a suíte de simulação continua rodando.

**[decisão]** valor inicial e quem recebe: **Kayron +2** (recomendado); alternativa, também Durvall/Sylas/Maelor/Brook +1 ("quem tem pouca
cura" no sentido do Higor incluiria o Durvall e o Sylas, que também têm 2 curas, mas eles já têm defesa maior).

### 2.1 Revisão do D10 (2026-09-20): equilíbrio de todos os personagens, defesa e PV por nível

O responsável ampliou o D10: o ajuste não é só do Kayron. O objetivo é equilibrar **todos** os personagens, lembrando que **quem tem muita cura já leva vantagem**, e
também passar a **PV base por nível e por classe** no padrão do D&D 5.5 (2024): **média do dado de vida + 1 + Constituição** a cada nível.

**PV por nível.** Dado de vida por classe (2024): Psi-warrior (Guerreiro) d10; Clérigos (Maelor, Sylas) d8; Místico d6; Paladino (Brook) d10. Média fixa do dado = dado/2 + 1
(d6 = 4, d8 = 5, d10 = 6). Nível 1 = dado máximo + mod. de Constituição; cada nível seguinte = média + mod. de Constituição (recalculado com a
Constituição vigente no nível). Como o M1 hoje parte de **20 PV** para todos, e um nível 1 puro do D&D (7 a 13 PV) ficaria abaixo da escala do jogo, o nível 1 ganha uma
constante de escala do jogo **K = 10** (calibrada para a média do grupo continuar perto de 20).

| Personagem | Dado | Con | Nível 1 (K+dado+Con) | Por nível | Nível 5 | Hoje |
|---|---|---:|---:|---:|---:|---:|
| Durvall | d10 | +1 | 21 | +7 | 49 | 20 |
| Maelor | d8 | +3 | 21 | +8 | 53 | 20 |
| Sylas | d8 | +2 | 20 | +7 | 48 | 20 |
| Kayron | d6 | +1 | 17 | +5 | 37 | 20 |
| Brook | d10 | +3 | 23 | +9 | 59 | 20 |

**Cuidado.** A tabela é a aplicação literal do padrão e **quase dobra os PV no nível 5**; sem ajustar o dano dos inimigos e as CDs, o jogo fica fácil. Por isso os números
são **provisórios**: a `SPEC-060` os calibra no simulador (`scripts/simulate.py`, 300 combates por nível, todos os personagens, salas e chefe) e o Higor confirma. Se a curva ficar
alta demais, a saída é uma escala do jogo aplicada ao ganho por nível (por exemplo, 60%), sem mudar a regra "média + 1 + Constituição". A fórmula fica em dado declarativo
(`hit_die` no `CharacterDef`, `hp_at(level)` no núcleo puro), e o bônus de conquista (+2 da Fechadura) e o upgrade Vitalidade continuam somando por cima.

**Defesa base (CA e CAM) por personagem.** Regra: **quanto menos cura, mais defesa**; quem tem 3 curas ou Guarda não recebe. Ponto de partida (provisório, a calibrar no simulador):

| Personagem | Cura | CA hoje | CAM hoje | Bônus proposto | CA / CAM final |
|---|---|---:|---:|---|---|
| Kayron | 2 | 11 | 11 | **+2 CA, +2 CAM** (fica decidido) | 13 / 13 |
| Sylas | 2 + Cópia | 10 | 13 | +1 CA, 0 CAM | 11 / 13 |
| Durvall | 2 | 13 | 12 | 0 CA, +1 CAM | 13 / 13 |
| Maelor | 3 | 10 | 11 | 0 | 10 / 11 (compensado pelo PV alto) |
| Brook | 3 + Guarda | 11 | 10 | 0 | 11 / 10 (compensado pelo PV alto) |

**Como o D14 muda:** o Maelor e o Brook deixam de ficar sem ajuste; o PV por classe os favorece (Con +3), e o simulador decide se algum precisa de defesa ou se o Kayron precisa de mais que +2.
O valor final de cada personagem é do Higor, ajustado com as tasks de playtest.

**Testes acrescentados à SPEC-065.** `hp_at(level)` bate com a tabela nos 5 níveis de cada personagem; o dado de vida vem do personagem; a Constituição vigente entra no cálculo; o
bônus de conquista e a Vitalidade somam por cima; `Player.max_hp` no nível 1 segue no intervalo esperado; tabela do simulador antes e depois guardada na evidência.

## 3. H17: cor diferente da classe, em destaque

**Hoje.** Fora da cor da classe, o ataque e o controle valem ×0,5 (`combat.py:233` e `:359`; pergaminhos não sofrem). O jogador só descobre
lendo o **log F12** ("compat 0.5") ou a frase do tutorial ("de outra cor, com 50% de eficiência", `tutorial_content.py:88`). Nada aparece
na carta nem no número de dano. A linha "Corrente: não conta" no detalhe da carta (`cards_widget.py:213-220`) já existe, então a peça
vizinha está lá.

**Proposta** (não depende só de cor; texto e forma além do tom):
- **Selo na carta da mão:** um pequeno selo "×0,5" num canto das cartas de ataque e de controle de outra cor, no padrão do selo "USO ÚNICO"
  (`_draw_single_use_badge`).
- **Detalhe ao passar o mouse:** uma linha nova em `detail_lines`: "Cor diferente da classe: dano ×0,5".
- **No dano:** o número flutuante ganha uma legenda curta "cor diferente ×0,5" sob o valor (`damage_fx.py`), e a mensagem do combate diz o
  mesmo uma vez por jogada.
- **Tutorial:** a página de cores mostra o selo e a regra com um exemplo numérico.
- O selo some para cartas que não sofrem a penalidade (cura, pergaminho, cor da classe).

**Testes.** O selo aparece só para ataque/controle de outra cor; o detalhe e a legenda do dano aparecem nesses casos e não nos outros; o
número de dano continua igual (só se mostra mais informação).

**Arte.** Nenhuma nova (selo e legenda desenhados em código).

**[decisão]** onde destacar: **selo + detalhe + legenda no dano + tutorial** (recomendado) ou só parte disso.

## 4. H18: teclas da exploração livre (caminhada)

**Hoje.** A caminhada usa W/↑ avançar, S/↓ recuar, **A/← virar à esquerda, D/→ virar à direita** e X meia-volta (`walk_screen.py:139-141`);
os botões da tela dizem "Virar (A)", "Avançar (W)", "Recuar (S)", "Virar (D)" (`walk_screen.py:90`). O tutorial "?" **não tem** uma página
de exploração (só "Mouse e pausa", "Dicas e atalhos" etc.), e o guia do playtester também não cita as teclas da caminhada.

**Proposta.**

| Tecla | Hoje | Novo |
|---|---|---|
| W ou ↑ | avançar | avançar |
| S ou ↓ | recuar | recuar |
| **Q** ou ← | (só ←) virar à esquerda | virar à esquerda |
| **E** ou → | (só →) virar à direita | virar à direita |
| **A** | virar à esquerda | **andar para a esquerda** (vira 90 graus e dá o passo) |
| **D** | virar à direita | **andar para a direita** (vira 90 graus e dá o passo) |
| X | meia-volta | meia-volta |

- **A/D no núcleo:** o `Walker` é a regra pura (`walker.py`); ganha `strafe_left()` e `strafe_right()` (girar e andar, com os eventos `Turned`
  e `Moved`/`Blocked`). A tela já enfileira comandos (`self.queue`), então o giro anima primeiro e o passo depois.
- **Parede:** se a célula do lado é parede, a tela vira e "bate" (o giro acontece e o passo é bloqueado), o que mostra ao jogador que ali
  não dá para ir.
- **Segurar a tecla:** hoje segurar repete o comando. Segurar **A** ou **D** repetiria "girar e andar" sem parar (o jogador daria voltas).
  Proposta: o primeiro toque gira e anda; **segurando, só repete o passo à frente** na nova direção, até soltar.
- **Botões da tela:** "Virar (Q)", "Esquerda (A)", "Avançar (W)", "Recuar (S)", "Direita (D)", "Virar (E)", e uma legenda curta das
  teclas (W/↑ avançar, S/↓ recuar, Q/E virar, A/D lado, X meia-volta, M mapa).
- **Ajuda:** uma página nova no tutorial "?" ("Explorar"), com as teclas acima e as setas; o tutorial abre nela quando o "?" é clicado
  na caminhada. O guia do playtester ganha a linha das teclas de caminhada.

**Testes.** No núcleo: `strafe_left` vira e anda; contra a parede vira e bloqueia; a posição e a direção finais estão certas nas 4 direções.
Na tela: cada tecla dispara o comando novo; segurar A repete só o passo; as setas continuam valendo; "Exploração: portas" (modo clássico)
não é afetada.

**Arte.** Nenhuma.

**[decisão]** (1) segurar A/D repete só o passo à frente (**recomendado**) ou gira e anda toda vez; (2) seis botões na tela (**recomendado**)
ou só a legenda de teclas.

## 5. H19: log de combate detalhado (Ctrl+F12)

**Hoje.** O F12 já mostra o cálculo de cada jogada (`devlog.py`, `describe_attack` e as irmãs): teste de acerto, dados, Corrente, fórmula,
passiva, total. É uma ferramenta de desenvolvimento, em linhas técnicas, e as linhas aparecem **na hora**, não quando o dado revela.
Faltam, para o objetivo do Higor: **o tipo/elemento do dano**, **de onde vem cada modificador** (atributo, Força Bruta, cor, Corrente, equipamento,
Bênção), **de quem é cada rolagem** dita em linguagem natural, **a composição da CA/CAM do alvo** (base, armadura, Romper Armadura, Luz
Reveladora), **quem sofreu o quê** (PV antes e depois, efeitos), as **Reações** e os **testes da exploração** (d20 + atributo contra a CD).
O log já entra no pacote da evidência (`evidence_export.py:93`).

**Proposta** (estilo do chat de combate do Baldur's Gate 3: um relato legível, cronológico, com quem, o quê e por quê):
- **Ctrl+F12** abre um painel novo, **"Log de combate"**, à esquerda/inferior, maior e com rolagem, separado do F12 (que **fica como está**).
- Uma linha por acontecimento, colorida por quem age (grupo, inimigos), com cada modificador listado com a origem. Exemplo:
  > **T3 · Durvall** usa *Golpe* em Slime Corrosivo.
  > Acerto: d20 **14** + Força **+3** = **17** contra CA **12** (10 + 1 armadura + 1 …) → **acertou**.
  > Dano físico: 2d6 [**4**, **3**] = 7 × Corrente **2** × cor **1,0** × Força Bruta **1,04** → 15, +3 Força = **18**.
  > Slime Corrosivo: PV 12 → **0**. Eliminado.
- Cobre: ataques, áreas, curas, controle, atordoamento, Localizar, Reações, ataques dos inimigos (**quem rolou** o d20 e o dano), efeitos de
  estado, recursos (Corrente, Poder Místico, Cópia, Guarda) e os testes de d20 da exploração.
- **Sem spoiler:** as linhas entram **no momento da revelação** (na batida em que o dado para e no impacto), usando a mesma sincronização
  do `SPEC-059`, para o log novo não repetir o problema do H16. O F12 continua imediato (é ferramenta de desenvolvimento).
- **Dados que faltam no `core`:** o tipo de dano (o `Card.elements` já tem fogo, radiante, psiônico...; físico e mágico vêm da cor) e a
  decomposição da CA/CAM (`Player.defense_breakdown()` e o equivalente do inimigo, puros e testáveis). Estruturar cada acontecimento como
  um registro (`CombatEvent`) evita duplicar as fórmulas, e o F12 e o painel novo consomem os mesmos números.
- **Evidência:** o pacote do F7 ganha o `log-de-combate.txt` (com o mesmo filtro de dados pessoais do log atual).
- **Rolagem e filtros:** rolar com a roda, botão para copiar o trecho para o bloco de notas (F5); filtro por personagem fica para depois.

**Testes.** Puros: cada `narrate_*` recebe um resultado e devolve as linhas esperadas (com modificadores, tipo de dano e quem rolou); o
painel abre com Ctrl+F12 e não com F12; as linhas só aparecem quando a batida corresponde (teste de sequência); o `.zip` contém o arquivo.

**Arte.** Nenhuma nova.

**[decisão]** escopo do primeiro corte: **combate completo + testes da exploração**, sem filtros (recomendado); os filtros e a exportação
formatada ficam para depois.

## 6. Como os dois planos se encaixam

- **Mesmo arquivo, specs diferentes:** o `tutorial_content.py` é tocado por três specs (`SPEC-060` "Ação Bônus", `SPEC-062` cores,
  `SPEC-063` exploração). Faço em sequência, uma spec por vez, para não haver conflito.
- **`SPEC-064` depende da `SPEC-059`** (a sincronização por batidas). Por isso o log é o último.
- **A `SPEC-061` (Mão Maior, `PLAN-007`)** é independente.
- **Ordem única do build `v0.9.2`:** 065, 059, 062, 060, 063, 061, 064.

## 7. Build v0.9.2

Igual ao `PLAN-007`, seção 7, agora com as oito notas (H13 a H20): specs aprovadas, implementação com testes primeiro, suíte inteira verde
(o teste da caminhada que já falha na linha de base precisa de decisão, ver o `PLAN-007`), auditoria dos assets, `game/version.py` para
`0.9.2`, `python scripts/build_local.py` e evidência. **Sem commit e sem publicar** até você aprovar.

## 8. Decisões, para aprovar em bloco

| # | Decisão | Recomendação |
|---|---|---|
| D10 | **Revisado:** defesa base e PV por nível para todos os personagens (dado de vida + 1 + Con, K = 10 no nível 1), Kayron +2/+2, calibrado no simulador (seção 2.1) | **Aprovado** |
| D11 | Cor diferente: selo na carta, linha no detalhe, legenda no dano e no tutorial | **Aprovado** |
| D12 | Caminhada: Q/E viram, A/D andam de lado e viram, segurando repete só o passo, seis botões, página nova no "?" | **Aprovado** |
| D13 | Log detalhado: Ctrl+F12, sem spoiler, com os testes da exploração e no pacote da evidência; F12 inalterado | **Aprovado** |
| D14 | Maelor e Brook: entram no equilíbrio da seção 2.1 (PV por classe); defesa só se o simulador pedir | **Aprovado** (absorvido pelo D10) |
