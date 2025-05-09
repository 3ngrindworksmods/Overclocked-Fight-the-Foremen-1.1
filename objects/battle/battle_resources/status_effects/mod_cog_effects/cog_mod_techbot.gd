@tool
extends StatusEffect


func apply() -> void:
	var cog: Cog = target
	cog.techbot = true



func get_status_name() -> String:
	return "Archaic Techbot"

func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/statuses/techbot.png")
