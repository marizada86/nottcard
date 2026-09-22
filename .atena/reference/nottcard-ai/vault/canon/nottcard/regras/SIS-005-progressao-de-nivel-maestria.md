---
id: "SIS-005"
type: "sistema-mecanico"
title: "Progressão de nível como maestria por personagem"
status: "canon"
created: "2026-09-19"
updated: "2026-09-19"
relations:
  - "[[SIS-001-atributos-e-eficiencia-de-cor]]"
  - "[[VSN-003-estrutura-de-missoes-arco-01]]"
  - "[[PERS-durvall-ficha-jogavel]]"
  - "[[PERS-maelor-ficha-jogavel]]"
sources:
  - "Declaração do responsável pelo projeto em 2026-09-19 (regras 1–7)"
  - "Decisões do responsável em 2026-09-19 (curva, cartas, nível 5, save, log, cor, entrada tardia)"
  - "Aprovação do responsável em 2026-09-19: \"tudo aprovado com as recomendações\" (curva, cartas, nível 5, contrapeso do Desistir, promoção a canon)"
  - "vault/02_Personagens/Durvall.md e Maelor.md (fichas de mestre, sessões 01–24) — base das cartas e passivas propostas"
---

# Progressão de nível como maestria por personagem

## Regra (decisões do responsável, 2026-09-19)

1. **Maestria por personagem.** O nível funciona como um sistema de maestria: a experiência obtida em cada aventura conta como progresso *daquele personagem*.
2. **Fontes de XP:** luta, conclusão de dungeon, abertura de baú e eventos específicos.
3. **Recompensa de nível:** novas cartas, **fixas por personagem e por nível**, seguindo a lógica de D&D e a lore de Nottgard (de preferência habilidades usadas em sessões oficiais).
4. **Nível 5:** o personagem ganha uma habilidade **passiva de classe** que complementa o personagem. Se a habilidade for considerada mais fraca, recebe também **+1 ou +2 em um atributo** para compensar. Depende do personagem; o equilíbrio é importante.
5. **Demo:** vai só até o nível 5.
6. **Início:** nível 1.
7. **XP e desfecho da missão:**
   - Completar ou não a missão: o XP obtido permanece.
   - **Derrota:** o XP é reduzido em 50%.
   - **Desistir:** falha a missão, mas o personagem ganha todo o XP recebido até o momento.
8. **Curva de XP:** com todas as tentativas bem-sucedidas, levar em média **cerca de 20 tentativas** até o nível 5, com um pouco de *grind*, cada nível mais difícil que o anterior:
   - 1→2: muito fácil — **1 tentativa bem-sucedida ou 2 fracassadas**.
   - 2→3: mais difícil — **2 ou 3 bem-sucedidas**.
   - 3→4: difícil — **várias** tentativas.
9. **Persistência:** **um único save**, com opção de **apagar o save atual e recomeçar do zero**. Ponto de partida do Roguelite. **Pode ser temporário:** vale enquanto o `.exe` estiver aberto; ao fechar, perde-se o save.
10. **Nível durante a missão:** o XP só é **contabilizado no fim da missão**, e o nível só sobe no fim da missão. Ao final da tentativa, **mostrar o log de XP** e **estatísticas básicas** (dano causado/sofrido, cura, inimigos derrotados, etc.).
11. **Eficiência de cor (SIS-001):** seguir as recomendações abaixo e **balancear em playtests**.
12. **Personagem que entra tarde:** entra no **nível 1**.

## Resumo por desfecho

| Desfecho | Missão | XP mantido |
|---|---|---|
| Vitória | concluída | 100% |
| Desistência | falha | 100% do acumulado até ali |
| Derrota | falha | 50% |

## Interpretações adotadas (a confirmar)

