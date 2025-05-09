extends ItemScript

const DMG_BONUS := 1.3

var turns_used = 0
var activate_turn = 7

func on_collect(_item: Item, _model: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	BattleService.s_action_started.connect(on_action_started)
	BattleService.s_battle_started.connect(refresh_turns)
	BattleService.s_round_ended.connect(on_round_ended)
	BattleService.s_battle_ending.connect(on_battle_ending)

func on_action_started(action: BattleAction) -> void:
	if action is ToonAttack:
		turns_used += 1
		if turns_used % activate_turn == 0:
			var bonus_dmg = 0
			if action.targets.size() == 1:
				bonus_dmg = int(action.targets[0].stats.hp * 0.15)
				#bonus_dmg =  int(action.targets[0].stats.hp * 0.1)
				#action.damage += bonus_dmg
				action.targets[0].stats.hp -= action.targets[0].stats.hp * 0.15
			else:
				if action.main_target != null:
						bonus_dmg = int(action.main_target.stats.hp * 0.15)
						action.main_target.stats.hp -= int(action.main_target.stats.hp * 0.15)
			action.store_boost_text(str(bonus_dmg) + " HP disappeared!", Color(0.4, 1.0, 0.7))  # Alien green

func refresh_turns() -> void:
	#irrelevant
	turns_used = 0
	
func on_round_ended(manager: BattleManager) -> void:
	var turns_remaining_in_cycle = activate_turn - (turns_used % activate_turn)
	var activation_turn_next_round = turns_remaining_in_cycle - 1     
	if turns_remaining_in_cycle <= Util.get_player().stats.turns:
		var dict = {}
		dict[activation_turn_next_round] = "The main target of this action will lose 15% of their hp"
		manager.battle_ui.s_item_effect.emit(dict)
func  on_battle_ending() -> void:
	turns_used = 0
