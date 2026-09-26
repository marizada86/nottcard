# Runtime Godot para testes

Este projeto usa o runtime portátil abaixo para importar, testar e abrir o
projeto sem uma instalação prévia do Godot.

| Campo | Valor |
| --- | --- |
| Godot | 4.7.2 stable (`ed1daf0bf`) |
| Plataforma | Windows 64-bit |
| Pacote | `godot-v4.7.2-stable-win64.zip` |
| SHA-256 do pacote oficial | `ac1eddfaa82b4375e31fe383cbc114159aca503ec71bd874831effc7a29a6829` |

Baixe o pacote na release `godot-v4.7.2-win64`, confira o arquivo
`SHA256SUMS.txt`, extraia ambos os executáveis em uma pasta e abra este
projeto com `Godot_v4.7.2-stable_win64.exe`.

Para validação automatizada, use
`Godot_v4.7.2-stable_win64_console.exe --headless --path . -s tests/run_all.gd`.
