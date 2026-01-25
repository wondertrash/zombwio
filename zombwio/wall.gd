extends StaticBody2D
var health: float = 600.0
func _ready():
	add_to_group("wall")
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	add_child(collision)
	var sprite = Sprite2D.new()
	sprite.texture = load("res://images/wall.png")
	add_child(sprite)
func _process(delta: float) -> void:
	pass
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
