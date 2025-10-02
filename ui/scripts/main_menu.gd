extends Control

func _on_play_pressed() -> void:
	SceneManager.transition_to("start_game")
