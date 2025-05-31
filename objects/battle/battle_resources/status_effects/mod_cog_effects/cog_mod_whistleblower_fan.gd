@tool
extends StatusEffect

var player: Player
var last_player_hp
var heal_multiplier = 2.5
const STATUS_EFFECT := preload('res://objects/battle/battle_resources/status_effects/resources/status_effect_budget_cuts.tres')
func apply() -> void:
	var cog: Cog = target
	player  = Util.get_player()
	player.stats.hp_changed.connect(on_toon_heal)
	manager.s_action_started.connect(on_action_started)
	last_player_hp = player.stats.hp

func on_toon_heal(health : int) -> void:
	if(health < last_player_hp and health != last_player_hp):
		if player.last_damage_source == "Whistleblower Fan":
			await manager.sleep(0.2)
			manager.battle_text(Util.get_player(),"Budget Cuts!")
			print(Util.get_player().last_damage_source)
		var hp_ratio = float(health - last_player_hp) / player.stats.max_hp
		
	else:
		print("got damaged oof: ", health - last_player_hp)
	last_player_hp = health
	
func on_action_started(action: BattleAction) -> void:
	if action is CogAttack and action.target_type != BattleAction.ActionTarget.SELF:
		if action.user == target:
			#action.custom_player_death_source = "Whistleblower Fan"
			player.last_damage_source = "Whistleblower Fan"
			apply_status_effect()
			print("action started and whistleblower  attack")

func cleanup() -> void:
	player.stats.hp_changed.disconnect(on_toon_heal)

func get_status_name() -> String:
	return "Whistleblower Fan"

func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/gags/inventory_whistle.png")

func apply_status_effect() -> void:
	var effect := STATUS_EFFECT.duplicate()
	effect.target = player
	effect.track_name = "Throw"
	manager.add_status_effect(effect)
