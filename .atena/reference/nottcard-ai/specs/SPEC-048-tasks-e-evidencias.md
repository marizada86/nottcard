---
id: "SPEC-048"
type: "spec"
title: "Tasks de playtest e evidências: login com nome, arquivos, painel, Discord e exportar evidência"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
  - "[[FB-002-playtest-higor-v0.6.0-2026-09-19]]"
  - "[[SPEC-007-log-dev-f12]]"
  - "[[EVID-004-playtest-maelor-e-combate-em-grupo]]"
sources:
  - "Responsável, 2026-09-20 (acréscimo): o menu ganha uma tela de login; por enquanto o playtester informa só o nome, que vai no .zip da evidência"
  - "Responsável, 2026-09-20: playtesters usarão Tasks para direcionar o preenchimento das evidências; evidências mais limpas e diretas, dizendo o que é a evidência e como fazê-la; as tasks ficam no Discord do Marizverso, com quem já testou, se não foi testada e as evidências"
---

# Tasks de playtest e evidências

> **Aprovada pelo responsável em 2026-09-20** (`execution_approval: per-spec`). Não muda regra de jogo: são
> arquivos, scripts e **um atalho no jogo** (F10). O Discord é a vitrine; **a verdade fica nos arquivos do repositório**.

## 1. O problema

- As evidências antigas (`EVID-002..004`) têm de 125 a 222 linhas, com tabelas de dezenas de linhas. Quem joga não
  sabe **o que é a evidência** nem **como produzi-la**.
- Cada pessoa escreve do seu jeito. As notas do Higor (FB-002) misturam bug, regra nova, balanço e opinião no
  mesmo texto, e isso é ótimo como feedback, mas não serve de evidência.
- Todas as EVID estão `pendente`; nada mostra **quem testou o quê, em qual build, e o que ficou sem teste**.
- O jogo não ajuda: o log F12 existe, mas o tester copia à mão.

## 2. Decisões de desenho

1. **Task = uma coisa pequena para testar.** Um arquivo, um objetivo, poucos passos.
2. **Evidência = fato que se prova**, não opinião. Cada task diz o que é a evidência e como gerá-la.
3. **Feedback é outra coisa.** Ideias, pedidos de mudança e opiniões vão para um `FB-NNN` (como o FB-002), com ids
   para as specs apontarem. A task só recebe o resultado.
4. **Sem dependência nova** (`dependencies: allowlist-with-plan`): scripts só com a biblioteca padrão do Python.
5. **Nada é publicado sem comando explícito** (`publishing: explicit-approval`): os scripts do Discord começam em
   `--dry-run` e só postam com `--yes`.
6. **Segredos fora do git:** tokens e webhooks ficam num arquivo local ignorado pelo git.

## 3. A task (arquivo)

`.atena/tasks/TASK-NNN-slug.md`. Quatro blocos fixos e curtos, e um cabeçalho que o script lê.

```markdown
---
id: "TASK-001"
title: "Nome, dica e defesa do jogador ficam legíveis"
specs: ["SPEC-044"]
min_build: "0.7.0"
testers_required: 1
priority: "alta"
---

## O que testar
Durante o combate, a linha sob o nome do personagem não cobre "CA · CAM".

## Como fazer
1. Comece uma tentativa com o personagem X.
2. Entre no primeiro combate.
3. Olhe o canto inferior esquerdo, abaixo do orbe de PV.
4. Repita com um personagem de nome longo (Sylas Malafa).

## Evidência
**O que é:** um print do canto inferior esquerdo com o nome, o "?" e "CA · CAM" visíveis.
**Como fazer:** aperte **F10** com a tela do combate aberta e anexe o `.zip`.

## Perguntas
1. Conseguiu ler "CA · CAM" sem esforço? (sim / não)
```

**Regras (o `validate` confere):** o cabeçalho tem `id`, `title`, `specs`, `min_build`; **no máximo 7 passos**; **no
máximo 3 perguntas**; os quatro blocos existem; "Evidência" tem as duas linhas **O que é** e **Como fazer**.

## 4. O resultado (o que o tester devolve)

