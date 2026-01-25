extends StaticBody2D
var storage: Dictionary = {
	"wood": 0,
	"stone": 0,
	"copper": 0,
	"fiber": 0,
}
var max_capacity: int = 100
var interaction_area: Area2D
var mode: String = "deposit"
var health: float = 800.0
func _ready():
	add_to_group("chest")
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	add_child(collision)
	var sprite = Sprite2D.new()
	sprite.texture = load("res://images/chest.png")
	add_child(sprite)
	await get_tree().process_frame
	interaction_area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var area_shape = CircleShape2D.new()
	area_shape.radius = 50
	area_collision.shape = area_shape
	interaction_area.add_child(area_collision)
	interaction_area.monitoring = true
	add_child(interaction_area)
func _process(_delta):
	var bodies = interaction_area.get_overlapping_bodies()
	var player_nearby = false
	for body in bodies:
		if body.is_in_group("player"):
			player_nearby = true
			if Input.is_action_just_pressed("interact"):
				if mode == "deposit":
					deposit_all(body)
					mode = "withdraw"
				else:
					withdraw_all(body)
					mode = "deposit"
func deposit_all(player):
	for resource in storage.keys():
		if player.inventory[resource] > 0:
			var amount = player.inventory[resource]
			storage[resource] += amount
			player.inventory[resource] = 0
func withdraw_all(player):
	for resource in storage.keys():
		if storage[resource] > 0:
			player.inventory[resource] += storage[resource]
			storage[resource] = 0
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
