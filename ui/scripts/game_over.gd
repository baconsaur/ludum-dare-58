extends Control


func _on_retry_pressed() -> void:
	SceneManager.transition_to("start_game")


func _on_next_pressed() -> void:
	# TODO
	SceneManager.transition_to("start_game")
