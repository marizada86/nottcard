---
id: "SPEC-050"
type: "spec"
title: "Modo playtester: tela de boas-vindas depois do login e bloco de notas (F9) para a evidência"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-048-tasks-e-evidencias]]"
  - "[[PLAN-001-roadmap-pos-playtest-v0.6.0-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: enquanto o jogo não lança, todo executável é para playtesters; depois do login, uma tela 'Obrigado por ajudar com a construção de NottCard...' explicando o que fazer (preencher tasks, F10) e um atalho que abre um 'notepad' para o playtester escrever algo na evidência. Revisão 2026-09-20: F9 abre a nota e F10 salva a evidência (nota + print); o F11 continua sendo tela cheia"
---

# Modo playtester: boas-vindas e bloco de notas (F9 nota, F10 salva)

> **Aprovada pelo responsável em 2026-09-20** (`execution_approval: per-spec`). Não muda regra de jogo. Estende a
> `SPEC-048` (login, F10 e tasks) com a parte de **orientar** e de **deixar o playtester comentar**. O número 049 continua
> reservado à primeira pessoa (PLAN-001).

## 1. O problema

O playtester recebe um `.exe`, digita o nome e cai no menu. Ninguém diz **para que ele está ali**, que existem tasks, nem que a
F10 gera a evidência. E a evidência sai só com print, log e estado: falta um jeito de o playtester dizer, na hora, "aqui o
dano pareceu alto" sem sair do jogo.

## 2. Decisões de desenho

1. **Todo executável é de teste** (até o lançamento): o modo playtester é o comportamento padrão, não um interruptor. Uma
   constante `PLAYTEST_BUILD = True` em `game/version.py` liga a boas-vindas, o bloco de notas e o lembrete; no lançamento
   vira `False` e as três coisas somem sem apagar código.
2. **A nota é opcional e curta.** Ela **acompanha a evidência** (não substitui o resultado da task, que continua sendo a linha
   do Discord). Ideia longa vira `FB-NNN`, como na `SPEC-048`.
3. **Sem dependência nova** e o `core` continua sem pygame.

## 3. Tela de boas-vindas

- **Quando aparece:** logo depois do login, **uma vez por perfil** (o `perfil.json` ganha `"boas_vindas": true` ao fechar). Em
  "Trocar jogador" para um nome novo, aparece de novo para ele. Sempre acessível pelo botão **Guia do playtester** no menu.
- **Sem perfil injetado** (o `App()` dos testes): não aparece (mesma regra do login).
- **Layout** (uma tela só, sem rolagem; botão **Começar** e Enter/Esc também fecham; "Guia" reabre sem o botão de começar):

```
Obrigado por ajudar a construir o Nottcard AI, <nome>!
Este jogo ainda não foi lançado: você está testando uma versão em construção. O que você
reportar muda o jogo de verdade.

O que fazer
 1. Pegue uma task no #playtest-tasks do Discord do Marizverso (as não testadas vêm primeiro).
 2. Jogue seguindo os passos dela. Não precisa jogar tudo: só o que a task pede.
 3. Aperte F10 na hora certa: o jogo salva um .zip (print, log e estado).
 4. Aperte F9 para escrever uma nota (o que estranhou, o que gostou) e F10 para salvar: nota e print vão juntos no .zip.
 5. No Discord, anexe o .zip e responda uma linha:  TASK-001 | resultado: passou | build: 0.7.0 | nota: ...

Teclas:  F9 nota · F10 salva a evidência · F11 tela cheia · F12 log · F1 como jogar
Resultado: passou (funcionou) · estranho (funcionou, mas algo incomoda) · falhou
```
- Os textos ficam em `game/ui/playtest_guide.py` como dados (lista de linhas), com o nome do jogador e a **versão** (de
  `game/version.py`) preenchidos; nenhum texto duplicado em `app.py`.
- **F10 durante a boas-vindas:** funciona (como em qualquer tela), e vale de teste do fluxo.

## 4. Bloco de notas (F9) e F10 salva

- **Atalhos:** **F9** abre e fecha o bloco de notas; **F10** salva a evidência (print + nota + log + estado). Também um item
  "Bloco de notas (F9)" no menu de pausa. Funcionam em qualquer tela, inclusive no meio do combate. O **F11 continua sendo tela cheia** (nada muda).
  O bloco **pausa** o jogo enquanto aberto (mesma regra da passiva e das pilhas: `screen.pause()`).
