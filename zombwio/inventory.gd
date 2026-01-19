extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var wood_label: Label
var stone_label: Label
func _ready() -> void:
	wood_label = Label.new()
	wood_label.position = Vector2(10, 75)
	wood_label.add_theme_font_size_override("font_size", 16)
	wood_label.modulate = Color(0.4, 0.22, 0.19)
	add_child(wood_label)
	stone_label = Label.new()
	stone_label.position = Vector2(10, 100)
	stone_label.add_theme_font_size_override("font_size", 16)
	stone_label.modulate = Color(0.35, 0.34, 0.32)
	add_child(stone_label)
func _process(delta):
	if player:
		wood_label.text = "Wood: %d" % player.inventory["wood"]
		stone_label.text = "Stone: %d" % player.inventory["stone"]
