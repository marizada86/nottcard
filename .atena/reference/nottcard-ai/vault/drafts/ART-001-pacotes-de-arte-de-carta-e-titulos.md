---
id: "ART-001"
type: "decision"
title: "Pacotes de arte de carta desbloqueados por títulos (moeda do jogo)"
status: "draft"
created: "2026-09-19"
relations:
  - "[[SIS-004-direcao-de-arte-pixel-art]]"
  - "[[SPEC-017-arte-final-no-jogo]]"
  - "[[VSN-001-visao-inicial]]"
sources:
  - "Responsável, 2026-09-19: compra só com moeda do jogo; arte por pacote, não por carta"
---

# Pacotes de arte de carta e títulos

Rascunho: nada aqui é regra até o responsável aprovar.

## Decisões já dadas pelo responsável

- A compra usa **somente moeda do jogo** (sem dinheiro real, loja externa ou validação de pagamento).
- A arte é organizada **por pacote**: um pacote cobre o conjunto de cartas, não uma carta isolada.
- **Fase 1 (teste):** todos os pacotes liberados; o jogador escolhe antes de iniciar a tentativa. Loja, títulos e preços ficam para depois. Ver `SPEC-030`.

## Proposta

### 1. Corpo da carta separado da ilustração

- Moldura, custo, cor da classe e texto são desenhados pelo código.
- A ilustração é só a janela de arte, com tamanho único e igual em todos os pacotes.
- Trocar de pacote troca apenas a imagem. Nome, atributos, dano e texto não mudam.
- **A verificar antes da spec:** se os PNGs atuais de `assets/cards/` já trazem moldura embutida. Se trouxerem, é preciso re-exportar só a janela de arte para o pacote padrão.

### 2. Estrutura de arquivos

```
assets/cards/<id>.png                  # pacote padrão (o que existe hoje)
assets/cards/<pacote>/<id>.png         # pacote alternativo
```

- `<pacote>` é um identificador em `snake_case` (ex.: `sombrio`).
- Resolução na carga: pacote ativo → pacote padrão → retângulo com o nome (regra atual do CLAUDE.md). Pacote incompleto nunca quebra o jogo.
- `process_art.py` processa uma pasta de pacote por vez, com as mesmas specs de `SIS-004`.

### 3. Modelo de dados (declarativo)

Cada pacote é um dado, não código:

| Campo | Significado |
|---|---|
| `id` | Identificador e nome da pasta. |
| `nome` | Nome exibido. |
| `titulo_requerido` | Título que desbloqueia o uso do pacote (ou vazio, se o pacote for padrão). |
| `preco` | Custo em moeda do jogo. |
| `cartas` | Lista das cartas cobertas. Cartas fora da lista usam o pacote padrão. |

### 4. Títulos, compra e escolha

- Ter o título **permite comprar** o pacote; comprar o pacote **permite equipá-lo**. Título sozinho não equipa nada.
- Os títulos vêm do mesmo mecanismo das conquistas (`game/core/achievements.py`).
- Estado persistido junto do progresso (`game/core/progress.py`): moeda, pacotes comprados, pacote ativo.
- Escolha do pacote ativo na tela de coleção (`game/ui/collection.py`). Um seletor global, sem sobrescrita por carta nesta primeira versão.
- O `core` guarda só identificadores e saldo. Nenhuma regra de jogo depende do pacote. `core` continua sem import de pygame.

### 5. Produção

- Cada pacote tem um bloco de estilo fixo (paleta, luz, técnica) e um prompt por carta que só troca o assunto.
- Os prompts ficam em `.atena/generated/ART-PROMPTS-<n>-*.md`, como os atuais.
- Todos os pacotes seguem a direção de `SIS-004` (pixel art, downscale nearest-neighbor). Estilo diferente quebra a identidade do jogo.

### 6. Peso do `.exe`

- O PyInstaller empacota `assets/` inteiro; cada pacote soma peso.
- Usar PNG indexado (como nas cenas) e medir o `.exe` a cada pacote adicionado.

## Perguntas em aberto

1. Como se ganha moeda do jogo? (por vitória, por sala, por conquista?) Sem isso não dá para calcular preço.
2. Título e pacote são 1 para 1, ou um título pode liberar vários pacotes?
3. O pacote cobre todas as 24+ cartas ou pode ser parcial (ex.: só as de uma classe)? O desenho acima aceita parcial.
4. Primeiro pacote alternativo: qual tema e qual título o libera?

## Próximos passos (ADD)

1. Responsável aprova ou ajusta este draft e responde às perguntas.
2. Promover para `canon/` (exige aprovação explícita).
3. Escrever a spec em `.atena/specs/` (loader com fallback, dados de pacote, persistência, tela de coleção) e só então implementar.
