---
id: "M4-001"
type: "ficha-de-producao"
title: "M4 — Ficha de produção de Rodhe's Bridge"
status: "promoted"
created: "2026-09-23"
promoted_to: "[[M4-001-rodhes-bridge]]"
sources:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21]]"
---

# M4 — Ficha de produção de Rodhe's Bridge

## Leitura confirmada

M4 continua imediatamente o sequestro de Kein no portão de Castle Rodhe:
o grupo persegue carroças rebeldes até Rodhe's Bridge, liberta os nobres e
encontra Bella. A missão pode revelar que Kein já foi Elias e perdeu a própria
memória, mas não explica ainda Greenholders, Ailalore ou a origem desse
apagamento.

## Material final disponível

| Papel | Arquivo | Situação |
|---|---|---|
| Cena-chave da perseguição | `assets/rooms/m4_ponte_perseguicao.png` | Importada, mas ainda é imagem isolada; não serve ao contrato `bg`/`fg`. |
| Inimigo-base | `assets/enemies/rebelde_ponte.png` | Importado. |
| Personagens | `assets/portraits/kein.png`, `assets/portraits/bella.png` | Importados. |
| Recompensa | `assets/items/cadernos_magicos.png` | Importado. |

Não há salas M4 declaradas, dados de missão, props de carroça/algemas ou
variações de rebelde no Godot atual.

## Fluxo proposto — precisa de aprovação

1. **Estrada sob chuva:** o grupo avista as carroças; uma situação de atributo
   resolve o atalho ou a aproximação discreta, representando a perseguição sem
   criar sistema global de corrida.
2. **Ponte de Rodhe:** combate contra rebeldes em formação para alcançar as
   grades das carroças. A arte já existente é promovida a esta sala.
3. **Carroça-prisão:** último grupo de três rebeldes, libertação dos nobres e
   encontro de Bella/Kein. A vitória registra os cinco cadernos mágicos como
   item narrativo de grupo.

O combate usa grupos de dois ou três `rebelde_ponte`; as escolhas da situação
alteram apenas recompensa/dano/XP local. A ambiguidade moral permanece no
texto de um rebelde capturado — “os humanos precisam de ajuda” — sem sistema
de reputação nem ramificação de história nesta fatia.

## Backlog P0

| Entrega | Quantidade | Decisão |
|---|---:|---|
| Salas em camadas | 3 pares `bg`/`fg` | Reaproveitar a arte de perseguição na ponte e criar estrada/caravana-prisão. |
| Prop de carroça-prisão | 1 | Grade, algemas e sinais de nobres sem identificar civis. |
| EnemyDef de rebelde | 1 | Um perfil-base humano, sem novas variantes até necessidade legível. |
| Dados M4 | 1 missão + mapa + lore + situação | Liberada ao concluir M3. |
| Persistência | 1 chave narrativa | `cadernos_magicos` ao vencer. |

## Não objetivos

- Não criar uma mecânica de perseguição, montaria, tempo ou reputação.
- Não detalhar Greenholders, Ailalore ou a identidade apagada de Kein além de
  “Elias”.
- Não adaptar o interrogatório/sacrifício de Kayron como decisão mecânica.
- Não criar carta, equipamento ou efeito jogável para os cadernos mágicos.

## Aceite proposto

- M4 fica bloqueada antes de M3 e liberada após a vitória em M3.
- A missão percorre a situação e os dois combates nas telas reais, sem
  fallback visual.
- A vitória salva os cadernos e preserva as revelações narrativas delimitadas.
- M1–M3 passam nas regressões aplicáveis.

## Decisão registrada

O recorte completo foi aprovado em 2026-09-23. O registro canônico e o
contrato de execução ficam em `[[M4-001-rodhes-bridge]]` e `SPEC-007`.
