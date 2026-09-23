class_name RunSession
extends RefCounted
## O estado de UMA tentativa (missão) e o fluxo que o App do Python orquestra: começar, sortear eventos, avançar salas, terminar (XP, save, recompensas).
## Sem UI: as telas leem e chamam. `save_store` é um SaveStore.

const PLAYTESTER_MULT := 5

var save_store: SaveStore
var mission: MissionDef
var party: Party
var party_characters: Array = []
var character: CharacterDef
var progress: Progress
var ledger: RunLedger = RunLedger.new()
var stats: RunStats = RunStats.new()
var run_kills: Dictionary = {}
var run_over: bool = true
var result: RunResult = null
var member_results: Array = []
var world: WorldMap
var walker: Walker
var room_index: int = 0
var temp_budget: TempBudget = TempBudget.new()
var event_plan: Array = []
var events_resolved: Dictionary = {}
var events_opened: Dictionary = {}
var rerolls_left: int = 0
var mulligan_used: bool = false
var boss_scroll_due: bool = false
var playtester_mode: bool = false
var rng: PyRandom = null   # os testes injetam um RNG fixo

var save_state: SaveState:
	get:
		return save_store.load_state()

var player: Player:
	get:
		return party.lead

func _init(save_store_: SaveStore) -> void:
	save_store = save_store_

## Nova tentativa. `characters`: 1 a 3 CharacterDef (o primeiro é o líder).
func start(characters: Array, mission_id: String) -> void:
	mission = Missions.set_current(mission_id)
	party_characters = characters.slice(0, Party.PARTY_MAX)
	character = party_characters[0]
	var state := save_state
	progress = state.for_character(character.id)
	var bonus_hp := Achievements.BONUS_HP_AMOUNT if Achievements.has_benefit(state, Achievements.BONUS_HP) else 0
	if Collection.ensure_collection(state):
		save_store.save(state)
	var deck_names: Array = state.decks[mini(state.active_deck, state.decks.size() - 1)]
	var players: Array = []
	for c in party_characters:
		var gear := Equipment.equipped_of(state, c.id)
		players.append(Player.for_character(c, state.for_character(c.id).level, bonus_hp, deck_names.duplicate(), state.upgrades,
			gear[Equipment.ARMA], gear[Equipment.ARMADURA], 1 if Achievements.has_benefit(state, Achievements.EXTRA_LUCK) else 0,
			Achievements.DAMAGE_BONUS_PCT if Achievements.has_benefit(state, Achievements.DAMAGE_BONUS) else 0.0))
	rerolls_left = Upgrades.rerolls(state.upgrades)
	party = Party.create(players)
	mulligan_used = false
	var mult := PLAYTESTER_MULT if playtester_mode else 1
	ledger = RunLedger.new()
	ledger.xp_mult = mult
	ledger.gold_mult = mult
	stats = RunStats.new()
	stats.mission_id = mission.id
	stats.party_size = party_characters.size()
	run_over = false
	result = null
	member_results = []
	run_kills = {}
	world = mission.make_world()
	var dg := mission.dungeon
	walker = Walker.new(dg.build(), dg.start[0], dg.start[1], dg.start[2])
	walker.gate = WalkRules.make_gate(world, mission.rooms_by_id, dg)
	room_index = mission.index_of(world.current)
	temp_budget = TempBudget.new()
	plan_events()

## Sorteia os eventos da missão (com a proteção contra azar do save) e a célula de cada marcador.
func plan_events() -> void:
	var r := rng if rng != null else PyRandom.new()
	events_resolved = {}
	events_opened = {}
	var catalog: Array = []
	for e in Events.all():
		if mission.event_ids == null or e.id in mission.event_ids:
			catalog.append(e)
	event_plan = EventPlan.roll_plan(save_state.event_pity, catalog, r, mission.event_rooms, playtester_mode)
	for inst in event_plan:
		inst.cell = mission.dungeon.event_cell(inst.room, r)
		inst.state = Events.roll_state(inst, r)

func current_room() -> Room:
	return mission.rooms[room_index]

func record_kill(enemy: Enemy, killer: String = "") -> void:
	ledger.add(enemy.name, enemy.xp)
	stats.enemies_defeated += 1
	var who := killer if killer != "" else party.active_member.player.character.id
	run_kills[who] = run_kills.get(who, 0) + 1

