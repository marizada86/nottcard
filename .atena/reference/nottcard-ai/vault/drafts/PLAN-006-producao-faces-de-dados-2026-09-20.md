---
id: "PLAN-006"
type: "plano"
title: "Plano de produção das 60 faces de dados"
status: "draft"
created: "2026-09-20"
relations:
  - "[[DICE-FACES-PROMPTS-001-todas-as-faces-2026-09-20]]"
  - "[[DICE-TEXTURE-PROMPTS-001-d20]]"
  - "[[DICE-TEXTURE-PROMPTS-002-d4-d6-d8-d10-d12]]"
  - "[[SPEC-002-animacao-dado-d20-procedural-3d]]"
sources:
  - "DICE-FACES-PROMPTS-001, 2026-09-20"
  - "Responsável, 2026-09-20: plano para criar as imagens das faces de dados"
---

# Plano de produção das faces de dados

> Rascunho operacional. São 60 matrizes independentes (4+6+8+10+12+20). A ausência de qualquer uma
> não bloqueia o jogo: o numeral existente, desenhado pelo código, é a reserva. Este plano não aprova a
> mudança de renderização, malhas novas, promoção a cânone, commit ou publicação.

## 1. Resultado e regras inegociáveis

Cada arquivo terá o nome `d<lados>_face_<NN>.png`, será salvo em `assets/_raw/dice/textures/` e processado
para a textura final de, no máximo, 128 px. A unidade de aceite é uma face, não um dado inteiro.

| Dado | Faces | Forma | Observação de integração |
|---|---:|---|---|
| d4 | 4 | triângulo | malha já existe |
| d6 | 6 | quadrado | malha já existe |
| d8 | 8 | triângulo | malha já existe |
| d10 | 10 | pipa | textura pode existir, mas aguarda malha própria |
| d12 | 12 | pentágono | textura pode existir, mas aguarda malha própria |
| d20 | 20 | triângulo | malha já existe; 01 e 20 são especiais |

Em toda face: gema-pedra esmeralda, face plana sem perspectiva, fundo magenta `#FF00FF` exclusivo do
recorte, e exatamente um numeral gravado, em pé e sem espelhamento. O numeral é mais importante que o
desenho de rachaduras; uma face bonita com valor errado é rejeitada.

## 2. Preparação e ficha de controle

1. Criar uma ficha por dado com 4/6/8/10/12/20 linhas: número pedido, arquivo bruto, imagem aceita,
   numeral conferido, leitura a 128 px, estado do processamento e observações sobre rachaduras.
2. Para cada dado, abrir uma conversa nova, colar o bloco de estilo e anexar o ícone `assets/dice/dN.png`
   mais a textura única `assets/dice/textures/dN_face.png` como referências de material.
3. Usar a face `01` do próprio dado como amostra. Somente depois de ela acertar forma, acabamento e tamanho
   do numeral, usá-la como referência de material para as demais — nunca copiar rachaduras ou desgaste.
4. Confirmar antes de iniciar que o pipeline continua reconhecendo `dice/textures/`, recortando magenta,
   preservando a forma e limitando o lado maior a 128 px. Adicionar o teste de convenção de nomes junto da
   futura spec de integração, sem reescrever as matrizes para contornar o código.

## 3. Ordem de produção

Produzir uma imagem por mensagem e revisar antes da próxima. A ordem contém uma amostra de baixo risco,
duas famílias já renderizáveis, as famílias aguardando malha, e fecha pelo d20 crítico.

1. **d6 (01–06):** quadrado mais simples; valida o tamanho e a legibilidade do numeral. A face 06 recebe
   sublinhado gravado.
2. **d4 (01–04) e d8 (01–08):** transfere a mesma linguagem para triângulos; conferir o numeral no centro
   de gravidade, não no centro geométrico do quadro. Faces 06 de d8 também recebem sublinhado.
3. **d20 (02–19):** produzir em blocos de três, registrando a leitura individual. 06, 09, 16 e 19 recebem
   sublinhado; valores 10–19 têm dois dígitos, que não podem tocar as bordas ou se fundir.
4. **d20 especial:** gerar 01 depois das demais para manter a rachadura funda sem esconder o `1`; gerar 20
   por último, com brilho de veios e âmbar discretamente maior, sem virar uma face de outra paleta.
5. **d10 (01–10) e d12 (01–12):** produzir por último, em blocos de dois ou três. A arte fica pronta para a
   futura malha, mas não justifica mudança no widget enquanto a pipa e o pentágono não forem projetados.

Se dois resultados consecutivos errarem o numeral, parar aquele item e usar a correção focal: pedir somente
o valor exato, com traços grossos, em pé e sem outro símbolo. Não compensar manualmente com texto externo.

## 4. Revisão de cada face

Antes de salvar, conferir numa ficha visual:

- forma correta, frontal, ocupando aproximadamente 90% do quadro, sem borda desenhada;
- magenta sólido somente fora da forma e nenhum vazamento magenta no cristal;
- o valor pedido é o único numeral, não está espelhado ou rodado e tem sublinhado quando necessário;
- os sulcos do numeral têm profundidade e luz verde fraca suficiente para leitura imediata a 128 px;
- rachaduras e desgaste diferem entre faces sem competir com o numeral;
- d20 01 permanece mais escuro com rachadura diagonal legível; d20 20 tem só um reforço moderado de brilho
  e âmbar.

Uma face reprovada não deve parar o próximo dado: registrar o fallback e continuar o lote, voltando ao item
em uma conversa de geração limpa.

## 5. Processamento, integração e aceite

Após aceitar um bloco de faces, rodar o processador somente para `dice`, abrir as texturas resultantes e
conferir alfa, recorte e lado máximo de 128 px. Testar em contato com o fundo do widget; nenhuma borda verde
ou recorte apertado pode aparecer.

O aceite de produção exige 60 matrizes e 60 versões finais no caminho exato, a ficha de numerais completa e
todos os valores lidos a 128 px. O aceite de jogo é separado: a futura spec deve selecionar
`dN_face_NN.png`, manter `dN_face.png` e o numeral por código como fallback, e acrescentar malhas de d10/d12
antes de tentar renderizar essas 22 faces no dado 3D.
