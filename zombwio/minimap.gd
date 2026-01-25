extends CanvasLayer
@export var minimap_size: Vector2 = Vector2(150, 150)
@export var map_world_size: Vector2 = Vector2(5120, 3840)
@export var minimap_position: Vector2 = Vector2(10, 10)
var background = ColorRect
var player_dot = ColorRect
var structure_container = Control
var zombie_container = Control
func _ready() -> void:
	layer = 10
	background = ColorRect.new()
	background.position = minimap_position
	background.size = minimap_size
	background.color = Color(0.1, 0.1, 0.1, 0.8)
	add_child(background)
	var border = ColorRect.new()
	border.position = minimap_position - Vector2(2, 2)
	border.size = minimap_size + Vector2(4, 4)
	border.color = Color(0.5, 0.5, 0.5)
	border.z_index = -1
	add_child(border)
	structure_container = Control.new()
	structure_container.position = minimap_position
	structure_container.size = minimap_size
	structure_container.clip_contents = true
	add_child(structure_container)
	zombie_container = Control.new()
	zombie_container.position = minimap_position
	zombie_container.size = minimap_size
	zombie_container.clip_contents = true
	add_child(zombie_container)
	player_dot = ColorRect.new()
	player_dot.size = Vector2(4, 4)
	player_dot.color = Color(0, 1, 0)
	player_dot.z_index = 10
	add_child(player_dot)
func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player) or player.current_health <= 0:
		visible = false
		return
	else:
		visible = true
	update_minimap()
func update_minimap():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var player_minimap_pos = world_to_minimap(player.global_position)
	player_dot.position = minimap_position + player_minimap_pos - Vector2(2, 2)
	for child in structure_container.get_children():
		structure_container.remove_child(child)
		child.queue_free()
	var structures = []
	structures.append_array(get_tree().get_nodes_in_group("wall"))
	structures.append_array(get_tree().get_nodes_in_group("door"))
	structures.append_array(get_tree().get_nodes_in_group("campfire"))
	for structure in structures:
		if is_instance_valid(structure):
			var pos = world_to_minimap(structure.global_position)
			if is_in_minimap_bounds(pos):
				var dot = ColorRect.new()
				dot.size = Vector2(2, 2)
				dot.position = pos - Vector2(1, 1)
				if structure.is_in_group("wall"):
					dot.color = Color(0.6, 0.4, 0.2)
				elif structure.is_in_group("door"):
					dot.color = Color(0.8, 0.6, 0.3)
				elif structure.is_in_group("campfre"):
					dot.color = Color(1, 0.5, 0)
				structure_container.add_child(dot)
	for child in zombie_container.get_children():
		zombie_container.remove_child(child)
		child.queue_free()
	var zombies = get_tree().get_nodes_in_group("zombie")
	for zombie in zombies:
		if is_instance_valid(zombie):
			var distance = zombie.global_position.distance_to(player.global_position)
			if distance < 640:
				var pos = world_to_minimap(zombie.global_position)
				if is_in_minimap_bounds(pos):
					var dot = ColorRect.new()
					dot.size = Vector2(2, 2)
					dot.position = pos - Vector2(1, 1)
					dot.color = Color(1, 0, 0, 0.7)
					zombie_container.add_child(dot)
func world_to_minimap(world_pos: Vector2) -> Vector2:
	var ratio = minimap_size / map_world_size
	return world_pos * ratio
func is_in_minimap_bounds(minimap_pos: Vector2) -> bool:
	return minimap_pos.x >= 0 and minimap_pos.x <= minimap_size.x and minimap_pos.y >= 0 and minimap_pos.y <= minimap_pos.y
