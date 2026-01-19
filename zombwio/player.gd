class_name Player extends CharacterBody2D
var move_speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var attack_range: float = 25.0
var attack_damage: float = 10.0
var max_health: float = 255.0
var invincibility_time: float = 0.8
var current_health: float = max_health
var max_hunger: float = 255.0
var hunger_drain_rate: float = 1.0
var hunger_damage_rate: float = 3.0
var current_hunger: float = max_hunger
var berry_health: float = 10.0
var regen_delay: float = 8.0
var regen_rate: float = 16.0
var time_since_last_damage: float = 0.0
var can_attack: bool = true
var current_weapon: String = "fist"
var projectile_scene = preload("res://projectile.tscn")
var is_invincible: bool = false
var cardinal_direction: Vector2 = Vector2.DOWN
var speed_multiplier: float = 1.0
var default_speed: float = 100.0
var is_dead := false
var inventory: Dictionary = {
	"wood": 0,
	"stone": 0,
	"berries": 0
}
func _ready():
	add_to_group("player")
	current_health = max_health
	var map_size = Vector2(5120, 3840)
	global_position = Vector2(
		randf_range(16, map_size.x - 16),
		randf_range(16, map_size.y - 16)
	)
	var camera = Camera2D.new()
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)
func _process(delta):
	look_at(get_global_mouse_position())
	direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			cardinal_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
		else:
			cardinal_direction = Vector2.DOWN if direction.y > 0 else Vector2.UP
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	current_hunger -= hunger_drain_rate * delta
	current_hunger = clamp(current_hunger, 0, max_hunger)
	if current_hunger <= 0:
		take_damage(int(hunger_damage_rate * delta))
	time_since_last_damage += delta
	if time_since_last_damage >= regen_delay and current_health < max_health:
		current_health += regen_rate * delta
		current_health = clamp(current_health, 0, max_health)
func _physics_process(_delta):
	velocity = direction * default_speed * speed_multiplier
	move_and_slide()
	var map_size = Vector2(5120, 3840)
	global_position.x = clamp(global_position.x, 0, map_size.x)
	global_position.y = clamp(global_position.y, 0, map_size.y)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_attack:
		_perform_attack()
func _perform_attack():
	can_attack = false
	if current_weapon == "bow" or current_weapon == "gun":
		shoot_projectile()
	else:
		melee_attack()
	await get_tree().create_timer(0.3).timeout
	can_attack = true
func take_damage(amount: int):
	if is_invincible:
		return
	current_health -= amount
	time_since_last_damage = 0.0
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
	if current_health <= 0:
		die()
func die():
	pass
func collect_resource(type: String, amount: int):
	if type == "berries":
		eat_food(40)
	else:
		inventory[type] += amount
func eat_food(amount: float):
	current_hunger += amount
	current_hunger = clamp(current_hunger, 0, max_hunger)
	current_health += berry_health
	current_health = clamp(current_health, 0, max_health)
func melee_attack():
	var hitbox = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = attack_range
	collision.shape = shape
	hitbox.add_child(collision)
	var mouse_dir = global_position.direction_to(get_global_mouse_position())
	hitbox.global_position = global_position + mouse_dir * attack_range
	get_parent().add_child(hitbox)
	hitbox.body_entered.connect(func(body):
		if body.is_in_group("zombie"):
			body.take_damage(attack_damage)
	)
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	hitbox.queue_free()
func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = global_position.direction_to(get_global_mouse_position())
	projectile.rotation = projectile.direction.angle()
	if current_weapon == "gun":
		projectile.damage = 80
	else:
		projectile.damage = 40
	get_parent().add_child(projectile)
