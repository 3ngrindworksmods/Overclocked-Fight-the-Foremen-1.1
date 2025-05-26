
@tool
extends StatusEffect

#const Add_Proxy_Attack := preload("res://objects/battle/battle_resources/cog_attacks/resources/proxy+.tres") # or whatever I rename it 
#var Add_Proxy_Attack := preload("res://objects/battle/battle_resources/cog_attacks/resources/proxy_attack.tres")
#var Add_Proxy_Attack := preload("res://objects/battle/battle_resources/cog_attacks/resources/proxy_attack.tres")	
var Rush_Job_Attack = preload("res://objects/battle/battle_resources/cog_attacks/resources/rush_job.tres")

var cog: Cog

func apply() -> void:
	cog = target
	
func renew() -> void:
	var cog = target
	var rush_job: = Rush_Job_Attack.duplicate()
	rush_job.user = cog
	rush_job.targets = [cog]
	manager.round_end_actions.append(rush_job) 
	

func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/statuses/proxy_add.png") #change the icon color red

func get_status_name() -> String:
	return "Laborious"
