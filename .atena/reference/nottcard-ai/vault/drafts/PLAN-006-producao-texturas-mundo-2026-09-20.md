---
id: "PLAN-006"
type: "plano"
title: "Plano de produção das texturas do mundo em primeira pessoa"
status: "approved"
reviewed: "2026-09-20"
created: "2026-09-20"
relations:
  - "[[ART-PROMPTS-016-mundo-em-primeira-pessoa-2026-09-20]]"
  - "[[SPEC-058-texturas-do-mundo]]"
  - "[[SPEC-056-renderizador-do-mundo]]"
  - "[[PLAN-005-caminhada-em-primeira-pessoa-2026-09-20]]"
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
sources:
  - "ART-PROMPTS-016, 2026-09-20"
  - "SPEC-058, aprovada em 2026-09-20"
  - "Responsável, 2026-09-20: fazer plano para os assets de ART-PROMPTS-016; aprovado"
---

# Plano de produção das texturas do mundo em primeira pessoa

> Plano aprovado para executar `ART-PROMPTS-016`. A arte é incremental: sem um
> arquivo final, o mundo continua usando o recorte do cenário pintado e, na falta dele,
> uma cor lisa. Este plano não autoriza mudança de regras, promoção a cânone, commit ou
> publicação.

## 1. Resultado e limites

Entregar 21 texturas obrigatórias — parede, piso e teto para cada um dos sete ambientes
da rota M1 — em `assets/world/<ambiente>/`. Cada matriz começa em
`assets/_raw/world/<ambiente>/`, é quadrada, sem transparência e ladrilhável nos dois
eixos; `scripts/process_art.py world` a reduz para 128×128.

| Ordem narrativa | Ambiente | Saída final |
|---|---|---|
| 1 | `docas` | `wall.png`, `floor.png`, `ceiling.png` |
| 2 | `cais` | `wall.png`, `floor.png`, `ceiling.png` |
| 3 | `rachadura` | `wall.png`, `floor.png`, `ceiling.png` |
| 4 | `porao` | `wall.png`, `floor.png`, `ceiling.png` |
| 5 | `biblioteca` | `wall.png`, `floor.png`, `ceiling.png` |
| 6 | `corredor` | `wall.png`, `floor.png`, `ceiling.png` |
| 7 | `ritual` | `wall.png`, `floor.png`, `ceiling.png` |

Os oito adereços de `ART-PROMPTS-016` (`tocha`, `barril`, `caixote`, `livros`,
`braseiro`, `rede`, `ossos`, `vela`) são uma onda opcional e separada. Eles entram em
`assets/world/props/` com alfa, somente depois de fechar as 21 texturas; não bloqueiam
o aceite da SPEC-058. Portas e cadeado existentes permanecem fora deste lote.

## 2. Onda 0 — preparar e fixar o contrato

1. Conferir em `game/ui/world_art.py` que todos os sete nomes de ambiente apontam para
   os mesmos caminhos da tabela e que a ausência de cada arquivo preserva o fallback.
2. Separar as sete referências de ambiente indicadas nos prompts:
   `assets/rooms/sala_1_docas/bg.png`, `sala_2_cais/bg.png`,
   `sala_3_rachadura/bg.png`, `sala_4_porao_entrada/bg.png`,
   `sala_5_porao_livros/bg.png`, `sala_5b_porao_corredor/bg.png` e
   `sala_6_ritual/bg.png`. Elas definem material, paleta e acabamento; não devem impor
   perspectiva à textura.
3. Confirmar antes da primeira geração que `scripts/process_art.py world` preserva a
   estrutura de subpastas, entrega PNG 128×128 e não aplica chroma-key, recorte nem
   paleta indexada às texturas. Cobrir esse contrato por teste automatizado se ainda não
   houver cobertura.
4. Criar uma ficha curta de revisão por imagem: prompt, referências anexadas, tentativa
   aceita, caminho bruto, resultado da costura 3×3, revisão em 128 px e captura no jogo.
   A ficha registra o processo sem versionar as matrizes brutas.

## 3. Onda 1 — amostra de calibração: Cais

O `cais` é a primeira amostra, conforme a ordem sugerida em `ART-PROMPTS-016`: é uma
área muito percorrida e revela cedo repetição, contraste e névoa. Abrir uma conversa só
para este ambiente, colar o bloco de estilo e gerar uma imagem por mensagem na sequência:

1. `assets/_raw/world/cais/wall.png`, com o fundo da sala 2 anexado.
2. `assets/_raw/world/cais/floor.png`, com o mesmo fundo e a parede aprovada apenas como
   referência de material, paleta e acabamento.
3. `assets/_raw/world/cais/ceiling.png`, nas mesmas condições.

Depois de cada imagem, fazer primeiro a costura em 3×3 ainda na resolução de origem;
depois processar a candidata e repetir a inspeção em 3×3 a 128×128. Aceitar o trio só se
as emendas horizontais e verticais desaparecerem e se madeira, pedra, corrupção e céu
continuarem reconhecíveis em movimento. Se a amostra falhar, interromper o lote, ajustar
o prompt-base e repetir somente o Cais.

