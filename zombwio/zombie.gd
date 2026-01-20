extends CharacterBody2D
@export var move_speed: float = 35.0
@export var aggro_radius: float = 240.0
@export var chase_radius: float = 320.0
@export var health: float = 255.0
@export var attack_damage: float = 14
@export var attack_range: int = 35
@export var attack_cooldown: float = 0.4
var can_attack_player: bool = true
var direction: Vector2 = Vector2.ZERO
var player: Node2D = null
var is_chasing: bool = false
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
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
		wander_timer -= delta
		if wander_timer <= 0:
			wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			wander_timer = randf_range(2.0, 4.0)
		direction = wander_direction
		if direction != Vector2.ZERO:
			rotation = direction.angle()
	velocity = direction * move_speed
	move_and_slide()
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
