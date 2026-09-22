class_name Card
extends RefCounted
## Porte de game/core/cards.py::Card. Gerado por tools/gen_dataclasses.py; métodos à mão.

var name: String = ""
var color: String = ""
var kind: String = ""
var dice: String = ""
var note: String = ""
var asset_id = null
var action_type: String = "acao"
var single_use: bool = false
var grants_action: int = 0
var modifier_attr: String = ""
var reacts_to: String = ""
var class_ability: bool = false
var ignores_ca: int = 0
var ignores_cam: int = 0
var stun_on_hit: bool = false
var breaks_armor: int = 0
var counter_dice: String = ""
var boosts_chain: int = 0
var marks_bonus: int = 0
var weakens: int = 0
var reveals: int = 0
var elements: Array = []
var area: bool = false
var drain_frac: float = 0.0
var heals_clone: bool = false
var spends_mystic: int = 0
var grants_mystic: int = 0
var self_damage: int = 0
var rarity: String = ""
var auto_hit: bool = false
var requires_hit: bool = false
var sneak_dice: String = ""
var exposes: bool = false
var stuns_attacks: int = 0
var halves_damage: bool = false
var thunder_dice: String = ""
var chain_dice: String = ""
var scroll: bool = false
var scroll_effect: String = ""
var grants_next_action: int = 0
var grants_guard: int = 0
var redeems: bool = false
var self_only: bool = false
var guard_dice: String = ""
var weakens_cam_on_hit: int = 0
var reduces_next_attack: int = 0
var advantage_on_hit: bool = false
var forces_disadvantage: bool = false
var temporary: bool = false

const ENEMY_TARGETED_KINDS := ["ataque", "controle", "atordoamento", "localizar", "enfraquecer"]

static func slugify(card_name: String) -> String:
	var rx := RegEx.new()
	rx.compile("[^a-z0-9]+")
	return rx.sub(card_name.to_lower(), "_", true).lstrip("_").rstrip("_")

var slug: String:
	get:
		return asset_id if asset_id != null and asset_id != "" else slugify(name)

var targets_enemy: bool:
	get:
		return kind in ENEMY_TARGETED_KINDS and not area

var targets_ally: bool:
	get:
		return kind == "cura" and not self_only

var ally_hint: String:
	get:
		return "" if kind != "cura" else ("Só em si" if self_only else "Alvo: aliado")

## dataclasses.replace: cópia com campos trocados (as cartas são imutáveis na origem).
func replace(changes: Dictionary) -> Card:
	var c := Card.new()
	for p in get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and p.name != "slug" and p.name != "targets_enemy" and p.name != "targets_ally" and p.name != "ally_hint":
			c.set(p.name, get(p.name))
	for k in changes:
		c.set(k, changes[k])
	return c

## Igualdade por valor (dataclass == dataclass).
func equals(other: Variant) -> bool:
	if other == null or not (other is Card):
		return false
	for p in get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and p.name != "slug" and p.name != "targets_enemy" and p.name != "targets_ally" and p.name != "ally_hint":
			if get(p.name) != other.get(p.name):
				return false
	return true
