extends RefCounted
## Contratos da camada visual: não dependem de uma janela e não executam regras.

func test_sequence_runs_beats_in_order_and_carries_time() -> String:
	var log: Array = []
	var seq := CombatSequence.new()
	seq.add("a", 0.10, func(): log.append("a+"), Callable(), func(): log.append("a-"))
	seq.add("b", 0.20, func(): log.append("b+"), Callable(), func(): log.append("b-"))
	seq.update(0.15)
	if log != ["a+", "a-", "b+"] or seq.current == null or seq.current.name != "b":
		return "a fila não preservou a ordem ou o tempo remanescente: %s" % [log]
	seq.update(0.20)
	return "" if log == ["a+", "a-", "b+", "b-"] and not seq.busy else "a fila não terminou corretamente"

func test_shown_value_only_changes_after_animate_to() -> String:
	var hp := CombatFx.ShownValue.new(20)
	hp.update(1.0)
	if hp.value != 20:
		return "o PV visual mudou antes do impacto"
	hp.animate_to(12, 0.6)
	hp.update(0.3)
	if not (hp.value < 20 and hp.value > 12):
		return "o PV visual não animou até o impacto"
	hp.update(0.4)
	return "" if hp.value == 12 else "o PV visual não chegou ao valor final"

func test_dice_roll_keeps_the_resolved_value() -> String:
	var die := DiceRollView.new(20, 17, "acerto")
	die.update(10.0)
	return "" if die.finished and die.target_value == 17 else "o dado de apresentação alterou o resultado resolvido"

func test_d20_3d_stage_creates_and_settles() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var stage := Dice3dView.new()
	tree.root.add_child(stage)
	stage.start([20], 1.0)
	stage.advance(0.6)
	var has_texture := stage.texture() != null
	stage.advance(1.0)
	var settled := not stage.active()
	stage.queue_free()
	return "" if has_texture and settled else "o palco 3D do d20 não criou textura ou não assentou"

func test_turn_indicator_assets_exist() -> String:
	for slug in ["ind_acao", "ind_bonus", "ind_reacao"]:
		if UiAssets.texture(slug, "hud") == null:
			return "asset de indicador ausente: %s" % slug
	return ""
