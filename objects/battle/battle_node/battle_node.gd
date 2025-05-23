extends Area3D
class_name BattleNode

#const COGVERSATION_PLAYER = preload("res://objects/cog/cogversations/cogversation_player.tscn")
const BATTLE_MANAGER = preload("res://objects/battle/battle_manager/battle_manager.tscn")
# Somehow preloading this is a cyclical reference i wish i was joking
const BATTLE_UI := "res://objects/battle/battle_ui/battle_ui.tscn"
const COG_DISTANCE := 2.25

# Object state
enum BattleState {
	INACTIVE,
	INITIALIZING,
	ACTIVE
}
var state := BattleState.INACTIVE

# Cogs present in battle
@export var cogs: Array[Cog]
@export var focus_cog: Cog
@export var override_intro: BattleStartMovie
@export var item_pool: ItemPool
@export var boss_battle := false
@export var rebalance := 0
@export var override_camera_angles : Dictionary[String, Transform3D] = {}

# Child References
@onready var battle_cam := $BirdsEye/BattleCamera

# Signals
signal s_player_entered(player: Player)
signal s_battle_initialized
signal s_battle_ending
signal s_battle_end

# Locals
var cog_toon_distance := 5.0
var player_pos: Vector3:
	get:
		return global_position + (global_transform.basis.z * cog_toon_distance * .66)
var mod_cogs := 0

var hidden_objects : Dictionary[Node3D, Node3D] = {}

func _ready():
	$ArrowReference.queue_free()
	
	for cog: Cog in cogs:
		if rebalance != 0:
			var old_effects0 = cog.dna.status_effects
			cog.ts_pmo = true
			cog.dna = null
			var level_add = rebalance + Util.floor_number - 1
			cog.level_rebalance += rebalance + Util.floor_number - 1
			#print("line 57 bm TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMOTS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO TS PMO")
			cog.randomize_cog()
			if old_effects0.size() >= 1:
				cog.dna.status_effects.append_array(old_effects0)
		if RandomService.randf_channel('mod_cog_chance') < get_mod_cog_chance() and not cog.has_forced_dna and not cog.virtual_cog:
			var old_effects = cog.dna.status_effects
			cog.dna = null
			mod_cogs += 1
			cog.use_mod_cogs_pool = true
			cog.skelecog_chance = 0
			cog.skelecog = false
			cog.level_rebalance -= 1
			cog.randomize_cog()
			if old_effects.size() >= 1:
				cog.dna.status_effects.append_array(old_effects)

	
	BattleService.s_battle_spawned.emit(self)

func body_entered(body: Node3D):
	if body is Player:
		s_player_entered.emit(body)

func player_entered(player : Player):
	# Disable game timer tick until battle is initialized
	player.game_timer_tick = false
	
	s_battle_initialized.emit()
	
	# Start loading the battle UI
	ResourceLoader.load_threaded_request(BATTLE_UI)
	
	# Free the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if player.state != Player.PlayerState.WALK:
		return
	player.state = Player.PlayerState.STOPPED
	player.set_animation('neutral')
	## Reparent player and any partners to the battle
	player.reparent(self)
	for partner in player.partners:
		partner.reparent(self)
	
	# Tell battle service the battle is initializing
	BattleService.battle_node = self
	
	# Focus a cog
	if not focus_cog:
		focus_cog = cogs[RandomService.randi_channel('true_random') % cogs.size()]
	
	# Turn on battle cam
	battle_cam.current = true
	
	# Play the battle start movie
	var movie: BattleStartMovie
	if override_intro:
		movie = override_intro
	elif focus_cog.dna.battle_start_movie:
		movie = focus_cog.dna.battle_start_movie.duplicate()
	else:
		movie = BattleStartMovie.new()
	
	movie.focus_cog = focus_cog
	movie.battle_node = self
	movie.camera = battle_cam
	movie.cogs = cogs
	movie.play()
	
	# Create Skip Button
	if movie.skippable:
		%SkipButton.show()
		%SkipButton.pressed.connect(movie._skip)
		movie.movie.finished.connect(%SkipButton.hide)
	
	# Wait until movie is finished
	await movie.movie.finished
	
	focus_character(self)
	
	# Initialize positions
	var initialization_barrier := SignalBarrier.new()
	# Move player
	var player_tween := player.move_to(player_pos,player.run_speed)
	player_tween.finished.connect(
	func():
		player.s_battle_ready.emit()
		face_battle_center(player)
	)
	# Add player to signal barrier
	initialization_barrier.append(player.s_battle_ready)
	
	# Activate cogs
	for cog in cogs:
		cog.battle_start()
		
		# Move cog into position and add tween to signal barrier
		var cog_tween := cog.move_to(get_cog_position(cog))
		cog_tween.finished.connect(
		func():
			cog.s_battle_ready.emit()
			face_battle_center(cog)
		)
		initialization_barrier.append(cog.s_battle_ready)
	
	# Make all partners join battle
	for partner in player.partners:
		partner.battle_started(self)
		initialization_barrier.append(partner.s_battle_ready)
	
	await initialization_barrier.s_complete
	
	# Bring in the battle manager
	var bm = BATTLE_MANAGER.instantiate()
	add_child(bm)
	bm.boss_battle = boss_battle
	bm.battle_ui = ResourceLoader.load_threaded_get(BATTLE_UI).instantiate()
	bm.start_battle(cogs,self)
	bm.s_focus_char.connect(focus_character)
	
	# Disable self
	set_deferred('monitoring',false)
	
	# Hook into battle ending
	bm.s_battle_ending.connect(func(): s_battle_ending.emit())
	
	# Hook into battle end
	bm.s_battle_ended.connect(
		func():
			s_battle_end.emit()
			queue_free()
	)
	# Re-enable game timer tick
	player.game_timer_tick = true

