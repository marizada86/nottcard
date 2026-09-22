---
id: "PLAN-016"
type: "plano"
title: "M2 — A Praça da Loucura: campanha, dungeon e chefe ritualista"
status: "draft"
created: "2026-09-20"
relations:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
  - "[[SPEC-042-brook-franca-paladino-juramento-de-lliira]]"
  - "[[SPEC-057-exploracao-por-caminhada]]"
sources:
  - "Responsável, 2026-09-20: acrescentar M2 ao jogo"
  - "VSN-003 e VSN-004: escopo canônico de M2 e do Interlúdio A"
---

# M2 — A Praça da Loucura

> Rascunho de produção. Não autoriza implementação: a política do projeto exige SPEC aprovada para cada mecânica.

## Resultado pretendido

Depois de vencer M1, o jogador atravessa o **Interlúdio A**, conhece Brook França e pode iniciar **M2 — A Praça da Loucura**. A missão funciona nos dois modos de exploração existentes (caminhada e portas), preserva M1 como está e termina ao interromper o ritual do sacerdote de A Mente Derretida, que invoca quatro zumbis.

O objetivo não é copiar M1 e trocar arte. A base atual ainda fixa M1 em `CURRENT_MISSION`, `ROOMS`, mapa, dungeon em grade, lore, eventos e recompensa de chefe. Antes de haver duas missões, esses dados precisam ganhar uma fronteira comum.

## Recorte canônico a preservar

| Elemento | Definição para M2 |
|---|---|
| Título | **A Praça da Loucura** |
| Entrada narrativa | Interlúdio A, em Castle Rodhe: o grupo vira Guardiões de Nottgard, recebe os broches; Brook é apresentado formalmente. |
| Objetivo | Rastrear, em Dagruve, o culto A Mente Derretida e interromper seu ritual de procura por um receptáculo. |
| Local | Praça da Loucura: beco sem saída em torno de uma igreja abandonada de Nott; interior da igreja. |
| Inimigos | Cerca de 10–14 cultistas, inclusive arqueiros; sacerdote encapuzado de olho móvel na testa; quatro zumbis invocados dos cadáveres. |
| Pessoas/cenas | Arlindo Orlando como informante; garoto de 15 anos resgatado, sem nome nem revelação adicional. |
| Recompensas narrativas | Mapa de Dagruve que abre M3, poção de força de gigante do gelo, gema elemental e ouro. |
| Limite de spoiler | Não identificar o garoto como receptáculo nem antecipar o segredo do Durvall. |

## Arquitetura-alvo

Criar um catálogo declarativo de missões no `core`, sem `pygame`. Cada `MissionDef` contém somente os dados e fábricas que variam: id, título, pré-requisitos, elenco liberado, salas/encontros, grafo, ponto inicial, dungeon em grade, posições do mapa, lore, eventos permitidos, conclusão, recompensa de chefe e HQ/briefing de saída.

| Hoje, acoplado a M1 | Destino em duas missões |
|---|---|
| `CURRENT_MISSION` e `HQ_BY_MISSION` | missão ativa no `App` + catálogo de campanha e transições por id |
| `ROOMS`, `SITUATIONS`, `CONCLUSAO_XP`, `BOSS_ID` globais | conteúdo da `MissionDef` ativa |
| `worldmap.M1_EDGES`, `dungeon_m1`, posições de `map_view` | dados próprios de M1 e M2, consumidos pelo mesmo `WorldMap`/`Walker` |
| `lore_m1`, arte por sala e eventos elegíveis globais | adaptadores por missão; ids de salas têm escopo de missão |
| `start_run()` sempre cria M1 | `start_run(mission_id, party)` valida desbloqueio e inicializa a missão selecionada |

M1 deve ser migrada primeiro para essa interface, sem alterar seus ids, regras, imagens, seed de eventos ou fluxo. Só então M2 entra como segundo registro. Isso reduz a regressão e transforma M3+ em adição de conteúdo, não em outra refatoração total.

## Proposta de estrutura jogável de M2

A topologia final deve ser fechada na SPEC de conteúdo. Como primeira proposta de balanceamento e ritmo, usar seis espaços conectados, sem bifurcação obrigatória:

