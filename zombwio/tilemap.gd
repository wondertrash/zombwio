extends TileMap
@export var map_size: Vector2i = Vector2i(160, 120)
@export var tile_id: int = 0
func _ready() -> void:
	for x in range(map_size.x):
		for y in range(map_size.y):
			var random_tile = randi() % 2
			set_cell(0, Vector2i(x, y), 0, Vector2i(random_tile, 0))
