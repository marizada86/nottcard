---
id: "SPEC-013"
titulo: "Ferramentas de playtest: pacote de evidências e Navegador QA"
status: "aprovada — em execução"
criado: "2026-09-23"
---

# SPEC-013 — Ferramentas de playtest: pacote de evidências e Navegador QA

## Intenção

Permitir que playtesters capturem e devolvam evidências completas sem sair do
jogo, e que a equipe interna chegue de modo rápido, seguro e reproduzível a
qualquer conteúdo já implementado: missão, sala, evento, combate, fase de
chefe ou HQ.

O resultado não depende de integração nem login no Discord: o jogo produz um
único arquivo autocontido que a pessoa anexa manualmente à task de playtest.

## Escopo

- F5 abre um bloco de notas; F6 guarda um print; F7 gera um pacote ZIP.
- O pacote acumula itens durante a sessão, sobrevive a queda/fechamento e é
  exportado com contexto suficiente para entender e reproduzir o relato.
- F11 continua alternando a tela cheia.
- F12 abre uma ferramenta de desenvolvimento com as abas **Log** e
  **Comandos**; o log é incluído na exportação.
- `Ctrl+O+P` abre o **Navegador QA** nas builds internas. O atalho deixa de
  desbloquear o perfil diretamente.
- O Navegador QA inicia cenários declarados para conteúdos existentes,
  incluindo missões, segmentos de combate/evento e HQs que tenham tela
  jogável. Cada cenário usa estado isolado e pode ser reiniciado.
- Há caminhos por botão no menu/pausa para as ferramentas de teste, como
  alternativa aos atalhos.

## Fora de escopo

- Enviar arquivos automaticamente para Discord, e-mail, Drive ou outro
  serviço externo.
- Gravar vídeo, editar imagens, editar ou reordenar itens já guardados.
- Criar uma HQ, sala, fase ou sistema de campanha que ainda não exista.
- Editor livre de memória/save, console de código arbitrário ou comandos que
  executem arquivos do computador.
- Garantir segredo do Navegador QA por combinação de teclas; a separação é por
  tipo de build, não por ofuscação.

## Modos de build e autorização

| Tipo de build | Evidências F5–F7 | F12 | Navegador QA | Uso |
|---|---:|---:|---:|---|
| Produção | não | não | não | jogadores finais |
| Playtest público | sim | log somente | não | feedback externo |
| QA interno | sim | log e comandos seguros | sim | equipe e testers confiáveis |

- `PLAYTEST_BUILD` habilita o pacote de evidências e seus textos de guia.
- `QA_TOOLS_ENABLED` habilita o Navegador QA e a aba de comandos. Só pode ser
  verdadeiro numa exportação QA interna; pressupõe `PLAYTEST_BUILD`.
- As flags são definidas pela configuração da build, não por perfil, save ou
  comando em tempo de execução.
- O atalho e os botões de QA não aparecem quando `QA_TOOLS_ENABLED` é falso.

## Fluxo de evidência

### F5 — Bloco de notas

- Funciona em qualquer tela elegível de uma build de playtest e pausa a tela
  de jogo enquanto está aberto.
- Antes de mostrar o painel, captura a tela limpa daquele instante. A nota
  descreve o que o tester viu, e não uma tela posterior.
- Aceita até 1.000 caracteres e oferece seleção, copiar, recortar, colar,
  desfazer/refazer, rolagem e contador de caracteres.
- Fechar por F5 ou Esc guarda automaticamente a nota se ela não estiver vazia,
  junto da captura inicial; nota vazia é descartada.
- O painel mostra o resumo do pacote e permite **Limpar pacote**, com
  confirmação em dois passos. Itens já guardados não são editáveis.
- F6 com o bloco aberto orienta o tester a fechá-lo primeiro. F7 fecha e guarda
  a nota atual antes de tentar exportar.

### F6 — Print da tela

- Guarda um print limpo da tela atual sem pausar o jogo.
- O print não inclui toast, contador de evidências, painel F12 nem o bloco de
  notas. A interface própria do jogo permanece na imagem.
- Um aviso curto confirma, por exemplo: `Print 3 guardado — F7 gera o ZIP`.

