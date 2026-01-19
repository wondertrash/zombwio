extends Area2D
@export var speed: float = 320.0
@export var damage: float = 40.0
@export var lifetime: float = 2.5
var direction: Vector2 = Vector2.ZERO
func _ready() -> void:
	var sprite = Sprite2D.new()
	var texture = PlaceholderTexture2D.new()
	texture.size = Vector2(8, 8)
	sprite.texture = texture
	sprite.modulate = Color(1, 1, 0)
	add_child(sprite)
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_hit)
	await get_tree().create_timer(lifetime).timeout
	queue_free()
func _process(delta: float) -> void:
	position += direction * speed * delta
func _on_hit(body):
	if body.is_in_group("zombie"):
		body.take_damage(damage)
		queue_free()
