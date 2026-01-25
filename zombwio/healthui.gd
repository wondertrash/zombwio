extends CanvasLayer
@onready var player = get_tree().get_first_node_in_group("player")
var health_bar: ColorRect
var hunger_bar: ColorRect
var health_bg: ColorRect
var hunger_bg: ColorRect
var time_label: Label
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	health_bg = ColorRect.new()
	health_bg.position = Vector2(10, viewport_size.y - 60)
	health_bg.size = Vector2(200, 20)
	health_bg.color = Color(0.2, 0.2, 0.2)
	add_child(health_bg)
	health_bar = ColorRect.new()
	health_bar.position = Vector2(10, viewport_size.y - 60)
	health_bar.size = Vector2(200, 20)
	health_bar.color = Color(0.8, 0.2, 0.2)
	add_child(health_bar)
	hunger_bg = ColorRect.new()
	hunger_bg.position = Vector2(10, viewport_size.y - 35)
	hunger_bg.size = Vector2(200, 20)
	hunger_bg.color = Color(0.2, 0.2, 0.2)
	add_child(hunger_bg)
	hunger_bar = ColorRect.new()
	hunger_bar.position = Vector2(10, viewport_size.y - 35)
	hunger_bar.size = Vector2(200, 20)
	hunger_bar.color = Color(0.8, 0.6, 0.2)
	add_child(hunger_bar)
	time_label = Label.new()
	time_label.position = Vector2(10, viewport_size.y - 90)
	time_label.add_theme_font_size_override("font_size", 20)
	add_child(time_label)
func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or player.current_health <= 0:
		visible = false
		return
	else:
		visible = true
	if player:
		var health_percent = float(player.current_health) / float(player.max_health)
		health_bar.size.x = 200 * health_percent
		var hunger_percent = float(player.current_hunger) / float(player.max_hunger)
		hunger_bar.size.x = 200 * hunger_percent
	var day_night = get_tree().current_scene.get_node_or_null("Daynightcycle")
	if day_night:
		var time_str = day_night.get_time_string()
		var phase = "Day" if not day_night.is_night() else "Night"
		time_label.text = "%s - %s" % [time_str, phase]
		time_label.modulate = Color(1, 1, 0.5) if not day_night.is_night() else Color(0.5, 0.5, 1)
