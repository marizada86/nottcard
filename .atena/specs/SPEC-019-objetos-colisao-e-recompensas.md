---
id: "SPEC-019"
titulo: "Objetos interativos, colisão e recompensas menores"
status: "aprovada — aguardando validação no runtime Godot"
criado: "2026-09-26"
aprovacao: "Plano aprovado pelo Guilherme em 2026-09-26"
---

# SPEC-019 — Objetos interativos, colisão e recompensas menores

## Escopo

- Objetos elegíveis usam as posições de props do mapa, têm estado de saqueado e
  bloqueiam a célula até a interação.
- Caixotes grandes exigem FOR 14 do personagem ativo; falha mantém o bloqueio.
- Saques menores dão ouro/XP e têm chance baixa de item ou carta temporária.
- Entradas, saídas, portas, âncoras, inimigos e marcadores são reservados.

## Critérios de aceite

- [ ] Objeto bloqueado não pode ser atravessado antes de ser resolvido.
- [ ] Caixote com FOR menor que 14 não abre; FOR 14 ou maior o remove.
- [ ] Recompensa respeita os limites de temporários da tentativa.
- [ ] Nenhuma rota obrigatória é bloqueada por um objeto comum.

## Tabela inicial aprovada

- Cada objeto resolvido concede 2–5 de ouro e 5 XP.
- Há 5% de chance de item temporário e 5% de carta temporária, sempre sujeita
  aos limites já existentes da tentativa.

## Não escopo

- Objetos obrigatórios de eventos e alterações de layout de missões.