Um registro curto por teste, sempre com os mesmos campos. Arquivo:
`.atena/tasks/resultados/TASK-NNN/<tester>-<AAAA-MM-DD>.md`.

```markdown
---
task: "TASK-001"
tester: "Higor"
data: "2026-09-21"
build: "0.7.0"
resultado: "passou"          # passou | estranho | falhou
personagem: "Sylas nv5"
evidencia: ["EV-20260921-120433.zip"]
---
Legível. O nome grande ainda encosta no "?" mas dá para ler.
```

- `resultado`: **passou** (funcionou como o roteiro diz), **estranho** (funcionou, mas algo incomoda) ou **falhou**.
- A nota tem **1 ou 2 linhas**. O que passar disso é feedback: vira `FB-NNN`.
- **Estado da task** (derivado, ninguém edita à mão):

| Estado | Regra |
|---|---|
| `nao_testada` | nenhum resultado |
| `em_teste` | há resultados, mas menos que `testers_required` de "passou" |
| `com_falha` | algum "falhou" sem um "passou" mais novo, do mesmo tester, depois dele |
| `estranha` | tem "estranho" e nenhum "falhou" aberto |
| `validada` | `testers_required` ou mais "passou" em build `>= min_build`, sem "falhou" aberto |

- Resultado de uma build **abaixo** de `min_build` aparece no painel como "build antiga" e não conta.

## 5. Login com nome (tela antes do menu)

Por enquanto **só um nome**, sem senha nem conta. Serve para a evidência dizer **quem** testou.
- **Quando aparece:** ao abrir o jogo sem perfil salvo, antes do menu. Com o perfil salvo, o jogo vai direto ao menu.
- **A tela:** título do jogo, o campo "Seu nome" e o botão "Entrar" (Enter também entra). O nome tem de 2 a 24
  caracteres depois de aparado; aceita letras (com acento), números, espaço, ponto, hífen e sublinhado. Vazio ou
  inválido mostra o motivo em vermelho e não avança. Texto colado com Ctrl+V vale.
- **Onde fica guardado:** `%APPDATA%\nottcard-ai\perfil.json` (`{"nome": "Higor"}`), **separado do save**: "Novo
  jogo" **não** apaga o nome. Sem permissão de escrita, o nome vale só nesta sessão e o jogo avisa.
- **No menu:** uma linha "Jogador: Higor" no canto e o botão **Trocar jogador** (volta à tela de login com o nome atual
  preenchido). Trocar o nome não mexe no save.
- **No `.zip` da evidência:** o `info.json` ganha `"jogador": "Higor"`, e o nome do arquivo passa a ser
  `EV-<jogador>-<AAAAMMDD>-<HHMMSS>.zip` (o nome vira só letras, números e hífens). O `add-result --zip` lê o
  jogador de dentro do arquivo, então o campo `tester` do resultado não precisa ser digitado.
- **Em testes e no `App` sem argumento:** o perfil é injetado (como o `save_store`); sem ele o jogo **não** mostra o
  login (assim os testes existentes não mudam e não tocam o disco).
- **Fora do escopo:** senha, conta, login com o Discord, mais de um perfil por computador. O nome **não** é um
  identificador seguro (qualquer um digita qualquer nome); serve só para a organização dos testes.

## 6. Exportar evidência pelo jogo (F10)

O que resolve o "como fazer a evidência".
- **Atalho:** **F10** (e um item "Exportar evidência" no menu de pausa). Funciona em qualquer tela, inclusive durante o combate.
- **O que salva:** um `.zip` em `%APPDATA%\nottcard-ai\evidencias\EV-<jogador>-<AAAAMMDD>-<HHMMSS>.zip` com:
  - `tela.png`: um print do que estava na tela (com o painel do log fechado);
  - `log.txt`: as últimas **200 linhas** do log dev (`DevLog`);
  - `info.json`: **jogador** (o nome do login), versão do jogo, data, tela atual, personagem(ns) e nível, sala, turno, moedas, tamanho da coleção e
    dos baralhos, upgrades e equipamentos (quando existirem) e se o save é em memória ou em disco.
- **Privacidade:** o único dado pessoal é o **nome digitado no login** (`jogador`). Nenhum nome de usuário do
  Windows nem caminho absoluto de pastas pessoais entra no `info.json`.
