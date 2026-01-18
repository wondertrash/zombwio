extends CharacterBody2D
@export var move_speed: float = 35.0
@export var aggro_radius: float = 80.0
@export var chase_radius: float = 160.0
@export var health: int = 3
@export var attack_damage: int = 10
@export var attack_range: int = 20
@export var attack_cooldown: float = 1.0
var can_attack_player: bool = true
var direction: Vector2 = Vector2.ZERO
var player: Node2D = null
var is_chasing: bool = false
func _ready():
	add_to_group("zombie")
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
		if distance_to_player < attack_range and can_attack_player:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage)
				can_attack_player = false
				await get_tree().create_timer(attack_cooldown).timeout
				can_attack_player = true
	else:
		direction = Vector2.ZERO
	velocity = direction * move_speed
	move_and_slide()
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
