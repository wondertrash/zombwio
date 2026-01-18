class_name Player extends CharacterBody2D
var move_speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var attack_range: float = 20.0
var attack_damage: int = 1
var max_health: int = 100
var invincibility_time: float = 1.0
var current_health: int = max_health
var can_attack: bool = true
var is_invincible: bool = false
var cardinal_direction: Vector2 = Vector2.DOWN
var speed_multiplier: float = 1.0
var default_speed: float = 100.0
var is_dead := false
var inventory: Dictionary = {
	"wood": 0,
	"stone": 0
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
	var hitbox = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = attack_range
	collision.shape = shape
	hitbox.add_child(collision)
	var mouse_dir = global_position.direction_to(get_global_mouse_position())
	hitbox.global_position = global_position + mouse_dir * attack_range
	get_parent().add_child(hitbox)
	await get_tree().process_frame
	hitbox.body_entered.connect(func(body):
		if body.is_in_group("zombie"):
			body.take_damage(attack_damage)
	)
	await get_tree().create_timer(0.2).timeout
	hitbox.queue_free()
	await get_tree().create_timer(0.4).timeout
	can_attack = true
func take_damage(amount: int):
	if is_invincible:
		return
	current_health -= amount
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
	inventory[type] += amount