- **Aviso na tela:** "Evidência salva: EV-...zip (pasta: ...\evidencias)". O tester anexa o arquivo no Discord.
- **Se falhar** (disco sem permissão): o jogo **não cai**; mostra "Não foi possível salvar a evidência: <motivo>".
- **Onde fica no código:** `game/core/evidence.py` monta o resumo (sem pygame; recebe o que precisa); a tela e o
  `.zip` ficam em `game/evidence_export.py`. O `App` só liga a tecla.

## 7. Scripts

`scripts/tasks.py` (tudo local, sem rede):
- `new "<título>" --specs SPEC-044` cria o arquivo da task a partir do modelo, com o próximo número.
- `validate` confere todas as tasks e resultados (as regras da seção 3 e 4).
- `add-result TASK-001 --tester Higor --resultado passou --build 0.7.0 --nota "..." --evidencia arq.zip` cria o registro.
- `status` gera `.atena/generated/tasks-status.md`: cada task com estado, quem testou (e a data), o último
  resultado, o link das evidências e "build antiga". Também lista as **não testadas** no topo.

`scripts/tasks_discord.py` (rede; **começa em `--dry-run`**; só stdlib):
- `publish` cria ou atualiza **uma thread por task** num canal de fórum, pelo webhook do canal (`thread_name` no primeiro
  post; o `thread_id` fica no estado local). O primeiro post repete o roteiro da task e o estado atual. Etiquetas do
  fórum: não testada, em teste, validada, com falha.
- `sync` lê as respostas das threads (token de bot **só de leitura**) e transforma cada resposta no formato abaixo
  em um resultado (`add-result`), guardando os anexos.
- `announce-build` posta no canal de downloads o link da build (chamado pelo CI depois de publicar o `.exe`).
- **Formato da resposta no Discord** (uma linha; o resto vira nota):

```
TASK-001 | resultado: passou | build: 0.7.0 | personagem: Sylas nv5 | nota: legível
```
  com o `.zip` da F10 anexado. Sem bot hospedado: os comandos rodam quando você quiser.
- **Configuração local** (ignorada pelo git, `.atena/tasks/discord.local.json`): `webhook_forum`, `webhook_downloads`,
  `bot_token`, `forum_channel_id`. Um `discord.example.json` (sem segredos) entra no repositório.

## 8. Discord do Marizverso (o que você cria)

Estrutura sugerida (você decide os nomes; eu leio de um arquivo local):

| Canal | Para quê |
|---|---|
| `#anuncios` | novidades dos jogos do Marizverso |
| `#downloads` | um executável por jogo e versão (o Nottcard AI vem do CI) |
| `#demos` | demos para jogadores |
| `#playtest-tasks` (fórum) | uma thread por task do Nottcard AI |
| `#feedback` | conversa livre; o que vira mudança vira `FB-NNN` |

**Papéis:** `Playtester` (vê o fórum de tasks e os downloads de teste) e `Jogador` (só demos). Só você e o Higor
postam em `#downloads`.

## 9. Migração das evidências antigas

- `EVID-001..004` passam a `status: "arquivada"` com uma linha no topo apontando para o `FB-002` e as tasks
  correspondentes. **Não são apagadas.** As verificações que ainda valem viram tasks.
- `EVID-005` (verificação automatizada) continua como está (não é de playtester).
- **Primeiro lote** (criado junto com as specs de cada assunto; as que dependem de código novo nascem com a spec):

| Task | Testa | Nasce com |
|---|---|---|
| T-001 | H1: nome, "?" e CA · CAM legíveis | SPEC-044 |
| T-002 | H2/H9: o dano de um Golpe em Corrente x1..x4 bate com a conta do log (Durvall) | SPEC-044 |
| T-003 | H10: Sylas contra o grupo de slimes e o chefe | SPEC-044 |
| T-004 | H11: Kayron contra o grupo de slimes e o chefe | esta spec |
| T-005 | H3: pilhas clicáveis (só a lista, sem ordem) | SPEC-044 |
| T-006 | H12: grupo de 2 personagens | esta spec |
| T-007 | H12: grupo de 3 personagens | esta spec |
| T-008..T-010 | loja, baralho, falha crítica e Sorte | SPEC-045/046 |