1. **Entrada de Dagruve** — briefing curto com Arlindo; escolha social/de atributo para uma pequena vantagem, nunca bloqueio.
2. **Praça externa** — primeira patrulha de três cultistas; apresenta o inimigo comum.
3. **Beco das sentinelas** — dois arqueiros e um cultista; encontro que valoriza cobertura/controle, se a UI suportar, ou combate normal enquanto não suportar.
4. **Porta da igreja** — situação de exploração: pistas do ritual e acesso ao interior; pode conceder item temporário ou ouro.
5. **Nave profanada** — três a quatro cultistas e o garoto cativo visível; a libertação é resolvida na história, não por uma identidade oculta.
6. **Altar da Mente Derretida** — sacerdote; ao cruzar o limiar de PV definido pela spec, anima/reergue quatro cadáveres como zumbis. Vitória só após todos caírem.

Esse desenho totaliza 10–14 cultistas, além do sacerdote e dos quatro zumbis. As DCs, PV, CA/CAM, XP, ouro, quantidade por encontro e recompensas de cartas são números de SPEC/playtest — não ficam congelados neste plano.

### Chefe: a única mecânica realmente nova

O chefe não deve começar com quatro zumbis já presentes, pois a invocação é parte da fantasia e do clímax. A alternativa recomendada é um pequeno `EncounterScript` no `core`: gatilho declarativo por PV do sacerdote, condição de disparar uma vez e lista de inimigos a adicionar. O combate informa o gatilho, cria os quatro `Enemy` e a UI os inclui nos slots antes do próximo turno válido.

O script é deliberadamente estreito: **invocar reforços uma vez**. Não criar, nesta entrega, um sistema geral de IA, fases arbitrárias ou cinematics de chefe. Ele deve ser reutilizável quando M5 precisar de fases, mas só depois de demonstrar valor.

## Campanha, progresso e elenco

1. Acrescentar a `SaveState` o conjunto `missions_completed`; M1 começa liberada e M2 exige `m1` concluída. A versão/migração do save deve tratar saves com `hq_001` visto como M1 concluída; progresso de XP, sozinho, não desbloqueia conteúdo narrativo.
2. Registrar a conclusão de M1 de forma durável no mesmo fluxo que já persiste resultado e oferta pendente. O jogador não deve perder o acesso a M2 se fechar o jogo depois da vitória; uma recompensa de chefe pendente continua obrigatória antes de iniciar outra tentativa.
3. Trocar o botão genérico “Próxima missão” por uma tela/briefing de Missão. No Interlúdio A ela explica a promoção, apresenta Brook e encaminha para M2; depois, a mesma tela poderá listar missões liberadas e replays.
4. A seleção de grupo recebe da missão a lista de personagens disponíveis. M2 libera os cinco: Durvall, Maelor, Sylas, Kayron e Brook; continua respeitando o limite técnico atual de três integrantes.
5. Recompensas persistentes existentes (coleção, equipamentos, upgrades, pergaminhos, moedas e nível) atravessam a transição. O mapa de Dagruve é uma recompensa de campanha/narrativa que libera M3, não uma carta aleatória nem um equipamento de combate.

## Decisões para confirmar antes da SPEC

1. **Brook em M1:** recomendo bloqueá-lo numa campanha nova até o Interlúdio A, pois sua apresentação é parte de M2. Para replay de M1, escolher uma política: (a) elenco histórico de quatro, recomendada pela coerência; ou (b) elenco já desbloqueado, mais livre mas anacrônico.
2. **Escolha de missão:** recomendo M2 ser a única continuação após M1, com M1 disponível apenas em “Rejogar”. Não introduzir mapa de campanha ramificado agora.
3. **Interlúdio A:** recomendo uma tela breve de briefing com texto na UI e arte de fallback, em vez de depender apenas da HQ-001, que ainda não apresenta Brook formalmente.
4. **Combate do chefe:** aprovar a invocação de quatro zumbis durante o combate. Se não for desejada uma mecânica de reforço, a alternativa é dividir altar e ressurreição em dois combates, com menor impacto técnico e menor fidelidade dramática.
5. **Mapa de M2:** recomendo seis espaços lineares, com escolhas locais de exploração; uma bifurcação grande é desnecessária antes do playtest de M2.

