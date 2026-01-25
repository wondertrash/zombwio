extends Area2D
@export var speed: float = 400.0
@export var damage: float = 40.0
@export var lifetime: float = 3.0
@export var projectile_type: String = "arrow"
var direction: Vector2 = Vector2.ZERO
var shooter: Node2D = null
func _ready() -> void:
	var sprite = Sprite2D.new()
	if projectile_type == "arrow":
		sprite.texture = load("res://images/arrow.png")
		speed = 350.0
	elif projectile_type == "bolt":
		sprite.texture = load("res://images/bolt.png")
		speed = 450.0
	elif projectile_type == "bullet":
		sprite.texture = load("res://images/bullet.png")
		speed = 600.0
	else:
		var texture = PlaceholderTexture2D.new()
		texture.size = Vector2(8, 4)
		sprite.texture = texture
		sprite.modulate = Color(1, 1, 0)
	add_child(sprite)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8, 3)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_hit)
	await get_tree().create_timer(lifetime).timeout
	queue_free()
func _process(delta: float) -> void:
	global_position += direction * speed * delta
func _on_hit(body):
	if shooter and shooter.is_in_group("turret"):
		if body.is_in_group("zombie"):
			body.take_damage(damage)
			queue_free()
		return
	if body.is_in_group("zombie"):
		body.take_damage(damage)
		queue_free()
	elif body is StaticBody2D:
		queue_free()