### F7 — Gerar pacote

- Com pacote vazio, não cria arquivo e informa: `Não há evidência a ser
  enviada`.
- Com itens, cria `EV-<tester>-<AAAAMMDD>-<HHMMSS>.zip` e só limpa o rascunho
  após fechar o ZIP com sucesso.
- O destino preferencial é `evidencias/` ao lado do executável. Caso não seja
  gravável, usa `user://evidencias/`; o aviso informa o nome do arquivo e a
  pasta efetivamente usada.
- Não tenta abrir nem enviar o arquivo automaticamente.

### Conteúdo do ZIP

```text
info.json       versão, data, origem, itens e contexto de cada item
estado.json     recorte sanitizado do estado de jogo necessário à reprodução
log.txt         até as últimas 200 linhas do F12
notas.md        notas numeradas, com hora e contexto
prints/01-nota.png
prints/02-print.png
...
```

O contexto de cada item inclui tela, missão, sala, turno, grupo e, quando
aplicável, o identificador do cenário QA e sua seed. Caminhos locais, nome de
usuário do sistema e outros dados pessoais são removidos de textos e JSON. Os
prints não sofrem manipulação e o guia avisa que eles mostram a tela do jogo.

### Persistência e limites

- Cada item é gravado imediatamente em `user://evidence_drafts/`; reabrir o
  jogo mantém os itens e informa seu total.
- Falha ao gravar um item ou exportar o ZIP não derruba o jogo e mantém o que
  já estava no pacote.
- Limite inicial: 20 imagens ou 8 MB de dados de imagem. A 80%, o jogo avisa;
  no limite, recusa novos itens até a exportação ou limpeza.

## F12 — Log e comandos seguros

- A aba **Log** liga/desliga um painel semitransparente, sem bloquear os
  comandos normais do jogo. O histórico é mantido mesmo fechado e limitado a
  300 linhas em memória.
- A aba **Comandos** só existe no QA interno. Ela expõe ações seguras e
  equivalentes ao Navegador QA, como listar cenários, iniciar um cenário pelo
  ID e reiniciá-lo; não executa GDScript, shell nem texto arbitrário.
- Dados de combate e eventos relevantes entram no log como explicações, sem
  duplicar ou alterar regras do `core`.

## Ctrl+O+P — Navegador QA

`Ctrl+O+P` passa a abrir/fechar o Navegador QA. Ele é tratado como o
pressionamento de `P` enquanto Ctrl e O estão mantidos; o evento é consumido
para não vazar a tecla à tela por trás. Um botão **Ferramentas de teste** no
menu e na pausa oferece o mesmo acesso.

O navegador não altera o save normal do usuário. Ele cria e usa uma sessão de
teste isolada, identificada visualmente por uma faixa `CENÁRIO DE TESTE`.
Sair volta ao menu normal; **Reiniciar cenário** recria exatamente o estado
inicial daquele cenário.

### Catálogo de cenários

Cada entrada é declarada em dados e tem, no mínimo:

```text
id, título, categoria, destino, missão/sala, grupo, seed,
patch de estado de teste e contexto de reprodução
```

O navegador organiza as entradas assim:

```text
Missões
  M1 … M9
    entrada, caminhada, situação, combate, chefe/fase existente e resultado
HQ
  cada HQ/interlúdio que tenha tela implementada
Telas
  menu, seleção, oferta e resultado
```

- O seletor permite trocar grupo, nível e seed entre presets válidos do
  cenário. A opção **Perfil de teste completo** libera o conteúdo necessário
  apenas no sandbox QA.
- Um cenário só é oferecido quando seu destino existe no jogo. Conteúdo ainda
  não implementado não recebe botão falso: permanece fora do catálogo até ter
  rota real e teste correspondente.
- Cenários de combate/fase configuram explicitamente inimigos, PV, flags e
  pré-condições; não dependem de o tester navegar uma campanha inteira.
- O identificador do cenário aparece na tela, no F12 e em `info.json`, para
  que um relatório possa ser repetido pela equipe.

## Arquitetura proposta

