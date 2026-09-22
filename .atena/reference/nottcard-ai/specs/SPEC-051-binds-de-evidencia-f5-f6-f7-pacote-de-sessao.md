---
id: "SPEC-051"
type: "spec"
title: "Novas binds de evidência: F5 nota, F6 print, F7 gera o .zip com tudo que foi guardado"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-048-tasks-e-evidencias]]"
  - "[[SPEC-050-modo-playtester-boas-vindas-e-bloco-de-notas]]"
sources:
  - "Responsável, 2026-09-20: F5 abre o bloco de notas, F6 tira um print da tela, F7 gera o .zip com todas as notas e prints"
---

# Binds de evidência: F5, F6 e F7

> **Aprovada pelo responsável em 2026-09-20** (`execution_approval: per-spec`). Não muda regra de jogo. **Substitui** as
> binds F9 (bloco de notas, `SPEC-050`) e F10 (salvar evidência, `SPEC-048`/`050`) e muda o modelo: em vez de **uma** evidência
> por F10, o playtester **acumula** notas e prints durante a sessão e gera **um** `.zip` no fim.

## 1. O problema

Com F9/F10 cada evidência é um `.zip` de um momento só. Uma task com 5 passos vira 5 `.zip` para anexar no Discord, e o
playtester precisa decidir "salvar agora" a cada passo. O que se quer é jogar, ir guardando prints e notas e, ao terminar a task,
gerar **um arquivo** só.

## 2. As binds

| Tecla | Faz | Pausa o jogo? |
|---|---|---|
| **F5** | Abre o bloco de notas. Ao fechar (F5 ou Esc), uma nota com texto **entra no pacote**; vazia é descartada. | sim (enquanto aberto) |
| **F6** | Tira um **print** da tela e o guarda no pacote. Aviso curto: "Print 3 guardado (F7 gera o .zip)". | não (instantâneo) |
| **F7** | **Gera o `.zip`** com tudo que está no pacote (mais o log e o estado) e **esvazia** o pacote. | não |
| F1 · F11 · F12 | Sem mudança (tutorial · tela cheia · log). | |

- **F9 e F10 deixam de existir** (recomendo o corte limpo: duas teclas para a mesma coisa confundem). O `Ctrl+O+P` (cheat) não muda.
- **Em qualquer tela**, inclusive login e boas-vindas, como hoje. F5 espera se outra sobreposição estiver aberta (regra da `SPEC-050`);
  F6 e F7 não esperam.
- Itens novos no menu de pausa: **Bloco de notas (F5)**, **Print da tela (F6)**, **Gerar .zip (F7)**.

## 3. O pacote da sessão

Uma lista em ordem de criação. Cada **item** é `print` ou `nota`, com hora e o contexto daquele instante (tela, sala, turno,
personagens).
- **Nota:** o texto (até 1000 caracteres, como na `SPEC-050`) **mais o print** do instante em que o F5 abriu (a nota fala do que o
  playtester via). Vira um par nota+print.
- **Print (F6):** só a imagem, sem o painel do log e **sem o aviso/lembrete** desenhado por cima (o print antigo saía com o toast).
- **Limite:** até **20 prints** e **8 MB** no total (o Discord aceita cerca de 10 MB por envio). Passou do limite, o jogo avisa
  "Pacote cheio: aperte F7 para gerar o .zip" e não guarda mais. Aviso amarelo em 80%.
- **Persistência (decisão 1):** cada item é gravado na hora em `%APPDATA%/nottcard-ai/evidencias/rascunho/`, então fechar o jogo ou uma
  queda **não perde** o que foi guardado; o F7 gera o `.zip` e limpa essa pasta. Ao abrir o jogo com itens pendentes, um aviso:
  "Você tem 3 itens guardados (F7 gera o .zip)". Sem permissão de escrita, o pacote vale só na sessão e o jogo avisa.
- **Ver e limpar:** o painel do F5 mostra "Guardado: 2 notas, 3 prints" e o botão **Limpar pacote** (dois cliques). Não há edição de
  item já guardado.

## 4. O `.zip` (F7)

`EV-<jogador>-<AAAAMMDD>-<HHMMSS>.zip` (o mesmo nome de hoje):

