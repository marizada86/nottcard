---
id: "PLAN-024"
type: "plano"
title: "Roteiro único: SPECs 098 a 106, arte e documentação (v0.14.1 a v0.18.0)"
status: "canon"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
  - "[[PLAN-022-pendencias-fora-do-playtest-2026-09-21]]"
  - "[[PLAN-023-visual-pixel-art-e-fluidez-da-caminhada-2026-09-21]]"
  - "[[ART-PROMPTS-023-cartas-novas-e-faltantes-2026-09-21]]"
sources:
  - "Responsável, 2026-09-21: 'junte todas as specs faltantes e faça um plano para implementar tudo' (playtest e Discord seguem fora)"
---

# Roteiro único

> Junta os três planos abertos (`PLAN-021` jogo, `PLAN-022` pendências, `PLAN-023` visual da caminhada) numa fila só, com ordem, versões e gates. O **quê e o como**
> ficam nas SPECs; aqui só ficam **ordem, dependências, versões e aprovações**. Fora de escopo: playtest (TASK-001..017) e Discord.

## 1. Inventário das SPECs

| SPEC | Assunto | Estado | Falta para começar |
|---|---|---|---|
| 098 | Vantagem e desvantagem | aprovada | — |
| 099 | Baralho base, Esquiva, poções, Golpe por conquista | aprovada | — |
| 100 | Cartas para Kayron/Brook, Olhar Fixo roxo, variedade | aprovada | — |
| 101 | Hover no Baralho | aprovada | — |
| 102 | Rolagem, tooltips, contraste do dado, clique direito | aprovada | — |
| 103 | Cópia do Sylas, equipamento único/proficiência, itens, bug da câmera, conquista de 30 | aprovada | conferir a **matriz de proficiências** |
| 104 | Caminhada: nitidez, luz de tocha, chamas, FPS | **draft** (sessão anterior) | **aprovação** |
| 105 | Caminhada: numpy, movimento fluido, cache de sprites | **draft** (nova) | aprovação; **depende da 104** |
| 106 | Auditoria de assets, textos de ajuda, integração da arte | **draft** (nova) | aprovação |

Ainda **sem prompt de arte**: os quadros de chama de tocha/braseiro e as variantes de parede (SPEC-104 §5, PLAN-023 bloco G) → `ART-PROMPTS-024` (a escrever
com a aprovação da SPEC-104, junto do validar-um-ambiente-primeiro).

## 2. Pontos onde as SPECs se cruzam (resolvidos aqui)

| Arquivo | Quem mexe | Regra |
|---|---|---|
| `dice_widget.py` | 098 (2 dados) e 102 item 6 (contraste) | Fazer o **contraste dentro da 098**: o widget nasce com os dois dados já legíveis. |
| `app.py` (laço, eventos) | 102 (clique direito), 104 (`fps_cap`), 103 G6 (limpar teclas) | G6 primeiro (bug), depois 102, depois 104; uma alteração por commit. |
| `profile.py` e menu de pausa/opções | 104 (`fps_cap`, `torch_flicker`), 105 (`walk_bob`) | Um bloco "Opções" só; 105 acrescenta a linha. |
| `save_file.py` | 099 (núcleo, conquista com carta), 103 G2 (unidades de equipamento) | Duas migrações **independentes e idempotentes**, cada uma com teste com fixture do save 0.14.0. |
| `walk_screen.py`/`walker.py` | 103 G6, 105 (movimento) | G6 antes da 105; a interpolação da 105 respeita o teste do G6. |
| `tutorial_content.py` | 098, 099, 103, 104, 105 (via 106) | Cada SPEC atualiza os textos **no próprio commit**. |
| `achievements.py` | 099 (Veterano de Durvall, `grant_card`), 103 (Golpe Devastador, `damage_bonus`) | Criar o mecanismo de benefício uma vez (na 099) e reaproveitar. |

## 3. Fila (fases, versões e gates)

