extends Control

func _ready():
	get_tree().paused = true

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		resume()

func resume():
	get_tree().paused = false
	queue_free()

func _on_resume_pressed() -> void:
	resume()

func _on_main_menu_pressed() -> void:
	SceneManager.transition_to("main_menu")
