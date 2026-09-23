---
id: "EVID-011"
spec: "SPEC-011"
data: "2026-09-23"
status: "verificado-com-ressalva-externa"
---

# Evidência — M8-A: A Vila das Sombras

## Entrega observada

- `m8` exige `m7`, oferece quatro salas lineares e configura o Demônio Sedutor
  da Vila como o único confronto obrigatório.
- A vila, a pousada e a igreja possuem situações próprias; a vitória registra
  `artefatos_bromnor` e `erik_recrutado`.
- Erik é uma chegada narrativa. Nenhum dos três recrutas passa a ser escolhível
  nesta entrega.

## Recursos visuais

| Uso | Recurso |
| --- | --- |
| Entrada da Vila | `assets/rooms/m8_sala_1_vila/{bg,fg}.png` |
| Pousada Vazia | `assets/rooms/m8_sala_2_pousada/{bg,fg}.png` |
| Salão da Armadilha | `assets/rooms/m8_sala_3_salao/{bg,fg}.png` |
| Igreja das Sombras | `assets/rooms/m8_sala_4_igreja/{bg,fg}.png` |
| Props | `lanterna_nevoa`, `mesa_pousada`, `altar_sombras`, `relicario_bromnor` |
| Item | `assets/items/artefatos_bromnor.png` |

Nove peças foram geradas pelo ImageGen integrado: quatro cenas, uma camada de
névoa para primeiro plano e quatro props transparentes. Os prompts mantiveram
a vila, a pousada, a igreja e os artefatos sem texto, logos ou spoilers de M9.
O demônio sedutor e o retrato de Erik reutilizam recursos já presentes.

## Verificações executadas

| Verificação | Resultado |
| --- | --- |
| Importação Godot de 13 recursos M8 | concluída |
| `test_compile` | 1 executado, 0 falhas |
| `test_m8` | 2 executados, 0 falhas |
| `test_ui_smoke` | 7 executados, 0 falhas; inclui M1 e M3–M8 |
| Auditoria de assets | 113 declarados, 10 HQ, 0 faltantes |
| Regressão completa | 56 executados, 2 falhas externas conhecidas |

As duas falhas de regressão são `test_save_roundtrip_on_disk` e
`test_profile_store_roundtrip`, ambas em `test_persistence.gd`. O ambiente
isolado bloqueia a escrita em `user://logs/godot.log`, o mesmo impedimento que
afeta os round-trips em disco; M8 e os demais testes de código passaram.

