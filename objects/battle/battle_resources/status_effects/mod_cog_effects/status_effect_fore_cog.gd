@tool
extends StatusEffect


const MOD_EFFECTS : Array[StatusEffect] = [ #res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_drop_immunity.tres
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_techbot.tres"), #0
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_disguise.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_proxy_add.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_drop_immunity.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_rebalance.tres"), 
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_lure_immunity.tres"), #5
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_troll.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_damage_drift.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_larynx.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_beneficiary.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_v15_foreman.tres"), #10
	preload("res://objects/battle/battle_resources/misc_movies/traffic_manager/mod_cog_green_light.tres"),
	preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_cursed_foreman.tres"),
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_sheer_force.tres"), #13
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_thorns.tres"), #14
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_alphabet.tres"), #15
	#preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_red_tape.tres"), #16


]

var overchaged = preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/mod_cog_overcharged.tres")
const RESTRICTED_EFFECT_INDEXES := [0, 3, 5, 6, 9]  # techbot, drop_immunity, lure_immunity, troll, beneficiary for chartist pool in future
const PENTHOUSE_FOREMAN_INDEXES := [2, 7, 8, 9]  # proxy+,damage_drift, larynx, beneficiary for boss pool
var force = false
func apply() -> void:
	if not MOD_EFFECTS.is_empty():
		var mod_effect: StatusEffect
		if Util.final_boss:
			var available_effects = []
			for idx in PENTHOUSE_FOREMAN_INDEXES:
				available_effects.append(MOD_EFFECTS[idx])
			mod_effect = RandomService.array_pick_random('mod_cog_effects', available_effects).duplicate()
		else:
			mod_effect = RandomService.array_pick_random('mod_cog_effects', MOD_EFFECTS).duplicate()
			if force: mod_effect = force_cheats(mod_effect)
		Globals.fore_cog_index += 1
		if Util.survive_the_foreman:
			if mod_effect.get_status_name() == "Green Lighter":
				mod_effect = MOD_EFFECTS[2].duplicate() #proxy+ since 2 seperate green light stuff fail
		mod_effect.target = target
		var forecharge = overchaged.duplicate()
		forecharge.target = target
		manager.add_status_effect(forecharge)
		manager.add_status_effect(mod_effect)
		
func force_cheats(mod_effect) -> StatusEffect:
			if Globals.fore_cog_index == 0:
				mod_effect = MOD_EFFECTS[11].duplicate()
			elif Globals.fore_cog_index == 1:
				mod_effect = MOD_EFFECTS[12].duplicate() #11
			elif Globals.fore_cog_index == 2:
				mod_effect = MOD_EFFECTS[10] #6
			else:
				mod_effect = MOD_EFFECTS[12].duplicate()
			return mod_effect
	
