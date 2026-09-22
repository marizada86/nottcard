---
id: "PLAN-004"
type: "plano"
title: "Plano de produção das cartas de arma"
status: "draft"
created: "2026-09-20"
relations:
  - "[[ART-PROMPTS-014-cartas-de-arma-2026-09-20]]"
  - "[[SPEC-047-equipamento-armas-e-armaduras]]"
  - "[[PLAN-003-producao-arte-primeira-pessoa-2026-09-20]]"
sources:
  - "ART-PROMPTS-014, 2026-09-20"
  - "Responsável, 2026-09-20: plano para gerar as imagens das cartas de arma"
---

# Plano de produção das três cartas de arma

> Rascunho operacional. A arte é incremental: sem imagem, o jogo conserva o retângulo de fallback.
> Este plano não autoriza mudanças de regra, promoção a cânone, commit ou publicação.

## 1. Resultado

Entregar as três ilustrações opacas de carta em `assets/cards/`, sempre derivadas da matriz em
`assets/_raw/cards/` e reduzidas pelo pipeline a 480×320:

| Ordem | Carta | Asset | Prova visual principal |
|---|---|---|---|
| 1 | Golpe Rápido | `golpe_rapido.png` | adaga pequena e dois riscos rápidos |
| 2 | Golpe Versátil | `golpe_versatil.png` | espada longa e transição para duas mãos |
| 3 | Golpe Esmagador | `golpe_esmagador.png` | maça, impacto e atordoamento |

O vermelho pertence à moldura programada da carta; na ilustração entra somente como acento seco e pontual.
Nenhuma imagem recebe texto, número, moldura, marca d'água ou símbolo de lore.

## 2. Preparação

1. Confirmar que os `asset_id` em `game/core/cards.py` são exatamente os três nomes acima e que
   `scripts/process_art.py cards` continua entregando 480×320.
2. Separar as referências indicadas no prompt: `golpe` e `golpe_perfurante` para a adaga; `golpe` e
   `golpe_contundente` para a espada; `golpe_contundente` e `atordoar` para a maça. Elas definem acabamento,
   paleta e leitura, não composição.
3. Abrir uma conversa de geração por família visual e colar o bloco de estilo de `ART-PROMPTS-014`. Produzir
   uma imagem por vez; se houver deriva, abrir conversa nova com o bloco e a última carta aceita como referência
   de acabamento.

## 3. Produção e revisão

### Onda 1 — Golpe Rápido

Gerar primeiro a adaga para calibrar a escala de arma pequena. Aceitar somente se, reduzida a aproximadamente
150 px de largura, ela continuar inequivocamente uma adaga e os dois riscos branco-azulados comunicarem rapidez.
Rejeitar se virar espada, golpe pelas costas, explosão ou dano pesado.

### Onda 2 — Golpe Versátil

Usar a adaga aprovada apenas como referência de acabamento. A leitura obrigatória é uma espada longa, com uma
mão já no cabo e a outra chegando à base para mostrar a mudança de empunhadura. Rejeitar se a segunda mão ficar
ambígua, se houver rosto ou se a arma se confundir com o `golpe.png` inicial.

### Onda 3 — Golpe Esmagador

Produzir a maça por último, porque é a cena mais carregada. A cabeça com flanges, a onda de choque e três estrelas
de atordoamento devem sobreviver à redução. O escudo e a criatura de pedra existem só para contextualizar o
impacto; não podem competir com a silhueta da maça ou introduzir personagem reconhecível.

## 4. Processamento e integração

Para cada carta aceita:

1. Salvar a matriz como `assets/_raw/cards/<asset_id>.png`.
2. Rodar `scripts/process_art.py cards`; conferir o recorte central 3:2, dimensão final 480×320 e PNG opaco.
3. Abrir a carta no jogo em mão normal, hover e tela de baralho/equipamento. A imagem não pode esconder nome,
   custo, raridade, descrição, bordas ou indicadores desenhados pela UI.
4. Se a composição não sobreviver ao layout real, regenerar a matriz; não consertar apenas o arquivo final.

## 5. Aceite e encerramento

Marcar o checklist de `ART-PROMPTS-014` somente quando cada arquivo:

- tiver matriz bruta e versão final no caminho exato;
- estiver em 3:2 / 480×320 final, sem letras, moldura ou transparência falsa;
- mantiver a arma identificável em miniatura e distinguível das cartas semelhantes;
- funcionar nas telas de mão, baralho e equipamento sem regressão de layout;
- passar a validação automatizada de assets e a verificação visual breve no jogo.

Após as três cartas, registrar capturas das três em contexto e a execução dos testes relevantes. Commit e publicação
continuam sujeitos à aprovação explícita do responsável.
