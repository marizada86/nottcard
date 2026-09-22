---
id: "SPEC-103"
type: "spec"
title: "Cópia do Sylas como alvo, equipamento único e por proficiência, itens novos, transferência, bug da câmera e conquista de 30 de dano"
status: "approved"
reviewed: "2026-09-21"
created: "2026-09-21"
relations:
  - "[[SPEC-047-armaduras-e-armas-com-carta-propria]]"
  - "[[SPEC-098-vantagem-e-desvantagem]]"
  - "[[PLAN-021-vantagem-balanceamento-do-baralho-e-playtest-do-higor-2026-09-21]]"
sources:
  - "Playtest do Higor, 2026-09-21 (v0.14.0); 'tudo confirmado' em 2026-09-21"
---

# Jogo: correções do playtest

Fazer em 103a (G6, G1, G7) e 103b (G2, G3, G4, G5), nesta ordem.

## G6 — BUG: câmera gira sozinha e teleporta para a luta
Reproduzir primeiro num teste: entrar em combate/pausa/perder foco da janela com Q/E ou seta pressionada e voltar. Hipótese: o estado de teclas/giro fica preso (KEYUP
perdido) e o caminhante repete o giro e o passo. Correção: limpar teclas e o giro pendente ao perder foco, ao pausar e ao trocar de tela; o passo e a colisão com
inimigo só rodam com input do frame atual; giro com limite por frame. Teste de regressão que simula o KEYUP perdido.

## G1 — Cópia Sombria é alvo dos inimigos
Ao escolher quem atacar, o inimigo sorteia (uniforme) entre **Sylas, a Cópia Sombria (se viva)** e os aliados vivos. Dano na Cópia não passa ao Sylas; a Cópia cai
como já cai hoje. HUD marca a Cópia como alvo possível; log diz em quem o golpe caiu. Sem grupo, escolhe entre Sylas e a Cópia.

## G7 — Conquista "Golpe Devastador"
Causar **30 ou mais de dano em um único ataque** (soma do golpe, não do turno). Benefício `damage_bonus` (novo em `achievements.py`): **+10% de dano permanente
para todos os personagens**, uma vez, arredondado para cima, mínimo +1; aplicado no cálculo de dano de ataque (não em cura). Entra na tela de Conquistas.

## G2 — Equipamento em unidades
Cada armadura/arma comprada é **1 unidade** (`SaveState.equipment_owned: Counter`); equipar em 2 personagens exige 2 compras. A tela Equipamento mostra "x1 / x2" e
bloqueia equipar sem unidade livre. **Migração:** o save atual vira 1 unidade por item hoje equipado (ninguém perde o que usa); itens só "desbloqueados" ficam
com 0 unidades até a compra.

## G3 — Proficiência e compatibilidade
`EquipmentDef.allowed` por personagem/classe (dado declarativo em `equipment.py`): Brook (armadura pesada e escudo; sem adaga, sem couro), Maelor (maça, cajado, armadura média), Durvall (armas
marciais, todas as armaduras), Kayron (leve, cajado, cetro), Sylas (leve, adaga, cajado). Item incompatível aparece na loja e no menu com o motivo ("Brook não tem
proficiência com adaga") e não pode ser equipado. Testes: todo personagem consegue equipar ao menos 1 arma e 1 armadura.

## G4 — Itens novos
- **Robe** (armadura leve, +CAM, sem bônus de CA extra) para conjuradores.
- **Cajado** (arma; carta própria **Roxa**, efeito distinto da carta de arma existente — ex.: ataque 1d6 mágico que devolve +1 Poder Místico/anula 1 de CAM do alvo).
- **Cetro** (arma; carta própria **Amarela**, ex.: ataque 1d6 que marca o alvo: −1 CAM até o fim do combate).
Cartas de arma no padrão da SPEC-047 (assinatura, só com a arma equipada, fora do teto). Cumprir a regra de variedade da SPEC-100. Arte com retângulo de fallback
e prompts em `.atena/generated/`.

## G5 — Transferir item entre personagens
Na exploração, no menu Equipamento/Mochila: "Passar para..." move a unidade de item de um personagem ao outro do grupo, respeitando G3 (bloqueia se incompatível) e
G2 (troca de dono, não cria unidade). Com o destino já equipado no espaço, o item antigo volta à mochila.

## Testes
`test_walker.py`/`tests/ui/test_walk_focus.py` (G6), `test_combat.py` (G1: distribuição de alvos com semente; dano não vaza), `test_achievements.py` (G7),
`test_equipment.py` (G2 unidades, migração, G3 matriz classe×item, G4 cartas, G5 transferência).