- **Base do corte de 50%:** incide sobre o XP ganho **na tentativa atual**, não sobre o total do personagem (derrota nunca faz perder nível). Arredondamento para baixo.
- **Sem perda de nível:** o nível e as cartas já obtidos nunca são revertidos.
- **XP individual:** cada personagem acumula o seu próprio XP. Com grupo (Brook em M2, Korrak e Leoric em M7), o XP é dividido entre os personagens que participaram da missão.
- **Nível 5 = teto da demo:** o XP acima do necessário é ignorado.
- **Um save, todos os personagens:** o save guarda o progresso de cada personagem (nível, XP, cartas). "Apagar save" zera todos.

## Proposta 1 — Curva de XP (calibrada nas suas metas)

Unidade: uma tentativa **bem-sucedida da M1** ≈ **100 XP**.

| Nível | XP acumulado | XP do degrau | Tentativas bem-sucedidas (degrau) | Acumulado em tentativas |
|---|---|---|---|---|
| 1→2 | 100 | 100 | **1** (ou 2 derrotas de ~100 XP brutos, que valem 50 cada) | 1 |
| 2→3 | 350 | 250 | **2–3** | 3–4 |
| 3→4 | 950 | 600 | **~6** ("várias") | ~9–10 |
| 4→5 | 1950 | 1000 | **~10** | **~19–20** |

**Fontes na M1 (soma ≈ 100 na rota principal; a Sala 4 opcional dá bônus):**

| Fonte | XP |
|---|---|
| Sala 2 — Criatura corrompida | 10 |
| Sala 3 — evento da rachadura | 10 |
| Sala 4 — Slime (opcional, se enfrentado) | +10 (bônus) |
| Sala 5 — Guardião (cópia) | 15 |
| Sala 6 — corredor (Criatura 10 + 2 Slimes 5 cada) | 20 |
| Sala 7 — Guardião verdadeiro (chefe) | 25 |
| **Conclusão da dungeon** | **20** |
| **Total (rota principal)** | **100** (110 com o Slime opcional) |

Pontos de atenção:
- **Desistir vale 100% do acumulado.** Sem contrapeso, dá para desistir na sala 7 antes do chefe e perder pouco. O contrapeso proposto é a **conclusão da dungeon (20) e o chefe (25) só existirem se a missão for concluída**: quem desiste perde até 45% do XP da rota. Confirmar se basta.
- **Tempo de grind:** 20 tentativas × 15–30 min (duração planejada da M1) = **5 a 10 horas** até o nível 5. Se for muito para a demo, basta mudar uma constante (`XP_SCALE`) sem mexer nas tabelas.
- **Derrota:** um jogador derrotado costuma ter acumulado ~100 XP brutos (chegou à sala 5–6), então rende ~50 — bate com "2 fracassadas = 1 sucesso" no nível 1.

## Proposta 2 — Cartas por nível (fixas por personagem)

**Como ler:** os nomes (aprovados) vêm de fatos das fichas de mestre (sessões 01–24). A mecânica é só uma ideia inicial; cada carta ganha texto, dado e custo em SPEC própria, e os números são balanceados no playtest. **Nada de segredo de mestre no texto de carta** (Ghaunadaur/receptáculo e a traição do Durvall; a família Vellen do Maelor), conforme as notas de designer das fichas.

### Durvall (Psi-warrior, Vermelho)

| Nível | Carta | Origem na lore | Ideia de mecânica |
|---|---|---|---|
| 2 | **Romper Armadura** | S7: rompe a armadura de Astherion | Vermelho, ataque; reduz a CA do alvo em 2 pelo resto do combate. Diferente do Golpe Perfurante, que só ignora 1 ponto no próprio golpe. |
| 3 | **Reação Instintiva** | S4: atacado por uma gárgula, reage e trinca a criatura | Vermelho, **Reação** contra ataque físico: reduz o dano e devolve um golpe curto. Complementa o Aparar (que só reduz). |
| 4 | **Amarrar e Saltar** | S5: amarra as duas carroças e salta entre elas, deixando Kayron controlar a inimiga | Roxo, Ação Bônus; o alvo perde a próxima Ação de ataque e a próxima carta do Durvall no turno ganha 1 de Corrente. |
| 5 | **Em Casa na Névoa** (passiva) | S1/S7: não sofre a névoa na aproximação da rachadura; "sente-se em casa" na névoa | Ver Proposta 3. |

