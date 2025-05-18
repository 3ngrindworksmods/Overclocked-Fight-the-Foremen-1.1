@tool
extends StatusEffect




func apply() -> void:
	manager.s_battle_ending.connect(expire_status)
	print("manager current round in bind")
	if manager.current_round < 1:
		manager.s_ui_initialized.connect(disable_items)
	else: manager.s_round_ended.connect(disable_items)

func expire() -> void:
	print("expiring bind")
	manager.battle_ui.enable_items()
func disable_items() -> void:
	print("disabling items")
	manager.battle_ui.disable_items()
func expire_status() -> void:
	manager.expire_status_effect(self)
func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/statuses/budget_throw.png")
