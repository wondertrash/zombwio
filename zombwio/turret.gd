extends StaticBody2D
var projectile_scene = preload("res://projectile.tscn")
var fire_rate: float = 1.5
var detection_radius: float = 200.0
var damage: int = 30
var can_shoot: bool = true
var detection_area: Area2D
var sprite: Sprite2D
var is_ghost: bool = false
var health: float = 1200.0
func _ready():
	add_to_group("turret")
	sprite = Sprite2D.new()
	sprite.texture = load("res://images/turret.png")
	add_child(sprite)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	add_child(collision)
	await get_tree().process_frame
	detection_area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = CircleShape2D.new()
	area_shape.radius = detection_radius
	area_collision.shape = area_shape
	detection_area.add_child(area_collision)
	detection_area.monitoring = true
	add_child(detection_area)
func _process(_delta):
	if is_ghost or modulate.a < 1.0:
		return
	if can_shoot:
		var target = find_nearest_zombie()
		if target:
			shoot_at(target)
func find_nearest_zombie() -> Node2D:
	if not detection_area or not is_instance_valid(detection_area):
		return null
	var bodies = detection_area.get_overlapping_bodies()
	var nearest = null
	var nearest_distance = detection_radius
	for body in bodies:
		if body.is_in_group("zombie") and is_instance_valid(body):
			var distance = global_position.distance_to(body.global_position)
			if distance < nearest_distance:
				nearest = body
				nearest_distance = distance
	return nearest
func shoot_at(target: Node2D):
	can_shoot = false
	if sprite:
		sprite.rotation = global_position.direction_to(target.global_position).angle()
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = global_position.direction_to(target.global_position)
	projectile.rotation = projectile.direction.angle()
	projectile.damage = damage
	projectile.projectile_type = "bullet"
	projectile.shooter = self
	get_tree().current_scene.add_child(projectile)
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
