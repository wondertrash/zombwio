extends StaticBody2D
var damage: float = 20.0
var damage_interval: float = 0.5
var damage_area: Area2D
var health: float = 1200.0
func _ready():
	add_to_group("spike_trap")
	var sprite = Sprite2D.new()
	sprite.texture = load("res://images/spiketrap.png")
	add_child(sprite)
	var body_collision = CollisionShape2D.new()
	var body_shape = RectangleShape2D.new()
	body_shape.size = Vector2(28, 28)
	body_collision.shape = body_shape
	add_child(body_collision)
	await get_tree().process_frame
	damage_area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = RectangleShape2D.new()
	area_shape.size = Vector2(32, 32)
	area_collision.shape = area_shape
	damage_area.add_child(area_collision)
	damage_area.monitoring = true
	add_child(damage_area)
func _process(_delta):
	var bodies = damage_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("zombie") and is_instance_valid(body):
			damage_zombie(body)
func damage_zombie(zombie):
	if not zombie.has_meta("spike_cooldown"):
		zombie.set_meta("spike_cooldown", 0.0)
	var cooldown = zombie.get_meta("spike_cooldown")
	if cooldown <= 0:
		zombie.take_damage(damage)
		zombie.set_meta("spike_cooldown", damage_interval)
		modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)
	else:
		zombie.set_meta("spike_cooldown", cooldown - get_process_delta_time())
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
