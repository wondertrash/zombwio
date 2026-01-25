extends Node2D
@export var zombie_scene = preload("res://zombie.tscn")
@export var fast_zombie_scene = preload("res://fastzombie.tscn")
@export var tank_zombie_scene = preload("res://tankzombie.tscn")
@export var max_zombies: int = 64
@export var spawn_distance: float = 256.0
@export var map_size: Vector2 = Vector2(5120, 3840)
@export var spawn_buffer: float = 16.0
var zombies: Array = []
func _ready() -> void:
	for i in range(max_zombies):
		spawn_zombie()
func _process(delta):
	var game_time = get_tree().current_scene.get_node("Player").survival_time if get_tree().get_first_node_in_group("player") else 0
	var time_bonus = int(game_time / 180.0) * 8
	max_zombies = 64 + time_bonus
	max_zombies = min(max_zombies, 255)
	zombies = zombies.filter(func(z): return is_instance_valid(z))
	while zombies.size() < max_zombies:
		spawn_zombie()
func spawn_zombie():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var spawn_pos = get_valid_spawn_location(player.global_position)
	var game_time = player.survival_time
	var special_chance = 0.3 + (game_time / 180.0) * 0.2
	special_chance = min(special_chance, 0.7)
	var rand = randf()
	var zombie
	if rand < (1.0 - special_chance):
		zombie = zombie_scene.instantiate()
	elif rand < (1.0 - special_chance * 0.5):
		zombie = fast_zombie_scene.instantiate()
	else:
		zombie = tank_zombie_scene.instantiate()
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