## O combate acabou. Devolve "defeat" | "event_win" | "room" (a sala foi vencida: chame advance_room(true)).
func combat_finished(victory: bool, event_win_pending: bool = false) -> String:
	for m in party.members:
		m.player.bless = 0
		if victory and (m.player.hp <= 0 or m.player.dead):
			m.player.revive(1)
	if not victory:
		return "defeat"
	if event_win_pending:
		return "event_win"
	return "room"

## Marca a sala resolvida. Devolve "victory" (era o chefe), "scroll:<grau>" (oferta de pergaminho) ou "explore".
func advance_room(after_combat: bool = false) -> String:
	var room := current_room()
	world.clear(room.id)
	if room.is_boss:
		boss_scroll_due = after_combat and room.reward_tier > 0
		return "victory"
	if after_combat and room.reward_tier > 0:
		return "scroll:%d" % room.reward_tier
	return "explore"

## Cria a oferta "escolha 1 pergaminho" do grau da sala, para quem tem menos guardados.
func offer_scroll(tier: int) -> void:
	var state := save_state
	if tier <= 0 or (state.pending_offer != null and not state.pending_offer.is_empty()):
		return
	var ids: Array = []
	for c in party_characters:
		ids.append(c.id)
	var cid := Scrolls.recipient(state, ids)
	Scrolls.set_offer(state, cid, Scrolls.offer(tier))
	save_store.save(state)

## Fim da tentativa: só agora o XP entra nos personagens. Devolve o RunResult do líder.
func finish(outcome: String) -> RunResult:
	if run_over:
		return result
	run_over = true
	var state := save_state
	if outcome == ProgressRules.VITORIA:
		ledger.add("Conclusão da dungeon", mission.completion_xp)
		state.missions_completed[mission.id] = true
		if mission.id == "m2":
			state.story_items["mapa_dagruve"] = true
		elif mission.id == "m3":
			state.story_items["ampulheta_silencio_eterno"] = true
		elif mission.id == "m4":
			state.story_items["cadernos_magicos"] = true
		elif mission.id == "m5":
			state.story_items["colar_visao_verdadeira"] = true
			state.story_items["tarn_dagruve_selada"] = true
		elif mission.id == "m6":
			state.story_items["pocao_sopro_de_fogo"] = true
			state.story_items["oleo_willie"] = true
		elif mission.id == "m7":
			state.story_items["diario_bromnor"] = true
			state.story_items["korrak_recrutado"] = true
			state.story_items["leoric_recrutado"] = true
		elif mission.id == "m8":
			state.story_items["artefatos_bromnor"] = true
			state.story_items["erik_recrutado"] = true
		elif mission.id == "m9":
			state.story_items["martelo_da_gloria"] = true
			state.story_items["tarn_caida"] = true
			state.story_items["sacrificio_helion"] = true
			state.story_items["veu_nascido"] = true
	var res := ProgressRules.settle_run(progress, ledger, outcome, stats, character.id, Callable(character, "reward_texts"))
	member_results = [res]
	for other in party_characters.slice(1):
		member_results.append(ProgressRules.settle_run(state.for_character(other.id), ledger, outcome, stats, other.id, Callable(other, "reward_texts")))
	for cid in run_kills:
		state.for_character(cid).kills += run_kills[cid]
	run_kills = {}
	var earned := Achievements.evaluate(state, outcome, stats)
	for a in earned:
		state.achievements[a.id] = true
	Achievements.grant_cards(state, earned)
	var layouts_earned := LayoutUnlocks.evaluate(state)
	for u in layouts_earned:
		state.achievements[u.achievement_id] = true
	state.event_pity = EventPlan.next_pity(state.event_pity, not events_opened.is_empty())
	if outcome == ProgressRules.VITORIA:
		Collection.offer_boss_reward(state, null, mission.boss_id)
	var best: Member = party.members[0]
	for m in party.members:
		if m.player.modifier_of("carisma") > best.player.modifier_of("carisma"):
			best = m
	var settlement := Economy.settle_coins(res.gained, ledger.mission_gold, outcome, state.upgrades, best.player.modifier_of("carisma"))
	state.coins += settlement.total
	var lost: Array = Scrolls.clear_all(state) if outcome != ProgressRules.VITORIA else []
	res.achievements = []
	for a in earned:
		res.achievements.append(a.name)
	for u in layouts_earned:
		res.achievements.append("Layout %s" % u.name)
	res.coins = settlement.total
	res.scrolls_lost = lost
	res.bag_coins = settlement.bag_coins
	res.charisma_pct = settlement.charisma_pct
	res.greed_pct = settlement.greed_pct
	res.charisma_who = best.character.name if settlement.charisma_pct != 0 else ""
	member_results[0] = res
	save_store.save(state)
	result = res
	return res