**Exemplo T-006 (grupo de 2), o roteiro completo:**
1. Na seleção, marque "+ Grupo" em dois personagens e comece.
2. No 1º combate, jogue uma carta com cada um (clique no retrato ou Tab para trocar).
3. Deixe um inimigo atacar e veja em quem cai o golpe (deve variar entre os personagens vivos: o alvo é sorteado, SPEC-086).
4. Na exploração, escolha quem faz o teste e falhe de propósito.
5. Ao vencer, veja que o pergaminho foi para quem tinha menos.
**Evidência — o que é:** um print no meio do combate com os dois retratos e o log; um print do resultado do teste
de exploração. **Como fazer:** F10 nos dois momentos e anexe os dois `.zip`.
**Perguntas:** 1. Ficou claro quem age? 2. O alvo do inimigo pareceu justo? 3. Faltou algum aviso?

## 10. Arquivos

| Arquivo | Mudança |
|---|---|
| `.atena/tasks/` (novo) | `README.md` (como testar), `TASK-*.md`, `resultados/`, `discord.example.json` |
| `scripts/tasks.py`, `scripts/tasks_discord.py` (novos) | scripts da seção 6 |
| `game/core/evidence.py` (novo), `game/evidence_export.py` (novo) | F10: resumo e `.zip` |
| `game/core/profile.py` (novo), `game/ui/login_screen.py` (novo) | perfil (nome) e a tela de login |
| `game/app.py` | login antes do menu, "Jogador: X" e "Trocar jogador"; tecla F10 e item no menu de pausa |
| `.gitignore` | `.atena/tasks/discord.local.json`, `.atena/tasks/discord-state.json` |
| `.github/workflows/build-release.yml` | passo opcional `announce-build` (só com o segredo configurado) |
| `.atena/evidence/EVID-001..004` | `status: arquivada` + nota |
| `tests/` | ver seção 10 |

## 11. Testes

- **Tasks:** o `validate` aceita o modelo e recusa (com mensagem clara) 8 passos, 4 perguntas, bloco faltando e
  "Evidência" sem "O que é"/"Como fazer".
- **Estados:** tabela da seção 4 (não testada, em teste, com falha, estranha, validada, build antiga), inclusive
  "falhou" seguido de um "passou" do mesmo tester.
- **Painel:** `status` gera o arquivo, com as não testadas no topo, em ordem estável.
- **Resposta do Discord:** o parser lê a linha `TASK-001 | resultado: ... | build: ...`, recusa resultado inválido
  e guarda o resto como nota.
- **Discord:** com `--dry-run` nenhum pedido de rede sai (o cliente HTTP é injetado e falso nos testes); sem `--yes`,
  nada é postado; sem o arquivo local, o comando explica o que falta.
- **Login:** o nome é aparado e validado (2 a 24 caracteres, só os permitidos; acentos valem); vazio, curto, longo e
  com caracteres proibidos são recusados com o motivo; Enter e o botão entram; colar texto vale.
- **Perfil:** grava e lê `perfil.json`; sem perfil o jogo abre no login e, com ele, vai direto ao menu; "Novo jogo"
  não apaga o nome; "Trocar jogador" volta ao login com o nome preenchido; sem permissão de escrita o nome vale só
  na sessão e o jogo avisa; um `perfil.json` corrompido cai no login sem derrubar o jogo.
- **Sem perfil injetado** (o `App()` dos testes): o login não aparece e nada toca o disco.
- **F10:** monta o `.zip` com `tela.png`, `log.txt` (≤200 linhas) e `info.json`; o `info.json` traz o `jogador` e não tem caminhos
  pessoais; o nome do arquivo usa o nome do jogador limpo; erro de disco vira mensagem, não exceção; o atalho funciona em combate, mapa e menu.
- Nenhum teste toca a rede nem a pasta `%APPDATA%` real (usa `tmp_path`).

## 12. Fora do escopo

Bot hospedado com comandos (`/tasks`, `/evidencia`), painel na web, integração com um rastreador de bugs,
gravação de vídeo pelo jogo, envio automático da evidência para o Discord pelo próprio jogo.

