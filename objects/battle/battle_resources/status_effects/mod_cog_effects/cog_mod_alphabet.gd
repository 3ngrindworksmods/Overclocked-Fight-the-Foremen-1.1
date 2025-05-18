@tool
extends StatusEffect
var debuff_turn_index = 0
var buff_turn_index = 0
signal s_gag_modified(indexes: Dictionary)  # New signal
var ascending = true
var placeholder_action = preload("res://objects/battle/battle_resources/cog_attacks/resources/placeholder.tres")


func apply() -> void:
	manager.s_gags_chosen.connect(on_gags_chosen)


func on_gags_chosen(actions: Array[ToonAttack]) -> void:
	print(actions)
	print("checking gags")
	var flag = false
	if ascending:
		for i in range(actions.size() - 1):
			if actions[i].action_name > actions[i + 1].action_name:
				print("not ascending: " + actions[i].action_name + " then ", actions[i + 1].action_name)
				flag = true
	else:
		for i in range(actions.size() - 1):
			if actions[i].action_name < actions[i + 1].action_name:
				print("not descending: " + actions[i].action_name + " then ", actions[i + 1].action_name)
				flag = true
	if flag: retaliate()

	

func renew() -> void:
	ascending = !ascending
	var end_action = placeholder_action.duplicate()
	end_action.user = target
	if ascending:
		description = "Gags selected must be different and in Alphabetical Order"
		end_action.action_name = "Ascending Order!"
		end_action.summary = "Gags names must be in Ascending Order!"
	else:
		description = "Gags selected must be different and in Descending Alphabetical Order"
		end_action.action_name = "Descending Order!"
		end_action.summary = "Gags names must be in Descending Order!"
	manager.round_end_actions.append(end_action)
	
	
func cleanup() -> void:
	manager.s_gags_chosen.disconnect(on_gags_chosen)

func get_status_name() -> String:
	return "Alphabet"

func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/statuses/green_plus.png")
	
func retaliate() -> void:
				var attack = load('res://objects/battle/battle_resources/cog_attacks/resources/finger_wag.tres').duplicate()
				attack.damage = 3
				attack.summary = "The Foreman Retaliates!"
				attack.user = target
				attack.targets = [Util.get_player()]
				attack.damage += target.level / 2 * 2 # yes i just did that
				manager.round_end_actions.append(attack)
