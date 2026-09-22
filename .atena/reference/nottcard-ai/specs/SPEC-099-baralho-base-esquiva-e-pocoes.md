---
id: "SPEC-099"
type: "spec"
title: "Baralho base: núcleo novo, Esquiva, poções e Golpe por conquista"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[SPEC-098-vantagem-e-desvantagem]]"
  - "[[SPEC-045-loja-de-upgrades-por-nivel]]"
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
sources:
  - "Responsável, 2026-09-21: 1 Toque Curativo, +1 Palavra Curativa, Esquiva roxa, 1 Poção por missão, Golpe Perfurante x2, Golpe por conquista do Durvall nv4"
---

# Baralho base

## Núcleo (`collection.CORE_DECK`, 8 cartas)
`Golpe ×2, Chama Menor ×2, Toque Curativo, Palavra Curativa, Poção de Cura, Esquiva`. Continua válido: 2 de cada cor (a Esquiva repõe a 2ª Roxa), 2 ataques, 3 curas.

## Cartas e tetos
- **Esquiva** (nova, comum, Roxa, `reacao`, `reacts_to="qualquer"`, `forces_disadvantage=True`): na janela "Reagir?", o ataque inimigo é **rolado de novo com
  desvantagem** (o d20 original + um novo, fica o menor); dano e efeitos seguem o resultado final. A janela só oferece a Esquiva quando o golpe **acertou**.
  Entra em `COMMON_NAMES`, `asset_id="esquiva"` (fallback: retângulo com o nome). Texto: "o ataque é rolado de novo com desvantagem".
- `COPY_CAP_BY_NAME`: `Poção de Cura` 1, `Toque Curativo` 1, `Palavra Curativa` 1, `Golpe Perfurante` 2 e `Golpe` 2 **no sorteio inicial** (`starting_extras` e
  `starting_deck` respeitam; `MAX_COPIES` segue 3 para o resto). Ganhar carta por conquista/loja pode passar do teto do sorteio, nunca do de validade (`deck_problems`).
- **Uma Poção por missão no total (medido em 2026-09-21):** numa tentativa com save, a Poção vem **só do núcleo** (2 hoje, com Durvall, Maelor, Sylas, Kayron e Brook):
  a Poção é carta coletável, então `signature_cards` não a duplica. Os baralhos fixos (1 Poção cada) só valem sem baralho do save (testes e `App` em memória) e ficam
  como estão. Basta o núcleo cair para 1 e o teto da Poção para 1. Maelor mantém a Palavra Curativa como HC; a coletável do núcleo é a segunda e `deck_problems` aceita.
- **Migração** (`ensure_core`/`ensure_collection`): saves com 2 Toques/2 Poções no baralho devolvem a cópia excedente à coleção (nada é apagado) e o núcleo é
  completado com Palavra Curativa e Esquiva na coleção e no baralho.

## Golpe permanente por conquista
- Conquista **"Veterano de Durvall"**: Durvall chega ao nível 4. Benefício `grant_card` (novo em `achievements.py`): +1 **Golpe** na coleção, uma vez; também
  concedido ao carregar um save em que Durvall já é nv≥4. A tela de Conquistas descreve o ganho.

## Poções: eventos e loja
- Evento aleatório **"Frasco esquecido"** (`event_data.py`, motor SPEC-074): dá 1 Poção de Cura temporária (SPEC-076) na tentativa; peso comparável aos eventos de
  ouro; 1 vez por tentativa. Um segundo evento troca uma Poção por outro benefício útil (escolha do jogador).
- Mercador (`events.py`): a Poção segue a `POTION_PRICE`, com **estoque 1 por visita**.

## Testes
`test_collection.py` (núcleo de 8 válido; tetos do sorteio em 1000 sementes; migração de save antigo sem perda), `test_combat.py` (Esquiva: só quando acertou, rola
com desvantagem, consome a reação), `test_achievements.py` (nv4 → +1 Golpe uma vez), `test_events.py` (Frasco esquecido; mercador com estoque 1).
