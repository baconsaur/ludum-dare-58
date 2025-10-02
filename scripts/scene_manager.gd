extends CanvasLayer

@onready var color_rect = $ColorRect

@export var scene_map : Dictionary[String, PackedScene]

func transition_to(scene_name):
	var new_scene = scene_map.get(scene_name)
	if not new_scene:
		return
	get_tree().paused = true
	color_rect.show()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color", Color.BLACK, 0.1)
	tween.tween_callback(change_scene.bind(new_scene)).set_delay(0.15)

func change_scene(new_scene):
	get_tree().change_scene_to_packed(new_scene)
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), 0.1)
	tween.tween_callback(resume)

func resume():
	get_tree().paused = false
	color_rect.hide()
