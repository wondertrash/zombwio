class_name Player extends CharacterBody2D
var move_speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var attack_range: float = 20.0
var attack_damage: int = 1
var can_attack: bool = true
var cardinal_direction: Vector2 = Vector2.DOWN
var speed_multiplier: float = 1.0
var default_speed: float = 100.0
var is_dead := false
func _ready():
	add_to_group("player")
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
