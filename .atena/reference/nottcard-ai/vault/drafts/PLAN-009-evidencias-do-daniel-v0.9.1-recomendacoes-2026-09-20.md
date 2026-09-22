---
id: "PLAN-009"
type: "plano"
title: "Evidências do Daniel (v0.9.1): recomendações para o que as SPEC-060 a 066 não cobrem"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[FB-004-playtest-higor-daniel-hiago-v0.9.1-2026-09-20]]"
  - "[[PLAN-008-retorno-dos-playtesters-v0.9.1-2026-09-20]]"
  - "[[SPEC-061-suspense-da-corrente]]"
  - "[[SPEC-062-cor-diferente-em-destaque]]"
  - "[[SPEC-063-guia-sempre-visivel-e-icones-nos-botoes]]"
sources:
  - "evidencias/PLANO-analise-evidencias-Daniel-v0.9.1.pdf (jogador DNA, 4 zips, builds v0.8.0 e v0.9.1, 20/09/2026)"
  - "Responsável, 2026-09-20: a ordem sugerida do plano e as recomendações estão aprovadas; os itens com \"já coberto? não\" são a prioridade"
---

# Evidências do Daniel: recomendações

Rascunho: nada aqui é regra até cada spec ser aprovada (`execution_approval: per-spec`). Os 12 pontos são os do PDF do plano
(`evidencias/PLANO-analise-evidencias-Daniel-v0.9.1.pdf`); reli as notas e os prints dos zips e conferi o código de cada um.
**Novidade importante:** as SPEC-060 a 066 já estão implementadas e no ar na 0.9.3, então a coluna "já coberto?" do PDF mudou (seção 1).

## 1. Situação de cada ponto hoje (0.9.3)

| # | Nota | No PDF | Hoje | Vai para |
|---|---|---|---|---|
| 1 | Atributo ao passar o mouse na opção (exploração) | Não | **Não** | SPEC-067 |
| 2 | "Comprar 1 carta (Bônus)" sem explicação; "Ação usada" | SPEC-063 | **Metade:** o Bônus ganhou a gema e a dica, **mas o botão da Ação não vira "Ação usada"** | Ajuste da SPEC-063 |
| 3 | Sem sinal de fim de turno / turno do inimigo | Não | **Não** | SPEC-068 |
| 4 | Recompensa da exploração (no 20 natural): ver e poder recusar | Não | **Não** | SPEC-069 |
| 5 | Texto das cartas passa do limite | Não | **Não** (e é geral, não só pergaminho) | SPEC-072 (correções) |
| 6 | F5 não abre com o baralho aberto | Não | **Não** | SPEC-072 |
| 7 | Baralho 12 e descarte 12 no turno 1 da 2ª sala | Não | **Não é bug**, é o desenho: falta explicar (ou decidir) | Decisão D15 + tutorial |
| 8 | Crítico em área: não vê os dados dobrados | Parcial | **Só no log (Ctrl+F12)**; na tela os dados saem misturados no centro | SPEC-070 |
| 9 | Só achou o log por acaso | SPEC-063 | **Metade:** o Guia cita "F12 log", mas **não** cita o Ctrl+F12 e não há botão do log | Ajuste da SPEC-063 |
| 10 | Barra de XP cobre a foto na seleção | Não | **Não** | SPEC-071 |
| 11 | Baralho do Kayron: 11 de 21 de outra cor | SPEC-062 (só destaca) | **O selo ×0,5 avisa, mas a composição é a mesma** | Decisão D16 |
| 12 | Texto sob o dado revela o resultado | SPEC-061 | **Provavelmente resolvido** (ver 2.2), a confirmar no playtest | Teste de regressão |

## 2. Recomendação por ponto

### 2.1 Bugs rápidos (fazer primeiro, só com teste de regressão)

