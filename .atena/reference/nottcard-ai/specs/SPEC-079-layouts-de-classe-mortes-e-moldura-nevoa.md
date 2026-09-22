---
id: "SPEC-079"
type: "spec"
title: "Layouts de classe: remoção dos antigos, moldura Névoa, contagem de mortes e graus 1 por classe"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
supersedes: "SPEC-030 (dez layouts de teste); SPEC-035 no que trata de layouts na loja"
relations:
  - "[[PLAN-012-novos-layouts-de-carta-2026-09-20]]"
  - "[[PLAN-013-layouts-de-classe-por-conquista-2026-09-20]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
sources:
  - "Responsável, 2026-09-20: PLAN-013 (C1 a C7) aprovado"
---

# Layouts de classe: mortes, Névoa e graus 1

> Proposta para aprovação do responsável (`execution_approval: per-spec`). Só implementar depois de aprovada.

## 1. Escopo desta spec
**Entra (fases 0 a 2 do `PLAN-013`):** remoção dos nove layouts antigos que não são o Clássico; nova composição da carta; moldura
**Névoa** (inicial, liberada); contagem de mortes por personagem; conquistas e desbloqueio; os **cinco layouts de grau 1** (troca de
paleta sobre a Névoa); seletor com bloqueados; migração do save e reembolso.

**Fica para a SPEC-080 (arte, depois desta):** graus 2 (camada de ornamentos) e 3 (moldura completa) de cada classe. Até lá, as
conquistas de 20 e 30 mortes já contam, mas o desbloqueio do grau 2 e do 3 mostra "em produção" e não libera nada.
**Fora:** brilho por raridade; qualquer nova mecânica de jogo.

## 2. Os layouts
| Id | Nome | Grau | Como se tem |
|---|---|---|---|
| `classico` | Clássico | 0 | Sempre (o que existe hoje, sem mudança de desenho) |
| `nevoa` | Névoa | base | Sempre |
| `guerreiro_1`, `luz_1`, `sombras_1`, `mistico_1`, `paladino_1` | "Guerreiro Psíquico I" etc. | 1 | 10 mortes com o personagem da classe |
| `<classe>_2`, `<classe>_3` | "… II", "… III" | 2 e 3 | 20 e 30 mortes (arte na SPEC-080) |

Nomes das conquistas: "Guerreiro Psíquico I/II/III", "Clérigo da Luz I/II/III", "Clérigo das Sombras I/II/III", "Místico I/II/III",
"Paladino I/II/III". Cada conquista libera só o layout dela, sem benefício de jogo.

## 3. Composição da carta (`PLAN-012`, D3 e D1)
- Carta segue **154x210** na mão; o painel de detalhe reaproveita a composição em escala maior.
- Camadas: arte por baixo (maior que hoje, cerca de 59% da carta, y 20–79%, conforme ART-PROMPTS-020), **moldura PNG** por cima com janela transparente, placa do nome no topo,
  placa do rodapé ("Ataque · 1d8", "bônus", "HC"), etiqueta de custo (Ação/Bônus/Reação) no canto superior esquerdo e **gema da cor da
  classe** no canto superior direito.
- A **nota da carta sai da mão** e fica só no painel de detalhe (hover e duplo clique, SPEC-018).
- Seleção, descarte, escurecimento, selo "×0,5" e etiquetas "USO ÚNICO"/"PERGAMINHO" continuam por código por cima, legíveis em qualquer layout.
- Moldura ausente: cai num retângulo simples (regra do projeto).
- Mesma composição na mão, no detalhe, na escolha da Comunhão, no catálogo e nos pacotes.
- O **Clássico** mantém o desenho de hoje (sem moldura PNG); a composição nova só se aplica às molduras PNG. **[a confirmar]** se o
  Clássico também ganha a arte maior e a nota fora da mão, para a mão não mudar de tamanho de layout ao trocar de tema. Recomendo
  **sim**: o Clássico passa a usar a mesma composição, com a moldura desenhada por código.

## 4. Moldura Névoa e graus 1
- **Névoa:** pedra escura com névoa verde subindo dos cantos inferiores, fios roxos ao redor da janela da arte, placa de pedra rachada. Verde
  e roxo ficam nas bordas e não cobrem arte nem texto.
- **Grau 1:** a mesma imagem da Névoa com **troca de paleta em código** (verde e roxo viram as cores da classe), sem PNG novo:

