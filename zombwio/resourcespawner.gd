extends Node2D
@export var resource_scene: PackedScene
@export var spawn_area_size: Vector2 = Vector2(5120, 3840)
@export var spawn_map_buffer: float = 16.0
@export var spawn_player_buffer: float = 16.0
@export var max_wood: int = 80
@export var max_stone: int = 48
@export var max_berries: int = 40
@export var max_copper: int = 16
@export var max_fiber: int = 48
var wood_resources: Array = []
var stone_resources: Array = []
var berry_resources: Array = []
var copper_resources: Array= []
var fiber_resources: Array = []
func _ready() -> void:
	call_deferred("spawn_initial_resources")
func spawn_initial_resources():
	for i in range(max_wood):
		spawn_resource("wood")
	for i in range(max_stone):
		spawn_resource("stone")
	for i in range(max_berries):
		spawn_resource("berries")
	for i in range(max_copper):
		spawn_resource("copper")
	for i in range(max_fiber):
		spawn_resource("fiber")
func _process(_delta):
	wood_resources = wood_resources.filter(func(r): return is_instance_valid(r))
	stone_resources = stone_resources.filter(func(r): return is_instance_valid(r))
	berry_resources = berry_resources.filter(func(r): return is_instance_valid(r))
	copper_resources = copper_resources.filter(func(r): return is_instance_valid(r))
	fiber_resources = fiber_resources.filter(func(r): return is_instance_valid(r))
	if wood_resources.size() < max_wood:
		spawn_resource("wood")
	if stone_resources.size() < max_stone:
		spawn_resource("stone")
	if berry_resources.size() < max_berries:
		spawn_resource("berries")
	if copper_resources.size() < max_copper:
		spawn_resource("copper")
	if fiber_resources.size() < max_fiber:
		spawn_resource("fiber")
func spawn_resource(type: String):
	var player = get_tree().get_first_node_in_group("player")
	var player_pos = player.global_position if player else Vector2.ZERO
	var pos = get_random_position()
	while pos.distance_to(player_pos) < spawn_player_buffer:
		pos = get_random_position()
	var resource = resource_scene.instantiate()
	resource.global_position = pos
	resource.resource_type = type
	get_parent().add_child(resource)
	if type == "wood":
		wood_resources.append(resource)
	if type == "stone":
		stone_resources.append(resource)
	if type == "berries":
		berry_resources.append(resource)
	if type == "copper":
		copper_resources.append(resource)
	if type == "fiber":
		fiber_resources.append(resource)
func get_random_position() -> Vector2:
	return Vector2(
		randf_range(spawn_map_buffer, spawn_area_size.x - spawn_map_buffer),
		randf_range(spawn_map_buffer, spawn_area_size.y - spawn_map_buffer)
	)