| Fase | O quê | SPEC | Versão |
|---|---|---|---|
| **0** | Higiene do repositório (PLAN-022 P7): renomear a pasta de evidência, apagar `tmp/m2_wall_repeat.png`, `.gitignore` de `tmp/`; **suíte inteira** e linha de base: `simulate.py` (5 personagens) e `profile_walk.py` (quando existir, fase 6) | — | — |
| **1** | **Bug da câmera** (G6): teste que reproduz, correção e regressão | 103 (G6) | 0.14.1 |
| **2** | Ferramenta `audit_assets.py` e testes de fallback (§1–2 da 106); primeira auditoria salva | 106 (§1–2) | — |
| **3** | Vantagem/desvantagem (motor, fontes, dois dados com contraste, log) | 098 + 102 (item 6) | 0.15.0 |
| **4** | Núcleo novo, Esquiva, caps, conquista do Golpe, poções em eventos, migração | 099 | 0.15.0 |
| **5** | Estocada Mística, Pancada de Escudo, Olhar Fixo roxo; **simulação depois** (±15% entre os 5) e ajuste dos números | 100 | 0.15.0 |
| **6** | Hover no Baralho; rolagem (resultado, catálogo, conquistas, guia); tooltips da loja; clique direito | 101 + 102 (restante) | 0.15.1 |
| **7** | Cópia do Sylas como alvo; conquista de 30 de dano | 103a (G1, G7) | 0.16.0 |
| **8** | Equipamento por unidade, proficiências, Robe/Cajado/Cetro, transferir item | 103b (G2–G5) | 0.16.1 |
| **9** | Medição da caminhada; nitidez; opção de FPS; névoa e luz de tocha; luz local; quadros de chama | 104 | 0.17.0 |
| **10** | **Decidir com a medição** da fase 9: numpy (parte 1) só se passar do orçamento; movimento fluido; cache de sprites | 105 | 0.18.0 |
| **11** | Documentos derivados: `CLAUDE.md` curto, `README`, marcar velhos, log do projeto (§5 da 106) | 106 | a cada versão |

Textos de ajuda (106 §3) entram **dentro** das fases 3, 4, 6, 8, 9 e 10, no mesmo commit da SPEC que os motiva.

**Gates de cada fase:** (1) suíte inteira verde (hoje mais de 1284 testes; a fase 0 registra o número exato); (2) o teste novo da SPEC falha antes e passa depois;
(3) `git status` limpo e commit **por SPEC/bloco** — **só com aprovação explícita** (`add.yaml`); (4) na virada de versão: `version.py`, build local,
**exe renomeado para `nottcard-ai-<versão>.exe` em `dist/`** e CI; (5) save 0.14.0 do Higor guardado como fixture abre nas versões novas (fases 4 e 8).

## 4. Trilha de arte (em paralelo, sem bloquear código)

| Lote | Quando gerar | Arquivo de prompts | Integração |
|---|---|---|---|
| 1 | Já (antes da fase 3 terminar) | `ART-PROMPTS-023` §4.1 a 4.3 (Esquiva, Estocada Mística, Pancada de Escudo) e 4.6 a 4.9 (raras do sacerdote) | `process_art.py cards` + conferir no jogo |
| 2 | Antes da fase 8 | `ART-PROMPTS-022` §A (salas 5 e 6, `fg` das 2 a 4) e §C (texturas M2: gerar 1 céu e copiar) | `rooms`, `world` |
| 3 | Fases 8 e 9 | `ART-PROMPTS-023` 4.4, 4.5 (Cajado e Cetro, **só depois que a simulação da fase 5 fixar o efeito**), 4.10; `ART-PROMPTS-022` §D, §F, §G | `cards`, `world/props`, `portraits`, `items` |
| 4 | Fase 9 | `ART-PROMPTS-024` (chamas e variantes de parede da SPEC-104) — **validar um ambiente (`docas`) primeiro** | `world/props` |
| 5 | Por último | `ART-PROMPTS-022` §H e §I (HQ e tela de missão) | `hq`, `screens` |

Cada lote roda a auditoria (fase 2) e só então é commitado.

## 5. Riscos e o que fazer

- **Migrações de save (099 e 103 G2):** as duas mexem no save; testar com o save real do Higor como fixture e com saves vazios/novos. Nada é apagado do jogador.
- **Simulação fora do alvo (100):** ajustar os números das cartas novas e repetir; o Cajado e o Cetro esperam esse resultado.
- **Numpy (105):** medir tamanho do `.exe` e paridade visual antes de aceitar; caminho antigo permanece como fallback.
- **Nitidez expõe arte fraca (104):** parte da arte de textura pode virar retrabalho; vem na trilha de arte, lote 4.
- **Tamanho:** são ~10 fases; recomendo **entregar por versão** (0.15.0 já muda o jogo; 0.17.0 muda o visual), com o responsável decidindo, a cada versão, se
  segue ou se manda para o playtest antes.

## 6. Aprovações que este plano precisa

1. Este plano (`PLAN-024`) e o `PLAN-021`/`PLAN-022`: promover para `canon/` **só com sua aprovação**.
2. SPECs **104, 105 e 106** (drafts): aprovar, ajustar ou recusar cada uma.
3. A matriz de proficiências da SPEC-103.
4. Autorização de commit por fase (padrão do projeto: nada sem aprovação).
