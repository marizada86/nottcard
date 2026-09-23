---
id: "EVID-012"
spec: "SPEC-012"
data: "2026-09-23"
status: "verificado-com-ressalva-externa"
---

# Evidência — M9-A: O Confronto com Kein

## Entrega observada

- `m9` exige `m8` e percorre a Raiz do Plano Abissal, o Templo da Tarn e o
  Altar do Véu.
- O confronto obrigatório preserva a ordem canônica: Kein, Beholder e Death
  Tyrant. A troca de forma acontece mesmo quando o dano excedente zera a fase
  anterior.
- A vitória registra `martelo_da_gloria`, `tarn_caida`, `sacrificio_helion` e
  `veu_nascido`. O Martelo da Glória é obtido somente no desfecho.
- Recrutas e consequências posteriores ao Ato 1 continuam apenas narrativos e
  fora do recorte.

## Recursos visuais

| Uso | Recurso |
| --- | --- |
| Raiz do Plano Abissal | `assets/rooms/m9_sala_1_raiz/{bg,fg}.png` |
| Templo da Tarn | `assets/rooms/m9_sala_2_templo/{bg,fg}.png` |
| Altar do Véu | `assets/rooms/m9_sala_3_altar/{bg,fg}.png` |
| Props | `raiz_abissal`, `pedestal_veu`, `fenda_veu` |
| Item | `assets/items/martelo_da_gloria.png` |
| Fases do chefe | `kein_fase_1`, `beholder`, `death_tyrant` |

Sete peças foram geradas pelo ImageGen integrado: três cenários, uma camada de
fenda/partículas para primeiro plano e três props transparentes. Os prompts
restringiram a arte a fantasia sombria, sem personagens, texto, marcas ou
spoilers posteriores ao Ato 1. As três formas do chefe e o Martelo reutilizam
recursos já existentes no acervo importado.

## Verificações executadas

| Verificação | Resultado |
| --- | --- |
| Reimportação Godot de 10 recursos M9 | concluída |
| `test_compile` | 1 executado, 0 falhas |
| `test_m9` | 3 executados, 0 falhas |
| `test_ui_smoke` | 8 executados, 0 falhas; inclui M1 e M3–M9 |
| Auditoria de assets declarados | 113 declarados, 10 HQ, 0 faltantes |
| Regressão completa | 60 executados, 2 falhas externas conhecidas |

As duas falhas de regressão são `test_save_roundtrip_on_disk` e
`test_profile_store_roundtrip`, ambas em `test_persistence.gd`. O ambiente
isolado bloqueia a escrita em `user://logs/godot.log`, o mesmo impedimento que
afeta os round-trips em disco; M9 e os demais testes de código passaram.
