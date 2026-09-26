# Nottcard Godot

Porte do Nottcard para Godot 4.7.2, com regras e conteúdo mantidos no próprio
projeto e verificações automatizadas em `tests/`.

## Runtime para desenvolvimento e testes

Não é necessário instalar o Godot globalmente. Baixe o runtime portátil da
release [`godot-v4.7.2-win64`](../../releases/tag/godot-v4.7.2-win64), confira
os hashes e siga as instruções em [GODOT_RUNTIME.md](GODOT_RUNTIME.md).

Após extrair os executáveis, abra `project.godot` pelo executável gráfico. Para
rodar a verificação automatizada no Windows, use o executável de console:

```powershell
.\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s tests/run_all.gd
```

Os binários do runtime e os pacotes de distribuição são artefatos de release;
não fazem parte do conteúdo versionado do jogo.