- **Ao abrir:** o jogo **captura a tela naquele instante** (sem o painel do log). A nota fala do que o playtester estava vendo,
  não do que estará na tela depois de fechar.
- **A caixa:** texto de várias linhas, até **1000 caracteres**, com contador. Digitar, Backspace, Enter (nova linha), setas
  esquerda/direita, Home/End e **Ctrl+V** (colar). Sem seleção nem desfazer. Acento e emoji digitáveis pelo `TEXTINPUT`; só
  caracteres imprimíveis entram.
- **Botões e teclas:**
  - **F10** (ou o botão **Salvar evidência (F10)**), com o bloco aberto: exporta **com a captura de quando abriu** e a nota
    escrita. Fecha e avisa "Evidência salva: ... (com nota)".
  - **Esc ou F9 de novo:** fecha sem exportar; o texto **fica guardado** na sessão como rascunho.
  - **Apagar tudo**: limpa o texto (pede um segundo clique para confirmar).
- **F10 fora do bloco:** se houver rascunho, a nota vai junto e o rascunho **zera** depois de exportar; o aviso diz "com nota". Sem
  rascunho, é a F10 da SPEC-048. Ao trocar de jogador ou fechar o jogo, o rascunho some (não vai para disco).
- **No `.zip`:** um arquivo **`nota.txt`** (o texto puro) e, no `info.json`, `"nota": true` e `"nota_caracteres": N`. Sem nota,
  nenhum dos dois aparece (o `.zip` da SPEC-048 continua idêntico).
- **Privacidade:** o texto é do playtester; passa pelo mesmo `scrub` do log (tira caminho da pasta pessoal e usuário do Windows).
  A tela de notas avisa "não escreva senhas nem dados pessoais".
- **Ligação com a task:** a nota não pede o id da task (o resultado, com o id, vai na linha do Discord). O `add-result --zip`
  passa a **anexar a nota**: se o `.zip` traz `nota.txt`, as duas primeiras linhas viram a nota do resultado e o resto fica
  guardado ao lado do `.zip`, sem estourar o limite de 2 linhas do `validate`.

## 5. Lembrete leve (opcional, recomendo)

Na **primeira** vez que o playtester entra em combate, sem bloquear nada, uma faixa de 6 s no rodapé: "F9 nota · F10 salva a evidência".
Uma vez por sessão. Some com qualquer clique. Não aparece nas telas de menu.

## 6. Onde fica o código

| Arquivo | Mudança |
|---|---|
| `game/version.py` | `PLAYTEST_BUILD = True` |
| `game/ui/playtest_guide.py` (novo) | texto e desenho da boas-vindas (dados + `WelcomeScreen`) |
| `game/ui/notepad.py` (novo) | `NotepadOverlay`: caixa de várias linhas, contador, botões, rascunho |
| `game/core/profile.py` | `boas_vindas` no `perfil.json` (`welcome_seen`, `mark_welcome_seen`) |
| `game/core/evidence.py` | `nota` e `nota_caracteres` no `info.json`; `note_text()` aplica o `scrub` e o limite |
| `game/evidence_export.py` | aceita `nota` e `screenshot` já capturado; escreve `nota.txt` |
| `game/app.py` | boas-vindas depois do login; F9 e item no menu de pausa; rascunho; a F10 leva o rascunho; "Guia do playtester" no menu |
| `scripts/tasks.py` | `add-result --zip` lê `nota.txt` |
| `.atena/tasks/README.md` | passo da nota (F9) |
| `tests/` | seção 7 |

## 7. Testes

- **Boas-vindas:** aparece uma vez por perfil, depois do login, e não de novo em outra abertura do jogo; volta para um nome novo;
  "Guia do playtester" reabre; nome e versão aparecem no texto; sem perfil injetado não aparece; Começar, Enter e Esc fecham; F10 funciona nela.
- **Bloco de notas:** F9 abre e pausa (e F9 de novo guarda o rascunho); o limite de 1000 caracteres; Backspace, Enter, setas e
  colar; só imprimíveis; "Apagar tudo" pede confirmação; o rascunho volta ao reabrir.
