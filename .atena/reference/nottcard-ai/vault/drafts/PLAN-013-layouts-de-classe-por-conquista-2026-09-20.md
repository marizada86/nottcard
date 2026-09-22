---
id: "PLAN-013"
type: "plano"
title: "Layouts de carta por classe: três graus cada, desbloqueados por mortes, e layout inicial Névoa"
status: "approved-decisions"
created: "2026-09-20"
relations:
  - "[[PLAN-012-novos-layouts-de-carta-2026-09-20]]"
  - "[[SPEC-030-pacotes-de-arte-de-carta-selecao-livre]]"
  - "[[SPEC-026-falha-critica-catalogo-conquistas-velocidade-e-cheat]]"
  - "[[VSN-002-fichas-jogaveis-elenco]]"
sources:
  - "Responsável, 2026-09-20: layouts por classe; cada um com 3 graus (só cor, mais detalhes, todos os detalhes); conquistas por mortes 10/20/30; uso em qualquer carta; layout inicial com névoa verde e efeitos roxos; Sylas em luz e sombra"
---

# Layouts de carta por classe

Rascunho: nada aqui é regra até a spec ser aprovada (`execution_approval: per-spec`). Commit, merge e publicação seguem exigindo
aprovação explícita.

**Relação com o `PLAN-012`:** este plano define **quais** layouts existem e **como se ganham**. O `PLAN-012` segue valendo para a
técnica (moldura PNG, composição da carta, remoção dos dez layouts atuais) e este plano **substitui** a lista de temas (D5) e a loja (D6)
dele. Leitura adotada: "cada raça" no pedido foi entendido como **cada classe**, as cinco que o jogo tem.

## 1. Decisões já tomadas (2026-09-20)

| # | Decisão |
|---|---|
| C1 | Cada classe tem **3 layouts**: grau 1 só muda a cor, grau 2 tem mais detalhes, grau 3 tem todos os detalhes da classe. |
| C2 | Conquista = **quantidade de mortes** com um personagem da classe: **10, 20 e 30**, um grau por marco. |
| C3 | Cada layout vale **em qualquer carta**, de qualquer personagem. |
| C4 | Layout inicial diferente dos de classe: tema de **névoa verde com efeitos roxos**. |
| C5 | O Clérigo das Sombras é **luz e sombra** (crepúsculo). |

| C6 | O layout padrão **atual (Clássico) fica como "grau 0"**: não é removido e continua sendo o de todo jogador desde o início. Os graus 1 a 3 seguem como recomendado (troca de paleta em código, camada de ornamentos, moldura completa). |
| C7 | Respostas aprovadas como recomendadas (2026-09-20): "mortes" = inimigos derrotados; conta quem dá o golpe final; vale em derrota e desistência; nomes "Classe I/II/III"; grau 1 por troca de paleta; "raça" = classe; moldura PNG em pixel art; nota da carta só no painel de detalhe; reembolso dos layouts antigos comprados. |

**Leitura adotada de C6 com C4:** o Clássico é o grau 0 e o inicial. A **Névoa** (C4) continua como moldura base do grau 1 e também
fica **liberada desde o início**, como segunda opção gratuita. Se a intenção era outra (por exemplo, Névoa como único inicial), avise.

Total: Clássico (grau 0) + Névoa (base) + 5 classes x 3 graus = **17 layouts**. Só o Clássico já existe; dos dez layouts atuais, os
outros nove são removidos (`PLAN-012`, fase 0).

## 2. Classes do jogo e temática visual

| Personagem | Classe | Cor de carta |
|---|---|---|
| Durvall | Guerreiro Psíquico (Psi-warrior) | Vermelho |
| Maelor | Clérigo da Luz | Azul |
| Sylas Malafa | Clérigo das Sombras (crepúsculo) | Amarelo |
| Kayron | Místico | Roxo |
| Brook França | Paladino | Azul |

Pesquisa (fontes ao fim): o Guerreiro Psíquico é força marcial movida pela mente (barreiras de força, golpes telecinéticos); o Místico
é a classe psiônica de playtest (Pontos de Psi, disciplinas, ordens); o Crepúsculo é o limiar entre luz e sombra; a Luz é radiação e
iluminação. A busca não achou os emblemas oficiais de cada classe; o resto vem do vocabulário do gênero e das fichas do vault. Símbolos
sem fonte ficam marcados "a confirmar". Nenhum elemento entrega revelação de mestre.

