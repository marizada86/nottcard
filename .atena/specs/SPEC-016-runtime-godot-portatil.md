---
id: "SPEC-016"
titulo: "Runtime portátil do Godot 4.7.2 para desenvolvimento e testes"
status: "concluída"
criado: "2026-09-26"
aprovacao: "Plano aprovado pelo Guilherme em 2026-09-26"
---

# SPEC-016 — Runtime portátil do Godot 4.7.2

## Intenção

Disponibilizar uma release verificável do runtime oficial Godot 4.7.2 para
Windows x64, permitindo abrir, importar e testar o Nottcard sem instalação
prévia do motor.

## Escopo

- Release independente com a tag `godot-v4.7.2-win64`.
- Pacote `godot-v4.7.2-stable-win64.zip` com os executáveis gráfico e de
  console oficiais.
- `SHA256SUMS.txt` para os executáveis e o arquivo ZIP, além da documentação
  operacional em `GODOT_RUNTIME.md` e `README.md`.
- Verificação do projeto e dos testes com o executável de console extraído.

## Fora de escopo

- Exportar ou publicar uma build jogável do Nottcard.
- Alterar regras, cenas, assets ou arquivos de save.
- Instalar o Godot globalmente ou adicionar dependências ao projeto.

## Impactos

- Os binários e pacotes são artefatos de release e permanecem fora do Git.
- A release externa fica separada de futuras releases do jogo.
- O runtime deve permanecer alinhado à versão `4.7` declarada em
  `project.godot`.

## Critérios de aceite

- [x] Ambos os executáveis reportam `4.7.2.stable.official.ed1daf0bf`.
- [x] Os hashes dos executáveis coincidem com o manifesto de hashes.
- [x] O ZIP contém exatamente os dois executáveis e passa na conferência do
      hash publicado.
- [x] Em diretório limpo, o console importa o projeto e executa
      `tests/run_all.gd` sem falhas.
- [x] A documentação aponta para a tag correta e explica o uso gráfico e
      headless.
- [x] A release `godot-v4.7.2-win64` contém o ZIP e `SHA256SUMS.txt`.

## Plano de voo

1. Confirmar versão, origem e hashes do runtime oficial.
2. Registrar o contrato operacional e ignorar os artefatos binários locais.
3. Montar o ZIP e o manifesto de hashes em `artifacts/`.
4. Validar o arquivo e executar importação e testes com o console portátil.
5. Publicar a release aprovada, registrar a URL e a evidência de validação.
6. Revisar os critérios, reconciliar a documentação e marcar a spec concluída.

## Evidência esperada

- Manifesto de hashes e listagem do conteúdo do ZIP.
- Saída da importação e da suíte `tests/run_all.gd` com 0 falhas.
- URL da release publicada e conferência dos anexos.

## Reconciliação

- Release publicada: `https://github.com/marizada86/nottcard/releases/tag/godot-v4.7.2-win64`.
- Os binários e o diretório temporário de empacotamento permanecem ignorados;
  a documentação e esta spec constituem o registro versionado da operação.