# -- situações e eventos (SPEC-031/074) -------------------------------------------------------------------------------

var event_instance: EventInstance = null
var event_win: Callable = Callable()

func shop_open() -> bool:
	return event_instance != null and event_instance.event_id == "mercador"

func gold_available() -> int:
	return Economy.spendable_gold(ledger, save_state) if shop_open() else ledger.mission_gold

func change_gold(amount: int) -> void:
	if amount < 0 and shop_open():
		if Economy.spend_gold(ledger, save_state, -amount):
			save_store.save(save_state)
			return
	ledger.add_gold(amount)

func pending_event(room_id: int) -> Variant:
	for e in event_plan:
		if e.room == room_id and not events_resolved.has(e.event_id):
			return e
	return null

func event_marker_cells() -> Array:
	var out: Array = []
	for e in event_plan:
		if e.cell != null and not events_resolved.has(e.event_id):
			out.append(e.cell)
	return out

## O evento pendente da sala do caminhante cujo marcador está a uma célula dele.
func event_near(w: Walker) -> Variant:
	var inst: Variant = pending_event(w.room)
	if inst == null or inst.cell == null:
		return null
	return inst if maxi(absi(w.x - inst.cell.x), absi(w.y - inst.cell.y)) <= 1 else null

func roll_situation(option: Option, tester: Player) -> CheckResult:
	return Exploration.resolve_check(tester, option)

func luck_reroll(option: Option, tester: Player, previous: CheckResult) -> CheckResult:
	return Exploration.reroll_with_luck(tester, option, previous)

## Aplica o desfecho e registra o XP do evento no ledger.
func apply_situation(option: Option, tester: Player, check: CheckResult) -> Applied:
	var room := current_room()
	if not option.auto and check.natural == "1":
		stats.natural_ones += 1
	var applied := Exploration.apply_result(tester, option, check, true)
	_after_applied(applied)
	if applied.xp != 0:
		ledger.add("Evento: %s" % room.name, applied.xp)
	return applied

func _after_applied(applied: Applied) -> void:
	if applied.gold != 0:
		change_gold(applied.gold)
	var players: Array = []
	for m in party.members:
		players.append(m.player)
	Events.apply_party_effects(applied, players)
	if applied.pending == null and event_instance != null:
		Events.apply_effect(event_instance, applied.effect)

func settle_situation_reward(applied: Applied, tester: Player, accept: bool) -> Applied:
	var before_gold := applied.gold
	var settled := Exploration.settle_reward(tester, applied, accept, temp_budget, rng)
	if settled.gold != before_gold:
		change_gold(settled.gold - before_gold)
	if accept and event_instance != null and settled.effect != "":
		Events.apply_effect(event_instance, settled.effect, rng)
	return settled

## Prepara o evento `instance` (o marcador foi tocado): registra que foi aberto.
func open_event(instance: EventInstance) -> Situation:
	event_instance = instance
	events_opened[instance.event_id] = true
	var players: Array = []
	for m in party.members:
		players.append(m.player)
	return Events.build_situation(instance, players, {"temp_budget": temp_budget, "ledger": ledger, "save_state": save_state})

func rebuild_event() -> Situation:
	var players: Array = []
	for m in party.members:
		players.append(m.player)
	return Events.build_situation(event_instance, players, {"temp_budget": temp_budget, "ledger": ledger, "save_state": save_state})

func finish_event() -> void:
	if event_instance != null:
		events_resolved[event_instance.event_id] = true
	event_instance = null

## O mímico caiu: ouro em dobro e um item temporário. Devolve o texto para o aviso.
func mimic_won(instance: EventInstance) -> String:
	var gold := Events.mimic_gold(instance)
	ledger.add_gold(gold)
	var pair := Temporaries.grant_item(player, temp_budget, rng if rng != null else PyRandom.shared)
	var item: Variant = pair[0]
	return "Mímico derrotado: +%d de ouro%s." % [gold, (" e %s" % item.nome) if item != null else ""]

## O jogador cruzou a soleira de uma sala andando. Devolve true se a sala atual não resolvida precisa abrir o encontro dela.
func walk_cross(room_id: int) -> bool:
	var current := world.current
	if room_id == current:
		return false
	if not world.is_cleared(current):
		return true
	if world.can_move_to(room_id):
		world.move_to(room_id)
		room_index = mission.index_of(room_id)
	return false