| Classe | Ideia central | Materiais e paleta | Ornamentos (grau 3) |
|---|---|---|---|
| **Guerreiro Psíquico** | Aço com força mental vazando pelas frestas | Aço negro angular, cinza-azulado; acento branco-azulado sutil; gema vermelha | Espada larga atrás da placa do nome; rachaduras de luz; hexágonos de barreira nos cantos |
| **Clérigo da Luz** | Santuário radiante | Pedra clara, vitral, vela; branco, dourado, azul-celeste; gema azul | Raios atrás da placa; símbolo solar; chama branca nos cantos (Chama Devota) |
| **Clérigo das Sombras** | Crepúsculo | Ferro escuro e fumaça; degradê índigo→âmbar; gema âmbar | Lua crescente e sol poente juntos; contorno que sangra sombra; segundo contorno defasado (Cópia Sombria) |
| **Místico** | Mente aberta, poder acumulado | Cristal de ametista, círculos concêntricos, glifos; roxo profundo, estrelas brancas; gema roxa | Cristais nos cantos que acendem (Carga de Poder Místico); olho aberto na placa; estrelas |
| **Paladino** | Juramento forjado | Aço polido e ouro, escudo e martelo; aço claro, ouro, azul; gema azul | Martelo cruzado atrás da placa (Martelo da Glória); fita de juramento; estrela de Lliira (forma a confirmar) |

### Os três graus, na prática
| Grau | O que muda | Exemplo (Paladino) |
|---|---|---|
| **1. Cor** | Mesma estrutura do layout inicial (Névoa), com a paleta da classe no lugar do verde e do roxo. Nenhum ornamento novo. | Moldura de névoa em aço claro e dourado |
| **2. Detalhes** | Grau 1 mais parte dos ornamentos (2 ou 3 dos da lista): material da placa e um ornamento de canto. | Placa de aço com fita e um cravo dourado |
| **3. Completo** | Moldura própria da classe com todos os ornamentos e efeito animado leve, se couber. | Martelo, fita, estrela, escudo, brilho dourado |

**Recomendação de técnica:** uma **moldura base "Névoa"** em PNG e o grau 1 por **troca de paleta em código** (sem arte nova por classe);
o grau 2 é uma **camada de ornamentos** em PNG sobre a base; o grau 3 é **moldura completa** em PNG. Isso reduz o trabalho de arte para
1 base + 5 camadas + 5 molduras completas (11 imagens), não 16.

## 3. Layout inicial: Névoa

Todo jogador começa com ele, sem conquistar nada.

- **Tema:** a névoa verde de `MUNDO-001` (o verde é a cor da ameaça: só aparece na rachadura e depois dela) com **efeitos roxos**.
- **Forma:** moldura de pedra escura, com névoa esverdeada subindo dos cantos inferiores, vinhas de fumaça nas laterais e faíscas ou
  fios roxos ao redor da janela da arte. Placa do nome em pedra rachada; rodapé com o mesmo material.
- **Cuidado de leitura:** a névoa não pode esconder a arte nem o texto; verde e roxo ficam nas bordas. A cor da classe segue na gema.
- **Cuidado de lore:** só a névoa esverdeada como no mundo (sem paisagem do outro lado, sem símbolos de entidades).
- É a **base** do grau 1 de todas as classes (seção 2).

## 4. Conquistas: mortes por classe

**Contagem (a confirmar, ver Decisões):** "mortes" = **inimigos derrotados** com o personagem da classe, **acumulado entre
tentativas** (não numa só: a M1 tem cerca de 7 inimigos por tentativa, então 10 mortes levam de uma a duas tentativas e 30 levam de
quatro a cinco).

| Classe | Grau 1 | Grau 2 | Grau 3 |
|---|---|---|---|
| Guerreiro Psíquico (Durvall) | 10 mortes | 20 mortes | 30 mortes |
| Clérigo da Luz (Maelor) | 10 | 20 | 30 |
| Clérigo das Sombras (Sylas) | 10 | 20 | 30 |
| Místico (Kayron) | 10 | 20 | 30 |
| Paladino (Brook) | 10 | 20 | 30 |

- 15 conquistas, uma por layout, com o nome da classe e o grau (ex.: "Paladino I, II e III" ou nomes temáticos, ver Decisões).
- Cada uma libera **só o layout** dela (não dá benefício de jogo).
- Maelor e Sylas são duas classes distintas (Luz e Sombras) e têm contagens separadas.

## 5. Uso e escolha
- Qualquer layout desbloqueado vale em qualquer carta, pelo seletor que já existe. No seletor, os bloqueados aparecem em silhueta com
  a condição ("Paladino I: derrote 10 inimigos com Brook, faltam 4").
- A tela de resultado lista os layouts novos da tentativa, com botão "Equipar agora".
- Cheat de teste (`unlock_all`): libera os 16.
- **Loja:** as molduras de classe não se compram; os layouts da loja atual saem com os dez antigos (`PLAN-012`, D6).

