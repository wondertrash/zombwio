extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var panel: Panel
var is_open: bool = false
var recipes = {
	"Fist": [0, 0, 0, 0],
	"Spear": [23, 9, 20, 10],
	"Bow": [20, 8, 10, 30],
	"Gun": [48, 72, 7, 50]
}
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel = Panel.new()
	panel.position = Vector2(200, 100)
	panel.size = Vector2(300, 250)
	panel.visible = false
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panel)
	var y_pos = 10
	for item_name in recipes.keys():
		var recipe = recipes[item_name]
		var button = Button.new()
		button.text = "%s (Wood: %d Stone: %d)" % [item_name,recipe[0], recipe[1]]
		button.position = Vector2(10, y_pos)
		button.size = Vector2(280, 40)
		button.pressed.connect(_craft_item.bind(item_name))
		panel.add_child(button)
		y_pos += 50
func _process(delta: float) -> void:
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
	var wood_cost = recipe[0]
	var stone_cost = recipe[1]
	var damage_bonus = recipe[2]
	var range_bonus = recipe[3]
	if player.inventory["wood"] >= wood_cost and player.inventory["stone"] >= stone_cost:
		player.inventory["wood"] -= wood_cost
		player.inventory["stone"] -= stone_cost
		player.attack_damage = 1 + damage_bonus
		player.attack_range = 20 + range_bonus
		print("Crafted ", item_name, "! Damage: ", player.attack_damage, " Range: ", player.attack_range)
	else:
		print("Not enough resources")
