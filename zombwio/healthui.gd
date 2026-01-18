extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var health_bar: ColorRect
var hunger_bar: ColorRect
var health_bg: ColorRect
var hunger_bg: ColorRect
func _ready() -> void:
	health_bg = ColorRect.new()
	health_bg.position = Vector2(10, 10)
	health_bg.size = Vector2(200, 20)
	health_bg.color = Color(0.2, 0.2, 0.2)
	add_child(health_bg)
	health_bar = ColorRect.new()
	health_bar.position = Vector2(10, 10)
	health_bar.size = Vector2(200, 20)
	health_bar.color = Color(0.8, 0.2, 0.2)
	add_child(health_bar)
	hunger_bg = ColorRect.new()
	hunger_bg.position = Vector2(10, 35)
	hunger_bg.size = Vector2(200, 20)
	hunger_bg.color = Color(0.2, 0.2, 0.2)
	add_child(hunger_bg)
	hunger_bar = ColorRect.new()
	hunger_bar.position = Vector2(10, 35)
	hunger_bar.size = Vector2(200, 20)
	hunger_bar.color = Color(0.8, 0.6, 0.2)
	add_child(hunger_bar)
func _process(delta: float) -> void:
	if player:
		var health_percent = float(player.current_health) / float(player.max_health)
		health_bar.size.x = 200 * health_percent
		var hunger_percent = float(player.current_hunger) / float(player.max_hunger)
		hunger_bar.size.x = 200 * hunger_percent