### Maelor (Clérigo da Luz, Azul)

| Nível | Carta | Origem na lore | Ideia de mecânica |
|---|---|---|---|
| 2 | **Localizar Criatura** | Magia usada em mesa (S16–24) | Azul, Ação Bônus: revela o próximo ataque de um inimigo (nome e dado) e dá +2 no acerto do próximo ataque contra ele. Útil com a Reação. |
| 3 | **Comunhão com Sendrinah** | S23: comunhão — "Encontre a fonte de tudo" | Azul, Ação Bônus, HC (1 uso): olha as 3 cartas do topo do baralho e escolhe 1 para a mão. Cresce em valor com a compra e o descarte por escolha (FB-001 A5/B2). |
| 4 | **Luz Mais Pura** | S14: usa o desejo para trazer a luz mais pura | Azul, **uso único** (como a Poção): cura grande (2d6 + Constituição). "Guarda um desejo" combina com o uso único. *(Refinado na SPEC-024: a ideia de remover condição foi descartada, porque o jogador não tem condições.)* |
| 5 | **Proteção de Sendrinah** (passiva) | S13: Sendrinah o protege por estar perto de Ailalore | Ver Proposta 3. |

Outras opções na lore para reserva: Durvall — disfarçar-se entre os mortos-vivos (S3); Maelor — invocação de aranha batedora, taumaturgia para despistar os cultistas (S3), teleporte, golpe final na Arch-hag com a essência de Sendrinah (S13), que combina com o Golpe Contundente.

## Proposta 3 — Nível 5 (passiva + compensação de atributo)

**Achado que muda o cálculo:** o modificador é `piso((valor − 10) / 2)`, então **+1 só faz efeito em atributo ímpar** (13→14 sobe o modificador; 12→13 não). **+2 sempre vale +1 de modificador.** Isso decide onde cada bônus cai.

| Personagem | Passiva de nível 5 | Peso da passiva | Atributo | Efeito |
|---|---|---|---|---|
| **Durvall** | **Em Casa na Névoa:** imune ao Eco da Névoa (o d6 da sala 1 que pode descartar uma carta da mão) e a futuros efeitos de névoa. | **Fraca** na M1 (um único d6, 1/3 de chance de perder uma carta). | **+2 Constituição** (12→14) | Mod. +1→+2: Azul +20%→+40% (Névoa Fria, Contrafeitiço) e +1 na Poção de Cura. Compensa o fraco. |
| **Maelor** | **Proteção de Sendrinah:** 1 vez por combate, ao cair a 0 PV, fica com 1 PV e recebe uma cura curta. | **Forte** (segurança de uma vida extra). | **+1 Inteligência** (13→14) | Mod. +1→+2: CAM 11→12 e Amarelo +20%→+40% (Chama Menor, Bola de Fogo). Compensação mínima, porque a passiva já pesa; ataca a maior fraqueza do Maelor (defesa mágica). |

Racional: o Durvall já é o mais forte em ataque (Força 16); a passiva dele é de conforto, então o bônus de atributo faz o resto. O Maelor ganha uma passiva com peso real e só um ajuste pequeno. Os dois números (Con +2, Int +1) e a passiva do Durvall são **candidatos a mudar no playtest**.

## Interação com a eficiência de cor (SIS-001)