## Fatiamento proposto em SPECs

| Ordem | SPEC nova | Entrega e dependência |
|---|---|---|
| 1 | Campanha e catálogo de missões | `MissionDef`, M1 portada para o catálogo, desbloqueio/migração de save, seleção/briefing de missão; sem conteúdo de M2 ainda. |
| 2 | M2 — mapa, exploração e narrativa | Salas, grafo, dungeon em grade, modo de portas, lore, situações, eventos e itens narrativos de M2. Depende da 1. |
| 3 | M2 — inimigos, sacerdote e reforços | Cultistas/arqueiros/sacerdote/zumbis, `EncounterScript` mínimo, recompensa de chefe e balanceamento inicial. Depende da 1; integra com a 2. |
| 4 | Arte de M2 | Cenários de combate, texturas/adereços de caminhada, portas, inimigos e HQ/briefing. Pode começar após o layout da 2; lógica usa fallback. |
| 5 | Validação e playtest | Simulações, regressão M1, campanhas novas e saves migrados, playtest humano e ajuste de números. Depende das anteriores. |

Não misturar a arte com os três primeiros itens: a regra de fallback já permite validar toda a missão antes de aceitar os assets finais.

## Testes e critérios de aceite

- M1 continua idêntica nos modos de portas e caminhada, inclusive eventos, HQ, recompensa e replays.
- Save novo só mostra M1; vitória persistida em M1 libera M2; save antigo com `hq_001` visto migra sem perder coleção, equipamentos ou progresso.
- Fechar e reabrir com recompensa de chefe pendente não permite contorná-la e não perde o desbloqueio da missão.
- O Interlúdio A apresenta Brook antes da seleção de M2; ele não aparece antes conforme a política de elenco aprovada.
- M2 pode ser concluída em ambos os modos de exploração; situação, combate, retorno pós-combate, mapa/automapa e overlays seguem funcionando.
- O sacerdote invoca exatamente quatro zumbis uma única vez; não duplica ao recarregar a UI, trocar de alvo ou chegar a 0 PV.
- A vitória exige sacerdote e reforços derrotados; entrega XP, ouro, recompensa de chefe e mapa de Dagruve; derrota/desistência seguem as regras atuais de persistência.
- Testes puros cobrem catálogo, pré-requisitos, migração, mapa e script de encontro; testes de fluxo cobrem a campanha M1 → Interlúdio A → M2 nos dois modos.
- Build empacotada abre sem assets M2 (fallback) e com assets processados; playtest mede duração, dificuldade por grupo e clareza da invocação.

## Riscos e contenção

| Risco | Contenção |
|---|---|
| Refatorar M1 e M2 simultaneamente quebra o jogo estável | Primeira SPEC só porta M1 para o catálogo, com regressão obrigatória antes de criar M2. |
| Salas usam ids numéricos repetidos e vazam dados de M1 | Todo lookup passa pela `MissionDef` ativa; ids externos usam `mission_id:room_id` quando necessário. |
| O chefe com cinco inimigos supera o layout atual | Verificar slots/legendas antes da SPEC; se necessário, reservar posições de reforço e não mudar a regra de alvo. |
| Brook já existe na seleção, em desacordo com a história | Decidir e testar a regra de elenco antes de liberar M2. |
| M2 fica grande demais por querer novos sistemas de stealth/cobertura | Tratar o arqueiro como inimigo normal nesta versão; sistemas novos só entram com benefício comprovado. |
| Conteúdo de M3 vaza para M2 | O mapa de Dagruve só registra o desbloqueio narrativo; M3 não aparece como jogável até sua própria SPEC. |

## Sequência de trabalho após aprovação

1. Aprovar as cinco decisões acima e a SPEC 1.
2. Portar M1 para o catálogo, executar a suíte e fazer um playthrough curto nos dois modos.
3. Aprovar as SPECs 2 e 3 com números iniciais, layout final e a política escolhida para o chefe.
4. Implementar M2 com fallback, validar a campanha completa e só então produzir/ligar arte.
5. Rodar playtest focado em duração, leitura do ritual e dificuldade de cada composição de grupo; registrar ajustes numa evidência antes de balancear de novo.