- **Evidência:** F10 com o bloco aberto usa a captura do momento de abrir (troca a tela depois e confere o PNG); o `.zip` traz
  `nota.txt` e `info.json` com `nota: true`; sem nota, o `.zip` é o de antes; a F10 comum leva o rascunho e o zera; caminho pessoal na nota é removido.
- **Tasks:** `add-result --zip` com `nota.txt` gera uma nota válida no `validate`.
- **Tela cheia:** F11 e o botão seguem alternando; F9 não mexe nela.
- **Lançamento:** com `PLAYTEST_BUILD = False` nada disso aparece e a F10 segue funcionando.

## 8. Fora do escopo

Lista de tasks dentro do jogo, envio automático para o Discord, rascunho em disco, formatação de texto, gravação de vídeo,
formulário estruturado (perguntas da task dentro do jogo). Fica para depois se o fluxo do Discord pesar.

## 9. Decisões pendentes (com a recomendação)

Decidido pelo responsável em 2026-09-20: **F9 abre a nota, F10 salva a evidência (nota + print), F11 segue tela cheia.**

1. **Boas-vindas uma vez por perfil**, mais o botão "Guia do playtester" no menu (recomendo). Alternativa: toda vez que a versão muda.
2. **Rascunho só em memória** e levado pela F10 comum (recomendo). Alternativa: a F10 nunca leva nota sem o bloco aberto.
3. **1000 caracteres** (recomendo; mais que isso vira `FB-NNN`).
4. **Lembrete de 6 s** no primeiro combate (recomendo sim).
5. **Texto da boas-vindas** como está na seção 3: me diga se troca alguma frase.

## 10. Critérios de aceite

- [x] Depois do login (uma vez por perfil) aparece a boas-vindas com o nome, a versão, os 5 passos e as teclas; o menu reabre o guia.
- [x] F9 abre o bloco de notas em qualquer tela, pausa o jogo e captura a tela do instante.
- [x] F10 com o bloco aberto gera o `.zip` com `tela.png` do instante, `log.txt`, `info.json` e `nota.txt`; sem nota, o `.zip` é o da SPEC-048.
- [x] A F10 comum leva o rascunho e o zera; o aviso diz "com nota".
- [x] A nota não vaza caminho pessoal; o limite e o contador funcionam.
- [x] A tela cheia segue no F11 e no botão, sem mudança.
- [x] `PLAYTEST_BUILD = False` desliga tudo; `core` sem pygame; todos os testes passam.
- [ ] (aguarda o primeiro playtest) Um playtester novo, só com a boas-vindas, entende o que fazer e devolve a evidência sem ajuda (verificado no primeiro playtest).

## 11. Ordem de execução

1. `PLAYTEST_BUILD` e o campo do perfil. 2. Boas-vindas e o botão do menu. 3. `NotepadOverlay` (sem exportar). 4. Nota no `.zip`
e na F10; captura do instante. 5. `add-result` lê a nota; `README` das tasks. 6. Lembrete. 7. Playtest.

## Registro da implementação (2026-09-20)

- Feito conforme a spec, com as decisões da seção 9 nas recomendações (boas-vindas uma vez por nome, rascunho só em memória, 1000
  caracteres, lembrete de 6 s). O `perfil.json` ganhou `boas_vindas` (lista de nomes que já viram a tela). Um perfil antigo, sem
  esse campo, vê a boas-vindas uma vez ao abrir.
- F9 espera enquanto outra sobreposição está aberta (pausa, tutorial, catálogo...); o menu de pausa tem o item próprio.
- Se a captura da tela falhar ao abrir o bloco, a F10 tira o print na hora de salvar.
- Testes: `tests/ui/test_playtest_mode.py`; 1110 no total.

## Review record

- Proposed by: Claude, a pedido do responsável em 2026-09-20.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: aprovada em 2026-09-20 (decisões pendentes ficam com as recomendações).

> **Nota de 2026-09-20 (SPEC-051):** o bloco de notas passou de F9 para **F5** e a evidência de F10 para **F6/F7**; a nota agora entra num pacote da sessão em vez de ir num `.zip` só. A boas-vindas, o perfil e o lembrete seguem, com os textos novos.