**Ponto 6, F5 com o baralho aberto.** Causa: `App.toggle_notepad` sai cedo quando qualquer sobreposição está aberta
(`tutorial`, `pause_menu`, `collection`, `layout_picker`, `backpack_overlay`, `pile_overlay`, `passive_overlay`, `guide`); o "baralho
aberto" do Daniel é o `pile_overlay` (as pilhas clicáveis, SPEC-044). **Recomendação:** o bloco de notas passa a abrir **por cima** de
qualquer sobreposição (ele já é desenhado por último e já captura o input primeiro). Dois cuidados: ao fechar, só retomar a tela de
baixo (`screen.resume()`) se nenhuma outra sobreposição continuar aberta; e o print da nota deve sair com a sobreposição atrás, que é o
que o jogador viu. Testes: F5 abre e fecha sobre cada sobreposição, a sobreposição continua aberta e a tela continua pausada.

**Ponto 5, texto das cartas.** Medi: a nota da carta tem só **44 px** de altura útil (2 linhas na fonte 18), e **11 das 25 cartas
universais medidas estouram** (Ataque Imprudente chega a 5 linhas), então não é só pergaminho. **Recomendação:** em `_draw_card`,
"caber por altura": tentar a fonte 18, 16, 14 e 13 até as linhas caberem; se ainda estourar, cortar com reticências e deixar o texto
completo no painel de detalhe (que já existe). Teste de largura/altura sobre **todas** as cartas (`all_cards()` do catálogo, incluindo
os 18 pergaminhos) em **todos** os 10 layouts, para nenhuma carta nova voltar a estourar.

**Ponto 7, 12 no baralho e 12 no descarte no turno 1 da 2ª sala.** Não é defeito: o baralho da tentativa é o mesmo do começo ao fim
da missão; as cartas usadas na sala anterior ficam no descarte e só voltam quando a compra acaba (`Player.draw` reembaralha).
**Recomendação (decisão D15):** (a) manter e **explicar** (uma linha no tutorial e na dica das pilhas: "o descarte só volta quando o
baralho acaba, e vale a missão inteira"), ou (b) **reembaralhar o descarte no baralho a cada início de combate**, o que deixa cada
sala mais previsível mas tira a pressão de gestão do baralho ao longo da missão. Recomendo **(a)**: não muda a regra e resolve a
dúvida do Daniel; se o Higor preferir (b), é uma linha em `restore_class_abilities` mais teste.

### 2.2 Ajustes nas specs já implementadas

**Ponto 2 (SPEC-063).** Hoje só o botão do Bônus diz "Ação Bônus usada". **Recomendação:** o botão "Comprar 1 carta" da Ação vira
**"Ação usada"** quando não resta Ação (`turn.actions_available == 0`), com a gema apagada, como o do Bônus. E a dica do Bônus passa a
dizer "Gasta a sua Ação Bônus (não é uma carta grátis)". O Daniel também pediu o texto "bonus action": o tutorial e o rótulo de
reserva já dizem "Ação Bônus"; mantenho o termo do jogo em português.

**Ponto 9 (SPEC-063).** **Recomendação:** (a) uma linha nova no Guia e no tutorial: "**Ctrl+F12** abre o log de combate (o passo a
passo de cada jogada); **F12** o log técnico"; (b) um botão **"Log"** ao lado do "Guia" no topo (só na build de playtest), que abre e
fecha o painel, para quem nunca leu o Guia; (c) o toast de primeiro combate ("F5 nota · F6 print · F7 gera o .zip") ganha "· Ctrl+F12 log".

**Ponto 12 (SPEC-061).** Conferi a sequência das batidas: o resultado do d20 (`_show_hit_result`) só sobe no fim do dado, o dano
só entra no `impacto-inimigo`, e agora a Corrente e os recursos esperam a revelação. O print 02 do zip 170435 mostra a barra de Poder
Místico e a Carga já em 5 com o dado ainda na mesa, o que é exatamente o que a SPEC-061 segura; portanto **provavelmente já
resolvido na 0.9.3**. **Recomendação:** um teste de regressão que percorre as batidas de um turno inteiro (ataque de alvo único,
de área e cada tipo de carta) e falha se qualquer texto novo (mensagem, número flutuante, HUD ou log) aparecer antes da batida de
revelação dele, e uma linha na task de playtest para o Daniel confirmar.

### 2.3 Specs novas (execution_approval: per-spec)

