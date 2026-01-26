extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var panel: Panel
var is_open: bool = false
var recipes = {
	"Fist": {"wood": 0, "stone": 0, "copper": 0, "fiber": 0, "damage": 10, "range": 25, "type": "melee"},
	"Mace": {"wood": 5, "stone": 2, "copper": 0, "fiber": 0, "damage": 20, "range": 35, "type": "melee"},
	"Bow": {"wood": 10, "stone": 0, "copper": 0, "fiber": 5, "damage": 40, "range": 200, "type": "bow"},
	"Crossbow": {"wood": 15, "stone": 5, "copper": 3, "fiber": 8, "damage": 60, "range": 250, "type": "bow"},
	"Gun": {"wood": 5, "stone": 8, "copper": 10, "fiber": 8, "damage": 80, "range": 300, "type": "gun"},
	"Bandage": {"wood": 0, "stone": 0, "copper": 0, "fiber": 3, "damage": 0, "range": 0, "type": "heal"},
	"Health Potion": {"wood": 0, "stone": 0, "copper": 1, "fiber": 0, "damage": 0, "range": 0, "type": "heal"},
	"Leather Armour": {"wood": 0, "stone": 0, "copper": 5, "fiber": 20, "damage": 0, "range": 0, "type": "armour"},
	"Copper Armour": {"wood": 0, "stone": 8, "copper": 10, "fiber": 5, "damage": 0, "range": 0, "type": "armour"}
}
var craft_sound: AudioStream = load("res://sounds/craft.wav")
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel = Panel.new()
	panel.position = Vector2(viewport_size.x - 560, viewport_size.y - 480)
	panel.size = Vector2(350, 400)
	panel.visible = false
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panel)
	var y_pos = 10
	for item_name in recipes.keys():
		var recipe = recipes[item_name]
		var button = Button.new()
		var costs = []
		if recipe["wood"] > 0: costs.append("W:%d" % recipe["wood"])
		if recipe["stone"] > 0: costs.append("S:%d" % recipe["stone"])
		if recipe["copper"] > 0: costs.append("C:%d" % recipe["copper"])
		if recipe["fiber"] > 0: costs.append("F:%d" % recipe["fiber"])
		button.text = "%s (%s)" % [item_name, ", ".join(costs)]
		button.position = Vector2(10, y_pos)
		button.size = Vector2(330, 35)
		button.pressed.connect(_craft_item.bind(item_name))
		panel.add_child(button)
		y_pos += 40
func _process(_delta):
	if Input.is_action_just_pressed("craft"):
		toggle_menu()
func toggle_menu():
	is_open = !is_open
	panel.visible = is_open
	get_tree().paused = is_open
func _craft_item(item_name: String):
	if not player:
		return
	var recipe = recipes[item_name]
	var can_craft = true
	if player.inventory["wood"] < recipe["wood"]: can_craft = false
	if player.inventory["stone"] < recipe["stone"]: can_craft = false
	if player.inventory["copper"] < recipe["copper"]: can_craft = false
	if player.inventory["fiber"] < recipe["fiber"]: can_craft = false
	if can_craft:
		player.inventory["wood"] -= recipe["wood"]
		player.inventory["stone"] -= recipe["stone"]
		player.inventory["copper"] -= recipe["copper"]
		player.inventory["fiber"] -= recipe["fiber"]
		if recipe["type"] == "melee" or recipe["type"] == "bow"  or recipe["type"] == "gun":
			if item_name == "Mace":
				player.current_weapon = "mace"
			elif item_name == "Bow":
				player.current_weapon = "bow"
			elif item_name == "Crossbow":
				player.current_weapon = "crossbow"
			elif item_name == "Gun":
				player.current_weapon = "gun"
			else:
				player.current_weapon = "fist"
			player.attack_damage = recipe["damage"]
			player.attack_range = recipe["range"]
		elif recipe["type"] == "heal":
			if item_name == "Bandage":
				player.current_health += 60
			elif item_name == "Health Potion":
				player.current_health += 200
			player.current_health = clamp(player.current_health, 0, player.max_health)
		elif recipe["type"] == "armour":
			if item_name == "Copper Armour":
				player.max_health += 100
			elif item_name == "Leather Armour":
				player.max_health += 50
		play_sound(craft_sound)
		panel.modulate = Color(0.5, 1, 0.5)
		await get_tree().create_timer(0.2).timeout
		panel.modulate = Color(1, 1, 1)
	else:
		panel.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.2).timeout
		panel.modulate = Color(1, 1, 1)
func play_sound(sound: AudioStream):
	var player_node = AudioStreamPlayer.new()
	player_node.stream = sound
	add_child(player_node)
	player_node.play()
	player_node.finished.connect(player_node.queue_free)
