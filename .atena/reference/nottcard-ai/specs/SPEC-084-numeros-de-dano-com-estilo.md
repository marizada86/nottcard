---
id: "SPEC-084"
type: "spec"
title: "Números de dano maiores, com estilo e efeitos"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[PLAN-015-observacoes-v0.11.0-strafe-minimapa-dano-abas-2026-09-20]]"
  - "[[SPEC-008-numero-de-dano-cresce-com-o-dano]]"
sources:
  - "Responsável, 2026-09-20: aumentar a fonte e dar estilo aos números de dano, com efeitos visuais se possível. Decisões D4 e D5 do PLAN-015 pelas recomendações"
---

# Números de dano com estilo

## Mudanças (`game/ui/damage_fx.py`)
- **Fonte (D4):** Alegreya Sans Bold no lugar da fonte padrão do sistema. Testada contra a Cinzel Decorative Bold numa folha de amostra: a Cinzel tem numerais antigos (o "1" vira um "I", alturas diferentes), ruins para um valor; a Alegreya tem dígitos alinhados e pesados.
- **Tamanho:** o dano da carta passa de 44 para **64 px**, e os degraus de dano alto de x1,25/x1,5 para **x1,3 (10+)** e **x1,7 (20+)**. Os pontos de chamada no `app.py` continuam passando a base antiga; `damage_font_size` aplica o fator.
- **Estilo (`styled_text`, em cache):** degradê vertical (claro em cima, cor cheia embaixo), **contorno escuro grosso** (proporcional ao tamanho), sombra projetada e, com `glow`, um **halo** na cor do número. A cor por tipo (cor da carta, cura verde, bloqueio cinza) não muda.
- **Movimento:** entrada com **pop** (escala 0,5 → 1,3 → 1,0 em 0,18 s), subida e fade como antes; **tremor** curto (0,3 s) nos que têm `shake`. O número nunca sai da tela.
- **Faíscas (D5):** `damage_fx(dano, crit, killed)` liga os efeitos completos (halo, faíscas, tremor) só no **crítico** e no **dano alto** (10+ e 20+, mais forte no segundo); quem **elimina** o inimigo ganha faíscas sem halo; dano comum só ganha o estilo e o pop. O "CRÍTICO!" também ganha halo, faíscas e tremor.
- **Reduzir movimento:** sem pop, tremor nem faíscas (só subida e fade). O combate copia `App.reduce_motion` para `FloatingNumbers.reduced` a cada quadro.
- **Desempenho:** a superfície estilizada é guardada em cache (antes era refeita a cada quadro); o traço do valor riscado é desenhado numa cópia.

## Pontos de uso
Dano da carta no inimigo (com crítico e eliminação), dano do inimigo no jogador (normal e especial), trovão e contra-ataque; "CRÍTICO!". Os demais números (cura, bônus, estados, "Acertou!/Errou!") ganham a fonte e o estilo, sem efeitos.

## Fora
Novo som, tremor de tela, números no modo caminhada e o HUD (`outlined_text`, que segue como está).

## Testes
`tests/ui/test_damage_style.py`: degraus de tamanho; efeitos só em crítico/dano alto/eliminação; gradiente, contorno e cache; halo maior; a fonte; a linha do tempo do pop; faíscas nascem e morrem, e só quando o número aparece; `reduzir movimento` desliga pop, tremor e faíscas; o tremor só nos primeiros instantes; o número não sai da tela; o traço não vaza para o cache; o tempo de vida e a subida. `test_damage_fx.py` foi ajustado aos novos tamanhos.
