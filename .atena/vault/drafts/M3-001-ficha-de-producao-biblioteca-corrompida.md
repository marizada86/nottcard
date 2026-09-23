---
id: "M3-001"
type: "ficha-de-producao"
title: "M3 — Ficha de produção da Biblioteca Corrompida"
status: "promoted"
created: "2026-09-22"
promoted_to: "[[M3-001-biblioteca-corrompida]]"
sources:
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[VSN-004-elementos-adaptaveis-m1-m6]]"
  - "[[PLAN-026-inventario-e-producao-de-assets-m1-a-m9-2026-09-21]]"
---

# M3 — Ficha de produção da Biblioteca Corrompida

## Objetivo aprovado pelo cânone

Explorar uma biblioteca de três andares, resistir à invasão psíquica de
Ghaunadaur e resolver os enigmas do silêncio para avançar. A missão apresenta
Livrinho, planta o pedido de socorro de Aila sem revelar sua origem e entrega
a Ampulheta do Silêncio Eterno.

## Material final já disponível

| Papel | Arquivo |
|---|---|
| Ambiente modular | `assets/world/biblioteca/{wall,floor,ceiling}.png` |
| Inimigo-base | `assets/enemies/gargula_corrompida.png` |
| Contato onírico | `assets/portraits/aila.png` |
| Recompensa-chave | `assets/items/ampulheta_silencio_eterno.png` |
| Companheiro/prop | `assets/world/props/livrinho.png` |

Esses arquivos estão importados no Godot. Não há ainda uma missão M3, salas
ou encontros declarados no jogo.

## Backlog visual necessário

| Prioridade | Entrega | Quantidade mínima | Observação |
|---|---|---:|---|
| P0 | Salas em camadas `bg`/`fg` | 3 | Uma composição por andar: entrada, acervo/enigma e arquivo final. |
| P0 | Prop diário das gárgulas | 1 | Contém a pista dos nomes verdadeiros. |
| P0 | Prop recorte de jornal de Aluris | 1 | Apenas gancho para Interlúdio D; não revela a solução. |
| P1 | Props de biblioteca | 3 | Estantes, livros sussurrantes e suporte da ampulheta; reaproveitar `livros` onde bastar. |
| P1 | Variações de gárgula | 0–2 | Só se a leitura dos grupos ficar ruim com o sprite-base. |
| P2 | Cartas de pesadelo | 0–4 | Só entram após cada trauma e efeito serem aprovados. |

## Proposta de fluxo jogável — precisa de aprovação

1. **Andar 1 — Entrada selada:** apresentação de Livrinho, primeira visão e
   gárgulas adormecidas.
2. **Andar 2 — Acervo do silêncio:** o diário revela a regra; os livros dão as
   pistas do enigma e o jogador evita despertar as estátuas.
3. **Andar 3 — Arquivo corrompido:** contato de Aila, Ampulheta e saída da
   biblioteca.

Para preservar as regras já portadas, a opção recomendada é modelar o
"puzzle de silêncio" como situações declarativas com escolhas e testes de
atributo, usando o diário para liberar a escolha segura. Não cria uma mecânica
global nova nem obriga combate contra as dez gárgulas.

## Limites narrativos

- Aila não recebe localização, filiação ou solução para seu sofrimento.
- O segredo de Durvall e os acontecimentos de Interlúdio D não são revelados.
- A frase de Ghaunadaur pode reaparecer como sabor, mas não cria uma regra de
  corrupção sem uma spec própria.
- O diário e o recorte são itens de lore/progressão; não viram carta ou
  equipamento sem especificação posterior.

## Plano de voo após aprovação

1. Promover esta ficha e criar a SPEC de M3 com IDs, salas, encontros, regras
   de desbloqueio e critérios de aceite fechados.
2. Produzir e aprovar a amostra de uma sala em camadas e do diário.
3. Gerar o lote P0, integrar os dados da missão e implementar apenas as
   situações aprovadas.
4. Validar o percurso M2 → M3, os assets no contexto real, save e regressão
   de M1/M2; registrar evidência.

## Decisão registrada

O fluxo inteiro foi aprovado em 2026-09-22. O registro canônico e a execução
estão em `[[M3-001-biblioteca-corrompida]]` e `SPEC-006`.
