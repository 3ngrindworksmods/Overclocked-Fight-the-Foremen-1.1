extends CogAttack
class_name Bellow

const SFX := preload("res://audio/sfx/battle/cogs/SA_bellow.ogg")

@export var play_sound := true

func action() -> void:
	manager.bellow = true
	# Get player
	if play_sound:
		AudioManager.play_sound(SFX)
	
	# Focus Cog
	user.set_animation('effort')
	battle_node.focus_character(user)
	var iterator = 0

	
	
	await manager.sleep(3.0)
	var status_effects = manager.status_effects.duplicate()
	for status_effect: StatusEffect in status_effects:
		if status_effect.target is Cog and status_effect.quality == 1:
			#print(status_effect.get_description())
			await manager.expire_status_effect(status_effect)
			await manager.sleep(0.7)
	#await manager.sleep(3.0)
	manager.bellow = false
