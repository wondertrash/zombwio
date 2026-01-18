extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var background: ColorRect
var health_bar: ColorRect
func _ready() -> void:
	background = ColorRect.new()
	background.position = Vector2(10, 10)
	background.size = Vector2(200, 20)
	background.color = Color(0.2, 0.2, 0.2)
	add_child(background)
	health_bar = ColorRect.new()
	health_bar.position = Vector2(10, 10)
	health_bar.size = Vector2(200, 20)
	health_bar.color = Color(0.8, 0.2, 0.2)
	add_child(health_bar)
func _process(delta: float) -> void:
	if player:
		var health_percent = float(player.current_health) / float(player.max_health)
		health_bar.size.x = 200 * health_percent
