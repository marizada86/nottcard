---
id: "EVID-010"
spec: "SPEC-010"
data: "2026-09-23"
status: "verificado-com-ressalva-externa"
---

# Evidência — M7-A: O Espeto de Pau

## Entrega observada

- `m7` exige `m6`, contém quatro salas lineares e termina no Mímico do Espeto.
- As fornalhas e os portais são situações encadeadas. A escolha âmbar aplica
  dano e marca `remain`, reabrindo somente a situação atual.
- A vitória registra `diario_bromnor`, `korrak_recrutado` e
  `leoric_recrutado`. As duas últimas flags são narrativas; M7-B continua
  necessária para integrantes selecionáveis.
- O percurso 3D usa o kit local `corredor`, enquanto cada encontro/combate da
  missão usa sua arte própria de ferraria.

## Recursos visuais

| Uso | Recurso |
| --- | --- |
| Pátio | `assets/rooms/m7_sala_1_patio/{bg,fg}.png` |
| Fornalhas | `assets/rooms/m7_sala_2_fornalhas/{bg,fg}.png` |
| Portais | `assets/rooms/m7_sala_3_portais/{bg,fg}.png` |
| Oficina | `assets/rooms/m7_sala_4_oficina/{bg,fg}.png` |
| Adereços | `bigorna_ferraria`, `braseiro_apagado`, `portal_gemeo`, `diario_bromnor` |
| Item | `assets/items/diario_bromnor.png` |

As nove peças inéditas foram geradas pelo fluxo ImageGen integrado, a partir de
prompts de pintura dark-fantasy para pátio chuvoso, fornalhas apagadas, porão
com portais azul/âmbar, oficina secreta e props transparentes. O mímico e os
retratos de Korrak/Leoric reutilizam os recursos já presentes no projeto.

## Verificações executadas

| Verificação | Resultado |
| --- | --- |
| Importação Godot de 13 recursos M7 | concluída |
| `test_m7` | 3 executados, 0 falhas |
| `test_ui_smoke` | 6 executados, 0 falhas; inclui M3–M7 |
| Auditoria de assets | 113 declarados, 10 HQ, 0 faltantes |
| Regressão completa | 53 executados, 2 falhas externas conhecidas |

As duas falhas da regressão completa pertencem a `test_persistence.gd`
(`test_save_roundtrip_on_disk` e `test_profile_store_roundtrip`). O ambiente
isolado não permite gravar em `user://logs/godot.log`, o mesmo bloqueio que
impede os testes de round-trip em disco; os testes de M7 e o restante da
regressão passaram.

