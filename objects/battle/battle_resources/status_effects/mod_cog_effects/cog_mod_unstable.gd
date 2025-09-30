@tool
extends StatusEffect

const CHEAT_REFERENCE := preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/status_effect_unstable_cog.tres")
var prev_ability = "idk"
func apply() -> void:
	var new_boost := CHEAT_REFERENCE.duplicate()
	new_boost.quality = StatusEffect.EffectQuality.POSITIVE
	new_boost.unstable_effect = self
	new_boost.target = target
	manager.add_status_effect(new_boost)

	


func get_status_name() -> String:
	return "Unstable"

func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/statuses/unstable.png")
	
func renew() -> void:
	var new_boost := CHEAT_REFERENCE.duplicate()
	new_boost.quality = StatusEffect.EffectQuality.POSITIVE
	new_boost.target = target
	new_boost.last_ability = "idk"
	new_boost.unstable_effect = self
	manager.add_status_effect(new_boost)
	
