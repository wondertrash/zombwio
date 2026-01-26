extends StaticBody2D
var storage: Dictionary
var max_capacity: int = 64
var resource_labels: Dictionary = {}
var interaction_area: Area2D
var ui_open: bool = false
var chest_ui: CanvasLayer
var health: float = 800.0
func _ready():
	add_to_group("chest")
	storage = {
		"wood": 0,
		"stone": 0,
		"copper": 0,
		"fiber": 0,
	}
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
	area_shape.radius = 48
	area_collision.shape = area_shape
	interaction_area.add_child(area_collision)
	interaction_area.monitoring = true
	add_child(interaction_area)
func _process(_delta):
	if ui_open:
		return
	var bodies = interaction_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			if Input.is_action_just_pressed("interact"):
				open_chest_ui(body)
				break
func open_chest_ui(player):
	ui_open = true
	get_tree().paused = true
	chest_ui = CanvasLayer.new()
	chest_ui.layer = 50
	chest_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(chest_ui)
	var viewport_size = get_viewport().get_visible_rect().size
	var bg = ColorRect.new()
	bg.size = viewport_size
	bg.color = Color(0, 0, 0, 0.7)
	chest_ui.add_child(bg)
	var panel = Panel.new()
	panel.position = Vector2(viewport_size.x * 0.25, viewport_size.y * 0.2)
	panel.size = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.6)
	chest_ui.add_child(panel)
	var title = Label.new()
	title.text = "Chest Storage"
	title.position = Vector2(panel.size.x * 0.3, 10)
	title.add_theme_font_size_override("font_size", 24)
	panel.add_child(title)
	var y_pos = 60
	resource_labels.clear()
	for resource in storage.keys():
		var label = Label.new()
		label.text = "%s: %d / %d" % [resource.capitalize(), storage[resource], max_capacity]
		label.position = Vector2(panel.size.x * 0.05, y_pos)
		label.add_theme_font_size_override("font_size", 18)
		panel.add_child(label)
		resource_labels[resource] = label
		var deposit_btn = Button.new()
		deposit_btn.text = "Deposit"
		deposit_btn.position = Vector2(panel.size.x * 0.45, y_pos - 5)
		deposit_btn.size = Vector2(80, 30)
		deposit_btn.pressed.connect(_deposit.bind(player, resource))
		panel.add_child(deposit_btn)
		var withdraw_btn = Button.new()
		withdraw_btn.text = "Withdraw"
		withdraw_btn.position = Vector2(panel.size.x * 0.7, y_pos - 5)
		withdraw_btn.size = Vector2(80, 30)
		withdraw_btn.pressed.connect(_withdraw.bind(player, resource))
		panel.add_child(withdraw_btn)
		y_pos += 45
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.position = Vector2(panel.size.x * 0.5 - 60, panel.size.y - 50)
	close_btn.size = Vector2(120, 40)
	close_btn.pressed.connect(_close_ui)
	panel.add_child(close_btn)
func _deposit(player, resource: String):
	if player.inventory[resource] > 0:
		var amount = min(player.inventory[resource], max_capacity - storage[resource])
		storage[resource] += amount
		player.inventory[resource] -= amount
		_update_label(resource)
func _withdraw(player, resource: String):
	if storage[resource] > 0:
		var space_available = player.max_inventory_per_item - player.inventory[resource]
		var amount_to_withdraw = min(storage[resource], space_available)
		player.inventory[resource] += amount_to_withdraw
		storage[resource] -= amount_to_withdraw
		_update_label(resource)
func _update_label(resource: String):
	if resource_labels.has(resource):
		resource_labels[resource].text = "%s: %d / %d" % [resource.capitalize(), storage[resource], max_capacity]
func _close_ui():
	if chest_ui:
		chest_ui.queue_free()
		chest_ui = null
	ui_open = false
	get_tree().paused = false
func _input(event):
	if ui_open and event.is_action_pressed("interact"):
		_close_ui()
func take_damage(amount: float):
	health -= amount
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if health <= 0:
		queue_free()
