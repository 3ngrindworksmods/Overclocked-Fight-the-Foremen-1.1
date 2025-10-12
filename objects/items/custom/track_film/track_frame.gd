extends MeshInstance3D

const BASE_ITEM := "res://objects/items/resources/passive/track_frame.tres"

var track: String

var resource: Item

@export var quota = false

func setup(item: Item):
	resource = item
	
	# Standard behavior
	if not resource.arbitrary_data.has('track'):
		randomize_track()
	else:
		track = resource.arbitrary_data['track']

	# Color the mesh if this is in-world (not generated for logic purposes i.e. on item application)
	if item.item_model_in_real_world(self):
		var mesh_mat: StandardMaterial3D = mesh.surface_get_material(0).duplicate(true)
		mesh_mat.albedo_color = get_color()
		set_surface_override_material(0, mesh_mat)


func modify(ui: MeshInstance3D) -> void:
	ui.set_surface_override_material(0, ui.mesh.surface_get_material(0).duplicate(true))
	ui.get_surface_override_material(0).albedo_texture = get_gag_got().icon
	ui.get_surface_override_material(0).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

# Weighted gag generation
func randomize_track() -> void:
	var hat := get_hat()
	
	if hat.is_empty():
		resource.reroll()
		return
	
	track = hat[RNG.channel(RNG.ChannelGagFrames).randi() % hat.size()]
	if Util.easy_way_out:
		Util.easy_way_out = false #the easy way out for thuse resourec stuff
		quota_gag()
	get_better_track()
	# Store the track in the item resource
	resource.arbitrary_data['track'] = track
	resource.item_description = "New %s Gag!" % track
	resource.big_description = resource.item_description
func get_better_track() -> void:
	var loadout = Util.get_player().stats.gags_unlocked
	if Util.floor_number == 3:
		print("in track frame better track")
		print(Util.battlesonfloor)
		if Util.battlesonfloor > 2 and loadout['Throw'] < 4:
			print("forcing throw")
			track = 'Throw'
			return
	#trade sound for lowest gag bc of foremen
	if Util.floor_number >= 3:
		if track == "Sound" and loadout["Sound"] >= 5:
			var lowest_gag = get_min_gag_unlocked()
			if lowest_gag != "":
				track = lowest_gag


func get_min_gag_unlocked() -> String:
	var min_key: String = ""
	var min_value: int = 999  
	var gag_loadout = Util.get_player().stats.gags_unlocked
	for key in gag_loadout:
		var current_value = gag_loadout[key]
		if current_value < min_value:
			min_value = current_value
			min_key = key
	#print(" track frame 62: minimum gag: ", min_key)
	return min_key
	
	return min_key			
func get_color() -> Color:
	if get_track(track):
		return get_track(track).track_color
	else:
		return Color.NAVY_BLUE

func collect() -> void:
	Util.get_player().stats.gags_unlocked[track] += 1
	resource.item_name = get_gag_got().action_name

func get_track(track_name: String) -> Track:
	var loadout := Util.get_player().stats.character.gag_loadout
	
	for gag_track in loadout.loadout:
		if gag_track.track_name == track_name:
			return gag_track
	return null

func get_hat() -> Array[String]:
	var loadout: GagLoadout = Util.get_player().character.gag_loadout
	
	# Put all missing gags in a hat
	var hat: Array[String] = []
	for gag_track in loadout.loadout:
		var unlocked: int = Util.get_player().stats.gags_unlocked[gag_track.track_name]
		var remaining := gag_track.gags.size() - unlocked
		for i in remaining:
			hat.append(gag_track.track_name)
	
	# Remove the gags from the floor that have already been spawned
	for item: Item in ItemService.items_in_play:
		if item.arbitrary_data.has('track'):
			hat.erase(item.arbitrary_data['track'])
	
	return hat

func get_gag_got() -> ToonAttack:
	var gag_track := Util.get_player().stats.character.gag_loadout.get_track_of_name(track)
	return gag_track.gags[Util.get_player().stats.gags_unlocked[track] - 1]

func quota_gag() -> void:
	var loadout = Util.get_player().stats.gags_unlocked
	if Util.floor_number == 1:
		var lure_count = loadout.get("Lure", null)
		print("hello in lure wuotoa")
		if lure_count != null and lure_count < 2:
			track = "Lure"
		
	elif Util.floor_number == 2:
		var throw_count = loadout.get("Throw", null)
		print("hello in throw wuotoa")
		if throw_count != null and throw_count < 3:
			track = "Throw"

func make_quota() -> void:
	quota = true