## 13. Decisões pendentes (com a recomendação)

1. **Sem bot hospedado no começo** (recomendo sim; o `sync` roda sob demanda).
2. **`testers_required`:** 1 para as tasks do Higor e 2 quando a task pede uma segunda opinião (recomendo).
3. **Quem cria as threads:** você roda `publish --yes` quando quiser (recomendo); nada automático.
4. **Idioma das tasks:** português (recomendo, o público de teste é o mesmo).
5. **F10 no menu de pausa também** (recomendo sim).
6. **Lembrar o nome** entre sessões (recomendo sim; a tela de login só reaparece em "Trocar jogador"). Alternativa:
   pedir o nome toda vez que o jogo abre.
7. **Nome livre** (recomendo, por enquanto): sem lista de testers autorizados.

## 14. Critérios de aceite

- [x] Uma task no modelo passa no `validate`; fora do modelo, o `validate` explica o que corrigir.
- [x] `status` gera o painel com o estado de cada task, quem testou e as não testadas no topo.
- [x] Ao abrir o jogo sem perfil, aparece a tela de login; o nome (2 a 24 caracteres) é salvo à parte do save, o
      menu mostra "Jogador: X" e "Trocar jogador", e "Novo jogo" não apaga o nome.
- [x] O `.zip` e o `info.json` da evidência trazem o nome do jogador.
- [x] F10 salva o `.zip` com tela, log (200 linhas) e `info.json`, avisa onde e não cai se o disco falhar.
- [x] Publicar e sincronizar no Discord só acontece com `--yes` e com o arquivo local de configuração; nenhum segredo entra no git.
- [x] `EVID-001..004` arquivadas com a nota; o primeiro lote de tasks existe (TASK-001..007; as de loja, baralho, falha crítica e Sorte, T-008..010, nascem com a SPEC-045/046).
- [ ] (aguarda um playtester real) Um playtester consegue, só com o texto da task, testar e devolver o resultado em menos de 5 minutos de escrita.
- [x] `core` sem pygame; todos os testes passam.

## 15. Ordem de execução

1. Modelo, `validate` e `status`. 2. Perfil e tela de login. 3. F10 (`evidence`), já com o nome. 4. `README` do playtester e as tasks T-004, T-006, T-007.
5. Arquivar as `EVID`. 6. `tasks_discord.py` em `--dry-run`. 7. Você cria o Discord e roda o primeiro `publish --yes`.

## Registro da implementação (2026-09-20)

- Feito: `scripts/tasks.py` (new, validate, add-result, status), `scripts/tasks_discord.py` (publish, sync, announce-build; `--dry-run` é o
  padrão), perfil e tela de login, F10 e "Exportar evidência" no menu de pausa, `game/core/evidence.py`, `.atena/tasks/` (README,
  TASK-001..007, `discord.example.json`), `EVID-001..004` arquivadas, passo opcional de anúncio no CI, versão 0.7.0 (a build mínima das tasks).
- Precedência dos estados (a tabela da seção 4 não dizia): `com_falha` > `estranha` > `validada` > `em_teste`. Um "estranho" impede
  a validação até o Higor olhar. Está no `tasks/README.md`.
- Tags do fórum: só aplicadas na criação da thread (o webhook não muda tag depois; o estado atual vai no texto do primeiro post, que
  o `publish --yes` edita). Mudar tag depois exigiria um bot com permissão de gerenciar, fora do que a spec aprovou.
- **Falta (é seu):** criar o Discord do Marizverso (seção 8), preencher `.atena/tasks/discord.local.json`, e rodar o primeiro
  `python scripts/tasks_discord.py publish --yes`. Nada foi enviado.

## Review record

- Proposed by: Claude, a pedido do responsável em 2026-09-20.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20 (sem alterações; decisões pendentes ficam com as recomendações).

> **Nota de 2026-09-20 (SPEC-051):** as teclas F9/F10 e o `.zip` de um só momento da seção 6 foram substituídos por F5 (nota), F6 (print) e F7 (gera um `.zip` com o pacote da sessão). O histórico acima fica como estava.