**Ponto 1, SPEC-067 "Atributo nas opções da exploração" (P).** Ao passar o mouse na opção de uma situação, mostrar uma dica:
"Carisma +2 (você) contra CD 12" e, com bônus, a origem ("+2 da armadura leve"). Vale também para o **mostrador de chance** implícito
(ex.: "precisa de 10 ou mais no d20"). Núcleo: `exploration.check_preview(player, option)` puro, com o modificador, os bônus (ganchos,
acessório, armadura furtiva) e a chance; a tela só desenha. Testes: cada atributo, bônus de gancho, desvantagem da armadura de placa.
Sem arte.

**Ponto 3, SPEC-068 "Faixa de turno" (P).** Uma faixa curta e destacada no topo do combate, com texto e ícone (não só cor):
"**Seu turno**" (com o nome do personagem ativo no grupo), "**Turno do inimigo**" e, quando o inimigo age, o nome dele. A troca dura
~1,2 s e não bloqueia o input nem acelera/atrasa as batidas (acompanha a velocidade 1x/2x e a pausa). Reaproveita as batidas que já
existem (`fim-turno-jogador`, início do turno inimigo, `_start_turn`); nenhuma regra muda. Testes: a faixa aparece na ordem certa em
combate de 1 inimigo, de 3 inimigos e em grupo; não aparece na exploração; respeita a pausa.

**Ponto 4, SPEC-069 "Recompensa da exploração: ver e recusar" (M).** No código, o 20 natural é só sucesso automático: a
"recompensa" que o Daniel viu é o **desfecho de sucesso** da opção (XP, comprar cartas, um item; `Outcome` em `exploration.py`), que
hoje entra sem o jogador ver o que é nem poder dizer não. **Recomendação:** (1) mostrar a recompensa **na tela** (nome e efeito do item;
a carta comprada; o XP) antes de aplicar, e no texto da opção mostrar de antemão o **tipo** de recompensa (sem revelar qual carta sai
do baralho); (2) botões **"Aceitar"** e **"Recusar"** para o que é opcional (**item** e **cartas**; o XP entra sempre); (3) **recusar
não troca por outra coisa** e a recusa não devolve o d20 nem a Sorte, para não virar "rerrolar de graça". Uma carta recusada não é
comprada (fica no baralho), e o item recusado não vai para a mochila. Núcleo: `apply_result` passa a devolver uma **oferta** com
`accept()` e `decline()` (o item já tem o fluxo "mochila cheia" da SPEC-036). **Decisão D17** (design): permitir recusar, sem troca.
Testes: aceitar entrega, recusar não entrega e não cobra nada, o XP entra nos dois casos, item com a mochila cheia segue a SPEC-036,
falha crítica não tem recompensa para recusar.

**Ponto 8, SPEC-070 "Dados do crítico em área, por alvo" (M).** O núcleo já dobra certo (o log confirma: 4d4 no alvo do crítico e 2d4
nos outros), mas na tela os d4 de todos os alvos rolam juntos no centro, e o Daniel não sabe quais são de quem. **Recomendação:** em
ataque de área, cada alvo tem o **seu grupo de dados** acima do próprio inimigo (o mesmo lugar do resultado do d20), com o rótulo
"crítico: 4d4" no alvo que dobrou; a rolagem é simultânea e a soma sobe no impacto. Um único alvo mantém o desenho de hoje (dados no
centro). Testes: número de dados por alvo, posição junto do inimigo, crítico em um de três alvos.

**Ponto 10, SPEC-071 "XP na seleção de personagem" (P).** **Recomendação:** mover a barra de XP para **acima do retrato**, numa faixa
própria, para nunca cobrir a foto; texto "XP 40/100 · Nível 2". Teste de layout: o retângulo da barra não intersecta o do retrato
nos 5 personagens e nas 3 resoluções (janela, tela cheia, redimensionada).

**SPEC-072 "Correções pequenas" (P).** Reúne os pontos 5 e 6 numa spec só, para não abrir duas para dois bugs (a regra do projeto
pede spec aprovada antes de mexer, e um bug de interface pede pouco texto).

### 2.4 Ponto 11, baralho inicial do Kayron (decisão de balanceamento, D16)

