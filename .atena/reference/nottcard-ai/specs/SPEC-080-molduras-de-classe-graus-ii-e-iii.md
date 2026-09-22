---
id: "SPEC-080"
type: "spec"
title: "Molduras de classe: graus II (camada de ornamentos) e III (moldura completa)"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[SPEC-079-layouts-de-classe-mortes-e-moldura-nevoa]]"
  - "[[PLAN-013-layouts-de-classe-por-conquista-2026-09-20]]"
  - "[[ART-PROMPTS-020-molduras-de-carta-chatgpt-2026-09-20]]"
sources:
  - "Responsável, 2026-09-20: 'os novos assets foram adicionados, implemente-os e verifique se falta algum asset' (as 11 imagens do ART-PROMPTS-020)"
---

# Molduras de classe: graus II e III

Escrita depois da implementação, a partir do pedido do responsável de implementar as 11 imagens entregues.

## O que entra
- **Grau II** (20 mortes): a moldura Névoa recolorida com a paleta da classe (igual ao grau I) **mais a camada** `assets/card_frames/<classe>_2_overlay.png` por cima.
- **Grau III** (30 mortes): moldura própria `assets/card_frames/<classe>_3.png`, sem troca de paleta.
- Os 15 layouts de classe liberam pelas conquistas de mortes já existentes (`AVAILABLE_GRADES = {1, 2, 3}`); o seletor mostra os 17 layouts.
- Imagens: `assets/_raw/card_frames/` (bruto, fora do git) → `python scripts/process_art.py card_frames` → `assets/card_frames/` (308x420, alfa).

## Medidas reais (mudam o contrato do ART-PROMPTS-020)
As 11 imagens saíram com a janela da arte em **x 11,3–88,7% e y 18,8–78,1%** (mais estreita que os 7–93% pedidos), igual em todas.
`card_layouts.ZONES` usa as medidas das imagens: arte (0,113; 0,188; 0,887; 0,781), placa do nome (0,10; 0,107; 0,88; 0,178),
rodapé (0,117; 0,815; 0,883; 0,910), etiqueta de custo e gema nos cantos superiores.

## Legibilidade
As placas de pedra clara (Luz) e de aço polido (Paladino) dos graus II e III usam texto escuro (`DARK_TEXT`); as demais, o texto claro.
O painel de detalhe segue com o desenho por código (fora do escopo, como na SPEC-079).

## Testes
Cada imagem processada existe, tem o dobro da carta e a janela transparente; as molduras completas fecham os quatro lados da janela;
todo layout monta a moldura no tamanho da carta; o grau II difere do I (placa por cima) e do III; a suíte de layouts, loja, conquistas e
save foi ajustada para 17 layouts.

## Fora
Efeitos animados, brilho por raridade, moldura no painel de detalhe.
