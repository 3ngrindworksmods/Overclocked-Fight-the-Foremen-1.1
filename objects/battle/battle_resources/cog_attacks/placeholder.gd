extends CogAttack
class_name Placeholder

#const SFX := preload("res://audio/sfx/battle/cogs/SA_bellow.ogg")

@export var play_sound := true

func action() -> void:
	
	# Focus Cog
	user.set_animation('effort')
	battle_node.focus_character(user)
	var iterator = 0
	await manager.sleep(3.5)
