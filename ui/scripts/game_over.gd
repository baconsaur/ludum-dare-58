extends Control


func _on_retry_pressed() -> void:
	SceneManager.transition_to("start_game")
