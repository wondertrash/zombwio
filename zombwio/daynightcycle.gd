extends CanvasLayer
@export var day_start_hour: float = 7.0
@export var night_start_hour: float = 19.0
@export var day_length: float = 180.0
@export var night_zombie_multiplier: float = 2.0
var time_of_day: float = 0.0
var overlay: ColorRect
func _ready() -> void:
	time_of_day = randf()
	overlay = ColorRect.new()
	overlay.size = get_viewport().get_visible_rect().size
	overlay.color = Color(0, 0, 0.2, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
func _process(delta):
	time_of_day += delta / day_length
	if time_of_day >= 1.0:
		time_of_day -= 1.0
	var darkness = calculate_darkness()
	overlay.color.a = darkness * 0.6
	update_zombie_stats()
func calculate_darkness() -> float:
	var current_hour = time_of_day * 24.0
	var transition_duration = 1.0
	if current_hour >= night_start_hour + transition_duration or current_hour < day_start_hour - transition_duration:
		return 1.0
	elif current_hour >= day_start_hour + transition_duration and current_hour < night_start_hour - transition_duration:
		return 0.0
	elif current_hour >= day_start_hour - transition_duration and current_hour < day_start_hour + transition_duration:
		var progress = (current_hour - (day_start_hour - transition_duration)) / (transition_duration * 2)
		return 1.0 - progress
	elif current_hour >= night_start_hour - transition_duration and current_hour < night_start_hour + transition_duration:
		var progress = (current_hour - (night_start_hour - transition_duration)) / (transition_duration * 2)
		return progress
	return 0.0
func is_night() -> bool:
	var current_hour = time_of_day * 24.0
	return current_hour >= night_start_hour or current_hour < day_start_hour
func update_zombie_stats():
	var zombie_manager = get_tree().current_scene.get_node_or_null("zombiemanager")
	if zombie_manager:
		if is_night():
			zombie_manager.max_zombies = 128
		else:
			zombie_manager.max_zombies = 64
	var zombies = get_tree().get_nodes_in_group("zombie")
	for zombie in zombies:
		if is_night():
			zombie.move_speed = zombie.move_speed * night_zombie_multiplier if zombie.move_speed < 64 else zombie.move_speed
func get_time_string() -> String:
	var hours = int(time_of_day * 24.0)
	var minutes = int((time_of_day * 24.0 - hours) * 60.0)
	return "%02d:%02d" % [hours, minutes]
