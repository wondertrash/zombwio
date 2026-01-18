extends Area2D
@export var resource_type: String
@export var amount: int = 1
@export var pickup_radius: float = 30.0
var sprite: Sprite2D
func _ready() -> void:
	sprite = Sprite2D.new()
	if resource_type == "wood":
		sprite.texture = load("res://images/stick.png")
	elif resource_type == "stone":
		sprite.texture = load("res://images/stone.png")
	elif resource_type == "berries":
		sprite.texture = load("res://images/salmonberry.png")
	add_child(sprite)
func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < pickup_radius:
			player.collect_resource(resource_type, amount)
			queue_free()
