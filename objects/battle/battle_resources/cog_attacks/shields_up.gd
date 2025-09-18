extends CogAttack
class_name Shieldup

const SFX1 := preload("res://audio/sfx/battle/cogs/SA_rage.ogg")
const SFX2 := preload("res://audio/sfx/battle/cogs/SA_defense.ogg")
const RAGE := preload("res://objects/battle/battle_resources/status_effects/resources/rage.tres")
@export var play_sound := true
var rage = true


func action() -> void:
	
	# Focus Cog
	if rage:
		var new_effect = RAGE.duplicate()
		new_effect.target = user
		new_effect.rounds = 1
		manager.add_status_effect(new_effect)
		user.set_animation('jump')
		if play_sound:  AudioManager.play_sound(SFX1)
	else: 
		user.set_animation('buffed')
		if play_sound:  AudioManager.play_sound(SFX2)
	battle_node.focus_character(user)
	await manager.sleep(3.5)
