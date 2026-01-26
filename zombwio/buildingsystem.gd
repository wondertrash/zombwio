extends CanvasLayer
var wall_scene = preload("res://wall.tscn")
var door_scene = preload("res://door.tscn")
var campfire_scene = preload("res://campfire.tscn")
var spike_trap_scene = preload("res://spiketrap.tscn")
var chest_scene = preload("res://chest.tscn")
var turret_scene = preload("res://turret.tscn")
var build_mode: bool = false
var current_buildable: String = ""
var ghost_preview: Node2D = null
var can_place: bool = true
var cost_label: Label = null
var build_sound: AudioStream = load("res://sounds/build.wav")
func _ready() -> void:
	cost_label = Label.new()
	cost_label.add_theme_font_size_override("font_size", 18)
	cost_label.visible = false
	add_child(cost_label)
func _process(_delta):
	if Input.is_action_just_pressed("build"):
		toggle_build_mode()
	if build_mode:
		if Input.is_key_pressed(KEY_1):
			set_buildable("Wall")
		elif Input.is_key_pressed(KEY_2):
			set_buildable("Door")
		elif Input.is_key_pressed(KEY_3):
			set_buildable("Campfire")
		elif Input.is_key_pressed(KEY_4):
			set_buildable("Spike Trap")
		elif Input.is_key_pressed(KEY_5):
			set_buildable("Chest")
		elif Input.is_key_pressed(KEY_6):
			set_buildable("Turret")
	if build_mode and ghost_preview:
		var camera = get_viewport().get_camera_2d()
		if camera:
			var mouse_pos = camera.get_global_mouse_position()
			ghost_preview.global_position = mouse_pos.snapped(Vector2(32, 32))
			ghost_preview.global_position += Vector2(-16, 16)
			cost_label.visible = true
			cost_label.position = get_viewport().get_mouse_position() + Vector2(20, -20)
			var cost = get_build_cost(current_buildable)
			var cost_text = current_buildable + ": "
			var parts = []
			if cost.get("wood", 0) > 0: parts.append("W:%d" % cost["wood"])
			if cost.get("stone", 0) > 0: parts.append("S:%d" % cost["stone"])
			if cost.get("copper", 0) > 0: parts.append("C:%d" % cost["copper"])
			if cost.get("fiber", 0) > 0: parts.append("F:%d" % cost["fiber"])
			cost_label.text = cost_text + ", ".join(parts)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_place:
			try_place_structure()
			can_place = false
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			can_place = true
	else:
		cost_label.visible = false
func toggle_build_mode():
	build_mode = !build_mode
	if build_mode:
		set_buildable("Wall")
	else:
		if ghost_preview:
			ghost_preview.queue_free()
			ghost_preview = null
func set_buildable(type: String):
	current_buildable = type
	if ghost_preview:
		ghost_preview.queue_free()
	if type == "Wall":
		ghost_preview = wall_scene.instantiate()
	elif type == "Door":
		ghost_preview = door_scene.instantiate()
	elif type == "Campfire":
		ghost_preview = campfire_scene.instantiate()
	elif type == "Spike Trap":
		ghost_preview = spike_trap_scene.instantiate()
	elif type == "Chest":
		ghost_preview = chest_scene.instantiate()
	elif type == "Turret":
		ghost_preview = turret_scene.instantiate()
	ghost_preview.modulate = Color(1, 1, 1, 0.5)
	if ghost_preview is StaticBody2D or ghost_preview is CharacterBody2D:
		ghost_preview.set_collision_layer_value(1, false)
		ghost_preview.set_collision_mask_value(1, false)
	_disable_all_collision(ghost_preview)
	get_tree().current_scene.add_child(ghost_preview)
func _disable_all_collision(node: Node):
	for child in node.get_children():
		if child is CollisionShape2D:
			var parent = child.get_parent()
			if parent is StaticBody2D or parent is CharacterBody2D:
				child.disabled = true
		elif child is StaticBody2D or child is CharacterBody2D:
			child.set_collision_layer_value(1, false)
			child.set_collision_mask_value(1, false)
		if not child is Area2D:
			_disable_all_collision(child)
func try_place_structure():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var cost = get_build_cost(current_buildable)
	if not can_afford(player, cost):
		return
	if ghost_preview.global_position.distance_to(player.global_position) > 92:
		return
	var map_size = Vector2(5120, 3840)
	var pos = ghost_preview.global_position
	if pos.x < 0 or pos.x > map_size.x or pos.y < 0 or pos.y > map_size.y:
		return
	for resource in cost:
		player.inventory[resource] -= cost[resource]
	var structure = null
	if current_buildable == "Wall":
		structure = wall_scene.instantiate()
	elif current_buildable == "Door":
		structure = door_scene.instantiate()
	elif current_buildable == "Campfire":
		structure = campfire_scene.instantiate()
	elif current_buildable == "Spike Trap":
		structure = spike_trap_scene.instantiate()
	elif current_buildable == "Chest":
		structure = chest_scene.instantiate()
	elif current_buildable == "Turret":
		structure = turret_scene.instantiate()
	player.buildings_placed += 1
	structure.global_position = ghost_preview.global_position
	get_tree().current_scene.add_child(structure)
	play_sound(build_sound)
func get_build_cost(type: String) -> Dictionary:
	match type:
		"Wall":
			return {"wood": 2}
		"Door":
			return {"wood": 5, "fiber": 5}
		"Campfire":
			return {"wood": 10, "stone": 5}
		"Spike Trap":
			return {"wood": 5, "stone": 5}
		"Chest":
			return {"wood": 15, "fiber": 5}
		"Turret":
			return {"wood": 20, "stone": 20, "copper": 5}
		_:
			return {}
func can_afford(player, cost: Dictionary) -> bool:
	for resource in cost:
		if player.inventory.get(resource, 0) < cost[resource]:
			return false
	return true
func play_sound(sound: AudioStream):
	var player_node = AudioStreamPlayer.new()
	player_node.stream = sound
	add_child(player_node)
	player_node.play()
	player_node.finished.connect(player_node.queue_free)