| Área | Responsabilidade |
|---|---|
| `core/build_config.gd` | flags de build e validação de combinação permitida |
| `core/evidence_bundle.gd` | itens, limites, metadados e arquivos de texto/JSON |
| `services/evidence_store.gd` | rascunho persistente, captura limpa e ZIP com `ZIPPacker` |
| `ui/evidence_notepad.gd` | overlay F5 e edição de texto |
| `ui/dev_console.gd` | abas Log/Comandos e buffer de log |
| `core/qa_scenario.gd` e `core/qa_scenarios.gd` | modelo e catálogo de destinos QA |
| `ui/qa_navigator.gd` | escolha, configuração e reinício de cenário |
| `ui/game_app.gd` | atalhos globais, contexto, sandbox e roteamento |
| `core/profile_store.gd` | apenas preferências de guia; nunca estado do sandbox QA |
| `project.godot` | ações nomeadas do `InputMap` e presets de exportação |

Não serão adicionadas dependências externas: o Godot captura o viewport e
salva PNG; `ZIPPacker` cria o arquivo de evidência.

## Impactos

- O save normal deve continuar carregando e salvando sem mudança de schema
  obrigatória. O sandbox QA usa diretório/estado separado.
- Toda missão/HQ nova que queira acesso direto de QA precisa declarar seus
  cenários e cobri-los por teste.
- O guia de playtest, menu e textos de pause precisam explicar F5/F6/F7 e a
  forma manual de anexar o ZIP à task.
- F9 e F10 não recebem apelidos de evidência, para não confundir o fluxo.

## Critérios de aceitação

- [ ] F5 guarda uma nota não vazia e seu print inicial; nota vazia não cria
      item; edição básica completa funciona.
- [ ] F6 adiciona print limpo sem pausar; F7 cria um ZIP válido e só limpa o
      rascunho após sucesso.
- [ ] ZIP vazio não é criado; falhas de escrita preservam o rascunho; a
      exportação traz `info.json`, `estado.json`, `log.txt`, `notas.md` e os
      PNGs na ordem correta.
- [ ] O rascunho sobrevive a reinício e respeita os limites de 20 imagens/8 MB.
- [ ] F11 continua funcionando; F12 não bloqueia a jogabilidade; as abas de
      comandos não existem fora da build QA.
- [ ] `Ctrl+O+P` e os botões de acesso abrem o Navegador QA somente na build
      QA, sem alterar o save normal.
- [ ] Cada destino ofertado pelo catálogo inicia, exibe `CENÁRIO DE TESTE`,
      reinicia de forma determinística e grava seu ID no pacote de evidência.
- [ ] Há pelo menos um cenário de acesso direto para cada missão jogável e
      para cada HQ que possua tela implementada.
- [ ] Builds de produção não expõem ações, textos, comandos ou botões de
      playtest/QA.

## Plano de voo

1. Confirmar esta intenção e os três perfis de build; registrar os cenários
   iniciais por missão/HQ que já têm rota real.
2. Implementar e testar `BuildConfig`, `EvidenceBundle` e `EvidenceStore`,
   incluindo ZIP, sanitização, rascunho e falhas de disco.
3. Implementar F6/F7 globalmente e o overlay F5; atualizar guia, menu e pausa.
4. Implementar `DevLog`/F12 e incluir seu recorte na exportação.
5. Implementar o catálogo de cenários, sandbox, Navegador QA e `Ctrl+O+P`.
6. Declarar cenários para M1–M9, telas existentes e HQs com rota jogável.
7. Executar testes unitários, de UI e uma prova manual de build pública e QA;
   registrar o ZIP produzido e a matriz de cenários em `evidence/`.
8. Revisar os critérios de aceitação, reconciliar documentação operacional e
   só então alterar o status desta spec para executável/concluída.

## Evidência e reconciliação esperadas

- Testes automatizados de bundle, persistência, ZIP, sanitização, atalhos,
  InputMap, sandbox e catálogo QA.
- Um ZIP real gerado por F5, F6 e F7, verificado quanto aos arquivos e aos
  metadados.
- Registro de cada cenário QA validado, com destino e seed quando aplicável.
- Revisão de que nenhum arquivo de evidência, sandbox ou flag QA é exposto na
  build de produção.
