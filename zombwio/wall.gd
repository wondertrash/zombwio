extends StaticBody2D
var health: float = 700.0
func _ready():
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
	if health <= 0:
		queue_free()
