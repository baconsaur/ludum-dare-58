class_name Modal
extends Control

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		close()

func close():
	queue_free()

func _on_close_pressed() -> void:
	close()
