---
id: "HQ-001"
type: "proposta-de-conteudo"
title: "Piloto — Da Fenda nas Docas aos Guardiões de Nottgard"
status: "draft"
created: "2026-09-19"
relations:
  - "[[HQ-000-guia-de-producao-e-ficha-de-transicao]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[MUNDO-001-tarn-cupula-de-nottgard]]"
---

# HQ-001 — Da Fenda nas Docas aos Guardiões de Nottgard

## Ficha de transição

| Campo | Definição |
|---|---|
| Entre | M1 — A Fechadura da Fenda nas Docas -> Interlúdio A — Guardiões de Nottgard |
| Função | Confirmar que a fenda foi selada e abrir a chegada do grupo a Castle Rodhe. |
| Estado que fecha | O ritual nas Docas foi interrompido; a névoa deixa de vazar pela pequena fenda na Tarn. |
| Estado que abre | O grupo será reconhecido pelo Conselho e receberá a missão seguinte. |
| Elenco em cena | Durvall, Kayron, Sylas e Maelor. Helion aparece apenas no quadro final. |
| Texto total | 29 palavras; leitura-alvo de 10 segundos. |
| Spoilers proibidos | A identidade de Durvall como receptáculo, destino final de Durvall, qualquer revelação sobre Astherion/Kein/Adam, entrada de Brook antes da apresentação formal. |
| Referências visuais | `assets/concepts/characters/durvall_fullbody.png`, `assets/portraits/durvall.png`, cenários e paleta de `ART-PROMPTS-001-m1-pixel-art.md`, `MUNDO-001`. |
| Saída | Quatro PNGs sem texto, um por quadro, para composição/UI. |

## Identidade visual do piloto

**Bloco de estilo para todos os quadros**

```text
Pixel art denso e sombrio, coerente com o visual já aprovado de Nottcard:
dithering pesado, alto contraste, contornos nítidos sem anti-aliasing suave,
blocos de cor definidos. Paleta: cinza-azulado de névoa, azul luminoso da
Tarn, roxo escuro apenas em efeitos de corrupção, vermelho seco como acento
de perigo, âmbar fraco como luz quente rara. Fantasia sombria de dungeon
crawler; composição narrativa clara, sem aparência fotográfica. Sem texto,
sem balões, sem legenda, sem moldura de HQ, sem logotipo, sem marca-d'água.
PNG opaco, quadro horizontal 16:9, 1920x1080 px.
```

**Continuidade de personagens**

- Durvall: drow, pele escura acinzentada, cabelo branco longo, armadura negra
  angular, espada larga; atitude reservada, energia psiônica branco-azulada
  apenas sutil quando presente.
- Kayron, Sylas e Maelor: usar suas referências canônicas carregadas no
  projeto StanleyAI; não inventar uniformes, armas ou traços novos.
- Helion: figura de autoridade arcana, visto à distância no último quadro;
  não é o foco, portanto não exige close nem texto na arte.

## Storyboard e texto de UI

| Q. | Função e enquadramento | Ação visível | Texto aplicado pela UI | Emoção |
|---|---|---|---|---|
| 1 | Plano aberto, câmara ritual | Os quatro heróis observam a névoa verde se recolher enquanto a fenda azul na Tarn se fecha. | **Legenda:** “A fenda nas Docas foi selada.” | Alívio frágil |
| 2 | Plano médio, saída do porão | O grupo sobe as escadas rumo à luz azul da cidade; Durvall conduz, os demais acompanham. | **Maelor:** “A cidade está respirando outra vez.” | União cautelosa |
| 3 | Plano aberto, exterior | Castle Rodhe visto sob a Tarn; o grupo avança pela ponte/entrada, pequeno diante do castelo. | **Legenda:** “Mas Nottgard ainda precisava de guardiões.” | Escala e propósito |
| 4 | Plano médio, salão do Conselho | Helion recebe o grupo; quatro broches celestiais repousam numa mesa em primeiro plano. | **Helion:** “Nottgard reconhece sua coragem.” | Recompensa e próximo passo |

## Prompts para o StanleyAI

### Q1 — A fenda contida

```text
[BLOCO DE ESTILO DO PILOTO]

Câmara ritual subterrânea de pedra, conectada à parede energética azul da
Tarn. Plano aberto horizontal; os quatro aventureiros aparecem como silhuetas
reconhecíveis no terço inferior: Durvall à frente com cabelo branco longo e
armadura escura, Kayron, Sylas e Maelor próximos dele. Uma fenda pequena e
cirúrgica na Tarn, no fundo, acaba de se fechar: só resta uma cicatriz de luz
azul estável. A névoa esverdeada no chão está sendo puxada de volta e se
dissipa, sem revelar nada além da barreira. Círculo ritual quebrado, ossos e
marcas abissais discretas nas pedras, braseiros âmbar muito fracos. A ação
precisa comunicar vitória incompleta e perigo contido. Reservar o terço
superior esquerdo com textura escura simples para uma legenda da UI. Não
mostrar inimigos, sangue, texto ou elementos do futuro.
```

