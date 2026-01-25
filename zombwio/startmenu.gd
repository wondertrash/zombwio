extends CanvasLayer
@export var game_scene: PackedScene
func _ready() -> void:
	get_tree().paused = false
	var viewport_size = get_viewport().get_visible_rect().size
	var bg = ColorRect.new()
	bg.size = viewport_size
	bg.color = Color(0.1, 0.1, 0.15)
	add_child(bg)
	var title = Label.new()
	title.text = "zombw.io"
	title.position = Vector2(viewport_size.x * 0.5 - 150, viewport_size.y * 0.2)
	title.add_theme_font_size_override("font_size", 64)
	add_child(title)
	var play_btn = Button.new()
	play_btn.text = "Play"
	play_btn.position = Vector2(viewport_size.x * 0.5 - 70, viewport_size.y * 0.5)
	play_btn.size = Vector2(140, 60)
	play_btn.pressed.connect(_start_game)
	add_child(play_btn)
	var controls = Label.new()
	controls.text = "WASD - Move | Mouse - Aim | Left-Click - Attack | C - Craft | B - Build"
	controls.position = Vector2(viewport_size.x * 0.5 - 270, viewport_size.y * 0.8)
	controls.add_theme_font_size_override("font_size", 16)
	add_child(controls)
func _process(delta: float) -> void:
	pass
func _start_game():
	get_tree().change_scene_to_file("res://main.tscn")