**Diagnóstico.** O baralho é o mesmo para todo o grupo: o núcleo travado tem 8 cartas (2 Golpe vermelho, 2 Chama Menor amarela,
2 Toque Curativo azul, 2 Poção roxa), mais 6 comuns sorteadas na coleção inicial, mais as cartas de assinatura do personagem. Como o
núcleo é universal, **um Kayron (roxo) só tem as 2 poções da cor dele no núcleo**; o resto do que ele joga com 100% de eficiência vem do sorteio
e da assinatura. Daí os 11 de 21 de outra cor. O selo ×0,5 (SPEC-062) mostra o custo, mas não o resolve.
**Opções, da mais barata para a mais forte:**
1. **Botão "Sugerir baralho para [personagem]"** na tela do Baralho: preenche as vagas livres com cartas da cor da classe da coleção
   (respeitando o núcleo, as 3 cópias e as regras de validade). Não muda a regra nem o sorteio; dá ao jogador o que o Daniel pediu.
2. **Sorteio inicial com peso:** as 6 cartas comuns sorteadas favorecem a cor do primeiro personagem escolhido.
3. **Núcleo por personagem:** cada classe tem o seu núcleo (mais trabalho e muda a SPEC-045).
**Recomendação:** **(1)** agora (baixo risco, reversível), e **(2)** se o playtest ainda mostrar o problema. Fica pendente a **confirmação do
Higor sobre a lista do núcleo** que já estava aberta desde a SPEC-045: é ela que decide quanto de cada cor todo baralho leva.

## 3. Ordem e trabalho (a ordem sugerida do PDF, atualizada)

| Fase | O que | Tipo |
|---|---|---|
| 1 | Bugs 6 e 5 (SPEC-072) e o teste de regressão do ponto 12 | correção + teste |
| 2 | Ajustes da SPEC-063 (pontos 2 e 9): "Ação usada", dica do Bônus, Ctrl+F12 no Guia e botão "Log" | ajuste de spec aprovada |
| 3 | **"Não cobertos" novos:** SPEC-068 (turno), SPEC-069 (recompensa do 20), SPEC-067 (dica de atributo), SPEC-070 (dados do crítico), SPEC-071 (XP) | specs novas |
| 4 | Decisões do responsável: D15 (descarte), D16 (baralho do Kayron), D17 (recusar recompensa) | decisão |

Motivo da ordem dentro da fase 3: a **SPEC-068** e a **SPEC-069** são as que o Daniel mais sentiu (não saber de quem é o turno e não
poder recusar uma carta ruim), e a SPEC-068 é a menor.

## 4. Decisões, para aprovar em bloco

| # | Decisão | Recomendação |
|---|---|---|
| D15 | Descarte entre salas | Manter e explicar no tutorial (a) |
| D16 | Baralho do Kayron | Botão "Sugerir baralho" (1); peso no sorteio só se o playtest pedir |
| D17 | Recusar a recompensa do 20 natural | Permitir, sem troca por outra |
| D18 | Numeração: SPEC-067 a 072 como acima | Sim |

## 5. Arquivamento e limpeza

- **Evidência do Daniel:** copiar os 4 zips (`EV-DNA-*.zip`) para `.atena/evidence/daniel-v0.9.1/` e apagar as pastas extraídas (`ev1`
  a `ev5` e a `EV-DNA-…151943/`): `ev1` e `ev2` são duplicatas do zip 151943, a `ev5` e a pasta do 151943 estão vazias e a `ev4` só tem
  "teste.". O PDF do plano fica junto. Nada disso foi movido ou apagado por mim.
- **Zips de teste na raiz:** a raiz do projeto está com **mais de 30 arquivos `EV-Higor-*.zip`**, gerados pela suíte de testes (o F7
  grava na pasta do executável, que em desenvolvimento é a raiz). **Recomendação:** um fixture automático (`conftest.py`) que aponta
  `evidence_dir()` para `tmp_path` em todos os testes, e apagar os zips atuais depois de o Higor confirmar que nenhum é de uma sessão real.
- Os logs dos 4 zips não têm erro nem queda; os "ERROU" são resultados de d20.
