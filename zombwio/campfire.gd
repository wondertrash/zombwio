extends Node2D
var heal_rate: float = 8.0
var hunger_reduction: float = 0.6
var heal_area: Area2D
var health: float = 150.0
func _ready():
	add_to_group("campfire")
	heal_area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = CircleShape2D.new()
	area_shape.radius = 64
	area_collision.shape = area_shape
	heal_area.add_child(area_collision)
	add_child(heal_area)
	var body = StaticBody2D.new()
	var body_collision = CollisionShape2D.new()
	var body_shape = CircleShape2D.new()
	body_shape.radius = 16
	body_collision.shape = body_shape
	body.add_child(body_collision)
	add_child(body)
	var sprite = Sprite2D.new()
	sprite.texture = load("res://images/campfire.png")
	add_child(sprite)
func _physics_process(delta):
	var bodies = heal_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			if body.has_method("heal"):
				body.heal(heal_rate * delta)
			if body.has_method("set_near_campfire"):
				body.set_near_campfire(true)
	var player = get_tree().get_first_node_in_group("player")
	if player and not bodies.has(player):
		if player.has_method("set_near_campfire"):
			player.set_near_campfire(false)
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
