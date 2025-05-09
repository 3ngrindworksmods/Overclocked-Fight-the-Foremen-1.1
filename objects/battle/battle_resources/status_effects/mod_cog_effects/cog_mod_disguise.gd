@tool
extends StatusEffect

var disguise = true
func apply() -> void:
	var cog: Cog = target
	print("applying disguise")
	target.body.set_color(Color(0.5, 0.5, 0.9))
	manager.s_action_started.connect(on_action_start)

func on_action_start(action : BattleAction) -> void:
	# target.body.set_color(Color(0.867, 0.627, 0.867))
	if action is ToonAttack and disguise:
		if action.damage > 1:
			if target in action.targets:
				action.damage = -1
				disguise = false
				description = "Foreman's shield has been broken and is vulnerable to attacks!"
		
				await manager.sleep(5.0)
				target.body.set_color(Color(0.867, 0.627, 0.867))


func cleanup() -> void:
	manager.s_action_started.disconnect(on_action_start)

func get_status_name() -> String:
	if disguise: return "Shield"
	else: return "Shield (Broken)"

func get_icon() -> Texture2D:
	if disguise: return load("res://ui_assets/battle/statuses/proxy_shield.png")
	else: return load("res://ui_assets/battle/statuses/broken_shield.png")
	return 
