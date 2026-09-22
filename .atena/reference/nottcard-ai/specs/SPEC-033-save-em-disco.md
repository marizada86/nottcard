---
id: "SPEC-033"
type: "spec"
title: "Save em disco (JSON em %APPDATA%)"
status: "approved"
reviewed: "2026-09-19"
created: "2026-09-19"
relations:
  - "[[SPEC-023-progresso-save-e-resultado-da-tentativa]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[SPEC-034-interludio-e-hqs-de-transicao]]"
  - "[[SPEC-035-loja-e-titulos]]"
sources:
  - "Responsável, 2026-09-19: aprovado como pré-requisito de loja, títulos e HQ já vista"
---

# Save em disco

## Problema

O save vive só em memória (`MemorySaveStore`, SPEC-023) e some ao fechar o `.exe`. Moeda, compras, títulos
e "HQ já vista" (SPEC-034/035) não fazem sentido assim. O `SaveStore` já é um `Protocol`: trocar a classe
não muda o jogo.

## Regras

- `FileSaveStore` implementa `SaveStore`, gravando **um JSON** em `%APPDATA%\nottcard-ai\save.json`
  (diretório criado sob demanda). Sem `%APPDATA%` (teste, outro SO), cai numa pasta do usuário e, em último
  caso, em memória.
- O arquivo tem `"version": 1`. Campos desconhecidos são ignorados; campos ausentes recebem o padrão. Assim
  as specs seguintes acrescentam campos (moeda, compras, itens, HQs vistas) sem quebrar saves antigos.
- **Quando grava:** no `finish_run` (já chama `save_store.save`), ao trocar o layout, e em qualquer compra.
  Nunca durante o combate.
- **Escrita atômica:** grava em `save.json.tmp` e renomeia, para uma queda no meio não corromper o save.
- **Arquivo corrompido ou de versão futura:** não apaga. Renomeia para `save.json.bak`, começa um save novo e
  mostra um aviso (toast) no menu.
- "Novo jogo" continua apagando o progresso, com a mesma confirmação, e **preserva o layout escolhido**
  (regra da SPEC-030). O `clear()` apaga o arquivo.
- `SaveState` serializa `progress` (nível, XP, cartas liberadas) e `achievements`. A escolha de layout passa
  a viver no save.
- Testes usam `MemorySaveStore` ou um diretório temporário; nenhum teste escreve no `%APPDATA%` real.

## Arquitetura

- `game/core/progress.py`: `SaveState.to_dict`/`from_dict` (sem pygame, sem I/O).
- `game/core/save_file.py` (novo): `FileSaveStore` (I/O do arquivo, atômico, backup).
- `game/app.py`: `App` usa `FileSaveStore` por padrão; o construtor aceita um store para os testes.
- O tutorial deixa de dizer que o nível "fica no save enquanto o jogo estiver aberto".

## Fora de escopo

Nuvem, múltiplos slots, exportar/importar save, criptografia.

## Critérios de aceite

- [x] Fechar e abrir o `.exe` mantém nível, XP, conquistas e layout.
- [x] Save corrompido vira `.bak`, o jogo abre com save novo e avisa.
- [x] Escrita atômica: nunca sobra `save.json` parcial.
- [x] Save de versão anterior (sem campos novos) carrega com os padrões.
- [x] "Novo jogo" apaga o progresso e mantém o layout.
- [x] Nenhum teste toca o `%APPDATA%` real. `core` sem pygame.
- [x] Texto do tutorial atualizado.
- [ ] Playtest (fechar e abrir o `.exe` de verdade).

Implementado em 2026-09-19: `SaveState.to_dict`/`from_dict`, `game/core/save_file.py` (`FileSaveStore`), `App(save_store=...)`,
o `main` passa o `FileSaveStore`; o `App` sem argumento segue em memória (testes não tocam o disco).