```
info.json          jogador, versão, data, e a lista de itens (número, tipo, hora, tela, sala, turno, personagens)
log.txt            as últimas 200 linhas do log dev, no momento do F7
notas.md           todas as notas, numeradas, cada uma com a hora e o contexto
prints/01-nota.png, prints/02-print.png, ...   na ordem de criação
```
- **Pacote vazio** (decisão 2, ajustada pelo responsável): o F7 **não gera nada** e avisa **"Não há evidência a ser enviada"**.
- **Sucesso:** aviso "Evidência salva: EV-...zip (2 notas, 3 prints)" e o pacote esvazia. **Falha de disco:** o jogo não cai, mostra o motivo
  e o pacote **fica** (nada se perde).
- **Privacidade (como na `SPEC-050`):** notas e log passam pelo `scrub` (caminho pessoal e usuário do Windows). Os **prints não** passam por
  filtro; a boas-vindas avisa "os prints mostram a tela do jogo".

## 5. Mudanças nos textos e nas tasks

- **Boas-vindas** (`playtest_guide.py`): os passos 3 e 4 viram "F6 tira um print, F5 escreve uma nota", e o 5 "F7 gera o .zip com tudo; anexe
  no Discord". A linha de teclas: `F5 nota · F6 print · F7 gera o .zip · F11 tela cheia · F12 log · F1 como jogar`.
- **Lembrete** do primeiro combate: "F5 nota · F6 print · F7 gera o .zip".
- **Tasks:** o bloco "Evidência" de cada `TASK-*` troca "aperte **F10** e anexe o `.zip`" por "aperte **F6** (ou **F5**) na hora certa, e **F7**
  no fim". O `validate` continua pedindo **O que é** e **Como fazer**. Tasks com dois momentos (T-003, T-006, T-007) passam a dizer "dois
  prints, um `.zip`".
- **`scripts/tasks.py`:** `add-result --zip` lê `notas.md` (as duas primeiras linhas da **primeira** nota viram a nota do resultado; o
  resto fica ao lado do `.zip`) e lista os prints em `evidencia`. Aceita ainda os `.zip` antigos (`nota.txt`, `tela.png`).
- **`.atena/tasks/README.md`** e os textos do Discord (`tasks_discord.py`, o roteiro do primeiro post) trocam F10/F9 pelas novas teclas.
- **Specs anteriores:** `SPEC-048` §6 e `SPEC-050` §4 ganham uma nota "substituído pela SPEC-051" (o histórico fica).

## 6. Onde fica o código

| Arquivo | Mudança |
|---|---|
| `game/core/evidence.py` | `Bundle` (itens, limites, `add_print`, `add_note`, `clear`, resumo) e `notes_markdown()`; sem pygame |
| `game/evidence_export.py` | `EvidenceStore` (rascunho em disco), `export_bundle()` (o `.zip` da seção 4); `screenshot_png` sem toast/lembrete |
| `game/ui/notepad.py` | fecha guardando a nota; mostra o contador e "Limpar pacote"; sem botão "Salvar evidência" |
| `game/app.py` | F5/F6/F7 no lugar de F9/F10; itens do menu de pausa; aviso de itens pendentes ao abrir |
| `game/ui/pause.py` | três itens (nota, print, .zip) |
| `game/ui/playtest_guide.py` | textos e teclas |
| `scripts/tasks.py`, `scripts/tasks_discord.py`, `.atena/tasks/` | textos e leitura do `notas.md` |
| `tests/` | seção 7 |

## 7. Testes

- **Binds:** F5 abre e pausa; F6 não pausa e guarda um print; F7 gera o `.zip`; **F9 e F10 não fazem mais nada**; F11 e F12 seguem iguais.
- **Pacote:** nota+print entram em ordem; nota vazia é descartada; limite de 20 prints e de 8 MB (aviso em 80%, recusa depois); "Limpar
  pacote" pede dois cliques.
- **`.zip`:** traz `info.json` (com a lista de itens), `log.txt` (≤200 linhas), `notas.md` numerado e `prints/NN-*.png` na ordem; pacote vazio não gera arquivo e avisa "Não há evidência a ser enviada"; sucesso esvazia o pacote (memória e pasta de rascunho); falha de disco mantém tudo.
- **Rascunho em disco:** um novo `App` com itens pendentes avisa e F7 os inclui; sem permissão de escrita o pacote vale na sessão e avisa.
- **Print:** sem o painel do log e sem o toast; F6 funciona no login, na boas-vindas, no menu e no combate.
- **Privacidade:** caminho pessoal e usuário somem do `notas.md` e do `log.txt`; `info.json` sem caminho.
- **Tasks:** `add-result --zip` lê `notas.md` novo e o `nota.txt` antigo; o `validate` passa com o texto novo das tasks.
- **Lançamento:** com `PLAYTEST_BUILD = False` F5 e F6 somem; o F7 (e o resto do pacote) some junto (a evidência é do modo playtester).
- Nenhum teste toca `%APPDATA%` real nem a rede.

