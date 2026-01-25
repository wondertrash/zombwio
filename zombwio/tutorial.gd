extends CanvasLayer
signal tutorial_closed
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var bg = ColorRect.new()
	bg.size = viewport_size
	bg.color = Color(0, 0, 0, 0.9)
	add_child(bg)
	var title = Label.new()
	title.text = "How To Play"
	title.position = Vector2(viewport_size.x * 0.5 - 150, viewport_size.y * 0.1)
	title.add_theme_font_size_override("font_size", 48)
	add_child(title)
	var left_text = Label.new()
	left_text.text = """GOAL:
Survive as long as possible

CONTROLS:
- WASD - Move
- Mouse - Aim
- Left Click - Attack
- ESC - Crafting Menu
- B - Build Mode
  (Press 1-6 for structure)

ZOMBIE TYPES:
- White - Normal
- Pink - Fast but weak
- Green - Slow but tanky"""
	left_text.position = Vector2(viewport_size.x * 0.1, viewport_size.y * 0.25)
	left_text.add_theme_font_size_override("font_size", 14)
	add_child(left_text)
	var right_text = Label.new()
	right_text.text = """SURVIVAL TIPS:
- Gather wood, stone,
  copper, and fiber
- Eat berries to restore
  hunger and health
- Craft better weapons
  (ESC menu)
- Build walls and turrets
  to defend yourself
- Stay near campfires
  to heal
- Beware - zombies are
more active at night!"""
	right_text.position = Vector2(viewport_size.x * 0.55, viewport_size.y * 0.25)
	right_text.add_theme_font_size_override("font_size", 14)
	add_child(right_text)
	var continue_btn = Button.new()
	continue_btn.text = "Start Game"
	continue_btn.position = Vector2(viewport_size.x * 0.5 - 70, viewport_size.y * 0.85)
	continue_btn.size = Vector2(140, 50)
	continue_btn.pressed.connect(_close_tutorial)
	add_child(continue_btn)
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		_close_tutorial()
func _close_tutorial():
	tutorial_closed.emit()
	queue_free()