func face_battle_center(object: Node3D):
	if object is Cog:
		object.global_rotation.y = global_rotation.y
	else:
		object.face_position(global_position)

func focus_character(character: Node3D, cam_dist := 4.0, dir := -1):
	if self == character:
		battle_cam.reparent($BirdsEye)
		battle_cam.rotation = Vector3(0, 0, 0)
		battle_cam.position = Vector3(0, 0, 0)
	else:
		battle_cam.reparent(self)
		if 'head_node' in character and character.head_node:
			battle_cam.global_position = character.head_node.global_position
		else:
			battle_cam.global_position = character.global_position
		
		if character is Player:
			cam_dist /= 2.0
		
		if get_local_position(character.global_position).z > 0:
			cam_dist = -cam_dist
		
		battle_cam.position.z += cam_dist
		
		# Make the camera partway up the character's height
		if 'head_node' in character and character.head_node:
			character.head_node.position.y *= .75
			battle_cam.global_position.y = character.head_node.global_position.y
			character.head_node.position /= .75
			
			var positions := [-1.0, 1.0]
			if dir >= 0 and positions.size() > dir:
				battle_cam.position.x += positions[dir]
			else:
				battle_cam.position.x += positions[RandomService.randi_channel('true_random') % 2]
			
			battle_cam.look_at(character.head_node.global_position)
		else:
			battle_cam.position.y = 1.0
			battle_cam.look_at(character.global_position)

func focus_cogs():
	battle_cam.reparent(self)
	battle_cam.global_position = Util.get_player().head_node.global_position
	battle_cam.global_position = battle_cam.global_position.move_toward(Vector3(global_position.x, battle_cam.global_position.y, global_position.z), 1.0)
	var avg_height := 0.0
	for cog in cogs:
		if cog.head_node:
			avg_height += cog.head_node.global_position.y
		else:
			avg_height += global_position.y
	avg_height /= cogs.size()
	battle_cam.global_position.y = avg_height
	battle_cam.rotation_degrees = Vector3(0,0,0)

func reposition_cogs():
	for cog in cogs:
		cog.move_to(get_cog_position(cog),cog.walk_speed).finished.connect(
		func():
			face_battle_center(cog)
		)

func get_cog_position(cog: Cog) -> Vector3:
	var cog_pos := cogs.find(cog) + 1
	if cog_pos == 0:
		return Vector3.ZERO
	
	# Get the center cog pos
	var cog_center := get_local_position(global_position - (global_transform.basis.z * cog_toon_distance * 0.33))
	
	# Get the center Cog's index as a float
	# Add 0.5 so that fights w/ even numbers of cogs are offset from center
	var center_cog_index: float = (float(cogs.size()) / 2.0) + 0.5
	
	# Determine the offset of the position from cog center
	var offset := Vector3.ZERO
	offset.x = COG_DISTANCE * (float(cog_pos) - center_cog_index)
	
	# Move Cog a little bit back if in middle
	if cog_pos > 1 and cog_pos < cogs.size():
		offset.z -= 1.0
	
	return get_relative_position(cog_center + offset)

