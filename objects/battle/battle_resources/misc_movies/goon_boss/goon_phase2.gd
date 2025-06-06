extends ActionScript

const COG := preload('res://objects/cog/cog.tscn')
const SFX_SPARK := preload("res://audio/sfx/battle/cogs/misc/LB_sparks_1.ogg")
const GAG_IMMUNITY_EFFECT := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_gag_immunity.tres")


func action() -> void:
	var goon: Goon = user
	var cogs: Array[Cog] = []
	
	var audio_player := AudioManager.play_snippet(goon.SFX_ALERT, 0.0, 2.2)
	audio_player.pitch_scale = 0.85
	
	var cog_count := 4
	if Util.on_easy_floor():
		cog_count -= 1
	
	for i in cog_count:
		var cog := COG.instantiate()
		cog.virtual_cog = false
		cog.skelecog = false
		cog.hide()
		# Proxies :)
		if RandomService.randf_channel('goon_boss_proxies') < battle_node.get_mod_cog_chance() / 2.0 and not Util.on_easy_floor():
			cog.use_mod_cogs_pool = true
		battle_node.add_child(cog)
		cog.battle_start()
		cogs.append(cog)
	assign_gag_immunities(cogs)
	
	for cog in cogs:
		manager.add_cog(cog)
	battle_node.reposition_cogs()
	
	var movie := manager.create_tween()
	movie.tween_callback(battle_node.focus_cogs)
	movie.tween_callback(goon.set_animation.bind('enraged'))
	movie.tween_interval(1.4)
	movie.tween_callback(AudioManager.play_sound.bind(load("res://audio/sfx/misc/CHQ_SOS_cage_land.ogg")))
	movie.tween_interval(0.1)
	movie.tween_callback(AudioManager.play_sound.bind(SFX_SPARK))
	for cog in cogs:
		movie.tween_callback(cog.show)
		movie.tween_callback(cog.set_animation.bind('drop'))
		movie.tween_callback(cog.animator_seek.bind(3.0))
	movie.tween_interval(3.0)
	movie.tween_callback(goon.set_animation.bind('neutral'))
	
	await movie.finished
	movie.kill()

func assign_gag_immunities(cogs: Array[Cog]) -> Array[StatusEffectGagImmunity]:
	var effects: Array[StatusEffectGagImmunity] = []
	var loadout: Array[Track] = Util.get_player().stats.character.gag_loadout.loadout
	
	# Assign a random gag immunity to each Cog
	for cog in cogs:
		var new_status1 := GAG_IMMUNITY_EFFECT.duplicate()
		new_status1.target = cog
		new_status1.rounds = -1
		new_status1.set_track(loadout[RandomService.randi_channel('true_random') % loadout.size()])
		cog.dna.status_effects.append(new_status1)
		var new_status := GAG_IMMUNITY_EFFECT.duplicate()
		new_status.target = cog
		new_status.rounds = -1
		new_status.set_track(loadout[RandomService.randi_channel('true_random') % loadout.size()])
		cog.dna.status_effects.append(new_status)
		cog.body.set_color(Color(new_status.track.track_color, 0.8))
	
	return effects
