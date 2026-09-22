---
id: "SPEC-059"
type: "spec"
title: "Bloco de notas com edição de verdade (F5) e .zip da F7 ao lado do executável"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-050-modo-playtester-boas-vindas-e-bloco-de-notas]]"
  - "[[SPEC-051-binds-de-evidencia-f5-f6-f7-pacote-de-sessao]]"
sources:
  - "Responsável, 2026-09-20: F7 deve gravar o .zip na pasta do executável; F5 é ruim de editar (só desfaz de um em um, campo sem intuitividade)"
---

# Bloco de notas editável e .zip ao lado do executável

> Aprovada pelo responsável em 2026-09-20 (plano aprovado na conversa). Não muda regra de jogo. Revisa `SPEC-050` e `SPEC-051`.

## 1. F7 — onde o .zip vai
- O `.zip` é gravado na **pasta do executável** (`sys.executable` no build; a raiz do projeto em desenvolvimento).
- Se essa pasta não aceitar gravação (ex.: `Program Files`), cai para `%APPDATA%/nottcard-ai/evidencias/` e o aviso diz onde salvou.
- O aviso mostra o caminho da pasta. O rascunho do pacote continua em `%APPDATA%`.

## 2. F5 — edição
Lógica em `game/core/textbuffer.py` (`TextBuffer`, sem pygame); `game/ui/notepad.py` só desenha e traduz input.

| Recurso | Como |
|---|---|
| Desfazer / refazer | Ctrl+Z · Ctrl+Y (ou Ctrl+Shift+Z); digitação contínua de uma palavra é um passo só; até 200 passos |
| Seleção | Shift+setas/Home/End/PgUp/PgDn, Ctrl+Shift+setas (palavra), Ctrl+A, arrastar com o mouse, duplo clique (palavra) |
| Copiar / recortar / colar | Ctrl+C · Ctrl+X · Ctrl+V (área de transferência do sistema, com cópia interna de reserva) |
| Apagar por palavra | Ctrl+Backspace · Ctrl+Delete |
| Repetição de tecla | segurar seta/Backspace repete enquanto o bloco está aberto |
| Rolagem | barra clicável/arrastável; a roda rola sem mover o cursor |
| "Apagar texto" | vira desfazível (Ctrl+Z) e **não pede mais "Certeza?"**; "Limpar pacote" mantém a confirmação |
| Ajuda | linha de atalhos visível no painel |

## 3. Fora do escopo
Reaproveitar o `TextBuffer` no campo de nome do login (fica para depois).

## 4. Verificação
`tests/core/test_textbuffer.py`, `tests/ui/test_notepad_navigation.py` e `tests/ui/test_evidence_bundle.py`.
