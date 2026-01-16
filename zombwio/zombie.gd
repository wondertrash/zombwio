extends CharacterBody2D
@export var move_speed: float = 35.0
@export var aggro_radius: float = 80.0
@export var chase_radius: float = 160.0
var direction: Vector2 = Vector2.ZERO
var player: Node2D = null
var is_chasing: bool = false
func _ready():
	player = get_tree().get_first_node_in_group("player")
func _physics_process(delta):
	if player == null:
		return
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= aggro_radius:
		is_chasing = true
	elif distance_to_player > chase_radius:
		is_chasing = false
	if is_chasing:
		direction = (player.global_position - global_position).normalized()
		var angle = global_position.direction_to(player.global_position).angle()
		rotation = angle
	else:
		direction = Vector2.ZERO
	velocity = direction * move_speed
	move_and_slide()