## 8. Fora do escopo

Editar ou reordenar itens já guardados, legenda no print, gravação de vídeo, marcar qual task cada item prova, envio automático ao Discord,
filtro de imagem nos prints.

## 9. Decisões pendentes (com a recomendação)

Decisões aprovadas pelo responsável em 2026-09-20: **todas nas recomendações, exceto a 2** (F7 com pacote vazio só avisa "Não há evidência a ser enviada").

1. **Pacote gravado em disco a cada item** (recomendo; não perde nada se o jogo fechar). Alternativa: só em memória (some ao fechar).
2. ~~F7 com pacote vazio tira um print e gera~~ **Decidido: só avisa "Não há evidência a ser enviada".**
3. **Cortar F9 e F10** de vez (recomendo). Alternativa: manter F10 como apelido do F7 por uma versão.
4. **Fechar o bloco com texto guarda a nota sozinho** (recomendo; nada se perde). Alternativa: um botão "Guardar nota" e Esc descarta.
5. **Limites** de 20 prints e 8 MB (recomendo). Cada print é PNG de 1280x720, cerca de 0,3 a 0,7 MB.
6. **Contador discreto na tela** ("2 notas · 3 prints") num canto, além do aviso ao guardar (opcional; recomendo só o aviso e o contador no painel do F5).

## 10. Critérios de aceite

- [x] F5 abre o bloco de notas; fechar com texto guarda a nota (com o print do instante).
- [x] F6 guarda um print sem pausar e avisa; o print sai sem o painel do log e sem o aviso.
- [x] F7 gera **um** `.zip` com `info.json`, `log.txt`, `notas.md` e `prints/`, esvazia o pacote e avisa o que entrou; com o pacote vazio não gera nada e avisa "Não há evidência a ser enviada".
- [x] O pacote sobrevive ao fechar o jogo (pasta de rascunho) e avisa ao reabrir; falha de disco não perde nada e não derruba o jogo.
- [x] F9 e F10 não fazem nada; F1, F11 e F12 seguem iguais; o menu de pausa tem os três itens.
- [x] Boas-vindas, lembrete, tasks, README e o texto do Discord falam F5/F6/F7.
- [x] `add-result --zip` lê o pacote novo e o antigo.
- [x] `core` sem pygame; todos os testes passam.

## 11. Ordem de execução

1. `Bundle` no `core` + testes. 2. `EvidenceStore` (rascunho) e `export_bundle`. 3. F6 e F7 no `App`. 4. Bloco de notas (F5) guardando no pacote e
o contador. 5. Menu de pausa e aviso de itens pendentes. 6. Textos: boas-vindas, lembrete, tasks e README. 7. `tasks.py` lê o `notas.md`. 8. Nota
nas SPEC-048/050. 9. Build 0.7.1 e playtest.

## Registro da implementação (2026-09-20)

- Feito conforme a spec, com a decisão 2 ajustada pelo responsável (F7 vazio só avisa "Não há evidência a ser enviada.") e as demais nas recomendações.
- **F6 com o bloco de notas aberto** avisa "Feche o bloco de notas (F5) antes de tirar um print." (o print pegaria o bloco por cima). O **F7** com o bloco aberto guarda a nota em edição e gera o `.zip`.
- `info.json`: `notas`, `prints` (avulsos, F6) e `imagens` (todos os PNGs, incluindo o de cada nota). O `.zip` não leva `notas.md` se não há nota.
- O rascunho fica em `%APPDATA%/nottcard-ai/evidencias/rascunho/`; o `App()` dos testes não usa disco (o `evidence_store` é injetado, como o save e o perfil).
- `add-result --zip` lê a primeira nota do `notas.md` (o resto e as demais notas ficam em `resultados/TASK-NNN/anexos/<zip>.nota.txt`) e ainda aceita o `nota.txt` antigo. O campo `evidencia` guarda o nome do `.zip` (os prints ficam dentro dele).
- Versão 0.7.1. Testes: `tests/ui/test_evidence_bundle.py`; 1119 no total.

## Review record

- Proposed by: Claude, a pedido do responsável em 2026-09-20.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20; decisão 2 alterada (F7 vazio só avisa), as demais nas recomendações.