Referências a anexar: Durvall e cenários de M1. Demais personagens: suas
referências de personagem aprovadas, quando disponíveis no StanleyAI.

### Q2 — Retorno à superfície

```text
[BLOCO DE ESTILO DO PILOTO]

Plano médio visto de trás e levemente de baixo, em uma escada de porão sob as
Docas. Durvall sobe primeiro, reconhecível pelo cabelo branco longo, armadura
negra angular e espada larga nas costas; Kayron, Sylas e Maelor seguem, todos
inteiros porém cansados. A luz azul da Tarn entra pela saída acima e recorta
as silhuetas; uma luz âmbar fraca fica para trás no porão. Mostrar só um fio
residual de névoa esverdeada no degrau mais baixo, em dissipação. A composição
leva o olhar de baixo para cima, rumo à cidade, e deixa o lado direito central
livre para um balão de fala da UI. Sem combate, sem criaturas, sem texto e sem
céu normal.
```

Referências a anexar: Durvall; fichas canônicas de Kayron, Sylas e Maelor.

### Q3 — Chamado para Castle Rodhe

```text
[BLOCO DE ESTILO DO PILOTO]

Plano aberto externo de Nottgard sob a Tarn em ciclo claro: Castle Rodhe em
pedra se eleva adiante, com uma ponte de acesso e bandeiras discretas. A
curvatura do domo energético azul é inequivocamente visível no céu; não há sol
nem nuvens. Os quatro aventureiros vistos de trás atravessam a ponte em direção
ao castelo, pequenos no terço inferior, com Durvall distinguível pelo cabelo
branco. Docas e cidade organizada ao fundo, sem ruínas. Iluminação azul fria,
pequenas janelas e postes âmbar. Reservar a área superior direita, lisa e
escura o bastante para legenda da UI. Sensação de cidade protegida, mas ainda
vulnerável. Sem texto, sem inimigos, sem personagens extras em destaque.
```

Referências a anexar: referência de ambiente das Docas/Tarn e as quatro
referências de personagem.

### Q4 — Reconhecimento

```text
[BLOCO DE ESTILO DO PILOTO]

Plano médio de um salão de conselho em Castle Rodhe, pedra escura elegante,
luz azul refletida da Tarn entrando por janelas altas e velas âmbar discretas.
Em primeiro plano, sobre uma mesa de pedra, quatro broches celestiais de metal
claro com brilho azul muito sutil: devem ser o foco visual. Ao fundo, Mago
Helion recebe Durvall, Kayron, Sylas e Maelor; as quatro figuras aparecem
inteiras o suficiente para serem reconhecidas, mas sem roubar o foco dos
broches. Helion é uma autoridade arcana acolhedora, não ameaçadora. Composição
formal e esperançosa, com espaço limpo no alto esquerdo para fala da UI. Sem
Brook, sem revelação de missão posterior, sem texto, sem balões, sem moldura.
```

Referências a anexar: fichas visuais dos quatro protagonistas; referência de
Helion, se disponível. Caso Helion ainda não tenha referência, manter sua
figura em segundo plano e não gerar close.

## Registro de geração

Preencher quando o piloto for feito no StanleyAI.

| Quadro | Projeto/ID StanleyAI | Referências anexadas | Versão aprovada | Arquivo exportado |
|---|---|---|---|---|
| Q1 | — | — | — | — |
| Q2 | — | — | — | — |
| Q3 | — | — | — | — |
| Q4 | — | — | — | — |

## Critérios de aceite

- [ ] O jogador entende que a fenda foi selada antes de ler o texto.
- [ ] A chegada a Castle Rodhe prepara o Interlúdio A sem introduzir Brook
  prematuramente.
- [ ] Durvall é visualmente consistente com a referência e não recebe pistas
  de corrupção, destino ou identidade oculta.
- [ ] A Tarn aparece como energia azul, não como cristal ou céu aberto.
- [ ] A névoa verde só existe nos quadros ligados ao rescaldo das Docas.
- [ ] Todos os quadros são 16:9, sem texto incorporado, moldura ou marca-d'água.
- [ ] O texto da UI cabe sem encobrir rostos, broches ou ação relevante.
- [ ] Os quatro quadros contam uma progressão clara: resolução -> retorno ->
  destino -> reconhecimento.

## Próximo passo após aprovação

Com o piloto aprovado, usar `HQ-000` para criar a ficha da transição
Interlúdio A -> M2. Ela deverá anunciar a investigação em Dagruve sem resolver
ou antecipar o ritual da Praça da Loucura.

