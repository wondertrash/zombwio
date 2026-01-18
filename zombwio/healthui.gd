extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var label: Label
func _ready() -> void:
	label = Label.new()
	label.position = Vector2(10, 10)
	label.add_theme_font_size_override("font_size", 24)
	add_child(label)
func _process(delta: float) -> void:
	if player:
		label.text = "Health: %d/%d" % [player.current_health, player.max_health]
