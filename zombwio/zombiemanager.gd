extends Node2D
@export var zombie_scene: PackedScene
@export var max_zombies: int = 64
@export var spawn_distance: float = 256.0
@export var map_size: Vector2 = Vector2(5120, 3840)
@export var spawn_buffer: float = 16.0
var zombies: Array = []
func _ready() -> void:
	for i in range(max_zombies):
		spawn_zombie()
func _process(delta):
	zombies = zombies.filter(func(z): return is_instance_valid(z))
	while zombies.size() < max_zombies:
		spawn_zombie()
func spawn_zombie():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var spawn_pos = get_valid_spawn_location(player.global_position)
	var zombie = zombie_scene.instantiate()
	zombie.global_position = spawn_pos
	zombie.rotation = randf() * TAU
	get_tree().current_scene.call_deferred("add_child", zombie)
	zombies.append(zombie)
func get_valid_spawn_location(player_pos: Vector2) -> Vector2:
	var pos = Vector2.ZERO
	var attempts = 0
	while attempts <= 64:
		pos = Vector2(
			randf_range(spawn_buffer, map_size.x - spawn_buffer),
			randf_range(spawn_buffer, map_size.y - spawn_buffer)
		)
		if pos.distance_to(player_pos) > spawn_distance:
			return pos
		attempts += 1
	var fallback = player_pos + Vector2(spawn_distance, 0).rotated(randf() * TAU)
	fallback.x = clamp(fallback.x, spawn_buffer, map_size.x - spawn_buffer)
	fallback.y = clamp(fallback.y, spawn_buffer, map_size.y - spawn_buffer)
	return fallback
