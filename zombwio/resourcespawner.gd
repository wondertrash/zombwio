extends Node2D
@export var resource_scene: PackedScene
@export var spawn_area_size: Vector2 = Vector2(640, 480)
@export var spawn_map_buffer: float = 35.0
@export var spawn_player_buffer: float = 35.0
@export var wood_count: int = 80
@export var stone_count: int = 80
func _ready() -> void:
	call_deferred("spawn_resources")
func _process(delta: float) -> void:
	pass
func spawn_resources():
	var player = get_tree().get_first_node_in_group("player")
	var player_pos = player.global_position if player else Vector2.ZERO
	for i in range(wood_count):
		var resource = resource_scene.instantiate()
		var pos = get_random_position()
		while pos.distance_to(player_pos) < spawn_player_buffer:
			pos = get_random_position()
		resource.global_position = pos
		resource.resource_type = "wood"
		get_parent().call_deferred("add_child", resource)
	for i in range(stone_count):
		var resource = resource_scene.instantiate()
		var pos = get_random_position()
		while pos.distance_to(player_pos) < spawn_player_buffer:
			pos = get_random_position()
		resource.global_position = pos
		resource.resource_type = "stone"
		get_parent().call_deferred("add_child", resource)
func get_random_position() -> Vector2:
	return Vector2(
		randf_range(spawn_map_buffer, spawn_area_size.x - spawn_map_buffer),
		randf_range(spawn_map_buffer, spawn_area_size.y - spawn_map_buffer)
	)
