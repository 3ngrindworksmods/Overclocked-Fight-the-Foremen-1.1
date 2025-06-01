@tool
extends StatusEffect


const MOD_EFFECTS : Array[StatusEffect] = [ #res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_drop_immunity.tres
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_techbot.tres"), #0
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_disguise.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_proxy_add.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_drop_immunity.tres"), #3
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_rebalance.tres"), 
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_lure_immunity.tres"), #5
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_troll.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_damage_drift.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_larynx.tres"), #8
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_beneficiary.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_v15_foreman.tres"), #10
	preload("res://objects/battle/battle_resources/misc_movies/traffic_manager/mod_cog_green_light.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_cursed_foreman.tres"),
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_sheer_force.tres"), #13
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_thorns.tres"), #14
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_alphabet.tres"), #15
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_red_tape.tres"), #16
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_laborious.tres"), #17
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_spongy.tres"), #18
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_ruins.tres"), #19
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_whistleblower_fan.tres"), #20
	


]

var overcharged = preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_overcharged.tres")
const RESTRICTED_EFFECT_INDEXES := [0, 3, 5, 6, 9]  # techbot, drop_immunity, lure_immunity, troll, beneficiary for chartist pool in future
const PENTHOUSE_FOREMAN_INDEXES := [2, 7, 8, 9]  # proxy+,damage_drift, larynx, beneficiary for boss pool
var force = false
var cheat_index = -1
func apply() -> void:
		var mod_effect
		if cheat_index == -1:
			print("no cheat index naaau")
			mod_effect = choose_random_cheat()
		#Globals.fore_cog_index += 1
		if Util.survive_the_foreman:
			if mod_effect.get_status_name() == "Green Lighter":
				mod_effect = MOD_EFFECTS[2].duplicate() #proxy+ since 2 seperate green light stuff fail
		mod_effect.target = target
		var forecharge = overcharged.duplicate()
		forecharge.target = target
		manager.add_status_effect(forecharge)
		manager.add_status_effect(mod_effect)
		
func force_cheats() -> int:
			var index
			if Globals.fore_cog_index == 0:
				index = 20
			elif Globals.fore_cog_index == 1:
				index = 20 #11
			elif Globals.fore_cog_index == 2:
				index = 7 #6
			else:
				index = 8
			return index
func choose_random_cheat() -> StatusEffect:
	var mod_effect : StatusEffect
	Globals.fore_cog_index += 1
	if Util.final_boss:
		var available_effects = []
		for idx in PENTHOUSE_FOREMAN_INDEXES:
			available_effects.append(MOD_EFFECTS[idx])
		mod_effect = available_effects[RandomService.randi_range_channel('mod_cog_effects', 0, available_effects.size() - 1)]
		var status_name = mod_effect.get_status_name()
		if Globals.last_fore_ability == status_name:
			if status_name != MOD_EFFECTS[8].get_status_name(): # not larynx
				mod_effect = MOD_EFFECTS[8]
			else:
				mod_effect = MOD_EFFECTS[2] # proxy+
		Globals.last_fore_ability = mod_effect.get_status_name()
	else:
		mod_effect = MOD_EFFECTS[RandomService.randi_range_channel('mod_cog_effects', 0, MOD_EFFECTS.size() - 1)]
		if force: mod_effect =  MOD_EFFECTS[force_cheats()]
	#index = RandomService.randi_range_channel('mod_cog_effects', 0, MOD_EFFECTS.size() - 1)
	if Util.survive_the_foreman:
		if mod_effect.get_status_name() == "Green Lighter":
			mod_effect = MOD_EFFECTS[2]
	return mod_effect

	
