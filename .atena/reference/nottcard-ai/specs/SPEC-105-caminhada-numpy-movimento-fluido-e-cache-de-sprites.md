---
id: "SPEC-105"
type: "spec"
title: "Caminhada: renderizador com numpy, movimento fluido e cache de sprites"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[PLAN-023-visual-pixel-art-e-fluidez-da-caminhada-2026-09-21]]"
  - "[[SPEC-104-caminhada-nitidez-luz-de-tocha-e-fps]]"
  - "[[PLAN-024-roteiro-unico-de-implementacao-2026-09-21]]"
sources:
  - "SPEC-104 §Fora desta SPEC: numpy (bloco C), balanço/inclinação (bloco E) e cache de sprites (bloco F) 'vêm numa SPEC-105, decididos com base na medição'"
  - "PLAN-023 §2 blocos C, E e F; decisão do responsável: adicionar numpy"
---

# Caminhada: numpy, movimento e cache

> Só desenho e input de caminhada; `game/core/` não muda. **Depende da SPEC-104 implementada** (a evidência de desempenho dela decide a parte 1).
> Rascunho: espera aprovação do responsável (`execution_approval: per-spec`).

## 1. Renderizador com numpy (bloco C) — condicional à medição
**Gate:** só se, depois da SPEC-104, a evidência `PERF-caminhada-*.md` mostrar média > 16 ms a 60 FPS **ou** p95 > 33 ms no PC do dono. Se estiver dentro
das metas, esta parte fica **adiada** (registrada na evidência) e a SPEC segue só com as partes 2 e 3.
- `numpy` entra em `requirements.txt`; conferir que `pyinstaller --onefile` (`build-release.yml`) empacota e **medir o tamanho do `.exe`** antes/depois
  (registrar na evidência; aceitar até +25 MB, acima disso decidir com o responsável).
- **Piso e teto:** mapa de coordenadas de textura por linha calculado uma vez por resolução (cache) e deslocado pela posição/ângulo; amostragem por indexação
  do `ndarray` da textura, em 240×68 por faixa (SPEC-104), ampliada 2× inteiro. Sem `get_at`/`set_at` por pixel.
- **Paredes:** raios em lote (DDA vetorizado, um raio por coluna) devolvendo distância, face e coluna de textura; a coluna vem por indexação de
  `ndarray`, sem 480 `blit`. `zbuf` vira `ndarray` de 480 posições, lido pelos sprites.
- **Paridade obrigatória:** `raycast.py` continua como referência. Teste percorre 200 posições/ângulos (M1 e M2) e exige mesma distância (tolerância 1e-6),
  mesma face e mesma coluna de textura que `cast_ray`; e o quadro final igual ao do renderizador antigo em pelo menos 99,5% dos pixels (fora bordas de
  arredondamento). A geometria e a oclusão dos sprites **não mudam**.
- Sem numpy instalado o jogo **não** cai: `WorldRenderer` mantém o caminho atual como fallback (import protegido) — o que também deixa o teste de paridade possível.

## 2. Movimento fluido (bloco E)
- **Curva de aceleração:** `_smooth` simétrico dá lugar a ease-in-out com arranque mais suave e parada mais curta (curva única em `walk_screen.py`, testada:
  contínua, monótona, `f(0)=0`, `f(1)=1`, derivada 0 nas pontas).
- **Balanço de passo:** deslocamento vertical da câmera de ±1,5 px (na tela 480×270) durante o avanço/recuo, uma onda por passo de grade; zero parado.
- **Inclinação ao girar:** rotação leve (≤ 1°) do quadro renderizado durante o giro, ou, se o custo passar de 1 ms, deslocamento horizontal equivalente de até 3 px.
- **Transição de porta/sala:** fade curto (≈ 0,25 s) reaproveitando `transition.py`.
- **Opção "Movimento suave: ligado | desligado"** (`Profile.walk_bob`, padrão ligado), ao lado das opções da SPEC-104, por acessibilidade. Desligado: sem
  balanço, sem inclinação, curva simples.
- A lógica continua por grade: posição e ângulo lógicos não mudam; só a **posição de desenho** é interpolada. **Interação com o bug da câmera (SPEC-103 G6):** a
  interpolação nunca acumula giro pendente; ao pausar, perder foco ou entrar em combate ela termina na hora.

## 3. Cache de sprites e sombra de contato (bloco F)
- Cache de sprites já redimensionados por `(slug, altura em px, nível de névoa, quadro)`, com limite (LRU de 256) e esvaziado ao trocar de ambiente.
- Adereços e inimigos usam o mesmo `fog_level` e as mesmas luzes locais da SPEC-104.
- **Sombra de contato:** elipse escura semitransparente no chão sob inimigos e adereços altos (pré-calculada por largura, também em cache), respeitando o `zbuf`.

## 4. Testes
- `test_raycast_numpy.py`: paridade (parte 1), com e sem numpy (`monkeypatch` do import).
- `test_walk_motion.py`: curva (contínua, monótona, extremos); balanço zero parado e dentro de ±1,5 px; `walk_bob=False` desliga tudo; posição lógica igual com e sem suavização;
  nenhum giro pendente após `pause()`/perda de foco.
- `test_sprite_cache.py`: mesma chave devolve o mesmo objeto; LRU respeita o limite; trocar de ambiente esvazia.
- Os testes existentes de raycast e mundo continuam passando.

## 5. Critérios de aceite
- Evidência de desempenho comparando SPEC-104 e SPEC-105, com tamanho do `.exe`.
- Captura de movimento (gif ou sequência) do corredor de M1 e de uma sala de M2 sem engasgos; opção de desligar funciona.
- Playtest do dono confirma "fluido" (como na SPEC-104); sem ele a SPEC fica "implementada, aguardando playtest".
