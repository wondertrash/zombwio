extends CanvasLayer
var survival_time: float = 0.0
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
func _process(delta: float) -> void:
	pass
func show_death_screen(time: float):
	survival_time = time
	visible = true
	get_tree().paused = true
	var bg = ColorRect.new()
	bg.size = Vector2(640, 480)
	bg.color = Color(0, 0, 0, 0.8)
	add_child(bg)
	var death_text = Label.new()
	death_text.text = "You Died"
	death_text.position = Vector2(220, 150)
	death_text.add_theme_font_size_override("font_size", 48)
	death_text.modulate = Color(1, 0, 0)
	add_child(death_text)
	var time_text = Label.new()
	time_text.text = "Survived: %.1f seconds" % survival_time
	time_text.position = Vector2(200, 220)
	time_text.add_theme_font_size_override("font_size", 24)
	add_child(time_text)
	var restart_btn = Button.new()
	restart_btn.text = "Restart"
	restart_btn.position = Vector2(250, 300)
	restart_btn.size = Vector2(140, 60)
	restart_btn.pressed.connect(_restart)
	add_child(restart_btn)
	var menu_btn = Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.position = Vector2(250, 370)
	menu_btn.size = Vector2(140, 60)
	menu_btn.pressed.connect(_main_menu)
	add_child(menu_btn)
func _restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
func _main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://startmenu.tscn")
