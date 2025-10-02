extends CanvasLayer

@export var pause_scene : PackedScene

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		var pause_menu = pause_scene.instantiate()
		add_child(pause_menu)
