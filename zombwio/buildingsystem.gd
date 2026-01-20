extends Node
var wall_scene = preload("res://wall.tscn")
var door_scene = preload("res://door.tscn")
var campfire_scene = preload("res://campfire.tscn")
var build_mode: bool = false
var current_buildable: String = ""
var buildables = ["wall", "door", "campfire"]
var current_buildable_index = 0
var ghost_preview: Node2D = null
func _ready() -> void:
	pass
func _process(_delta):
	if Input.is_action_just_pressed("build"):
		toggle_build_mode()
	if build_mode:
		if Input.is_key_pressed(KEY_1):
			set_buildable("wall")
		elif Input.is_key_pressed(KEY_2):
			set_buildable("door")
		elif Input.is_key_pressed(KEY_3):
			set_buildable("campfire")
	if build_mode and ghost_preview:
		var camera = get_viewport().get_camera_2d()
		if camera:
			ghost_preview.global_position = camera.get_global_mouse_position()
		ghost_preview.global_position = ghost_preview.global_position.snapped(Vector2(32, 32))
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			try_place_structure()
func toggle_build_mode():
	build_mode = !build_mode
	if build_mode:
		set_buildable("wall")
	else:
		if ghost_preview:
			ghost_preview.queue_free()
			ghost_preview = null
func set_buildable(type: String):
	current_buildable = type
	if ghost_preview:
		ghost_preview.queue_free()
	if type == "wall":
		ghost_preview = wall_scene.instantiate()
	elif type == "door":
		ghost_preview = door_scene.instantiate()
	elif type == "campfire":
		ghost_preview = campfire_scene.instantiate()
	ghost_preview.modulate = Color(1, 1, 1, 0.5)
	if ghost_preview is StaticBody2D or ghost_preview is CharacterBody2D:
		ghost_preview.set_collision_layer_value(1, false)
		ghost_preview.set_collision_mask_value(1, false)
	_disable_all_collision(ghost_preview)
	get_tree().current_scene.add_child(ghost_preview)
func _disable_all_collision(node: Node):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.disabled = true
		elif child is Area2D or child is StaticBody2D:
			child.set_collision_layer_value(1, false)
			child.set_collision_mask_value(1, false)
		_disable_all_collision(child)
func try_place_structure():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var cost = get_build_cost(current_buildable)
	if not can_afford(player, cost):
		return
	if ghost_preview.global_position.distance_to(player.global_position) > 100:
		return
	for resource in cost:
		player.inventory[resource] -= cost[resource]
	var structure = null
	if current_buildable == "wall":
		structure = wall_scene.instantiate()
	elif current_buildable == "door":
		structure = door_scene.instantiate()
	elif current_buildable == "campfire":
		structure = campfire_scene.instantiate()
	structure.global_position = ghost_preview.global_position
	get_tree().current_scene.add_child(structure)
func get_build_cost(type: String) -> Dictionary:
	match type:
		"wall":
			return {"wood": 5, "stone": 2}
		"door":
			return {"wood": 8, "fiber": 3}
		"campfire":
			return {"wood": 10, "stone": 5}
		_:
			return {}
func can_afford(player, cost: Dictionary) -> bool:
	for resource in cost:
		if player.inventory.get(resource, 0) < cost[resource]:
			return false
	return true