## 4. Onda 2 — produção das texturas obrigatórias

Com o Cais aprovado, abrir uma conversa por ambiente e produzir o trio completo, uma
imagem por mensagem. Anexar o `bg.png` correspondente à parede; nas imagens seguintes,
usar a parede aceita exclusivamente para manter material e acabamento. Não misturar
referências de ambientes distintos.

| Lote | Ambientes | Propósito da revisão |
|---|---|---|
| A | `docas`, `rachadura` | validar exterior seguro versus câmara de pedra e o uso contido de brilho mágico |
| B | `porao`, `biblioteca` | validar umidade, materiais subterrâneos e estantes/livros sem texto legível |
| C | `corredor`, `ritual` | validar progressão de corrupção, leitura do piso e teto escuros sem virar ruído |

Para cada ambiente, não avançar ao próximo componente antes de aprovar o anterior. Rejeitar
imediatamente perspectiva, horizonte, vinheta, sombra direcional, texto, runas legíveis,
personagens, criaturas, porta desenhada, marca d'água ou elemento único que denuncie a
repetição. Quando a costura for o único defeito, regenerar a matriz com o pedido explícito
de continuidade nas bordas opostas; não retocar somente o PNG final.

## 5. Onda 3 — processamento e integração por lote

Para cada trio aprovado:

1. Salvar as matrizes nos caminhos exatos de `assets/_raw/world/<ambiente>/`.
2. Processar com `python scripts/process_art.py world` e confirmar os três PNGs em
   `assets/world/<ambiente>/`, cada um com 128×128 e sem alfa inesperado.
3. Montar uma grade temporária 3×3 para parede, piso e teto finais. A parede deve encaixar
   ao lado; piso e teto devem encaixar nos dois eixos.
4. Percorrer a região correspondente no `WalkScreen`: observar paredes a curta e longa
   distância, piso/teto em perspectiva projetada, giros de 90° e névoa. Conferir que a
   textura não mascara portas, inimigos, interações ou a bússola.
5. Repetir uma execução sem um dos três arquivos para confirmar que o fallback continua
   saudável. Restaurar o arquivo aceito após a prova.

Fechar o lote A antes do B e o B antes do C. A pausa entre lotes é o ponto para corrigir
paleta, escala de detalhe ou contraste em todos os prompts ainda não executados, sem
invalidar os arquivos já aceitos.

## 6. Onda 4 — adereços opcionais

Somente após as 21 texturas, gerar os oito adereços em uma conversa própria. Eles usam o
mesmo acabamento, mas são cartazes com objeto centralizado, margem e fundo verde `#00FF00`;
o processamento precisa remover o chroma e preservar alfa. Produzir por famílias:

1. Docas: `barril`, `caixote`, `rede`.
2. Subsolo: `tocha`, `braseiro`, `vela`, `ossos`.
3. Biblioteca: `livros`.

Testar cada silhueta contra parede clara e escura, em escala próxima e distante. Caso o
pipeline atual não tenha contrato específico para `world/props`, registrar a lacuna e
resolver esse suporte antes de promover qualquer adereço; as texturas opacas não devem
esperar por isso.

## 7. Critérios de aceite

Um arquivo obrigatório só recebe marcação no checklist de `ART-PROMPTS-016` quando:

- o nome e as pastas bruta/final correspondem exatamente ao ambiente e ao componente;
- a matriz é quadrada, plana e sem transparência; a versão final mede 128×128;
- a amostra 3×3 não mostra costura, linha, quebra de padrão ou objeto cortado nas bordas;
- a leitura do material sobrevive à redução e à névoa do jogo, sem excesso de ruído;
- parede, piso e teto são uma família coerente, mas cada ambiente ainda é identificável;
- o teste no mundo não causa regressão visual em portas, sprites, HUD ou fallback.

A SPEC-058 estará pronta para encerramento quando os sete trios estiverem aceitos, a rota
1→7 estiver revisada no `WalkScreen`, os testes do pipeline e de fallback estiverem verdes
e houver ao menos uma captura de cada ambiente em contexto. Adereços permanecem uma melhoria
posterior, a menos que sejam explicitamente incorporados ao aceite.

## 8. Riscos e resposta

| Sinal | Resposta |
|---|---|
| Emenda visível em 3×3 | regenerar a matriz, reforçando continuidade das bordas; não disfarçar no renderizador |
| Textura vira pintura em perspectiva | rejeitar e repetir com “vista de frente, totalmente plana, sem horizonte” |
| Detalhe desaparece em 128 px | simplificar o material e ampliar seus traços no prompt seguinte |
| Ambiente fica claro/escuro demais no raycaster | ajustar a textura-base, não a névoa global que afeta todos os ambientes |
| Deriva de estilo entre conversas | abrir conversa nova com bloco de estilo e uma amostra aprovada somente como acabamento |
| Adereço perde alfa ou cria franja verde | manter a onda opcional bloqueada até o pipeline ter suporte e teste próprios |