func face_forward():
	face_battle_center(Util.get_player())
	if Util.get_player().animator.current_animation != 'neutral':
		Util.get_player().set_animation('neutral')
	for cog in cogs:
		face_battle_center(cog)

func get_partner_position(partner_index: int) -> Vector3:
	var dist: float = 1.0 * float(partner_index + 2) / 2
	if partner_index % 2 == 1:
		dist = -dist
	var pos_node := Node3D.new()
	add_child(pos_node)
	pos_node.position.z = cog_toon_distance * 0.66
	pos_node.position.x += dist
	var return_pos := pos_node.global_position
	pos_node.queue_free()
	return return_pos

## Returns the global position relative to the battle node
func get_relative_position(translation: Vector3) -> Vector3:
	var pos_node := Node3D.new()
	add_child(pos_node)
	pos_node.position = translation
	var return_pos := pos_node.global_position
	pos_node.queue_free()
	return return_pos

func get_local_position(translation: Vector3) -> Vector3:
	var pos_node := Node3D.new()
	add_child(pos_node)
	pos_node.global_position = translation
	var return_pos := pos_node.position
	pos_node.queue_free()
	return return_pos

func get_mod_cog_chance() -> float:
	if not SaveFileService.progress_file.proxies_unlocked:
		return 0.0

	var test : CogPool = Globals.GRUNT_COG_POOL

	var floor_num := Util.floor_number
	#var max_mod_cogs := mini(roundi(floor_num * 0.75), 3)
	var max_mod_cogs :=  2 * (floor_num + 1)
	if mod_cogs >= max_mod_cogs:
		return 0.0
	
	var chance := (floor_num * 0.075 * 1.5)
	if Util.get_player() and not is_equal_approx(Util.get_player().stats.proxy_chance_boost, 0.0):
		chance += Util.get_player().stats.proxy_chance_boost
	return chance


func get_cog_orgin_point() -> Vector3:
	var cog_center := get_local_position(global_position - (global_transform.basis.z * cog_toon_distance * 0.33))
	return cog_center
	
func _on_camera_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		return
	var current_node: Node = body
	while current_node:
		if current_node.has_meta("battle_cam_hide"):
			if current_node is Node3D:
				hidden_objects[body] = current_node
				fade_node_and_children(current_node)
			break
		current_node = current_node.get_parent()
	
func _on_camera_area_body_exited(body: Node3D) -> void:
	if body in hidden_objects:
		var hidden_object: Node3D = hidden_objects[body]
		unfade_node_and_children(hidden_object)
		hidden_objects.erase(body)

func fade_node_and_children(node: Node3D):
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	if RenderingServer.get_current_rendering_method() == 'forward_plus':
		for geom_node in NodeGlobals.get_children_of_type(node, GeometryInstance3D, true):
			tween.tween_property(geom_node, "transparency", 0.9, 0.3)
		if node is GeometryInstance3D:
			tween.tween_property(node, "transparency", 0.9, 0.3)
	else:
		var mesh_nodes := NodeGlobals.get_children_of_type(node, MeshInstance3D, true)
		if node is MeshInstance3D:
			mesh_nodes.append(node)
		for mesh_node: MeshInstance3D in mesh_nodes:
			for i in range(mesh_node.get_surface_override_material_count()):
				var material: BaseMaterial3D = mesh_node.get_surface_override_material(i)
				if material:
					material = material.duplicate()
					material.set_meta("original_color", material.albedo_color)
					material.set_meta("original_transparency", material.transparency)
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mesh_node.set_surface_override_material(i, material)
					tween.tween_property(material, "albedo_color:a", 0.1, 0.3)

func unfade_node_and_children(node: Node3D):
	if RenderingServer.get_current_rendering_method() == 'forward_plus':
		for geom_node in NodeGlobals.get_children_of_type(node, GeometryInstance3D, true):
			geom_node.transparency = 0.0
		if node is GeometryInstance3D:
			node.transparency = 0.0
	else:
		var mesh_nodes := NodeGlobals.get_children_of_type(node, MeshInstance3D, true)
		if node is MeshInstance3D:
			mesh_nodes.append(node)
		for mesh_node: MeshInstance3D in mesh_nodes:
			for i in range(mesh_node.get_surface_override_material_count()):
				var material: BaseMaterial3D = mesh_node.get_surface_override_material(i)
				if material and material.has_meta("original_transparency"):
					material.transparency = material.get_meta("original_transparency")
					material.albedo_color = material.get_meta("original_color")