## 6. Impacto no código
- `game/core/progress.py`: contador **`kills`** por personagem no progresso já guardado por personagem (`save.progress[cid]`),
  somado no fim da tentativa a partir de `RunStats.enemies_defeated` (que já existe). Save antigo carrega com 0.
- `game/core/achievements.py`: campo `layout` em `Achievement`; 15 conquistas geradas de uma tabela (personagem, marco, id do layout);
  `evaluate` passa a saber quais personagens jogaram a tentativa. O tipo "libera layout" é novo.
- `game/core/shop.py`: `LAYOUT_ITEMS` esvaziado; `owned_layouts` passa a vir das conquistas.
- `game/ui/card_layouts.py`, `layout_picker.py`, `cards_widget.py`, `game/app.py`: os do `PLAN-012`, mais a troca de paleta do grau 1 e
  as camadas do grau 2.
- Sem mudança de regra de combate.

## 7. Fases
| Fase | O que | Depende de |
|---|---|---|
| 0 | Remover os dez layouts e a loja de layouts; layout provisório simples | Spec aprovada |
| 1 | Composição da carta (`PLAN-012`), moldura Névoa e troca de paleta (grau 1 de todas as classes) | Fase 0 |
| 2 | Contador de mortes, conquistas e desbloqueio, seletor com bloqueados | Fase 1 |
| 3 | Grau 2 e grau 3: primeiro o Guerreiro Psíquico e o Paladino, depois Luz, Sombras e Místico | Fase 2, arte |
| 4 | Prompts em `ART-PROMPTS-020`, um por imagem, com revisão de cada uma dentro do jogo | Em paralelo à fase 3 |

## 8. Testes previstos
Contagem de mortes acumula entre tentativas e só do personagem certo; cada marco libera só o seu layout e uma única vez; bloqueado não
se equipa; liberado persiste depois de "Novo jogo"; save antigo carrega com 0 mortes e o layout inicial; moldura ausente cai no
retângulo simples; nome longo cabe na placa nos 16; o grau 1 usa a paleta da classe e o inicial usa verde e roxo; a leitura de
seleção, descarte e da gema da classe funciona em todos.

## 9. Decisões (todas resolvidas em 2026-09-20)
Resposta do responsável: recomendados aprovados, "raça" = classe, Clássico como grau 0 (C6, C7). Sobra uma **suposição minha**: o brilho por
raridade (D4 do `PLAN-012`) fica **fora desta leva**, para depois. O texto abaixo é o histórico das perguntas.

Deste plano:
1. **"Mortes"** = inimigos derrotados (leitura adotada), e não as vezes em que o personagem morreu? Recomendo inimigos derrotados.
2. **Atribuição da morte** com grupo de até 3: conta quem dá o golpe final (recomendado, se o combate já registra isso; a spec confere)
   ou todos os personagens do grupo na tentativa?
3. **Vale em derrota e desistência?** Recomendo que sim, para não punir quem tenta.
4. **Nome das conquistas:** "Paladino I/II/III" ou nomes temáticos (ex.: "Juramento", "Martelo", "Glória")?
5. **Grau 1 = troca de paleta em código** sobre a moldura Névoa (recomendado) ou moldura própria por classe?
6. **Confirmar "raça" = classe** (leitura adotada).

Herdadas do `PLAN-012` (sem resposta ainda):
7. **D1/D2:** moldura em PNG em pixel art (recomendado) ou pintada?
8. **D3:** a nota da carta sai da mão e fica só no painel de detalhe (recomendado) ou fica uma linha curta sobre a arte?
9. **D4:** brilho por raridade agora ou depois?
10. **D6:** resolvida por este plano (sem loja de layouts nesta leva, com reembolso de quem comprou os antigos); só falta confirmar o **reembolso**.

## Fontes da pesquisa
- Psi Warrior: [RPGBot 2024](https://rpgbot.net/2024-dnd/classes/fighter/fighter-subclasses/psi-warrior/), [Nerdarchy](https://nerdarchy.com/play-your-next-5e-dd-game-as-a-superhero-psi-warrior-fighter-from-tashas-cauldron-of-everything/)
- Místico: [Unearthed Arcana, The Mystic](https://media.wizards.com/2017/dnd/downloads/UAMystic3.pdf), [Cannibal Halfling Gaming](https://cannibalhalflinggaming.com/2017/03/17/unearthing-the-dd5e-mystic/)
- Clérigo: [Twilight Domain, Wikidot](https://dnd5e.wikidot.com/cleric:twilight), [Cleric 101: Light Domain](https://www.dndbeyond.com/posts/868-cleric-101-light-domain)

## Review record
- Proposed by: Claude, 2026-09-20, com as decisões C1 a C5 do responsável.
- Reviewed by: responsável do projeto, 2026-09-20.
- Approval decision: decisões C1 a C7 aprovadas. Próximo: SPEC-079 para aprovação.
