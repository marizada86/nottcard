---
id: "SPEC-106"
type: "spec"
title: "Auditoria de assets, textos de ajuda e integração da arte nova"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-022-pendencias-fora-do-playtest-2026-09-21]]"
  - "[[ART-PROMPTS-023-cartas-novas-e-faltantes-2026-09-21]]"
  - "[[PLAN-024-roteiro-unico-de-implementacao-2026-09-21]]"
sources:
  - "PLAN-022 P2, P3, P5 e P6; responsável, 2026-09-21: 'junte todas as specs faltantes'"
---

# Auditoria de assets, textos e integração de arte

> Rascunho: espera aprovação. Nada de regra de jogo: ferramenta, texto e fiação de arte.

## 1. `scripts/audit_assets.py`
- Lê do código tudo que o jogo carrega por nome: cartas (`asset_id`/`slug` de `cards.py`, `scrolls.py`, `equipment.py`), inimigos (`enemies.py`), salas e camadas
  (`rooms.py`, `dungeon_*.py`), texturas do mundo (`world_art.py`), adereços, portas, retratos, itens (`items.py`), HQ (`hq.py`), telas (`screens`) e ícones de HUD.
- Compara com `assets/` e escreve `.atena/generated/ASSETS-AUDITORIA-<data>.md` com **existe/falta por categoria**, a contagem e os caminhos finais esperados
  (e, ao lado, o bruto em `_raw/` quando existir mas o final não).
- Não mexe em arquivo nenhum; saída determinística (mesma entrada, mesmo texto), ordem alfabética.
- `--check`: código de saída 1 se faltar algo de uma **lista de obrigatórios** (`scripts/audit_assets.py` traz `REQUIRED` vazio por padrão; nada é obrigatório
  enquanto houver fallback). Serve para CI futuro; não entra no `build-release.yml` agora.

## 2. Testes de fallback
`tests/ui/test_assets_fallback.py`: para cada tipo (carta, inimigo, sala bg/fg, textura, adereço, porta, retrato, item, HQ, tela, ícone), pedir um nome
inexistente devolve o retângulo com o nome (ou `None` tratado) e **não levanta exceção**; desenhar a tela correspondente com o asset ausente também não.

## 3. Textos de ajuda (tutorial e "Como jogar")
Atualizar `tutorial_content.py` e o guia conforme cada SPEC entra, no mesmo commit dela:
- SPEC-098: seção "Vantagem e desvantagem"; Esquiva na lista de reações; Ataque Imprudente agora dá vantagem aos inimigos.
- SPEC-099: "Uma Poção por missão; ache mais em eventos ou compre do mercador"; o núcleo novo (sem "Toque Curativo x2").
- SPEC-103: equipamento por unidade, proficiência, passar item; conquistas novas.
- SPEC-104/105: opções de FPS, tremulação e movimento suave.
**Teste de texto proibido:** o tutorial não cita "acerta sem teste", "2 Toques" nem "2 Poções" (busca por palavras-chave).

## 4. Integração da arte
- `scripts/process_art.py`: garantir as categorias usadas pelos prompts novos (`cards`, `rooms`, `world`, `world/props`, `items`, `portraits`, `hq`, `screens`); os
  quadros de chama da SPEC-104 (`tocha_0..2`, `braseiro_0..2`) entram como props; erro claro se faltar o verde/magenta de chroma-key.
- Antes de aprovar cada lote: abrir dentro do jogo (combate, Baralho, caminhada) e conferir a silhueta a 150 e 64 px.
- Depois de cada lote, rodar a auditoria e commitar `assets/` (o bruto `_raw/` continua fora do git).

## 5. Documentos derivados
- `CLAUDE.md`: trocar "Marco atual" por um resumo curto (versão, o que é jogável, pendências); o histórico vai para `.atena/vault/canon/` (proposta para aprovação).
- `README`: comandos, teclas e versão.
- Marcar `ASSETS-PENDENTES-001.md` e `ART-PROMPTS-014` como `superseded` apontando para `ART-PROMPTS-023` e a auditoria.
- Log do projeto (marizverso.com) e a descrição viva: uma entrada datada por versão, como documentos separados.

## 6. Testes
`tests/test_audit_assets.py` (com pasta de assets e código sintéticos: categorias, existe/falta, ordem, determinismo, `--check`), `tests/ui/test_assets_fallback.py`,
`tests/ui/test_tutorial_text.py` (palavras proibidas; cada seção nova existe).