Recomendações adotadas, para balancear em playtest:
1. **Teto de atributo de 18 na demo** (D&D usa 20; +80% de eficiência já é muito). Nenhum bônus da progressão passa disso.
2. **Ordem de aplicação:** bônus de cor multiplica o dado base **antes** da Corrente e da compatibilidade, e o modificador fixo (Constituição na cura) **não** é multiplicado — como já é hoje.
3. **Só o nível 5 mexe em atributo.** Os níveis 2–4 dão cartas, sem mudar os multiplicadores.
4. **Playtest:** comparar no nível 5 a duração dos combates e a taxa de derrota, com e sem o bônus de atributo.

## Persistência (save temporário)

- Um objeto de save em memória (`SaveState`) guardando, por personagem: nível, XP e cartas liberadas. Vive enquanto o processo do `.exe` estiver aberto.
- Menu: **Continuar** (aparece se há save), **Novo jogo** (apaga o save, com confirmação) e escolha de personagem.
- **Interface de armazenamento (`SaveStore`)** com uma implementação em memória agora; trocar por arquivo JSON depois muda uma classe, não o jogo.

## Fim da tentativa: log de XP e estatísticas

Tela "Resultado da tentativa" ao final de qualquer desfecho (vitória, derrota, desistência):
- **Log de XP**, linha a linha: fonte (ex.: "Criatura corrompida +10", "Evento da rachadura +10", "Conclusão da dungeon +20"), depois o ajuste do desfecho (Derrota −50%) e o total.
- **Barra de nível** com o progresso para o próximo, e o aviso **"Nível N! Nova carta: X"** (ou a passiva e o atributo do nível 5).
- **Estatísticas básicas:** dano causado, dano sofrido, cura, inimigos derrotados, cartas jogadas, maior Corrente, turnos, acertos/erros/críticos e tempo.
- **Coleta:** `RunStats` no `core`, acumulado por eventos do combate (sem pygame).
- **"Desistir":** a opção de voltar ao menu do menu de pausa (FB-001 A1) é o desistir; a confirmação deve dizer que a missão falha mas o XP acumulado é mantido.

## Entrada tardia

Brook, Korrak, Leoric e Erik entram no **nível 1**, com o próprio progresso e o próprio XP.

## Impacto esperado no código (ainda não especificado)

- `CharacterDef` continua imutável; novos: `Progress` (nível, XP, cartas), `SaveState`/`SaveStore`, `RunStats` e uma tabela de progressão declarativa por personagem (cartas por nível, passiva e atributo do nível 5).
- `build_deck` passa a receber o nível (hoje devolve 16 e 13 cartas com `assert` fixo); o deck cresce 3 cartas até o nível 4.
- Passiva do nível 5 como ganchos declarativos em `CharacterDef`, no padrão de `chain_elements` e `hit_attr_by_element`.
- Modificadores de atributo aplicados via `Progress` (o `CharacterDef` não muda).
- UI: tela de resultado, Continuar/Novo jogo no menu, exibição do nível no painel do jogador.
- Nada disto é implementado antes de uma SPEC aprovada em `.atena/specs/` (`execution_approval: per-spec`).

## Pendências que restam

- Valores de XP para as fontes fora da M1 (baú, eventos), quando essas fontes existirem.
- Regra de divisão de XP no grupo, quando houver grupo.
- **Números a calibrar em playtest:** XP por fonte, `XP_SCALE`, atributo do nível 5 (Durvall +2 CON, Maelor +1 INT) e a passiva "Em Casa na Névoa". Mudar esses números não exige reabrir este documento, só registrar em EVID e na SPEC.
- O texto e os números de cada carta (Propostas 2) fecham na SPEC-024, não aqui.

## Review record

- Proposed by: Claude, a partir das decisões do responsável em 2026-09-19.
- Reviewed by: responsável pelo projeto, em 2026-09-19.
- Approval decision: aprovado com as recomendações (Propostas 1, 2 e 3, contrapeso do Desistir e teto de atributo 18) e promovido a canon.
- Implementação: SPEC-023 (progresso, save e resultado) e SPEC-024 (cartas e passivas por nível).
