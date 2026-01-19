extends CanvasLayer
@export var game_scene: PackedScene
func _ready() -> void:
	var bg = ColorRect.new()
	bg.size = Vector2(640, 480)
	bg.color = Color(0.1, 0.1, 0.15)
	add_child(bg)
	var title = Label.new()
	title.text = "zombw.io"
	title.position = Vector2(180, 100)
	title.add_theme_font_size_override("font_size", 64)
	add_child(title)
	var play_btn = Button.new()
	play_btn.text = "Play"
	play_btn.position = Vector2(250, 250)
	play_btn.size = Vector2(140, 60)
	play_btn.pressed.connect(_start_game)
	add_child(play_btn)
	var controls = Label.new()
	controls.text = "WASD - Move | Mouse - Aim | Left-Click - Attack | C - Craft"
	controls.position = Vector2(100, 400)
	controls.add_theme_font_size_override("font_size", 16)
	add_child(controls)
func _process(delta: float) -> void:
	pass
func _start_game():
	get_tree().change_scene_to_packed(game_scene)
