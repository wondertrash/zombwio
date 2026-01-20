extends StaticBody2D
var health: float = 500.0
var is_open: bool = false
func _ready():
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	add_child(collision)
	var sprite = Sprite2D.new()
	sprite.texture = load("res://images/door.png")
	add_child(sprite)
	var area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = CircleShape2D.new()
	area_shape.radius = 40
	area_collision.shape = area_shape
	area.add_child(area_collision)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
func _process(delta: float) -> void:
	pass
func _on_body_entered(body):
	if body.is_in_group("player"):
		call_deferred("open_door")
func _on_body_exited(body):
	if body.is_in_group("player"):
		call_deferred("close_door")
func open_door():
	is_open = true
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	modulate = Color(1, 1, 1, 0.5)
func close_door():
	is_open = false
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", false)
	modulate = Color(1, 1, 1, 1)
func take_damage(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
