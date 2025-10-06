extends Control

@export var content_template: String = ""

@onready var title = $Margin/Content/Title
@onready var content = $Margin/Content/Text

func set_title(text):
	title.text = text

func set_content(text):
	content.text = text

func set_template_content(data):
	var formatted = content_template.format(data)
	content.text = formatted

func _on_retry_pressed() -> void:
	SceneManager.transition_to("start_game")


func _on_next_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_start_pressed() -> void:
	get_tree().paused = false
	queue_free()
