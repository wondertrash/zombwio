class_name Player extends CharacterBody2D
var move_speed: float = 88.0
var direction: Vector2 = Vector2.ZERO
var state: String = "idle"
var attacking: bool = false
var cardinal_direction: Vector2 = Vector2.DOWN
var speed_multiplier: float = 1.0
var default_speed: float = 88.0
var is_dead := false
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
