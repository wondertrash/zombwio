extends CharacterBody2D
@export var move_speed: float = 20.0
@export var aggro_radius: float = 160.0
@export var chase_radius: float = 320.0
@export var health: float = 800.0
@export var attack_damage: float = 20
@export var attack_range: int = 40
@export var attack_cooldown: float = 0.8
var base_speed: float = 20.0
var can_attack_player: bool = true
var direction: Vector2 = Vector2.ZERO
var player: Node2D = null
var zombie_attack_sprite: Sprite2D = null
var zombie_idle_sprite: Sprite2D = null
var is_chasing: bool = false
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var zombies_killed: int = 0
func _ready():
	add_to_group("zombie")
	base_speed = move_speed
	zombie_idle_sprite = Sprite2D.new()
	zombie_idle_sprite.texture = load("res://images/zombie.png")
	add_child(zombie_idle_sprite)
	zombie_attack_sprite = Sprite2D.new()
	zombie_attack_sprite.texture = load("res://images/zombiehands_attack.png")
	zombie_attack_sprite.visible = false
	add_child(zombie_attack_sprite)
	player = get_tree().get_first_node_in_group("player")
	modulate = Color(0.5, 0.5, 1)
	scale = Vector2(1.5, 1.5)
func _process(_delta):
	var day_night = get_tree().current_scene.get_node_or_null("Daynightcycle")
	if day_night and day_night.is_night():
		move_speed = base_speed * 2.0
	else:
		move_speed = base_speed
func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
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
				zombie_idle_sprite.visible = false
				zombie_attack_sprite.visible = true
				player.take_damage(attack_damage)
				can_attack_player = false
				await get_tree().create_timer(attack_cooldown).timeout
				zombie_idle_sprite.visible = true
				zombie_attack_sprite.visible = false
				can_attack_player = true
	else:
		wander_timer -= delta
		if wander_timer <= 0:
			wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			wander_timer = randf_range(2.0, 4.0)
		direction = wander_direction
		if direction != Vector2.ZERO:
			rotation = direction.angle()
	check_building_collision()
	velocity = direction * move_speed
	move_and_slide()
	var map_size = Vector2(5120, 3840)
	global_position.x = clamp(global_position.x, 0, map_size.x)
	global_position.y = clamp(global_position.y, 0, map_size.y)
func take_damage(amount: int):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(0.5, 0.5, 1)
	if health <= 0:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.zombies_killed += 1
		zombies_killed += 1
		var blood = Node2D.new()
		blood.global_position = global_position
		for i in range (8):
			var particle = Sprite2D.new()
			var texture = PlaceholderTexture2D.new()
			texture.size = Vector2(4, 4)
			particle.texture = texture
			particle.modulate = Color(0.6, 0, 0)
			blood.add_child(particle)
			var angle = randf() * TAU
			var distance = randf_range(8, 32)
			particle.position = Vector2(cos(angle), sin(angle)) * distance
		get_parent().add_child(blood)
		var tween = get_tree().create_tween()
		tween.tween_property(blood, "modulate:a", 0.0, 2.0)
		tween.finished.connect(blood.queue_free)
		queue_free()
func check_building_collision():
	var buildings = []
	buildings.append_array(get_tree().get_nodes_in_group("wall"))
	buildings.append_array(get_tree().get_nodes_in_group("door"))
	buildings.append_array(get_tree().get_nodes_in_group("campfire"))
	buildings.append_array(get_tree().get_nodes_in_group("spiketrap"))
	buildings.append_array(get_tree().get_nodes_in_group("chest"))
	buildings.append_array(get_tree().get_nodes_in_group("turret"))
	for building in buildings:
		if is_instance_valid(building):
			var distance = global_position.distance_to(building.global_position)
			if distance <= attack_range and can_attack_player:
				if building.has_method("take_damage"):
					building.take_damage(attack_damage)
					can_attack_player = false
					await get_tree().create_timer(attack_cooldown).timeout
					can_attack_player = true
					break