| Classe | Paleta do grau 1 |
|---|---|
| Guerreiro Psíquico | aço escuro e branco-azulado, gema vermelha |
| Clérigo da Luz | branco, dourado e azul-celeste, gema azul |
| Clérigo das Sombras | índigo e âmbar (crepúsculo), gema âmbar |
| Místico | violeta e branco estelar, gema roxa |
| Paladino | aço claro e ouro, gema azul |

Cores exatas em `game/ui/card_layouts.py`, como dado.

## 5. Contagem de mortes
- **Morte = inimigo derrotado**; acumula **entre tentativas**, por personagem, e vale também em derrota e desistência.
- **Quem conta:** o personagem que dá o **golpe final**. Hoje `App.record_kill(enemy)` não sabe quem matou; a spec obriga a passar o
  personagem que agiu (ou o dono da carta) e, se um dano não vier de um personagem (efeito residual, veneno), o kill vai ao personagem que
  aplicou o efeito; sem origem conhecida, ao personagem ativo. Os testes cobrem esses três casos.
- Guarda-se em `CharacterProgress` (o progresso por personagem que o save já tem) um contador `kills`; ao fim da tentativa soma o que foi
  registrado. Save antigo carrega com 0.

## 6. Conquistas e desbloqueio
- `game/core/achievements.py`: `Achievement` ganha `layout: str = ""` e a condição passa a receber o progresso por personagem. As 15
  conquistas saem de uma tabela (personagem, marco, id do layout), não escritas à mão.
- Marco cruzado em `finish_run`: entra em `save_state.achievements` e aparece na tela de resultado com o nome do layout e o botão
  "Equipar agora". Mais de um marco no mesmo fim de tentativa: todos aparecem.
- Cheat de teste (`unlock_all`): libera todos os layouts.
- `owned_layouts` (em `shop.py`) passa a ser o Clássico, a Névoa e os das conquistas ganhas.

## 7. Seletor
O seletor existente mostra os 17 layouts. Os bloqueados aparecem em silhueta com a condição ("Paladino I: derrote 10 inimigos com Brook,
faltam 4"). Layout escolhido vale em qualquer carta e sobrevive a "Novo jogo" (é gosto).

## 8. Loja, save e migração
- `LAYOUT_ITEMS` esvaziado: layouts saem da loja.
- **Reembolso:** quem comprou layouts antigos recebe as moedas de volta **uma única vez**, e o `owned` perde os ids removidos. Um marcador
  de migração no save impede repetir. `card_layout` desconhecido cai no Clássico (já é o comportamento de `card_layouts.get`).
- Os títulos que prendiam layouts (fechadura, veteranos, sorte) continuam existindo como conquistas de benefício, sem layout preso.

## 9. Impacto no código
`game/ui/card_layouts.py` (reescrito: lista, paletas, Névoa), `cards_widget.py` (`_draw_card`, painel de detalhe, silhueta),
`layout_picker.py`, `assets.py` (sem `pack=layout.id`), `game/app.py` (botões, cheat, `record_kill`, `finish_run`),
`game/core/shop.py`, `game/core/progress.py`, `game/core/achievements.py`, `game/ui/result_panel.py`, `game/ui/shop_screen.py`,
`scripts/process_art.py` (a moldura Névoa), e os testes de layout, loja, save, coleção e `test_spec072.py`.
Arte nova nesta spec: **1 PNG** (a moldura Névoa), prompt em `ART-PROMPTS-020`.

## 10. Testes
- Contagem: acumula entre tentativas; só do personagem do golpe final; vale em derrota e desistência; efeito residual e origem
  desconhecida seguem a regra da seção 5; save antigo com 0.
- Conquistas: cada marco libera só o seu layout e uma única vez; dois marcos numa tentativa; grau 2 e 3 contam mas ainda não liberam.
- Layouts: bloqueado não se equipa; liberado persiste depois de "Novo jogo"; cheat libera todos; Clássico e Névoa sempre disponíveis.
- Desenho: moldura ausente cai no retângulo simples; troca de paleta do grau 1 usa a cor da classe; nome longo cabe na placa nos 7
  layouts desta spec; seleção, descarte e gema legíveis; nota fora da mão e presente no detalhe.
- Migração: reembolso das moedas uma vez; `owned` sem ids removidos; id de layout desconhecido cai no Clássico.
- Nenhum teste depende da lista dos dez antigos.

## 11. Fora desta spec
Graus 2 e 3 (SPEC-080), brilho por raridade, layouts pagos, novas classes.
